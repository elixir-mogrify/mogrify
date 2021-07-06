defmodule Mogrify.Detect do
  @spec has_imagemagick?() :: boolean()
  def has_imagemagick?() do
    {_, exit_code} = Mogrify.cmd_convert(["-version"], [])
    exit_code == 0
  end

  @spec has_pango?() :: boolean()
  def has_pango?() do
    {version, _} = Mogrify.cmd_convert(["-version"], [])
    String.contains?(version, "pangocairo")
  rescue
    _ -> false
  end

  @spec has_plasma?() :: boolean()
  def has_plasma?() do
    {version, _} = Mogrify.cmd_convert(["-version"], [])
    [version_number] = Regex.run(~r/\d\.\d\.\d+-\d+/, String.split(version, "\n") |> hd())
    Version.parse!(version_number).major > 6
  rescue
    _ -> false
  end
end
