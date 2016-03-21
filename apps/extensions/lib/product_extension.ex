defmodule SayHelloWorld do

  defmacro __using__(_opts) do
    quote do
	    def hello_world! do
        IO.puts "hello world!"
      end
    end
  end
end

defmodule ExtendProduct do
  def extend do
    quote do
      use SayHelloWorld
    end
  end
end

defmodule ExtendVariant do
  def extend do
    quote do
      use SayHelloWorld
    end
  end
end

defmodule LoadExtensions do
  defmacro __before_compile__(env) do
    # determine from env which model we want to extend
    # load all impls for extend#Module here
    # use SayHelloWorldInProduct
    module_to_extend = env.context_modules |> List.first |>  Module.split |> List.last
    try do
      apply(String.to_atom("Elixir.Extend" <> module_to_extend), :extend, [])
    after
      :ok
    end
  end
end
