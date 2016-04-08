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

This post aims at documenting how extensions approach 2 is structured. And the order of dependencies amongst the various nuts and bolts of NectarCommerce and its extensions.

NectarCommerce can be divided in two components, both of which reside in the same umbrella application.

1. Nectar: The phoenix project, which acts as the backbone of your E-Commerce application.
2. Extension Manager: A plugin manager/DSL provider for nectar. We intend to make the actual DSL as a package and make Extension Manager be solely responsible for downloading and installing extensions.

## Application Overview ##

### Nectar ###

Nectar while being a run of the mill phoenix application, with models, controllers and all has some additional conveniences built into it which makes it amenable to extension. It has no dependencies on other application in the umbrella besides worldly which we intend to move into its own mix package.

1. __Nectar.Extender__, if any module is using this during compile time, Nectar.Extender searches for wether a module has been compiled which can act as a extension to the module and includes it into the module. There is a basic naming convention followed right now for doing this. If ```Nectar.Product``` uses ```Nectar.Extender``` then it will search for module ```ExtensionsManager.ExtendProduct```. This is a very basic and a proof of concept implementation and we can flesh it out later to support fully name-spaced extension modules.
[source](links to Nectar.Extender)

2. __Nectar.RouteExtender__, Similar to ```Nectar.Extender``` except it is specialized for extending routes.

3. __Nectar Compiler__, it is a basic compile time step that marks files which are using the above modules for recompilation so that they pick up any changes made to the extensions. It is currently based on [phoenix compiler](https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/compile.phoenix.ex).

So any extension that needs to modify Nectar, needs to utilize the DSL provided by extension manager, we will go through this in detail when we flesh out how to go about building an extension.

### Extension Manager ###

This is a regular mix application that will be used to fetch the extensions and provides a thin DSL(for more details on this see our posts on _, _ and _) which can be used to express how changes are to made to Nectar. Also any extension that we need to install will be added here as a dependency and properly hooked into the correct modules (Please see the example implementation for one way of doing this).

## Dependencies and Code loading ##

Extension Manager does not depend upon Nectar directly(it may be a transitive dependency via the extensions) neither does Nectar Depend upon it. Nectar searches for modules in the umbrella via ```Code.ensure_loaded``` to find if extensions exists. While not ideal, we feel it is a pragmatic solution for what it allows us to achieve which is basically a form of mutual dependency.

__Extensions__ themselves depend upon nectar. Again, This may seem counterintuitive since nectar will be enhanced via extensions, And initially we felt that this might not be needed since Nectar should be available at runtime. But, ultimately we had to abandon our original approach to accommodate the dependency. Mainly to allow for testing and ultimately running nectar as part of a bigger application instead of running nectar as the main application(link to implementation of approach 1 here).
 

