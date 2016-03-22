defmodule Extensions do
  defmacro __using__(opts) do
    # determine from env which model we want to extend
    # load all impls for extend#Module here
    # use SayHelloWorldInProduct
    useable_module = infer_module_from_caller(__CALLER__)
    IO.puts "Importing #{useable_module} in #{__CALLER__.module}"
    quote do
      use unquote(useable_module)
    end
  end

  def infer_module_from_caller(caller) do
    module_to_extend = caller.module |> Module.split |> List.last
    module_name = String.to_atom("Elixir.Extend" <> module_to_extend)
    if Code.ensure_loaded?(module_name) do
      apply(module_name, :__info__, [:module])
    else
      apply(DefaultExtend, :__info__, [:module])
    end
  end
end
