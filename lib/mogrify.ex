defmodule Mogrify do
  alias Mogrify.Image

  def open(path) do
    path = Path.expand(path)
    unless File.regular?(path), do: raise(File.Error)

    %Image{path: path, ext: Path.extname(path)}
  end

  def save(image, path) do
    File.cp!(image.path, path)
    %{image | path: path}
  end

  def copy(image) do
    name = Path.basename(image.path)
    random = :crypto.rand_uniform(100_000, 999_999)
    temp = Path.join(System.tmp_dir, "#{random}-#{name}")
    File.cp!(image.path, temp)
    Map.put(image, :path, temp)
  end

  def verbose(image) do
    {output, 0} = run(image.path, "verbose")
    info = Regex.named_captures(~r/\S+ (?<format>\S+) (?<width>\d+)x(?<height>\d+)/, output)
    info = Enum.reduce(info, %{}, fn ({key, value}, acc) ->
      {key, value} = {String.to_atom(key), String.downcase(value)}
      Map.put(acc, key, value)
    end)
    Map.merge(image, info)
  end

  def format(image, format) do
    {_, 0} = run(image.path, "format", format)
    ext = ".#{String.downcase(format)}"
    rootname = Path.rootname(image.path, image.ext)
    %{image | path: "#{rootname}#{ext}", ext: ext}
  end

  def resize(image, params) do
    {_, 0} = run(image.path, "resize", params)
    image |> verbose
  end

  defp run(path, option, params \\ nil) do
    args = ~w(-#{option} #{params} #{String.replace(path, " ", "\\ ")})
    System.cmd "mogrify", args, stderr_to_stdout: true
  end
end
