---
layout: post
title: MOS - Security
---

# 9 Security

## 9.3.4 Trusted Systems

"Is it possible to build a secure operating system?" "Theoretically yes, but
there are reasons why modern OSes aren't secure":

  - Users are unwilling to throw away current unsecure systems. For example,
    there is actually a "secure OS" from Microsoft, but they never adversite it
and people won't be happy if told that their Windows systems will be replaced.
  - Features are the enemy of security, yet system designers keep adding
    features that they believe their users will like. For example, emails used
to be ASCII texts which in no way poses a security threat, and one day email
developers added rich contents like Word documents that can have viruses written
in macro. Another example is web pages, which used to be static HTML files that
were secure, until the appearance of dynamic widgets like applet and Javascript.
Since then security problems pop one after another.

### 9.3.5 Trused Computing Base

At the heart of a "trusted system" is a minimal **Trusted Computing Base
(TCB)**. If the TCB is working to specification, it is believed that the system
security cannot be compromised, no matter what else goes wrong.

TCB typically consists of most of the hardware, a portion of the operating
system, and most or all user programs that have superuser power (binaries with
SETUID bit for instance). MINIX 3 does a great job minimizing the TCB: its
kernel is only a few thousand lines of code, as opposed to the Linux kernel
which has millions if not tens of millions. Everything else that don't belong in
the TCB is moved to user space, such as printer and video card drivers.

## 9.3.6 Formal Models of Secure Systems

There are research that attempts to prove that given a set of _authorized_
states of a system, and a list of _protection commads_ (that grant of revoke
permissions), whether it is possible to derive a _unauthorized_ state, using
formal verification methods.

## 9.3.7 Multilevel Security

### DAC v.s. MAC

Discretionary Access Control (DAC) v.s. Mandatory Access Control (MAC). The
former gives owners of resources the right to decide who else can have access to
resources they own. The latter, however, says an organizational admin globally
mandates who has access to what, thus enforcing a stronger information security.
MAC is common in the military, organizations, and hospitals.

### Multilevel

The concept "multilevel" refers to the design that there are mutliple _security
levels_ on a system, and users/processes at each level has restricted access to
resource on the system. Two notable models of multilevel security are the
Bella-La Padula model and the Biba model.

The Bella-La Padula model was designed for military use, where the core of
security is information security, i.e., a general can have access to most
information including everything a lieutenant knows, but he cannot tell
everything he knows to the lieuteannt. When applied to an operating system, this
means a process can read files with an equal or lower level, but can write to
files with an equal or higher level. This is why the model is often remembered
as "read down and write up".

The Bella-La Padula model makes sure information never flows from a higher level
to lower, which is great for the military, but when applied to a corpration, it
may break _data integrity_. For example, it would entitle an engineer to write
to the CEO's company OKRs or the CFO's finacial reports. For corparations, an
exact opposite model exists, and that is the Biba model.
