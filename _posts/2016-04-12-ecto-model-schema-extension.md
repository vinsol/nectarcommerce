---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Ecto Model Schema Extension
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Pikender'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

>
The post belongs to _NectarCommerce and Extension Framework Awareness_ Series
>
1. [NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)
1. Extension Framework Game Plan
1. Introduction to Writing Macros
1. Running Multiple Phoenix Apps Together
1. **Ecto Model Schema Extension**
1. Ecto Model Functions Extension
1. Phoenix Router Extension
1. Phoenix View Extension
1. Extension Approach Explained
1. Developer Experience and Workflow developing Favorite Product Extension
1. Developer Experience and Workflow testing Favorite Product Extension


## What will be NectarCommerce

>
Off-the-shelf Opensource E-commerce application for building online store.
>
Provides an Extension Framework to support features not included in core as extensions.
>
Strives for un-obstrusive parallel development of NectarCommerce and Extensions

NectarCommerce is committed to provide a ready-to-use e-commerce solution but definition of 100% is different under different business domains. It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

# Ecto Model Schema Extension

### Why

We want to allow Extensions to modify schema of existing Nectar Models without changing the Nectar Models.

Extensions should be able to add new fields and associations to existing models as needed for the cause.

### How

There are three parts needed at minimium to create & use an extension effectively:

- Library Code
- Service Code
- Consumer Code

An extension and its use with Nectar can be viewed as Producer / Consumer relationship bound by a communication protocol.

**Extension** which want to add a virtual field, say special, to Nectar Product Model Schema is a **Producer (Service Code)**.

**Nectar Model** is a **Consumer (Consumer Code)** allowing the schema changes through a **communication protocol (Library Code)**

Let's begin the journey of incremental changes to bring consumer, service and library code into existence starting from a simple use-case of adding a virtual boolean field, say special to Nectar Product.

>
Note: Please refer [Introduction to Writing Macros]() for more information on Metaprogramming in Elixir

1.  Straightforward way to add virtual field, say special, to Nectar Product would be to add it directly in Nectar.Product Schema definition, but it requires change in Nectar source. Let's move to next step for the workaround to avoid modification to Nectar.Product

    <script src="https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/2faba2e7a14bb77cceec769ef676fd439244878d.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  We can add a function to Nectar Model Schema to which other extensions can delegate the reponsibility of schema changes, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/5f4ada57be942f8dce713cf4c6c0d6761a7632a0). See Nectar.ExtendProduct example below on how to use it.

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/867502fb2218c41b6495bf318fab527a8a185193.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  Now, with delegation function `extensions` in place, we can work towards providing a way to register the schema changes, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/d2b931acb891d74014d2c5f6a1996f69c222e01c). Please check the usage of Module attributes for same below.

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/51619c29cf3a741c85b64e8e6e6ee254457393c5.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  Earlier, Module.put_attribute need to be used multiple times to define multiple routes instead we wrapped it in an anonymous function to encapsulate the collection of schema changes through a simple and consistent interface, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/3312acebeb9edec66e61da2ad447f7b18d5a9c8e). There can be multiple extensions used for different functionality and hence multiple schema changes need to be registered and defined

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/a1390db765a519334926834da392db90b70a2e84.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  Now, Nectar.ExtendProduct is getting cluttered with ancillary method definitions, lets move it out to another module and use it, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/4d3d831a6541e1e0c8ffeca4bbf44fbff579da35)

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/3323216f040a457e2a23dab6715be545dfa001e6.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  Let's further reduce the boilerplate of registering schema_changes module attribute and importing include_method method definition with __using__ callback, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/3e16ffe09593e53a8ca598df821dd260f92c4856)

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/bce26efc97a14745007ed06a2bf29c52e95965af.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  Reference of schema_changes Module attribute is scattered across Nectar.ExtendProduct and Nectar.ModelExtension so lets move it out to Nectar.ModelExtension to consolidate the usage via `__before_compile__` and definition together, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/3f09764e15098234e8b8d43361d403a4e8d370a2)

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/abd73fd87467c23c6d8a9ab262cc50306356f3d7.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

1.  With above changes, it's now possible to define schema changes any number of times needed, see full version [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1). Also, schema changes can now be added using `include_method` in Nectar.ExtendProduct without making any changes to Nectar.Product.

    <script src="https://gist.github.com/pikender/cb43c04937fbb95b289bfa43d8dfab08/518fae3a31366e82b12270cf8d60139dff86b3a4.js"></script>

    <script src="https://gist.github.com/pikender/bf89a77d2ed7c684dd0258d88e777cc0.js"></script>

To check all the revisions at once, please check [here](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1/revisions)

Now, in the [last version](https://gist.github.com/pikender/f58b2208ae8951c7b13214bf320e8ec1), you can easily find the three components, _consumer, service and library code_, as desired in extensible system

_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
