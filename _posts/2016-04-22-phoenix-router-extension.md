---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Phoenix Router Extension
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Pikender'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

>
The post belongs to NectarCommerce and Extension Framework Awareness
>
1. _[NectarCommerce Vision](http://vinsol.github.io/nectarcommerce/vision)_
1. _[Extension Framework Game Plan](http://vinsol.github.io/nectarcommerce/extension-framework-game-plan)_
1. _[Introduction to Metaprogramming](http://vinsol.github.io/nectarcommerce/intro-to-macros)_
1. _[Ecto Model Schema Extension](http://vinsol.github.io/nectarcommerce/ecto-model-schema-extension)_
1. _[Ecto Model Support Functions Extension](http://vinsol.github.io/nectarcommerce/model-function-extension)_
1. **Phoenix Router Extension**
1. _[Phoenix View Extension](http://vinsol.github.io/nectarcommerce/phoenix-view-extension)_
1. _[Running Multiple Elixir Apps Together](http://vinsol.github.io/nectarcommerce/running-multiple-apps-in-umbrella-project)_
1. _[Extension Approach Explained](http://vinsol.github.io/nectarcommerce/extension-approach-2)_
1. _[Learning from failures: First Experiment at NectarCommerce Extension Approach](http://vinsol.github.io/nectarcommerce/developing-nectar-extensions-part-1)_
1. _[Developing NectarCommerce Extensions](http://vinsol.github.io/nectarcommerce/developing-nectar-extensions-part-2)_
1. _[Building an exrm release including NectarCommerce](http://vinsol.github.io/nectarcommerce/exrm-release)_


## What will be NectarCommerce

>
Off-the-shelf Opensource E-commerce application for building an online store.
>
Provides an Extension Framework to support features not included in core as extensions.
>
Strives for unobtrusive parallel development of NectarCommerce and Extensions

NectarCommerce is committed to providing a ready-to-use e-commerce solution but the definition of 100% is different under different business domains.It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

# Phoenix Router Extension

>
**Note:** This blog post is very similar to [Ecto Model Schema Extension](http://vinsol.com/blog/2016/04/15/ecto-model-schema-extension/), you can wish to jump straight to [final version](#final_version)

### Why

We want to allow Extensions to add routes into Nectar Router without modifying the Nectar Router source.

### How

Minimum three parts are needed to create & use an extension effectively:

- Library Code
- Service Code
- Consumer Code

An extension and its use with Nectar can be viewed as Producer / Consumer relationship bound by a communication protocol.

**Extension** which wants to add a route, say a list of favorites, is a **Producer (Service Code)**.

**Nectar Router** is a **Consumer (Consumer Code)** allowing the route additions through a **communication protocol (Library Code)**

Let's begin the journey of incremental changes to bring consumer, service and library code into existence starting from a simple use-case of adding a route for showing favorites.

>
Note: Please refer [Introduction to Metaprogramming]() for more information on Metaprogramming in Elixir

1.  A straightforward way to add favorites route in Nectar.Router would be adding it directly in Nectar.Router, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/a4cda70666cb5132ecaf1c91a98710c09872a444), but it requires change in Nectar source. Let's move to next step for avoiding any modification to Nectar.Router

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/7020bb2f62d6224fb3cda074257a507ab01d5106.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  We can add a function to Nectar to which other extensions can delegate the responsibility of route additions, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/155a427b80b5dc11d201adcea0262e7ccd342bb1). See Nectar.ExtendRouter example below on how to use it

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/1c0ffd904c0cdf75be54efd70f126e42ec9a3828.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  Now, with delegation function `mount` in place, we can work towards providing a way to register the routes to be added, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/346f1d8423f8c36d43f9a18d83317bd7a3152304). Please check the usage of Module attributes for same below.

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/44fa6030ac35d78033468e6f7aadb1a5ce2d3479.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  Earlier, Module.put_attribute need to be used multiple times to define multiple routes whereas now we wrapped it in an anonymous function to encapsulate the collection of routes through a simple and consistent interface, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/948e680ec11599955695b9db5e09d297b9df4de4). There can be multiple extensions used for different functionality and hence multiple routes need to be registered and defined

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/0f5c4176ef1573c412c692afe7ab3e335f2a3de2.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>


1.  Now, Nectar.ExtendRouter is getting cluttered with ancillary method definitions. Let's move it out to another module and use it, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/9708b3aace1c094e71172d97501d57a47253bcaa)

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/c41cfdede0618d4b78f93362d6767b8fcaa5745a.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  Let's further reduce the boilerplate of registering defined_routes module attribute and importing define_route method definition with __using__ callback, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/b6016f1f29cc95ebad8b2b2a9546a434275cea3f)

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/c84f28c0fec71209b1d0a0cfe19312f18f69479c.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  Reference of defined_routes Module attribute is scattered across Nectar.RouterExtender and Nectar.RouterExtension so let's move it out to Nectar.RouterExtension to consolidate the usage via `__before_compile__` and definition together, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/4f33d8935a8aaeebe92a33812fbb4252a576f4aa)

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/4de0ec9ad28b27d0c6cd52bf61c8d9003b4fa393.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

1.  With above changes, it's now possible to define routes any number of times, see full version [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/c495577952eea865f100092c314898fc9ed35d03). Also, routes can now be added using `define_route` in Nectar.ExtendRouter without making any changes to Nectar.Router.

    <script src="https://gist.github.com/pikender/607493614533860699d835111feb11cd/453d78e87cdd2b65323d6499c81b30f5f836c2f8.js"></script>

    <script src="https://gist.github.com/pikender/e2fccd747620b9e67f4b201fb124ebbe.js"></script>

Check all the revisions at once, [here](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46/revisions)

<a name="final_version">&nbsp;</a>Now, in the [final version](https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46), you can easily find the three components, _consumer, service and library code_, as desired in extensible system

<script src="https://gist.github.com/pikender/52c5f30c74f1a2bbff886e6ffcc6be46.js"></script>

Please refer the demonstration approach for [library code](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-aa0d91998a3539f6cf29553e1bc5d24bR1), [service code](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-1d4fe030d5ab0511fa7e328d362f6e40R11) and [consumer code](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-1b46ba545dda128d0ad3f50dd1ff7d0dR103) as used with [favorite products extension](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-3d8e34555d30c9e6493acb096f42207cR6)

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
