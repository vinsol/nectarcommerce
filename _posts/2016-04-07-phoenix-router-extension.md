---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Phoenix Router Extension
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Pikender'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

>
The post belongs to NectarCommerce and Extension Framework Awareness
>
1. NectarCommerce Vision
1. Extension Framework Game Plan
1. Introduction to Writing Macros
1. Running Multiple Phoenix Apps Together
1. Ecto Model Extension
1. **Phoenix Router Extension**
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

NectarCommerce is committed to provide a ready-to-use e-commerce solution but definition of 100% is different under different business domains.

NectarCommerce aims to solve common use-cases as part of the project and relying on extension framework to tap the rest.

# Phoenix Router Extension

### Why

We want to allow Extensions to add routes into Nectar Router without modifying the Nectar Router source.

### How

Here is the walkthrough of incremental code changes, we made to develop RouterExtension Module and Macros to facilitate Route Additions in Nectar without modifying NectarRouter.

>
Note: Please refer [Introduction to Writing Macros]() for more information on Metaprogramming in Elixir

1.  Straightforward way to add favorites route in Nectar.Router would be to add it directly in Nectar.Router, see  diff [here](https://github.com/vinsol/nectarcommerce/compare/aa204e2f83cc68d6683222613f6eb1dea984a88e...475e0ae3136fae055605d1c1277c48c4bff611b1), but it requires change in Nectar source. Let's move to next step for the workaround to avoid modification to Nectar.Router

    ```elixir
    defmodule Nectar.Router do
      get "/favorites", FavoriteProducts.FavoriteController, :index
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  We can add a function to Nectar to which other extensions can delegate the responsibility of route additions, see diff [here](https://github.com/vinsol/nectarcommerce/compare/475e0ae3136fae055605d1c1277c48c4bff611b1...c16ecea1960a5d6a01770079b01837fa67be32f9). See Nectar.ExtendRouter example below on how to use it

    ```elixir
    defmodule Nectar.ExtendRouter do
      defmacro mount do
        quote do
          get "/favorites", FavoriteProducts.FavoriteController, :index
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  Now, with delegation function `mount` in place, we can work towards providing a way to register the routes to be added, see diff [here](https://github.com/vinsol/nectarcommerce/compare/c16ecea1960a5d6a01770079b01837fa67be32f9...f0f3b4e0600ca8d5b965c65005250fc8bb3b9a62). Please check the usage of Module attributes for same below.

    ```elixir
    defmodule Nectar.ExtendRouter do
      Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)
      Module.put_attribute(__MODULE__, :defined_routes, quote do: (get "/favorites", FavoriteProducts.FavoriteController, :index))

      defmacro mount do
        @defined_routes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  Earlier, Module.put_attribute need to be used multiple times to define multiple routes instead we wrapped it in an anonymous function to encapsulate the collection of routes through a simple and consistent interface, see diff [here](https://github.com/vinsol/nectarcommerce/compare/f0f3b4e0600ca8d5b965c65005250fc8bb3b9a62...e694be7f9614c8da61834f5276214fa3302a21a7). There can be multiple extensions used for different functionality and hence multiple routes need to be registered and defined

    ```elixir
    defmodule Nectar.ExtendRouter do
      Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)
      define_route = fn (route) -> Module.put_attribute(__MODULE__, :defined_routes, route) end

      define_route.(quote do: get "/favorites", FavoriteProducts.FavoriteController, :index)

      defmacro mount do
        @defined_routes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```


1.  Now, Nectar.ExtendRouter is getting cluttered with ancillary method definitions, lets move it out to another module and use it, see diff [here](https://github.com/vinsol/nectarcommerce/compare/e694be7f9614c8da61834f5276214fa3302a21a7...8e28323a2f22a58238179dac1ff6ec6078181bbf)

    ```elixir
    defmodule Nectar.RouterExtension do
      defmacro define_route([do: block]) do
        route = Macro.escape(block)
        quote bind_quoted: [route: route] do
          Module.put_attribute(__MODULE__, :defined_routes, route)
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendRouter do
      Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)

      import Nectar.RouterExtension, only: [define_route: 1]

      define_route do: get "/favorites", FavoriteProducts.FavoriteController, :index

      defmacro mount do
        @defined_routes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  Let's further reduce the boilerplate of registering defined_routes module attribute and importing define_route method definition with __using__ callback, see diff [here](https://github.com/vinsol/nectarcommerce/compare/8e28323a2f22a58238179dac1ff6ec6078181bbf...de4c555dcc8a76fcdd11825f8a38ede60d2e3276)

    ```elixir
    defmodule Nectar.RouterExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)

          import Nectar.RouterExtension, only: [define_route: 1]
        end
      end

      defmacro define_route([do: block]) do
        route = Macro.escape(block)
        quote bind_quoted: [route: route] do
          Module.put_attribute(__MODULE__, :defined_routes, route)
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendRouter do
      use Nectar.RouterExtension

      define_route do: get "/favorites", FavoriteProducts.FavoriteController, :index

      defmacro mount do
        @defined_routes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  Reference of defined_routes Module attribute is scattered across Nectar.RouterExtender and Nectar.RouterExtension so lets move it out to Nectar.RouterExtension to consolidate the usage via `__before_compile__` and definition together, see diff [here](https://github.com/vinsol/nectarcommerce/compare/de4c555dcc8a76fcdd11825f8a38ede60d2e3276...27f7444a83819d22ab0655d3fa2b0501d98da90f)

    ```elixir
    defmodule Nectar.RouterExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)

          import Nectar.RouterExtension, only: [define_route: 1]
          @before_compile Nectar.RouterExtension
        end
      end

      defmacro define_route([do: block]) do
        route = Macro.escape(block)
        quote bind_quoted: [route: route] do
          Module.put_attribute(__MODULE__, :defined_routes, route)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          defmacro mount do
            @defined_routes
          end
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendRouter do
      use Nectar.RouterExtension

      define_route do: get "/favorites", FavoriteProducts.FavoriteController, :index
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
    ```

1.  With above changes, it's now possible to define routes any number of times needed, see diff [here](https://github.com/vinsol/nectarcommerce/compare/27f7444a83819d22ab0655d3fa2b0501d98da90f...07384f21052282ac706d091aead260e906afc19c). Also, routes can now be added using `define_route` in Nectar.ExtendRouter without making any changes to Nectar.Router. Mission accomplished !!

    ```elixir
    defmodule Nectar.RouterExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :defined_routes, accumulate: true)

          import Nectar.RouterExtension, only: [define_route: 1]
          @before_compile Nectar.RouterExtension
        end
      end

      defmacro define_route([do: block]) do
        route = Macro.escape(block)
        quote bind_quoted: [route: route] do
          Module.put_attribute(__MODULE__, :defined_routes, route)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          defmacro mount do
            @defined_routes
          end
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendRouter do
      use Nectar.RouterExtension

      define_route do: get "/favorites", FavoriteProducts.FavoriteController, :index
      define_route do: post "/favorites", FavoriteProducts.FavoriteController, :create
    end
    ```

    ```elixir
    defmodule Nectar.Router do
      # get "/favorites", FavoriteProducts.FavoriteController, :index
      require Nectar.ExtendRouter
      Nectar.ExtendRouter.mount
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ mix phoenix.routes Nectar.Router | grep Favorite
       favorite_path  GET  /favorites  FavoriteProducts.FavoriteController :index
       favorite_path  POST  /favorites  FavoriteProducts.FavoriteController :create
    ```

_Enjoy the Elixir potion !!_
