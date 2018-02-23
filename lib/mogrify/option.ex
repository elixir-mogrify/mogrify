defmodule Mogrify.Option do
  @moduledoc false

  @type name        :: binary
  @type argument    :: binary | nil
  @type require_arg :: boolean

  @type t :: %__MODULE__{
    name:        name,
    argument:    argument,
    require_arg: require_arg,
  }

  defstruct name:        nil,
            argument:    nil,
            require_arg: false

end
