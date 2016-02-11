defmodule NestedSet.Category do

  alias ExShop.Repo
  alias ExShop.Category
  
  # import Ecto
  import Ecto.Query


  def recalculate_lft_rgt do
    # Find the root node
    root = 
      Category 
        |> where(parent_id: 0) 
        |> Repo.one
    
    # Load sub categories
    sub_categories = Category.sub_categories(root) |> Repo.all

    # Starting left counting with 1. and prepare a map. This map would have left and right values for all nodes.
    category_map = %{last_used_count: 1}

    {_last_used_count, category_map } = calculate_lft_rgt(root, sub_categories, category_map)
    category_map = Map.delete(category_map, :last_used_count)


    Repo.transaction(fn ->
      Enum.map(category_map, fn(c_map) -> 
        {cat_id, %{lft: lft, rgt: rgt} } = c_map
        IO.puts "id: #{cat_id}, lft: #{lft}, rgt: #{rgt}"

        category = Repo.get_by(Category, id: cat_id)
        changeset = Category.nested_set_changeset(category, %{lft: lft, rgt: rgt})

        case Repo.update(changeset) do
          {:ok, _category} ->
            nil
          {:error, changeset} ->
            raise changeset.errors
        end  


      end)      
    end)


  end

  defp calculate_lft_rgt(node, [], category_map) do
    lft = category_map[:last_used_count]
    map = %{lft: lft, rgt: lft+1}

    # Update the last_used_count 
    category_map = Map.put(category_map, :last_used_count, lft+1)

    # update the category map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    updated_category_map = Map.put_new(category_map, node.id, map)
    {category_map[:last_used_count], updated_category_map}
  end

  defp calculate_lft_rgt(node, children, category_map) do
    # left value for the current node
    lft = category_map[:last_used_count]

    # MapReduce with the category_map, this category_map will be used as accumulator 
    {_ , updated_category_map} = 
      Enum.map_reduce(children, category_map, 
        fn(node, acc_map) ->
          # Find all sub categories for the current node
          sub_categories = Category.sub_categories(node) |> Repo.all

          # Increase the last_used_count by 1, as the current one is already assigned to the node
          acc_map = Map.put(acc_map, :last_used_count, acc_map[:last_used_count] + 1)

          # Recursion
          calculate_lft_rgt(node, sub_categories, acc_map)
        end) 

    # Increment the last used count by one as the current one was already assigned to the right value of previous node  
    updated_category_map = Map.put(updated_category_map, :last_used_count, updated_category_map[:last_used_count] + 1)

    
    # update the category map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    map = %{lft: lft, rgt: updated_category_map[:last_used_count] }
    updated_category_map = Map.put_new(updated_category_map, node.id, map)

    {updated_category_map[:last_used_count], updated_category_map}
  end
  
end