---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Overview of Extension Approach 2 
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Nimish'
navigation: true
logo: 'assets/images/nectar-cart.png'
---
>
The post belongs to _NectarCommerce and Extension Framework Awareness_ Series
>
1. _[NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)_
1. _[Extension Framework Game Plan](http://vinsol.com/blog/2016/04/12/extension-framework-game-plan/)_
1. _[Introduction to Metaprogramming](http://vinsol.com/blog/2016/04/14/introduction-to-metaprogramming/)_
1. _[Ecto Model Schema Extension](http://vinsol.com/blog/2016/04/15/ecto-model-schema-extension/)_
1. Ecto Model Support Functions Extension
1. Phoenix Router Extension
1. Phoenix View Extension
1. Running Multiple Elixir Apps Together
1. **Extension Approach Explained**
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

## NectarCommerce Extension Approach 2 ##

This post aims at documenting how extensions approach 2 is structured, the order of dependencies amongst the various nuts and bolts of NectarCommerce and its extensions as implemented.

NectarCommerce can be divided in two components, both of which reside in the same umbrella application.

1. Nectar: The phoenix project, which acts as the backbone of your E-Commerce application.
2. Extension Manager: A plugin manager/DSL provider for nectar. It also owns the compile time step for Nectar. We intend to make the DSL/Compiler as a separate package and make Extension Manager solely responsible for downloading and installing extensions.

## Application Overview ##

### Nectar ###

Nectar while being a run of the mill phoenix application, with models, controllers and all has some additional conveniences built into it which makes it amenable to extension. It has no dependencies on other application in the umbrella besides worldly which once done should also be a separate package.

1. __Nectar.Extender__, if any module is using this during compile time, Nectar.Extender searches for whether a module has been compiled which can act as an extension to the module and includes it into the module. There is a basic naming convention followed right now for doing this. If ```Nectar.Product``` uses ```Nectar.Extender``` then it will search for module ```ExtensionsManager.ExtendProduct```. This is a very basic and a proof of concept implementation and we can flesh it out later to support fully name-spaced extension modules.
[source](https://github.com/vinsol/nectarcommerce/blob/extension/approach-2/apps/nectar/lib/nectar/extender.ex).

	> **Note**: This currently limits the point of extension per module to a single module. It is by design to keep things in one place.

2. __Nectar.RouteExtender__, Similar to ```Nectar.Extender``` except it is specialized for extending routes.

So any extension that needs to modify Nectar, needs to utilize the DSL provided by extension manager, we will go through this in detail when we expand on how to build an extension.

### Extension Manager ###

This is a regular mix application that will be used to fetch the extensions and provides a thin DSL(for more details on this see our posts on [Model Extension](http://vinsol.com/blog/2016/04/15/ecto-model-schema-extension), [View Extension](http://vinsol.com/blog/2016/04/25/phoenix-view-extension/) and [Router Extension](http://vinsol.com/blog/2016/04/21/phoenix-router-extension/) which can be used to express how changes are to made to Nectar. Also any extension that we need to install will be added here as a dependency and properly hooked into the correct modules (Please see the example implementation for one way of doing this). This module provides 3 Components for building and compiling Nectar Extensions

1. __DSL__ : A simple DSL for declaring components that need to be injected into models/router. See our previous posts for how the DSL looks and behaves.

2. __Extension Compiler__: It is a basic compile time step that marks files which are using Nectar.Extender(i.e. ```use Nectar.Extender```) for recompilation so that they pick up any changes made to the extensions. It is currently based on how [phoenix compiler](https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/compile.phoenix.ex) works.

3. __Install__: Extensions can document how they are to be installed by declaring the code using DSL inside method calls and describing how and which modules to call these methods in.
These instructions are then followed to compile the injection payload. If this seems cryptic/vague, please refer to the [example implementation](https://github.com/vinsol/nectarcommerce/pull/47) of favorite products extensions on how the [install](https://github.com/vinsol/nectarcommerce/blob/extension/approach-2/apps/extensions_manager/lib/extensions_manager/install_extensions.ex) file is structured.


## Dependencies and Code loading ##

__Extensions Manager & Nectar__ : Extension Manager does not depend upon Nectar directly(it may be a transitive dependency via the extensions) neither does Nectar Depend upon it. Nectar searches for modules in the umbrella via ```Code.ensure_loaded``` to find if extensions exists. While not ideal and as explicit as want it to be, we feel it is a pragmatic solution for what it allows us to achieve which is basically a form of mutual dependency.

__Extensions & Nectar__: Extensions should depend upon nectar. Again, This may seem counterintuitive since Nectar will be enhanced via extensions, but ultimately we will need the Nectar dependency for running tests, pattern matching on Nectar Struct and models and for building exrm releases(more on this later). After we are done we can always recompile nectar to use the extensions.

This concludes our high level description of how the different parts of NectarCommerce interact with each other. Lets continue and see how we can utilize the above infrastructure for building our extensions in our next post.

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_