---
layout: post
title: Boot Loaders
category: [ design-patterns ]
toc: true
---

* TOC
{:toc}

This post studies boot loaders.

# uboot

https://www.denx.de/wiki/view/U-Bootdoc/Presentation

# CoreBoot

https://coreboot.org/Payloads

# BIOS

# SeaBIOS

An open source implementation of the _legacy bios_. Developed for and used by
QEMU. Can not run directly on hardware. But if coreboot is used as the firmware,
then SeaBios can run as a payload of coreboot.

# EFI

An upgrade from BIOS. Full name: Extensible Firmware Interface.

# UEFI

Unified EFI. A _unitified_ version of EFI. Promoted by Microsoft. Windows
releases after September 2017 has stopped support for "legacy" BIOS, which is
the traditional BIOS before EFI.

# grub

# syslinux
