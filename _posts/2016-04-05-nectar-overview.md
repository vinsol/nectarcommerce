---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: NectarCommerce Overview
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Pikender'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

Vision
======

**E-commerce Framework with an extension methodology which allows easy integration of custom features unique to the domain.**

## NectarCommerce in NutShell

[NectarCommerce](https://github.com/vinsol/nectarcommerce) is an Elixir/Phoenix Application which is currently having following E-commerce features:

- Product Management
- Order Management
- Basic Stock Management

Please check out the [demo](https://github.com/vinsol/nectarcommerce#demo) and [README](https://github.com/vinsol/nectarcommerce/blob/master/README.md)

## NectarCommerce and Extensions

Project is in its early stages where NectarCommerce and extensions are residing side-by-side in _Elixir umbrella app_.

Plan is to evolve where Nectar and all other extensions will be phoenix projects, which can be downloaded as hex packages.

So, NectarCommerce should provide an [Extension Framework](https://github.com/vinsol/nectarcommerce/pull/48), where custom features as needed per domain can be developed and integrated back to NectarCommerce with minimal effort.

Extension Framework should seamlessly integrate with NectarCommerce such that changes in extensions should not result / demand a change in NectarCommerce Project
and extensions can incrementally adapt to changes in NectarCommerce for better support, new features and betterments.

NectarCommerce and extensions can be grown and develop in isolations, wherein, Nectar being maintained by one team and extensions probably by many different teams where no one team will own all the extensions and Nectar Project.
