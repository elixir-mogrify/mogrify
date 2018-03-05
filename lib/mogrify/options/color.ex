defmodule Mogrify.Options.Color do
  alias Mogrify.Option

  @known_options %{
    gamma:                    %Option{name: "-gamma", require_arg: true},
    plus_gamma:               %Option{name: "+gamma", require_arg: true},
  }

  require Mogrify.Options.Helpers
  Mogrify.Options.Helpers.option_functions(@known_options)
end
