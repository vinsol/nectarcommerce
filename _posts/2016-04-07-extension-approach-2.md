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

## NectarCommerce Extension Approach 2 ##

This post aims at documenting how extensions approach 2 is structured. And the order of dependencies amongst the various nuts and bolts of NectarCommerce and its extensions as implemented.

NectarCommerce can be divided in two components, both of which reside in the same umbrella application.

1. Nectar: The phoenix project, which acts as the backbone of your E-Commerce application.
2. Extension Manager: A plugin manager/DSL provider for nectar. It also owns the compile time step for Nectar. We intend to make the DSL/Compiler as a separate package and make Extension Manager solely responsible for downloading and installing extensions.

## Application Overview ##

### Nectar ###

Nectar while being a run of the mill phoenix application, with models, controllers and all has some additional conveniences built into it which makes it amenable to extension. It has no dependencies on other application in the umbrella besides worldly which once done should also be a separate package.

1. __Nectar.Extender__, if any module is using this during compile time, Nectar.Extender searches for wether a module has been compiled which can act as an extension to the module and includes it into the module. There is a basic naming convention followed right now for doing this. If ```Nectar.Product``` uses ```Nectar.Extender``` then it will search for module ```ExtensionsManager.ExtendProduct```. This is a very basic and a proof of concept implementation and we can flesh it out later to support fully name-spaced extension modules.
[source](links to Nectar.Extender).

> **Note**: This currently limits the point of extension per module to a single module. It is by design to keep things in one place.

2. __Nectar.RouteExtender__, Similar to ```Nectar.Extender``` except it is specialized for extending routes.

So any extension that needs to modify Nectar, needs to utilize the DSL provided by extension manager, we will go through this in detail when we flesh out how to go about building an extension.

### Extension Manager ###

This is a regular mix application that will be used to fetch the extensions and provides a thin DSL(for more details on this see our posts on _, _ and _) which can be used to express how changes are to made to Nectar. Also any extension that we need to install will be added here as a dependency and properly hooked into the correct modules (Please see the example implementation for one way of doing this). This module provides 3 Components for building and compiling Nectar Extensions

1. __DSL__ : A simple DSL for declaring components that need to be injected into models/router. See our previous posts for how the DSL looks and behaves.

2. __Extension Compiler__, it is a basic compile time step that marks files which are using Necatr.Extender(literally ```use Nectar.Extender```) for recompilation so that they pick up any changes made to the extensions. It is currently based on how [phoenix compiler](https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/compile.phoenix.ex) works.

3. __Install__: Extensions can document how they are to be installed by declaring the code using DSL inside method calls and describing how and which modules to call these methods in.
These instructions are then followed to compile the injection payload. If this seems cryptic/vague, please refer to the example implementation of favorite products extensions on how the install file is structured.


## Dependencies and Code loading ##

__Extensions Manager & Nectar__ : Extension Manager does not depend upon Nectar directly(it may be a transitive dependency via the extensions) neither does Nectar Depend upon it. Nectar searches for modules in the umbrella via ```Code.ensure_loaded``` to find if extensions exists. While not ideal and as explicit as want it to be, we feel it is a pragmatic solution for what it allows us to achieve which is basically a form of mutual dependency.

__Extensions & Nectar__: Extensions should depend upon nectar. Again, This may seem counterintuitive since nectar will be enhanced via extensions, But ultimately we will need the Nectar dependency for running tests, pattern matching on Nectar Struct and models and for building exrm releases. After we are done we can always recompile nectar to use the extensions.

This concludes our high level description of how the different parts of NectarCommerce interact with each other. Lets continue and see how we can utilize the above infrastructure for building our extensions in our next post.