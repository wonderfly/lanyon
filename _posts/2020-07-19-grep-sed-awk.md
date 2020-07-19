---
layout: post
title: grep, sed and awk
category: [cs-basics]
toc: true
---

* TOC
{:toc}

These three tools seem to have a great deal of overlapping functionalities. All
have built-in regular expression matching, and many `grep` functionalities can
be replicated by `sed` and `awk`. For example, if I have a file, `test.txt`,
with the content:

```
NE 1 I
TWO 2 II
#START
THREE:3:III
FOUR:4:IV
FIVE:5:V
#STOP
SIX 6 VI
SEVEN 7 VII
```

And if I want to print the lines that don't have the keywords "START" or "STOP"
in them, I could do:

    grep -vE "START|STOP" test.txt 

Or:

    sed -nr '/START|STOP/ !p' test.txt 

Or:

    awk '$0 !~ /START|STOP/' test.txt

Having used all, my rules of thumb for picking the right tool to use for a task
are:

  - `grep` is for search only
  - `sed` if for *search and replace*. The underscore is on `ed`, for editing.
    You start with a regular expression matching to find the text you want to
    edit on, and take an action on the matching (or non-matching) text. The
    possible actions are:

      - substitute, with the `s/<pattern>/<substitue>/` command
      - delete, with the `d` command
      - or simply print, with the `p` command

  - `awk`'s unique power is in processing *columns* or *fields* in the matching
    lines of text. Suppose you have a table of data. You could first use pattern
    matching to select the rows you want to operate on, and then use `awk`'s
    powerful column matching to process each column - printing, modifying,
    skipping, etc.

Of course I could separate the search from the editing and column processing, by
using `grep` for the search and piping its output to `sed` or `awk`, but
sometimes it's nicer to have them all done with one command.
