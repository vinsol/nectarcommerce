defmodule Extensions do
  defmacro __using__(opts) do
    # determine from env which model we want to extend
    # load all impls for extend#Module here
    # use SayHelloWorldInProduct
    module_to_extend = __CALLER__.module |>  Module.split |> List.last
    module_name = String.to_atom("Elixir.Extend" <> module_to_extend)
    quote do
      use unquote(module_name)
    end
  end
end
