---
layout: post
title: Write programs for better cache performance
category: [ cs-basics ]
toc: true
---

* TOC
{:toc}

# Common Techniques

- Use small, cache line aligned data types; such that objects of those types
  won't spread across multiple cache lines or even worse, go outside of cache.
- Temporal locality. Make sure hot data are processed by hot code. Examples
  include merging loops that touch the same array into one (called Loop Fusion).
