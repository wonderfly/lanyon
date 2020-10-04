---
layout: post
title: Comparing two unsigned 64 bit numbers
category: [cs-basics]
toc: true
---

* TOC
{:toc}

Suppose you are to write a C function that compares two `uint64_t` numbers.  The
function is supposed to return a negative number if the first argument compares
less than the second, zero if they compare equal, or a positive number if the
first is greater.  Sounds pretty familiar, right?  Many C library functions
takes a "comparator" function pointer that does that.  While it sounds trivial,
there is a subtle gotcha that is worth writing a blog post about.

It is tempting to writing a trivial comparator like this.

```
int compare1(uint64_t a, uint64_t b) {
  return a - b;
}
```

While it looks pretty neat, and seemingly satisfies the requirement, it is
vulnerable to a common pitfall when it comes to arithmetics of large numbers:
*overflow*!  To demonstrate the problem with this implementation, let's look at
the following sample program:

```
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  uint64_t a = 0;
  uint64_t b = UINT64_MAX;

  printf("a - b (as uint64_t) = %" PRIu64 "\n", a - b);
  printf("a - b (as int64_t) = %" PRIi64 "\n", (int64_t)(a - b));
  printf("a - b (as delta of int64_t's) = %" PRId64 "\n",
         (int64_t)a - (int64_t)b);
  return 0;
}
```

What do you think the output of the three `printf` statements would be?

```
~$ clang -c source.c && ./a.out
a - b (as int64_t) = 1
a - b (as uint64_t) = 1
a - b (as delta of int64_t's) = 1
~$
```

All three would print a positive 1, even though `a` (0) is clearly smaller than
`b` (`UINT64_MAX`).  It is because `0 - UINT64_MAX` overflows the range of 64
bit integers and wraps around to become 1.  As you can see, casting the result
or `a` and `b` individually to signed numbers don't help because `UINT64_MAX` is
already larger than `INT64_MAX`.  If `a` and `b` were 32 bit numbers and you had
a 64 bit machine you could try up-casting them to 64 bit numbers to avoid the
overflow problem, but for 64 bit numbers that trick doesn't work any more.

So what is the fix? Well, don't try to be smart to do subtractions. Use plain
old comparisons:

```
int compare2(uint64_t a, uint64_t b) {
  if (a < b) return -1;
  if (a > b) return 1;
  return 0;
}
```

For those that understand a little bit of assembly may wonder, doesn't
comparisons boil down to subtractions eventually since `cmp src dst`
instructions basically subtracts `dst` from `src` any way?  While that's true,
the hardware is kind enough to have a flag register which keeps track of
overflows in arithmetic operations.  In this case, since we are dealing with
unsigned integer overflows, the `carry` flag will be set if we tried to `cmp 0
UINT64_MAX`.  On the other hand, the compiler is smart enough to read this flag
after a `cmp` instruction, and will use an "overflow aware" jump instruction
like `jae` (jump if the first operand of the previous `cmp` instruction is above
or equal to its second operand, taking into consideration the `carry` flag) to
always get the correct comparison result.


This is evident in the compiler generated assembly code for the above two
comparator implementations (generated with `clang -S source.c`):

```
	.p2align	4, 0x90         ## -- Begin function compare1
_compare1:                              ## @compare1
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rax
	subq	-16(%rbp), %rax
                                        ## kill: def $eax killed $eax killed $rax
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
```

```
	.p2align	4, 0x90         ## -- Begin function compare2
_compare2:                              ## @compare2
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movq	%rsi, -24(%rbp)
	movq	-16(%rbp), %rax
	cmpq	-24(%rbp), %rax
	jae	LBB2_2                  <===== Notice the use of JAE here
## %bb.1:
	movl	$-1, -4(%rbp)
	jmp	LBB2_5
LBB2_2:
	movq	-16(%rbp), %rax
	cmpq	-24(%rbp), %rax
	jbe	LBB2_4
## %bb.3:
	movl	$1, -4(%rbp)
	jmp	LBB2_5
LBB2_4:
	movl	$0, -4(%rbp)
LBB2_5:
	movl	-4(%rbp), %eax
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
```
