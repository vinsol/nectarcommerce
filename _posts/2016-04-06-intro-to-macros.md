---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Intro to Metaprogramming
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Pikender'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

>
_The post belongs to NectarCommerce and Extension Framework Awareness_
>
1. _[NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)_
1. _[Extension Framework Game Plan](http://vinsol.com/blog/2016/04/12/extension-framework-game-plan/)_
1. **Introduction to Metaprogramming**
1. Ecto Model Schema Extension
1. Ecto Model Support Functions Extension
1. Phoenix Router Extension
1. Phoenix View Extension
1. Running Multiple Elixir Apps Together
1. Extension Approach Explained
1. Developer Experience and Workflow developing Favorite Product Extension
1. Developer Experience and Workflow testing Favorite Product Extension


### What will be NectarCommerce

>
Off-the-shelf Opensource E-commerce application for building online store.
>
Provides an Extension Framework to support features not included in core as extensions.
>
Strives for un-obstrusive parallel development of NectarCommerce and Extensions

NectarCommerce is committed to providing a ready-to-use e-commerce solution but the definition of 100% is different under different business domains. It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

# Metaprogramming in Elixir

_Note:_ If you are already familiar and experienced with Elixir Metaprogramming, you can jump to [last section](#last-section) as it lists the Metaprogramming resources
and constructs used in upcoming blog when creating different extension DSL's.

**Elixir _docs_** are excellent resources to get familair with Metaprogramming:

- [Quote and unquote](http://elixir-lang.org/getting-started/meta/quote-and-unquote.html)
- [Macros](http://elixir-lang.org/getting-started/meta/macros.html)
- [Domain Specific Languages](http://elixir-lang.org/getting-started/meta/domain-specific-languages.html)

Please check **Understanding Elixir Macros _blog_ series** by [@sasajuric](https://twitter.com/sasajuric)

- [Understanding Elixir Macros, Part 1 - Basics](http://theerlangelist.com/article/macros_1)
- [Understanding Elixir Macros, Part 2 - Micro Theory](http://theerlangelist.com/article/macros_2)
- [Understanding Elixir Macros, Part 3 - Getting into the AST](http://theerlangelist.com/article/macros_3)
- [Understanding Elixir Macros, Part 4 - Diving Deeper](http://theerlangelist.com/article/macros_4)
- [Understanding Elixir Macros, Part 5 - Reshaping the AST](http://theerlangelist.com/article/macros_5)
- [Understanding Elixir Macros, Part 6 - In-place Code Generation](http://theerlangelist.com/article/macros_6)

[**_Book_** Metaprogramming Elixir](https://pragprog.com/book/cmelixir/metaprogramming-elixir) by [@chris_mccord](https://twitter.com/chris_mccord) is next step for deep dive into metaprogramming.

>
Why another tutorial on already well-documented metaprogramming topic ?
>
**To revise and refresh only what we would refer again and again when reviewing Model, Router, View extension DSLs**

Extension DSLs will be using below constructs to get the job done :)

- [Module.register_attribute/3](http://elixir-lang.org/docs/stable/elixir/Module.html#register_attribute/3)
  - Registers an attribute. By registering an attribute, a developer is able to customize how Elixir will store and accumulate the attribute values.
- [Module.put_attribute/3](http://elixir-lang.org/docs/stable/elixir/Module.html#put_attribute/3)
  - Puts an Erlang attribute to the given module with the given key and value
- [@before_compile](http://elixir-lang.org/docs/stable/elixir/Module.html)
  - A hook `__before_compile__/1` that will be invoked before the module is compiled
  - allows us to inject code into the module when its definition is complete
- [\_\_using\_\_ hook](http://elixir-lang.org/docs/stable/elixir/Kernel.html#use/2)
  - check the examples for the usage, context and best practises
  - `use ModuleName` looks and invokes `__using__` macro defined in `ModuleName` module
- [bind_quoted](http://elixir-lang.org/docs/stable/elixir/Kernel.SpecialForms.html#quote/2)
  - check `bind_quoted` option
  - By using `bind_quoted`, we can automatically disable unquoting while still injecting the desired variables into the tree
- [Code.ensure_loaded?/1](http://elixir-lang.org/docs/stable/elixir/Code.html#ensure_loaded?/1)
  - Ensures the given module is loaded
- [apply/3](http://elixir-lang.org/docs/stable/elixir/Kernel.html#apply/2)
  - Invokes the given `function` from `module` with the array of arguments `args`.
- [Macro.escape/1](http://elixir-lang.org/docs/stable/elixir/Macro.html#escape/2)
  - Recursively escapes a value so it can be inserted into a syntax tree

#### <a name="last-section">Metaprogramming pattern as used across extensions</a>

There are three parts needed at minimium to create & use an extension effectively:

- Library Code
- Service Code
- Consumer Code

An extension and its use with Nectar can be viewed as Producer / Consumer relationship bound by a communication protocol.

**Extension** which want to add a route, say list of favorites, is a **Producer (Service Code)**.

**Nectar Router** is a **Consumer (Consumer Code)** allowing the route additions through a **communication protocol (Library Code)**

- **Library code** defines a macro providing a DSL, say `define_route`
- Collect all definitions provided using DSL from **Service code** in Module attribute, say `defined_routes`
- **Library code** defines a `before_compile` hook to add a macro extracting all collected definitions from module attribute, as module attributes are cleaned up as compilation completes
- Inject generated code into targeting module **Consumer code** through `__using__` hook as invoked by `use ModuleWithDSLImplementation`, say `use ExtensionsManager.RouterExtension`

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
