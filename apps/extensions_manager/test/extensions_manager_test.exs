defmodule ExtensionManager.Test do
  use ExUnit.Case

  defmodule SimpleModelExtension do
    use ExtensionsManager.ModelExtension

    add_to_schema(:field, :injected, :string, [])
    include_method do
      def inject_method do
        :injected_value
      end
    end
  end
  defmodule SimpleModel do
    use SimpleModelExtension
    use Ecto.Schema

    schema "source" do
      field :name
      extensions
    end
  end

  test "adds fields to the model" do
    assert SimpleModel.__schema__(:fields) == [:id, :name, :injected]
  end

  test "adds the methods to the model" do
    assert (Keyword.has_key? SimpleModel.__info__(:functions), :inject_method)
  end

  test "injected method is callable from the module" do
    assert SimpleModel.inject_method == :injected_value
  end

  test "captures schema changes" do
    assert SimpleModelExtension.schema_changes == [{:field, :injected, :string, []}]
  end

  test "captures method declarations" do
    # !!NOTE: test will break if line number of inject_method changes
    assert SimpleModelExtension.method_blocks == [[do: {:def, [line: 9], [{:inject_method, [line: 9], nil}, [do: :injected_value]]}]]
  end

end
