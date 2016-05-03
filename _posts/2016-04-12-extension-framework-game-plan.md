---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Extension Framework Game Plan
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
1. **Extension Framework Game Plan**
1. _[Introduction to Metaprogramming](http://vinsol.github.io/nectarcommerce/intro-to-macros)_
1. _[Ecto Model Schema Extension](http://vinsol.github.io/nectarcommerce/ecto-model-schema-extension)_
1. _[Ecto Model Support Functions Extension](http://vinsol.github.io/nectarcommerce/model-function-extension)_
1. _[Phoenix Router Extension](http://vinsol.github.io/nectarcommerce/phoenix-router-extension)_
1. _[Phoenix View Extension](http://vinsol.github.io/nectarcommerce/phoenix-view-extension)_
1. _[Running Multiple Elixir Apps Together](http://vinsol.github.io/nectarcommerce/running-multiple-apps-in-umbrella-project)_
1. _[Extension Approach Explained](http://vinsol.github.io/nectarcommerce/extension-approach-2)_
1. _[Learning from failures: First Experiment at NectarCommerce Extension Approach](http://vinsol.github.io/nectarcommerce/developing-nectar-extensions-part-1)_
1. _[Developing NectarCommerce Extensions](http://vinsol.github.io/nectarcommerce/developing-nectar-extensions-part-2)_
1. _[Building an exrm release including NectarCommerce](http://vinsol.github.io/nectarcommerce/exrm-release)_

## What will be NectarCommerce

>
Off-the-shelf Opensource E-commerce application for building online store.
>
Provides an Extension Framework to support features not included in core as extensions.
>
Strives for un-obstrusive parallel development of NectarCommerce and Extensions

NectarCommerce is committed to provide a ready-to-use e-commerce solution but definition of 100% is different under different business domains. It aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

## Extension Framework Game Plan

Let's validate and list the capabilities needed in Extension Framework through an **extension** which provides feature **to mark a product as user's favorite**

_**Favorite Product Extension Requirements:**_

- **Ability to mark and unmark a Product as favorite**
  - a View _probably_ showing all products with Ability to mark/unmark product as favorite
  - a controller action preparing the view
  - a route exposing the controller / view through Web
  - a controller action handling mark product as favorite
  - a route exposing the controller / view through Web
  - a controller action removing product from the list of favorites
  - a route exposing the controller / view through Web
  - a model interfacing with database to store product favorited by user
  - a migration to create join table in database
  - a join table storing product\_id and user\_id
- **Showing All Products favorited by a User**
  - association in User to get favorite products
  - a View showing list of Favorite Products
  - a controller preparing the view
  - a route exposing    the controller / view through Web
- **Showing Users who favorited a particular Product**
  - association in Product to get users who favorited
  - a View showing list of Users who favorited
  - a controller preparing the view
  - a Route exposing the controller / view through Web
- Ability to test the integration of above mentioned requirements

**Let's break the above requirements into _two_ groups**

- Model layer changes
- Request layer changes

### Model Layer Changes

- Ability to mark and unmark a Product as favorite
  - a model interfacing with database to store product favorited by user
  - a migration to create join table in database
  - a join table storing product_id and user_id
- Showing All Products favorited by a User
  - association in  User to get favorite products
- Showing Users who favorited a particular Product
  - association in Product to get users who favorited

_**translates to**_

- Ability to mark and unmark a Product as favorite
  - **New Ecto Model** with user\_id and product\_id fields
  - **Ecto migration** to create join table storing product_id and user_id
- Showing All Products favorited by a User
  - **extending User schema** to have associations as needed
  - **support functions in User Model** to retrieve all products favorited by a user
- Showing Users who favorited a particular Product
  - **extending Product schema** to   have associations as needed
  - **support functions in Product Model** too retrieve all users who favorited a product


### Request Layer Changes

- Ability to mark and unmark a Product as favorite
  - a View probably showing all products with ability to mark/unmark product as favorite
  - a controller action preparing the view
  - a route exposing the controller / view    through Web
  - a controller action handling mark product as favorite
  - a route exposing the controller / view through Web
  - a controller action removing product from the list of favorites
  - a route exposing the controllerontroller / view through Web
- Showing All Products favorited by a User
  - a View showing list of Products
  - a controller preparing the view
  - already route exposing the controller / view through Web
- Showing Users who favorited a particular Product
  - a View showing list of Users
  - a controller preparing the view
  - a route exposing the controller / view through Web

_**translates to**_

- Ability to mark and unmark a Product as favorite
  - a **View** probably showing all products with ability to mark/unmark product as favorite
  - a **controller** with index / create / delete action
  - a **route** exposingposing index / create / delete action
- Showing All Products favorited by a User
  - a **View** showing list of Products
  - a **controller** preparing the viewew
  - a **route** exposing the controller / view through Web
- Showing Users who favorited a particular Product
  - a **View** showing list of  Users
  - a **controller** preparing the view
  - a **route** exposing throughe controller / view through Web

## What we need

- way to extend schema definitions for existing models
- way to add new functions in existing models
- way to add routes
- way to add controller / views for newly added routes
- way to extend views
- way to reuse layouts
- way to reuse already available routes

## How we attempt to solve

- Elixir Metaprogramming
- Elixir umbrella app dependencies to share and reuse code among Nectar & Extensions using ExtensionManager
- Extensions as Phoenix project leveraging NectarCommerce

## Bridging the Gap

**Next Posts** would refer the *Favorite Product Extension* to help co-relate and reveal the challenges & solutions implemented to propose an Extension framework.

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

We look forward for your support and feedback on [twitter](https://twitter.com/NectarCommerce) and [github](https://github.com/vinsol/nectarcommerce/pull/47)

_Enjoy the Elixir potion !!_
