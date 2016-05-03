---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Phoenix View Extension
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
1. _[NectarCommerce Vision](http://vinsol.github.io/nectarcommerce/vision)_
1. _[Extension Framework Game Plan](http://vinsol.github.io/nectarcommerce/extension-framework-game-plan)_
1. _[Introduction to Metaprogramming](http://vinsol.github.io/nectarcommerce/intro-to-macros)_
1. _[Ecto Model Schema Extension](http://vinsol.github.io/nectarcommerce/ecto-model-schema-extension)_
1. _[Ecto Model Support Functions Extension](http://vinsol.github.io/nectarcommerce/model-function-extension)_
1. _[Phoenix Router Extension](http://vinsol.github.io/nectarcommerce/phoenix-router-extension)_
1. **Phoenix View Extension**
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

NectarCommerce is committed to providing a ready-to-use e-commerce solution but the definition of 100% is different under different business domains. It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

## Phoenix View Extension

### Why

We want to allow Extensions to provide alternate view for an existing view in Nectar or provide an alternate template path for all views without changing the Nectar Views.

### How

>
Note: Please refer [Introduction to Metaprogramming](http://vinsol.com/blog/2016/04/14/introduction-to-metaprogramming/) for more information on Metaprogramming in Elixir

## Alternate View Templates Path than Default for all templates override

To fully understand the changes below, please refer [Phoenix View Implementation](https://github.com/phoenixframework/phoenix/blob/master/lib/phoenix/view.ex#L136)

As per the reference above, we simply defined a function which adds the function which would check in custom path for templates and if not found will fallback to default view paths :)

<script src="https://gist.github.com/pikender/c84672d42558ac731eddd77e338ec1da.js"></script>

## Only Few Template Overrides than all

>
**Note:** This section would be very similar to [Ecto Model Support Functions Extension](http://vinsol.com/blog/2016/04/18/ecto-model-support-functions-extension/), so only complete code-snippets are shown and not incremental walkthrough

Check the [library code](#library_code), [service code](#service_code) and [consumer code](#consumer_code) as used with [favorite products extension](#extension_code)

<strong><a name="library_code">Library Code</a></strong>
<script src="https://gist.github.com/pikender/5a7f1e07cbf8dcdbecab26065b072d1e.js"></script>

<strong><a name="service_code">Service Code</a></strong>
<script src="https://gist.github.com/pikender/9e5b73b6ff98f616b13c7e068f90d6b0.js"></script>

<strong><a name="consumer_code">Consumer Code</a></strong>
<script src="https://gist.github.com/pikender/1475537a4e135652799f6c1aa691e815.js"></script>

<strong><a name="extension_code">Partial Override from Extension</a></strong>
<script src="https://gist.github.com/pikender/ab134008a7b35bbfcd9f262c169bebfa.js"></script>
<script src="https://gist.github.com/pikender/4b9740d3d427c19e9dcaaf8f7d99de71.js"></script>

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
