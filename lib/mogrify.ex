defmodule Mogrify do
  alias Mogrify.Image

  @doc """
  Opens image source
  """
  def open(path) do
    path = Path.expand(path)
    unless File.regular?(path), do: raise(File.Error)

    %Image{path: path, ext: Path.extname(path)}
  end

  @doc """
  Saves modified image to a temporary location
  """
  def save(image) do
    do_save(image, temporary_path_for(image))
  end

  @doc """
  Saves modified image to specified path
  """
  def save(image, path) do
    do_save(image, path)
  end

  defp do_save(image, output_path) do
    System.cmd "mogrify", arguments(image, output_path), stderr_to_stdout: true
    %{image | path: output_path, ext: Path.extname(output_path), operations: [], dirty: %{}}
  end

  def arguments(image, path) do
    base_arguments = ~w(-write #{path} #{String.replace(image.path, " ", "\\ ")})
    additional_arguments = Enum.flat_map image.operations, fn {option,params} -> ~w(-#{option} #{params}) end

    additional_arguments ++ base_arguments
  end

  @doc """
  Makes a copy of original image
  """
  def copy(image) do
    temp = temporary_path_for(image)
    File.cp!(image.path, temp)
    Map.put(image, :path, temp)
  end

  def temporary_path_for(%{dirty: %{path: dirty_path}} = _image) do
    do_temporary_path_for(dirty_path)
  end
  def temporary_path_for(%{path: path} = _image) do
    do_temporary_path_for(path)
  end

  defp do_temporary_path_for(path) do
    name = Path.basename(path)
    random = :crypto.rand_uniform(100_000, 999_999)
    Path.join(System.tmp_dir, "#{random}-#{name}")
  end

  @doc """
  Provides detailed information about the image
  """
  def verbose(image) do
    {output, 0} = run(image.path, "verbose")
    info = Regex.named_captures(~r/\S+ (?<format>\S+) (?<width>\d+)x(?<height>\d+)/, output)
    info = Enum.reduce(info, %{}, fn ({key, value}, acc) ->
      {key, value} = {String.to_atom(key), String.downcase(value)}
      Map.put(acc, key, value)
    end)
    Map.merge(image, info)
  end

  @doc """
  Converts the image to the image format you specify
  """
  def format(image, format) do
    ext = ".#{String.downcase(format)}"
    rootname = Path.rootname(image.path, image.ext)

    %{image | operations: image.operations ++ [format: format],
              dirty: Map.put(image.dirty, :path, "#{rootname}#{ext}")}
  end

  @doc """
  Resizes the image with provided geometry
  """
  def resize(image, params) do
    %{image | operations: image.operations ++ [resize: params]}
  end

  @doc """
  Extends the image to the specified dimensions
  """
  def extent(image, params) do
    %{image | operations: image.operations ++ [extent: params]}
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

  def auto_orient(image) do
    %{image | operations: image.operations ++ ["auto-orient": nil]}
  end

  def custom(image, action, options \\ nil) do
    %{image | operations: image.operations ++ [{action, options}]}
  end

  defp run(path, option, params \\ nil) do
    args = ~w(-#{option} #{params} #{String.replace(path, " ", "\\ ")})
    System.cmd "mogrify", args, stderr_to_stdout: true
  end
end
