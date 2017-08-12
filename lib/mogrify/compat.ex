defmodule Mogrify.Compat do
  @moduledoc false

  def rand_uniform(high) do
    Code.ensure_loaded(:rand)
    if function_exported?(:rand, :uniform, 1) do
      :rand.uniform(high)
    else
      # Erlang/OTP < 19
      apply(:crypto, :rand_uniform, [1, high])
    end
  end

end