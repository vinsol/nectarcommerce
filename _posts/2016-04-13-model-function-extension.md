---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Ecto Model Support Functions Extension
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
1. _[NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)_
1. _[Extension Framework Game Plan](http://vinsol.com/blog/2016/04/12/extension-framework-game-plan/)_
1. Intro to Metaprogramming
1. Ecto Model Schema Extension
1. **Ecto Model Support Functions Extension**
1. Phoenix Router Extension
1. Phoenix View Extension
1. Running Multiple Elixir Apps Together
1. Extension Approach Explained
1. Developer Experience and Workflow developing Favorite Product Extension
1. Developer Experience and Workflow testing Favorite Product Extension


## What will be NectarCommerce

>
Off-the-shelf Opensource E-commerce application for building an online store.
>
Provides an Extension Framework to support features not included in core as extensions.
>
Strives for unobtrusive parallel development of NectarCommerce and Extensions

NectarCommerce is committed to providing a ready-to-use e-commerce solution but the definition of 100% is different under different business domains. It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

## Ecto Model Support Functions Extension

### Why

We want to allow Extensions to add functions to existing Nectar Models without changing the Nectar Models.

### How

There are three parts needed at minimum to create & use an extension effectively:

- Library Code
- Service Code
- Consumer Code

An extension and its use with Nectar can be viewed as Producer / Consumer relationship bound by a communication protocol.

**Extension** which want to add a function, say fn\_from\_outside to Nectar Product Model, is a **Producer (Service Code)**.

**Nectar Model** is a **Consumer (Consumer Code)** allowing the new function additions through a **communication protocol (Library Code)**

Let's begin the journey of incremental changes to bring consumer, service and library code into existence starting from a simple use-case of adding a function, say `fn_from_outside`.

>
Note: Please refer [Intro to Metaprogramming]() for more information on Metaprogramming in Elixir

1.  A straightforward way to add a function, say fn\_from\_outside, to Nectar Product would be to add it directly in Nectar.Product, but it requires change in Nectar source. Let's move to next step for the workaround to avoid modification to Nectar.Product

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/a0608017b19c05337e71bd79231e3562bf190131.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Like, other extensions, adding a function to Nectar Model and importing it would not solve our purpose of calling function as `Nectar.Product.fn_from_outside`.
    `import <Module>` makes the `<Module>` functions available inside the module and can only be called inside Module and not from outside like `Nectar.Product.fn_from_outside`
    As always, Elixir is well-aware of the use-case and provides `@before_compile <Module>` hook to inject function in Modules as if their own and can be called as  `Nectar.Product.fn_from_outside`, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/de73b334b169009ec247ae15d0e10707c9e1ee55). See Nectar.ExtendProduct example below on how to use it.

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/c0d7f9f2aedaacffb8ca26fb778839e05d0ad868.js"></script>
    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/0f3a8d81e636a5e2a1b138e2a0eb0ddf545bfa0d.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Now, with `@before_compile Nectar.ExtendProduct` in place, we can work towards providing a way to register the new functions, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/2e7b4ee7ce7b76a70440ca256c612307e786c52c). Please check the usage of Module attributes for same below.

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/8a9cc9d0f3f9b33fd3516ec3b0bd625946b7fe1d.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Earlier, Module.put_attribute need to be used multiple times to define many functions instead we wrapped it in an anonymous function to encapsulate the collection of schema changes through a simple and consistent interface, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/0f75aef16bf12000068d331d5a4147c0a6f819d0). There can be multiple extensions used for different functionality and hence multiple schema changes need to be registered and defined

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/020dd42284c391e64bac9b4a14c3a3bb97a0f621.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Now, Nectar.ExtendProduct is getting cluttered with ancillary method definitions, let's move it out to another module and use it, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/d9883af5365109c349363ffa38e2a13ad30bc9d2)

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/447cdad10471f9ab7c47c0352070ae00dde12f03.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Let's further reduce the boilerplate of registering method_block module attribute and importing include_method method definition with __using__ callback, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/1ba90f0e6e86e87c1e116d62d8e9eaf4ee42b37c)

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/2125c83a64300b108c21048a35b8436d3f281764.js"></script>
    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/ad4a872557c8906389198e0ba3aafde3dd69fac4.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Reference of method_block Module attribute is scattered across Nectar.ExtendProduct and Nectar.ModelExtension so let's move it out to Nectar.ModelExtension to consolidate the usage via `__before_compile__` and definition together, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/8b21ccb99dbdb507c25b5e9d3f3fdfe72fc8bec1)

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/71a8f9cce9f4d3607ac2e0ee35123404bbd8b6dc.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  Now, `Nectar.ExtendProduct` is having `__using__` macro definition, which can also be moved to `Nectar.ModelExtension` to just have new method defintions in `Nectar.ExtendProduct`, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/b985b7af90e558773d974bcb34658eae222ea2b7)

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/e2dc2266dfecd0e35bfebdd5c39a88df1b291fc9.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e/2cbcedac70352d0f83c358669381084b946bcb8b.js"></script>

1.  With above changes, it's now possible to define schema changes any number of times needed, see full version [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/56e57c15324c99c7355e6d418cf7286a0d1afbeb). Also, schema changes can now be added using `include_method` in Nectar.ExtendProduct without making any changes to Nectar.Product.

    <script src="https://gist.github.com/pikender/a60a3c193f3077f648daa6f81f2c5f17/fcb09e32bb34d11d78833895fe321228c40eb6e7.js"></script>

    <script src="https://gist.github.com/pikender/c5aa7869610b006653bdae9e00cf360e.js"></script>

To check all the revisions at once, please check [here](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba/revisions)

Now, in the [final version](https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba), you can easily find the three components, _consumer, service and library code_, as desired in extensible system

<script src="https://gist.github.com/pikender/892fd3707043bacecc73ad24ba45cdba.js"></script>

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
