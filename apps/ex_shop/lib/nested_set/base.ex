defmodule NestedSet.Base do

  import Ecto
  import Ecto.Query

  def descendants_count(model) do
    count = (model.rgt - model.lft )/2
    Float.floor(count) |> round
  end

  def descendants(model, opts \\ %{}) do
    descendants = _descendants(model)

    if(opts[:ordered] != false) do
      descendants = descendants
        |> ordered(opts[:order_by_field]) 
    end
    
    descendants
  end

  def ancestors(model, opts \\ %{}) do
    ancestors = _ancestors(model)
    
    if(opts[:ordered] != false) do
      ancestors = ancestors
        |> ordered(opts[:order_by_field]) 
    end
    
    ancestors    
  end

  def self_and_descendants(model) do
    _self_and_descendants(model)
  end

  def self_and_ancestors(model) do
    _self_and_ancestors(model)
  end   

  def ancestors_count(model, repo) do
    ancestors = _ancestors(model)
      |> repo.all

    length(ancestors)
  end  

  def self_and_siblings(model) do
    _self_and_siblings(model)
  end 

  def leaves(model) do
    _descendants(model)
      |> where(fragment("rgt - lft") == 1 ) 
  end  

  def recalculate_lft_rgt(root, repo, opts ) do
    # Load children
    children = get_children(root, opts[:order_by_field]) |> repo.all

    # Starting left counting with initial value passed(default 1). and prepare a map. This map would have left and right values for all nodes.
   
    model_map = %{last_used_count: opts[:lft]}
    {_last_used_count, model_map } = calculate_lft_rgt(root, children, repo, opts, model_map)
    model_map = Map.delete(model_map, :last_used_count)


    repo.transaction(fn ->
      Enum.map(model_map, fn(c_map) -> 
        {model_id, %{lft: lft, rgt: rgt} } = c_map

        model = repo.get_by(root.__struct__, id: model_id)
        changeset = root.__struct__.nested_set_changeset(model, %{lft: lft, rgt: rgt})

        case repo.update(changeset) do
          {:ok, _model} ->
            nil
          {:error, changeset} ->
            raise changeset.errors
        end  

      end)      
    end)
  end

  defp calculate_lft_rgt(node, [], repo, opts, model_map) do
    lft = model_map[:last_used_count]
    map = %{lft: lft, rgt: lft+1}

    # Update the last_used_count 
    model_map = Map.put(model_map, :last_used_count, lft+1)

    # update the model map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    updated_model_map = Map.put_new(model_map, node.id, map)
    {model_map[:last_used_count], updated_model_map}
  end

  defp calculate_lft_rgt(node, children, repo, opts, model_map) do
    # left value for the current node
    lft = model_map[:last_used_count]

    # MapReduce with the model_map, this model_map will be used as accumulator 
    {_ , updated_model_map} = 
      Enum.map_reduce(children, model_map, 
        fn(node, acc_map) ->
          # Find all sub categories for the current node
          children = get_children(node, opts[:order_by_field]) |> repo.all

          # Increase the last_used_count by 1, as the current one is already assigned to the node
          acc_map = Map.put(acc_map, :last_used_count, acc_map[:last_used_count] + 1)

          # Recursion
          calculate_lft_rgt(node, children, repo, opts, acc_map)
        end) 

    # Increment the last used count by one as the current one was already assigned to the right value of previous node  
    updated_model_map = Map.put(updated_model_map, :last_used_count, updated_model_map[:last_used_count] + 1)

    
    # update the model map which include node's lft right value like %{5 => %{lft: 5, rgt: 6}, last_used_count: 6}
    map = %{lft: lft, rgt: updated_model_map[:last_used_count] }
    updated_model_map = Map.put_new(updated_model_map, node.id, map)

    {updated_model_map[:last_used_count], updated_model_map}
  end
  


  defp ordered(query, field) do
    from c in query, order_by: ^field
  end

  def get_root_node(model) do
    model
      |> where([m], is_nil(m.parent_id)) 
  end

  defp get_children(model, order_by_field) do
    assoc(model, :children) 
      |> ordered(order_by_field) 
  end

  defp _descendants(model) do
    model.__struct__
      |> where([c], c.lft > ^model.lft  and c.rgt < ^model.rgt) 
  end

  defp _ancestors(model) do
    model.__struct__
      |> where([c], c.lft < ^model.lft  and c.rgt > ^model.rgt) 
  end  

  defp _self_and_descendants(model) do
    model.__struct__
      |> where([c], c.lft >= ^model.lft  and c.rgt <= ^model.rgt) 
  end  

  defp _self_and_ancestors(model) do
    model.__struct__
      |> where([c], c.lft <= ^model.lft  and c.rgt >= ^model.rgt) 
  end 

  defp _self_and_siblings(model) do
    model.__struct__
      |> where([c], c.parent_id == ^model.parent_id) 
  end 

end