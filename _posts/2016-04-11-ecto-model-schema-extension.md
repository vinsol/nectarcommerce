---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Ecto Model Schema Extension
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
1. [NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)
1. Extension Framework Game Plan
1. Introduction to Writing Macros
1. Running Multiple Phoenix Apps Together
1. **Ecto Model Schema Extension**
1. Ecto Model Functions Extension
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

# Ecto Model Schema Extension

### Why

We want to allow Extensions to modify schema of existing Nectar Models without changing the Nectar Models.

Extensions should be able to add new fields and associations to existing models as needed for the cause.

### How

There are three parts needed at minimium to create & use an extension effectively:

- Library Code
- Service Code
- Consumer Code

An extension and its use with Nectar can be viewed as Producer / Consumer relationship bound by a communication protocol.

**Extension** which want to add a virtual field, say special, to Nectar Product Model Schema is a **Producer (Service Code)**.

**Nectar Model** is a **Consumer (Consumer Code)** allowing the schema changes through a **communication protocol (Library Code)**

Let's begin the journey of incremental changes to bring consumer, service and library code into existence starting from a simple use-case of adding a virtual boolean field, say special to Nectar Product.

>
Note: Please refer [Introduction to Writing Macros]() for more information on Metaprogramming in Elixir

1.  Straightforward way to add virtual field, say special, to Nectar Product would be to add it directly in Nectar.Product Schema definition, see diff [here](https://github.com/vinsol/nectarcommerce/compare/aa204e2f83cc68d6683222613f6eb1dea984a88e...87018127fc9fd2e04d22faaa103fb55159ef7789), but it requires change in Nectar source. Let's move to next step for the workaround to avoid modification to Nectar.Product

    ```elixir
    defmodule Nectar.Product do
      schema do
        field :special, :boolean, virtual: true
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  We can add a function to Nectar Model Schema to which other extensions can delegate the reponsibility of schema changes, see diff [here](https://github.com/vinsol/nectarcommerce/compare/87018127fc9fd2e04d22faaa103fb55159ef7789...2defb7c2bd6ddaf3afac2c10d9c3f1ac42aa280f). See Nectar.ExtendProduct example below on how to use it.

    ```elixir
    defmodule Nectar.ExtendProduct do
      defmacro extensions do
        quote do
          field :special, :boolean, virtual: true
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  Now, with delegation function `extensions` in place, we can work towards providing a way to register the schema changes, see diff [here](https://github.com/vinsol/nectarcommerce/compare/2defb7c2bd6ddaf3afac2c10d9c3f1ac42aa280f...84fd1b898c60d104ce80b8e2a6903feed965ce3a). Please check the usage of Module attributes for same below.


    ```elixir
    defmodule Nectar.ExtendProduct do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      Module.put_attribute(__MODULE__, :schema_changes, quote do: (field :special, :boolean, virtual: true))

      defmacro extensions do
        @schema_changes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  Earlier, Module.put_attribute need to be used multiple times to define multiple routes instead we wrapped it in an anonymous function to encapsulate the collection of schema changes through a simple and consistent interface, see diff [here](https://github.com/vinsol/nectarcommerce/compare/84fd1b898c60d104ce80b8e2a6903feed965ce3a...f75a8e735428d70341a0b54b7598eb178c7bfaa8). There can be multiple extensions used for different functionality and hence multiple schema changes need to be registered and defined

    ```elixir
    defmodule Nectar.ExtendProduct do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      add_to_schema = fn(schema_change) -> Module.put_attribute(__MODULE__, :schema_changes, schema_change) end

      add_to_schema.(quote do: (field :special, :boolean, virtual: true))

      defmacro extensions do
        @schema_changes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  Now, Nectar.ExtendProduct is getting cluttered with ancillary method definitions, lets move it out to another module and use it, see diff [here](https://github.com/vinsol/nectarcommerce/compare/f75a8e735428d70341a0b54b7598eb178c7bfaa8...34bdea55da6fd7a4de545de0a49d966e56f62234)

    ```elixir
    defmodule Nectar.ModelExtension do
      defmacro add_to_schema([do: block]) do
        schema_change = Macro.escape(block)
        quote bind_quoted: [schema_change: schema_change] do
          Module.put_attribute(__MODULE__, :schema_changes, schema_change)
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendProduct do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      import Nectar.ModelExtension, only: [add_to_schema: 1]

      add_to_schema do: (field :special, :boolean, virtual: true)

      defmacro extensions do
        @schema_changes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```


1.  Let's further reduce the boilerplate of registering schema_changes module attribute and importing include_method method definition with __using__ callback, see diff [here](https://github.com/vinsol/nectarcommerce/compare/34bdea55da6fd7a4de545de0a49d966e56f62234...3324f663fb176397946169b8410f3a3e39c4b92d)

    ```elixir
    defmodule Nectar.ModelExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
          import Nectar.ModelExtension, only: [add_to_schema: 1]
        end
      end

      defmacro add_to_schema([do: block]) do
        schema_change = Macro.escape(block)
        quote bind_quoted: [schema_change: schema_change] do
          Module.put_attribute(__MODULE__, :schema_changes, schema_change)
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendProduct do
      use Nectar.ModelExtension

      add_to_schema do: (field :special, :boolean, virtual: true)

      defmacro extensions do
        @schema_changes
      end
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  Reference of schema_changes Module attribute is scattered across Nectar.ExtendProduct and Nectar.ModelExtension so lets move it out to Nectar.ModelExtension to consolidate the usage via `__before_compile__` and definition together, see diff [here](https://github.com/vinsol/nectarcommerce/compare/3324f663fb176397946169b8410f3a3e39c4b92d...707ba035ed278b6218f77a7904f21aee1ec0bfe7)

    ```elixir
    defmodule Nectar.ModelExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
          import Nectar.ModelExtension, only: [add_to_schema: 1]
          @before_compile Nectar.ModelExtension
        end
      end

      defmacro add_to_schema([do: block]) do
        schema_change = Macro.escape(block)
        quote bind_quoted: [schema_change: schema_change] do
          Module.put_attribute(__MODULE__, :schema_changes, schema_change)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          defmacro extensions do
            @schema_changes
          end
        end
      end
    end
    ```

    ```elixir
    defmodule Nectar.ExtendProduct do
      use Nectar.ModelExtension

      add_to_schema do: (field :special, :boolean, virtual: true)
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      import Nectar.ExtendProduct

      schema do
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```

1.  With above changes, it's now possible to define schema changes any number of times needed, see diff [here](https://github.com/vinsol/nectarcommerce/compare/27f7444a83819d22ab0655d3fa2b0501d98da90f...07384f21052282ac706d091aead260e906afc19c). Also, schema changes can now be added using `include_method` in Nectar.ExtendProduct without making any changes to Nectar.Product. 


    ```elixir
    ## Library Code
    ## Defines DSL to be used by Service Code
    ## in order to get properly consumed by Consumer
    defmodule Nectar.ModelExtension do
      defmacro __using__(_opts) do
        quote do
          Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
          import Nectar.ModelExtension, only: [add_to_schema: 1]
          @before_compile Nectar.ModelExtension
        end
      end

      # Part of Schema Addition DSL
      defmacro add_to_schema([do: block]) do
        schema_change = Macro.escape(block)
        quote bind_quoted: [schema_change: schema_change] do
          Module.put_attribute(__MODULE__, :schema_changes, schema_change)
        end
      end

      defmacro __before_compile__(_env) do
        quote do
          defmacro extensions do
            @schema_changes
          end
        end
      end
    end
    ```

    ```elixir
    ## Service Code
    defmodule Nectar.ExtendProduct do
      ## Makes DSL available defined in library code
      use Nectar.ModelExtension

      add_to_schema do: (field :special, :boolean, virtual: true)
      add_to_schema do: (field :type, :string, virtual: true)
    end
    ```

    ```elixir
    defmodule Nectar.Product do
      ## Make Service Code available to be consumed
      ## through Library Code
      import Nectar.ExtendProduct

      schema do
        ## Service Consumer Code
        extensions
      end

      ## Add #special boolean to get casted
      def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, ~w(special))
      end
    end
    ```

    ```bash
    nectarcommerce ~/elixir$ iex -S mix
    ## File Compilation Removed
    iex(4)> a = Nectar.Product.changeset(%Nectar.Product{}, %{}); a.model.special;
    nil
    iex(5)> b = Ecto.Changeset.put_change(a, :special, true); b.changes.special;
    true
    ```


Now, in the last version, you can easily find the three components, _consumer, service and library code_, as desired in extensible system

_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
