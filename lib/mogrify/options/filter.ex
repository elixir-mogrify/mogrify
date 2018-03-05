defmodule Mogrify.Options.Filter do
  alias Mogrify.Option

  @known_options %{
    gaussian_blur:          %Option{name: "-gaussian-blur", require_arg: true},
  }

  require Mogrify.Options.Helpers
  Mogrify.Options.Helpers.option_functions(@known_options)
end
