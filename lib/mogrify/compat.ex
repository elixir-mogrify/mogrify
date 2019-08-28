defmodule Mogrify.Compat do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      Code.ensure_loaded(Kernel.SpecialForms)
      if not macro_exported?(Kernel.SpecialForms, :__STACKTRACE__, 0) do
        def __STACKTRACE__, do: System.stacktrace()
      end
    end
  end

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
