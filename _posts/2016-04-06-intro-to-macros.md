---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Intro to Macros
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
1. NectarCommerce Vision
1. Extension Framework Game Plan
1. **Introduction to Writing Macros**
1. Running Multiple Phoenix Apps Together
1. Ecto Model Extension
1. Phoenix Router Extension
1. Phoenix View Extension
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

NectarCommerce is committed to provide a ready-to-use e-commerce solution but definition of 100% is different under different business domains.

NectarCommerce aims to solve trivial use-cases as part of the project and relying on extension framework to tap the rest.

# Metaprogramming in Elixir

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
- [\_\_using__ hook](http://elixir-lang.org/docs/stable/elixir/Kernel.html#use/2)
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

## Metaprogramming pattern as used across extensions

- Define a macro providing a DSL, say `define_route`
- Collect all definitions provided using DSL in Module attribute, say `defined_routes`
- Define a `before_compile` hook to add a macro extracting all collected definitions from module attribute, as module attributes are cleaned up as compilation completes
- Inject generated code into targeting module through `__using__` hook as invoked by `use ModuleWithDSLImplementation`, say `use ExtensionsManager.RouterExtension`
