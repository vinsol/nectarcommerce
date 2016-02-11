defmodule NestedSet.Category do

  import Ecto
  import Ecto.Query

  alias ExShop.Repo
  
  @model ExShop.Category


  def recalculate_lft_rgt do
    # Find the root node
    root = get_root_node
    
    # Load children
    children = get_children(root) |> Repo.all

    # Starting left counting with 1. and prepare a map. This map would have left and right values for all nodes.
    model_map = %{last_used_count: 1}

    {_last_used_count, model_map } = calculate_lft_rgt(root, children, model_map)
    model_map = Map.delete(model_map, :last_used_count)


    Repo.transaction(fn ->
      Enum.map(model_map, fn(c_map) -> 
        {cat_id, %{lft: lft, rgt: rgt} } = c_map
        IO.puts "id: #{cat_id}, lft: #{lft}, rgt: #{rgt}"

        category = Repo.get_by(@model, id: cat_id)
        changeset = @model.nested_set_changeset(category, %{lft: lft, rgt: rgt})

        case Repo.update(changeset) do
          {:ok, _model} ->
            nil
          {:error, changeset} ->
            raise changeset.errors
        end  


      end)      
    end)


  end

  defp calculate_lft_rgt(node, [], model_map) do
    lft = model_map[:last_used_count]
    map = %{lft: lft, rgt: lft+1}

    # Update the last_used_count 
    model_map = Map.put(model_map, :last_used_count, lft+1)

    # update the model map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    updated_model_map = Map.put_new(model_map, node.id, map)
    {model_map[:last_used_count], updated_model_map}
  end

  defp calculate_lft_rgt(node, children, model_map) do
    # left value for the current node
    lft = model_map[:last_used_count]

    # MapReduce with the model_map, this model_map will be used as accumulator 
    {_ , updated_model_map} = 
      Enum.map_reduce(children, model_map, 
        fn(node, acc_map) ->
          # Find all sub categories for the current node
          children = get_children(node) |> Repo.all

          # Increase the last_used_count by 1, as the current one is already assigned to the node
          acc_map = Map.put(acc_map, :last_used_count, acc_map[:last_used_count] + 1)

          # Recursion
          calculate_lft_rgt(node, children, acc_map)
        end) 

    # Increment the last used count by one as the current one was already assigned to the right value of previous node  
    updated_model_map = Map.put(updated_model_map, :last_used_count, updated_model_map[:last_used_count] + 1)

    
    # update the category map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    map = %{lft: lft, rgt: updated_model_map[:last_used_count] }
    updated_model_map = Map.put_new(updated_model_map, node.id, map)

    {updated_model_map[:last_used_count], updated_model_map}
  end
  


  defp ordered(query, field) do
    from c in query, order_by: ^field
  end

  defp get_children(model) do
    assoc(model, :children) 
      |> ordered(:name) 
  end

  defp get_root_node do
    @model 
      |> where(parent_id: 0) 
      |> Repo.one
  end

end