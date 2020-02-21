---
layout: page
title: Links
---

- [x] [A Short Guide to Motherboard Parts and Their Functions](https://www.makeuseof.com/tag/short-guide-motherboard-parts/)
- [x] [What is a CPU](https://www.makeuseof.com/tag/cpu-technology-explained/)
- [x] [What is a CPU Socket](https://www.makeuseof.com/tag/cpu-socket-types-explained-from-socket-5-to-bga-makeuseof-explains/)
- [x] [What is Hyper-Threading](https://www.makeuseof.com/tag/hyperthreading-technology-explained/)
- [x] [How to Build Your Own PC](https://www.makeuseof.com/tag/the-guide-build-your-own-pc/)
- [x] [Difference Between Multi-Core and Multi-Processor](https://superuser.com/a/214341)
- [x] [System Bus](https://en.wikipedia.org/wiki/System_bus)
- [] [What's New in CPUs Since the 80s](http://danluu.com/new-cpu-features/)
- [x] [Scaling the Linux Networking Stack](https://www.kernel.org/doc/Documentation/networking/scaling.txt)
- [x] [Queueing in the Linux Network Stack](https://www.linuxjournal.com/content/queueing-linux-network-stack)
- [] [How to Optimize Code for x86 and x86\_64](https://www.agner.org/optimize/)
- [x] [LinuxBoot Explained](https://lwn.net/Articles/748586/)
- [x] [Kernel Bypass for Higher Speed Network](https://blog.cloudflare.com/kernel-bypass/)
- [x] [Improving Linux Networking Performance -- how to process a packet in 120ns](https://lwn.net/Articles/629155/)
  - CPU budget per packet: 1230ns for 10Gb NICs, and 120ns for 100Gb
  - Why is the kernel networking stack slow?
    - 16ns per spinlock/spinunlock cycle --> lockless!
    - 32ns per cache miss  --> SKB
    - 70ns per slab allocation (particularly in the RX path)  --> Networking
      specific MM?
- [x] [Implementing Circular Buffer in C](https://embedjournal.com/implementing-circular-buffer-embedded-c/)
- [] [Race Condition in Reading RTC Timekeeping Registers](https://embedjournal.com/rtc-registers-read-atomic-values/)
- [x] [BPF vs Loadable Kernel Modules](https://news.ycombinator.com/item?id=14726311)
