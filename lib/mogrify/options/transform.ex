defmodule Mogrify.Options.Transform do
  alias Mogrify.Option

  @known_options %{
    rotate:                    %Option{name: "-rotate", require_arg: true},
  }

  require Mogrify.Options.Helpers
  Mogrify.Options.Helpers.option_functions(@known_options)
end
