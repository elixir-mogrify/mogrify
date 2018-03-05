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

  def string_trim(string) do
    Code.ensure_loaded(String)
    if function_exported?(String, :trim, 1) do
      String.trim(string)
    else
      # Elixir < 1.3
      apply(String, :strip, [string])
    end
  end

end