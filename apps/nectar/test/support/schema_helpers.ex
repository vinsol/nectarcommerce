defmodule Nectar.Test.SchemaHelpers do

  def timestamps, do: ~w(inserted_at updated_at)a

  defmacro has_associations(model, assocs) do
    quote bind_quoted: [assocs: assocs, model: model] do
      test "has association count #{ Enum.count assocs }" do
        assert (Enum.count unquote(model).__schema__(:associations)) == (Enum.count unquote(assocs))
      end
      for assoc <- assocs do
        test "has association #{ assoc }" do
          assert Enum.member? unquote(model).__schema__(:associations), unquote(assoc)
        end
      end
    end
  end

  defmacro has_fields(model, fields) do
    quote bind_quoted: [fields: fields, model: model] do
      test "has field count #{ Enum.count fields }" do
        assert (Enum.count unquote(model).__schema__(:fields)) == (Enum.count unquote(fields))
      end
      for field <- fields do
        test "has defined field #{ field }" do
          assert Enum.member? unquote(model).__schema__(:fields), unquote(field)
        end
      end
    end
  end

  # TODO: Provide custom messages in case of assertion failure

  defmacro belongs_to?(model, assoc, via: via) do
    quote bind_quoted: [model: model, assoc: assoc, to: via] do
      test "#{inspect(model)} belongs to #{ assoc } via: #{ inspect(to) }" do
        assoc_struct = unquote(model).__schema__(:association, unquote(assoc))
        if assoc_struct do
          assert assoc_struct.__struct__ ==  Ecto.Association.BelongsTo
          assert assoc_struct.related    ==  unquote(to)
        else
          flunk "association not found"
        end
      end
    end
  end

  defmacro has_many?(model, assoc, via: via) do
    quote bind_quoted: [model: model, assoc: assoc, to: via] do
      test "#{inspect(model)} has many #{ assoc } via: #{ inspect(to) }" do
        assoc_struct = unquote(model).__schema__(:association, unquote(assoc))
        if assoc_struct do
          assert assoc_struct.__struct__  ==  Ecto.Association.Has
          assert assoc_struct.related     ==  unquote(to)
          assert assoc_struct.cardinality ==  :many
        else
          flunk "association not found"
        end
      end
    end
  end

  defmacro has_many?(model, assoc, through: through) do
    quote bind_quoted: [model: model, assoc: assoc, to: through] do
      test "#{inspect(model)} has many #{ assoc } through: #{ inspect(to) }" do
        assoc_struct = unquote(model).__schema__(:association, unquote(assoc))
        if assoc_struct do
          assert assoc_struct.__struct__  ==  Ecto.Association.HasThrough
          assert assoc_struct.through     ==  unquote(to)
          assert assoc_struct.cardinality ==  :many
        else
          flunk "association not found"
        end
      end
    end
  end

  defmacro has_one?(model, assoc, via: via) do
    quote bind_quoted: [model: model, assoc: assoc, to: via] do
      test "#{inspect(model)} has one #{ assoc } via: #{ inspect(to) }" do
        assoc_struct = unquote(model).__schema__(:association, unquote(assoc))
        if assoc_struct do
          assert assoc_struct.__struct__  ==  Ecto.Association.Has
          assert assoc_struct.related     ==  unquote(to)
          assert assoc_struct.cardinality ==  :one
        else
          flunk "association not found"
        end
      end
    end
  end

  defmacro has_one?(model, assoc, through: through) do
    quote bind_quoted: [model: model, assoc: assoc, to: through] do
      test "#{inspect(model)} has one #{ assoc } through: #{ inspect(to) }" do
        assoc_struct = unquote(model).__schema__(:association, unquote(assoc))
        if assoc_struct do
          assert assoc_struct.__struct__  ==  Ecto.Association.HasThrough
          assert assoc_struct.through     ==  unquote(to)
          assert assoc_struct.cardinality ==  :one
        else
          flunk "association not found"
        end
      end
    end
  end

end
