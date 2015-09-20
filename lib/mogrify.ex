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

  @doc """
  Extends the image to the specified dimensions
  """
  def extent(image, params) do
    {_, 0} = run(image.path, "extent", params)
    image |> verbose
  end

  @doc """
  Resize the image to fit within the specified dimensions while retaining
  the original aspect ratio. Will only resize the image if it is larger than the
  specified dimensions. The resulting image may be shorter or narrower than specified
  in the smaller dimension but will not be larger than the specified values.
  """
  def resize_to_limit(image, params) do
    resize(image, "#{params}>")
  end

  @doc """
  Resize the image to fit within the specified dimensions while retaining
  the aspect ratio of the original image. If necessary, crop the image in the
  larger dimension.
  """
  def resize_to_fill(image, params) do
    [_, width, height] = Regex.run(~r/(\d+)x(\d+)/, params)
    image = Mogrify.verbose(image)
    {width, _} = Float.parse width
    {height, _} = Float.parse height
    {cols, _} = Float.parse image.width
    {rows, _} = Float.parse image.height

    if width != cols || height != rows do
      scale_x = width/cols #.to_f
      scale_y = height/rows #.to_f
      if scale_x >= scale_y do
        cols = (scale_x * (cols + 0.5)) |> Float.round
        rows = (scale_x * (rows + 0.5)) |> Float.round
        image = resize image, "#{cols}"
      else
        cols = (scale_y * (cols + 0.5)) |> Float.round
        rows = (scale_y * (rows + 0.5)) |> Float.round
        image = resize image, "x#{rows}"
      end
    end

    if cols != width || rows != height do
      image = extent(image, params)
    end
    image
  end

  defp run(path, option, params \\ nil) do
    args = ~w(-#{option} #{params} #{String.replace(path, " ", "\\ ")})
    System.cmd "mogrify", args, stderr_to_stdout: true
  end
end
