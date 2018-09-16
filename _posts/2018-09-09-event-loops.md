---
layout: post
title: Event Loops
category: [ design-patterns ]
toc: true
---

* TOC
{:toc}

**Work in progress...**

Event loops has been something I've always wanted to take a deeper look into as
it has appeared in so many places, ranging from networking servers to system
daemons. In this blog I will take a case study on some of the popular event
loop implementations, and summarize common patterns.

# NGINX

## Design

Nginx achieves its high performance and scalability by multiplexing a single
process for hundreds of thousands of connections, as opposed to using one
process/thread per connection as traditional servers used to do. The reason is
that a connection is cheap (it is a matter of a file descriptor plus a small
amount of memory) while a process is much more heavy weight. A process is
heavier not only in the sense that a process object takes more memory, but also
because context switches between processes are costly - TLB flush, cache
pollution.

Nginx's design choice is to use no more than one (worker) process per CPU core,
and run a _event loop_ on each of these processes. The events are changes
happening on the connections (data available for read, for write, timeout, or
connection closed) assigned to each process. They are put into a queue by the
operating system. The worker process takes an event at a time, processes it, and
goes on to the next. When there is nothing to do, it sleeps and relinquishes the
CPU. So in this way, if there is traffic on most connections, all CPUs can be
busy processing packets, thus reaching their full capacity (the best as far as
performance tuning goes). Unlike the traditional one process per connection
model, with Nginx the CPUs are spending most of their time doing meaningful
work, as opposed to on useless overhead such as context switches.

Note that Nginx assumes that the processing of each event is fast, or at least
not blocking. Should that be the case, for example, a disk read is needed, it
uses [separate threads][thread-pools] to process the event asynchronously,
without blocking other events in the queue that are fast to process. Since the
operating system kernel usually handles the heavy lifting like transmitting
packets on the wire, reading data from disk into the page cache, when the Nginx
worker process is getting notified, the data is usually readily available and it
will be a matter of copying them from one buffer to another.

[thread-pools]: https://www.nginx.com/blog/thread-pools-boost-performance-9x/

## Implementation

### The main loop

Nginx supports a wide variety of operating systems, but in this blog we will
only look at Linux. The Linux version of the main loop is implemented by the
[`ngx_worker_process_cycle`][ngx_process_cycle] function in
`src/os/unix/ngx_process_cycle.c`. As we can see, the main body of the function
is an infinite for loop, which terminates only when the process itself is
terminating. In the loop, other than some edge condition checking, the gut of it
is a function call to
[`ngx_process_events_and_timers`][ngx_process_events_and_timers]. Let's ignore
the timer handling part for now. The core of the function, is a call to
[`ngx_process_events`][ngx_process_events_and_timers], which is a macro defined in
[`src/event/ngx_event.h`][ngx_event.h]. As we can see, it merely points to the
`process_events` field of the [`ngx_event_actions`][ngx_event_actions] external
variable.

As many OSes as Nginx supports, it supports even more event notification
mechanisms (`select`, `epoll`, `kqueue`, etc.). For an analyses of these various
options, see [The C10K problem][c10k-problem]. Nginx refers to these options as
"modules", and has an implementation for each in the `src/event/modules` sub
directory. Again, for brevity, we will only examine the `epoll` based solution
here: [`ngx_epoll_module.c`][ngx_epoll_module].

In this module, the `process_events` action is defined by the
`ngx_epoll_process_events` function. It calls the [`epoll_wait`][epoll_wait]
system call, with a statically assigned `ep`, and a list of events `event_list`
to listen on. If the system call returns with a non negative value, some events
have happened, and which will be stored in the passed in `event_list` array,
with their types saved in the returned `events` bitmask. The rest of the
function processes the events one by one, and returns to the outer main loop
which will then invoke another call to `ngx_process_events`. As we can see,
events are processed sequentially, so it is important to not have _blocking_
operations in the middle. As mentioned earlier, separate threads will be used
for those operations and that is hidden behind the _handler_ of each event.

[ngx_process_cycle]: https://github.com/nginx/nginx/blob/release-1.15.3/src/os/unix/ngx_process_cycle.c#L727
[ngx_process_events_and_timers]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event.c#L193
[ngx_event.h]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event.h#L411
[ngx_event_actions]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event.h#L177..L197
[c10k-problem]: http://www.kegel.com/c10k.html#top
[ngx_epoll_module]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/modules/ngx_epoll_module.c
[epoll_wait]: http://man7.org/linux/man-pages/man7/epoll.7.html

### Events

The main event interfaces are declared in [`src/event/ngx_event.h`][ngx_event.h]
and implemented in [`src/event/ngx_event.c`][ngx_event.c] Two most important
data structures are the `ngx_event_s` and `ngx_event_actions_t`. The former
defines a shared data structure that works with many different underlying event
types (`select`, `epoll`, etc.). The latter defines the methods on an event.

Various event types are registered at various places throughout the code base.
As one example, the events of the "listening sockets" are registered by the
[`ngx_enable_accept_events`][ngx_enable_accept_events]. It loops through the
array of all listening sockets, and registers a read event for each of them.

[ngx_event.h]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event.h
[ngx_event.c]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event.c
[ngx_enable_accept_events]: https://github.com/nginx/nginx/blob/release-1.15.3/src/event/ngx_event_accept.c#L356

# Systemd

## Event sources

While Nginx supports many notification mechanisms, `sd-event` supports many more
_event types_: I/O, timers, signals, child process stage changes, and `inotify`.
See the event source type definitions at [sd-event.c][sd-event.c]. All these
event sources are represented by a uniform data structure,
[sd_event_soure][sd_event_source], which has a big `union` field for eight
possible types, each for one event source. Each event type has its own specific
fields, but all of them have an event handler, named `sd_event_x_handler_t` (`x`
is the event type).

Systemd is able to handle these many event types thanks to the Linux APIs
`timerfd`, `signalfd`, and `waitid`, which are `epoll` like APIs for
multiplexing on timers, signals, and child processes.

### Event loop

Event loops objects are of the type `sd_event`, which has a reference counter, a
fd used for `epoll`, another fd for `watchdog`, a few timestamps, a hash map for
each event source type, three priority queues (pending, prepare and exit), and
lastly, a counter for the last iteration. To get a new loop object, the function
`sd_event_new` can be called. However, since it is recommended that one thread
only to possess one loop, the helper function `sd_event_default` is recommended
which creates a new loop object only when there hasn't been one for the current
thread.

## Working with events

An event loop is allocated by `sd_event_new`. As can be seen from its
implementation, three objects are allocated: the loop obect of type `sd_event`,
a priority queue for pending events,  and an  `epoll` fd. Events can be added to
a given loop via one of the `sd_event_add_xxx` methods. A callback function can
be added which will be called when an event of the added type is dispatched.
They are put in to a priority queue. An event loop can be executed for one
iteration by `sd_event_run`, or loop until there's no more events by
`sd_event_loop`. An event is taken out of the priority queue at each iteration,
and dispatched by calling the callbacks of a particular source type registered
at the `sd_event_add_xxx` call.

[sd-event.c]: https://github.com/systemd/systemd/blob/v239/src/libsystemd/sd-event/sd-event.c#L31..L47
[sd_event_source]: https://github.com/systemd/systemd/blob/v239/src/libsystemd/sd-event/sd-event.c#L31..L47

# Others

# Summary

As you can see from the case studies above, an event loop can be useful when:
  - you have to monitor changes on multiple sources, and
  - processing of each change (event) is fast

The implementation of an event loop would include:
  - One or more event sources that put events in a queue
  - A cycle that dequeues one element at a time and processes it
And number 1, and the queue, are usually provided by the operating system
kernel. The loop process registers event sources and gets notified when there
are changes.
