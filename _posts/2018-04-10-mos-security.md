---
layout: post
title: MOS - Security
---

# 9 Security

## 9.3.4 Trusted Systems

"Is it possible to build a secure operating system?" "Theoretically yes, but
there are reasons why modern OSes aren't secure":

  - Users are unwilling to throw away current insecure systems. For example,
    there is actually a "secure OS" from Microsoft, but they never adversite it
and people won't be happy if told that their Windows systems will be replaced.
  - Features are the enemy of security, yet system designers keep adding
    features that they believe their users will like. For example, emails used
to be ASCII texts which in no way poses a security threat, and one day email
developers added rich contents like Word documents that can have viruses written
in macro. Another example is web pages, which used to be static HTML files that
were secure, until the appearance of dynamic widgets like applet and JavaScript.
Since then security problems pop one after another.

### 9.3.5 Trusted Computing Base

At the heart of a "trusted system" is a minimal **Trusted Computing Base
(TCB)**. If the TCB is working to specification, it is believed that the system
security cannot be compromised, no matter what else goes wrong.

TCB typically consists of most of the hardware, a portion of the operating
system, and most or all user programs that have superuser power (binaries with
SETUID bit for instance). MINIX 3 does a great job minimizing the TCB: its
kernel is only a few thousand lines of code, as opposed to the Linux kernel
which has millions if not tens of millions. Everything else that don't belong in
the TCB is moved to user space, such as printer and video card drivers.

### 9.3.6 Formal Models of Secure Systems

There are research that attempts to prove that given a set of _authorized_
states of a system, and a list of _protection commads_ (that grant of revoke
permissions), whether it is possible to derive a _unauthorized_ state, using
formal verification methods.

### 9.3.7 Multilevel Security

#### DAC v.s. MAC

Discretionary Access Control (DAC) v.s. Mandatory Access Control (MAC). The
former gives owners of resources the right to decide who else can have access to
resources they own. The latter, however, says an organizational admin globally
mandates who has access to what, thus enforcing a stronger information security.
MAC is common in the military, organizations, and hospitals.

#### Multilevel

The concept "multilevel" refers to the design that there are multiple _security
levels_ on a system, and users/processes at each level has restricted access to
resource on the system. Two notable models of multilevel security are the
Bella-La Padula model and the Biba model.

The Bella-La Padula model was designed for military use, where the core of
security is information security, i.e., a general can have access to most
information including everything a lieutenant knows, but he cannot tell
everything he knows to the lieutenant. When applied to an operating system, this
means a process can read files with an equal or lower level, but can write to
files with an equal or higher level. This is why the model is often remembered
as "read down and write up".

The Bella-La Padula model makes sure information never flows from a higher level
to lower, which is great for the military, but when applied to a corporation, it
may break _data integrity_. For example, it would entitle an engineer to write
to the CEO's company OKRs or the CFO's financial reports. For corporations, an
exact opposite model exists, and that is the Biba model.

### 9.3.8 Covert Channels

Even when mathematically proven secure, a system could still leak information,
through various _Covert Channels_. A covert channel can often be established by
an agreed protocol between the leaker and the receiver, not through the usual
IPC or RPC mechanism but something unobvious. For example, they could agree on
that the leaker would signal a bit 1 by computing for a certain interval of
time, and signal bit 0 much more promptly. This way the receiver could construct
a bit stream from the leaker's response times to its requests. Other signals can
be paging rates, status of a lock file, etc. And by multiplying the number of
signals, the bandwidth can be significantly increased.

In practice, just finding all the covert channels is challenging, let alone
blocking them.

#### Steganography

Steganography is a slightly different kind of covert channel. A classic example
is by tweaking the three lower bits of the RGB bytes of an image file (one per
color), and with the help of simple compression, one could embed as much as
700KB of secrete data in a 1024x768 image, without anybody noticing a difference
in the resulting image. Many websites use steganography to insert hidden
watermarks into their images to prevent from theft and reuse on other web pages.

Example: <https://www.cs.vu.nl/~ast/books/mos2/zebras.html>

## 9.4 Authentication

Most authentication methods are based on one or more of the three general
principles:

1. Something the user knows
1. Something the user has
1. Something the user is

### 9.4.1 Authentication Using Passwords

It's a good practice to always prompt for password even when a user doesn't
exist, and if you have a laptop computer, take the time to set your BIOS
password so anybody can't take it, change your boot sequence, and bypass your
system login (and eventually steal your data).

#### How Crackers Break In

- Usernames and passwords are easy to guess - 80% of them
- A classic break-in sequence:
  - Construct a dictionary of common usernames and passwords
  - Choose a domain name, e.g., `foobar.edu`
  - Run a DNS query to get its network address (upper bits of IP)
  - Run a ping to probe all hosts that are live in that network
  - Run telnet to log in, using the usernames and passwords from the dictionary
- As you can see, the above is very easy to automate and is what computers are
  good at
- Once break in, the cracker typically installs a _packet sniffer_, that
  examines incoming and outgoing packets for certain patterns (password sent to
a bank's site for example)

#### UNIX Password Security

Unix used to have a world-readable file (`/etc/passwd`) with all the usernames
and passwords. This is for sure not secure. An improvement was to store an
encrypted version of passwords, but it could be worked around because the
encryption algorithm was well known. With the usual dictionary of usernames and
passwords, the cracker could, at their leisure, encrypt all the passwords with
the same algorithm, and compare them one bye one with the entries in
`/etc/passwd`. Any matching entry will mean a compromised user login.

Morris and Thompson came up with a technique that defeat this attack, or rather
made it harder than what it could ever achieve. The idea is to assign a random
number to each password, called _salt_, and encrypt the salt and the password
together. Now, imagine in the same situation, the cracker has access to a
`/etc/passwd`, their usual dictionary will have to be updated to take account
into the added salt numbers. But because the salt is randomly assigned, for any
possible password, they would have to enumerate all possible salt numbers,
encrypt their concatenation, and then compare against the entries in
`/etc/passwd`. That just increases the complexity by 2^n, n being the number of
bits the salt has, which for UNIX, is 12.
