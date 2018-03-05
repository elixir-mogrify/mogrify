defmodule Mogrify.Options do
  defmacro __using__(_) do
    quote do
      import Mogrify.Options.Transform
      import Mogrify.Options.Color
      import Mogrify.Options.Filter
    end
  end
end
