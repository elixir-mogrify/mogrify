defmodule Mogrify.Options.Helpers do
  @moduledoc false

  defmacro option_functions(options_map) do
    quote bind_quoted: [options_map: options_map] do
      Enum.each options_map, fn {k, v} ->
        function_name = String.to_atom("option_" <> Atom.to_string(k))
        def unquote(function_name)(), do: unquote(Macro.escape(v))
        def unquote(function_name)(argument), do: Map.put(unquote(Macro.escape(v)), :argument, argument)
      end
    end
  end

end
