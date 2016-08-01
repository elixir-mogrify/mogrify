defmodule Mogrify.Image do
  defstruct path: nil,
            ext: nil,
            format: nil,
            width: nil,
            height: nil,
            animated: false,
            operations: [],
            dirty: %{}
end
