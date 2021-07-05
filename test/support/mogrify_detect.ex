defmodule Mogrify.Detect do
  @spec has_imagemagick?() :: boolean()
  def has_imagemagick?() do
    "convert"
    |> System.find_executable()
    |> is_nil()
    |> Kernel.!()
  end

  @spec has_pango?() :: boolean()
  def has_pango?() do
    {version, _} = System.cmd("convert", ["version"])
    String.contains?(version, "pangocairo")
  rescue
    _ -> false
  end

  @spec has_plasma?() :: boolean()
  def has_plasma?() do
    {version, _} = System.cmd("convert", ["version"])
    [version_number] = Regex.run(~r/\d\.\d\.\d+-\d+/, String.split(version, "\n") |> hd())
    Version.parse!(version_number).major > 6
  rescue
    _ -> false
  end
end
