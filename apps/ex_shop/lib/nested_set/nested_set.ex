require IEx
require NestedSet.Base
defmodule NestedSet do
  
  defmacro __using__(options) do
    quote do

      options = unquote(options)

      if (options[:model] == nil)  do
        raise "Please specify model name  like: \"use NestedSet, model: MyApp.MyModel, order_by_field: :name\" "
      else
        @model options[:model]
      end
      
      if (options[:order_by_field] == nil)  do
        @order_by_field :id
      else
        @order_by_field options[:order_by_field]
      end

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Then get the descendents_count by:
            ExShop.Category.descendents_count(model) #=> 3
      """
      def descendants_count(model) do
        NestedSet.Base.descendants_count(model)
      end

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the descendants ordered by default field by:
            ExShop.Category.descendants(model)

            # Get the descendants ordered by default field by other field like id:
            ExShop.Category.descendants(model, %{order_by_field: :id})

            # Get the unordered descendants 
            ExShop.Category.descendants(model, %{ordered: :false})
      """
      def descendants(model, opts \\ %{}) do
        default_opts = %{order_by_field: @order_by_field}
        options = Map.merge(default_opts, opts)
        NestedSet.Base.descendants(model, options)
      end

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the ancestors ordered by default field by:
            ExShop.Category.ancestors(model)

            # Get the ancestors ordered by default field by other field like id:
            ExShop.Category.ancestors(model, %{order_by_field: :id})

            # Get the unordered ancestors 
            ExShop.Category.ancestors(model, %{ordered: :false})
          """  
      def ancestors(model, opts \\ %{}) do
        default_opts = %{order_by_field: @order_by_field}
        options = Map.merge(default_opts, opts)
        NestedSet.Base.ancestors(model, options)  
      end

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the self_and_descendants by:
            ExShop.Category.self_and_descendants(model)

      """
      def self_and_descendants(model) do
        NestedSet.Base.self_and_descendants(model)
      end

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the self_and_ancestors by:
            ExShop.Category.self_and_ancestors(model)

      """
      def self_and_ancestors(model) do
        NestedSet.Base.self_and_ancestors(model)
      end   

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the ancestors_count by:
            ExShop.Category.ancestors_count(model, ExShop.Repo)

      """
      def ancestors_count(model, repo) do
        NestedSet.Base.ancestors_count(model, repo)
      end  

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the self_and_siblings by:
            ExShop.Category.self_and_siblings(model)

      """
      def self_and_siblings(model) do
        NestedSet.Base.self_and_siblings(model)
      end 

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Get the leaves by:
            ExShop.Category.leaves(model)

      """
      def leaves(model) do
        NestedSet.Base.leaves(model)
      end  

      @doc """
            # First get the model by:
            model = ExShop.Repo.get_by(ExShop.Category, id: 35)

            # Recalculate lft and rgt values for tree, or sub tree by passing node and the lft value(default 1) of the node
            ExShop.Category.recalculate_lft_rgt(model, ExShop.Repo)
            ExShop.Category.recalculate_lft_rgt(model, ExShop.Repo, %{order_by_field: :name, lft: 5})

      """
      def recalculate_lft_rgt(root, repo, opts \\ %{} ) do
        default_opts = %{order_by_field: @order_by_field, lft: 1}
        options = Map.merge(default_opts, opts)
        NestedSet.Base.recalculate_lft_rgt(root, repo, options)
      end
      
      @doc """
            Get root node:
            ExShop.Category.get_root_node()
      """
      def get_root_node do
        NestedSet.Base.get_root_node(@model)
      end

    end
  end
end