---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Running Multiple Apps in Umbrella Project
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
1. NectarCommerce Vision
1. Extension Framework Game Plan
1. Introduction to Writing Macros
1. **Running Multiple Phoenix Apps Together**
1. Ecto Model Extension
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

# Elixir Umbrella Project

[Elixir Umbrella Project](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html#umbrella-projects
) are a convenience to help you organize and manage your applications. Applications inside the apps directory are still decoupled from each other. Dependencies between them must be explicitly listed. This allows them to be developed together, but compiled, tested and deployed independently if desired.

As NectarCommerce extensions are envisioned to use with Nectar and would be dependent on Nectar directly or indirectly, we chose umbrella project to have Nectar, extensions\_manager, user\_app, and extensions apps as part of it.

We plan to use `phoenix app` for extensions where web-component is needed and which would be part of umbrella project.

The `user_app` would be a resting ground where Nectar and extensions are evaluated for compile time requirements and prepared to be used together.

As of now, `user_app` have following responsibilities:

- [defining nectar as umbrella dependency](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-cfadcd558b7d7d0fa0bb1b43ff49ba98R44)
- [defining available extensions as umbrella dependencies](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-cfadcd558b7d7d0fa0bb1b43ff49ba98R45)
- [acting as a pass-through for all the outbound requests](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-02eb191c0680951b40ba159f4163a7c6R21)

## Phoenix Framework commands aware of Umbrella project

- [Forwarding Requests to other Phoenix.Router](https://hexdocs.pm/phoenix/Phoenix.Router.html#forward/4)
    - `forward "/", Nectar.Router`
    - All paths that matches the forwarded prefix will be sent to the forwarded plug.This is useful to share router between applications or even break a big router into smaller ones.
- DB Migration
    - `mix ecto.migrate -r Nectar.Repo`
    - `mix ecto.migrate -r ExtensionApp.Repo`
- Listing Routes
    - `mix phoenix.routes Nectar.Router`
    - `mix phoenix.routes ExtensionApp.Router`

## Few Tricks

- Using View Layout of Nectar from extensions
    - `defdelegate render(template, assigns), to: Nectar.LayoutView`
- Using Routes of Nectar in extensions
    - `alias Nectar.Router.Helpers, as: NectarRoutes`
    - `NectarRoutes.favorite_path(conn, :index)`
    - `alias` are resolved at runtime, so routes can be used but compile-time checks can't be used :(

## Gotchas

- [Nectar endpoint has to be commented as we want to serve all requests through UserApp endpoint](https://github.com/vinsol/nectarcommerce/pull/47/files#diff-001ce116edeff3304fe941b84c128c5dR12)

_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
