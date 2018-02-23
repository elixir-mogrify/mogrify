defmodule Mogrify.Options do
  defmacro __using__(_) do
    quote do
      import Mogrify.Options.Transform
    end
  end
end
