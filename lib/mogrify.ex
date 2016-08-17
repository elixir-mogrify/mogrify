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
  Saves modified image

  ## Options

  * `:path` - The output path of the image. Defaults to a temporary file.
  * `:in_place` - Overwrite the original image, ignoring `:path` option. Default false.
  """
  def save(image, opts \\ []) do
    output_path = output_path_for(image, opts)
    System.cmd "mogrify", arguments(image, output_path), stderr_to_stdout: true
    %{image | path: output_path,
              ext: Path.extname(output_path),
              format: Map.get(image.dirty, :format, image.format),
              operations: [],
              dirty: %{}}
  end

  defp output_path_for(image, save_opts) do
    if Keyword.get(save_opts, :in_place) do
      image.path
    else
      Keyword.get(save_opts, :path, temporary_path_for(image))
    end
  end

  defp arguments(image, path) do
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
    args = ~w(-verbose -write #{dev_null} #{String.replace(image.path, " ", "\\ ")})
    {output, 0} = System.cmd "mogrify", args, stderr_to_stdout: true

    info =
      ~r/\b(?<animated>\[0])? (?<format>\S+) (?<width>\d+)x(?<height>\d+)/
      |> Regex.named_captures(output)
      |> Enum.map(&normalize_verbose_term/1)
      |> Enum.into(%{})
    Map.merge(image, info)
  end

  defp dev_null do
    case :os.type do
      {:win32, _} -> "NUL"
      _ -> "/dev/null"
    end
  end

  defp normalize_verbose_term({"animated", "[0]"}), do: {:animated, true}
  defp normalize_verbose_term({"animated", ""}), do: {:animated, false}
  defp normalize_verbose_term({key, value}), do: {String.to_atom(key), String.downcase(value)}

  @doc """
  Converts the image to the image format you specify
  """
  def format(image, format) do
    downcase_format = String.downcase(format)
    ext = ".#{downcase_format}"
    rootname = Path.rootname(image.path, image.ext)

    %{image | operations: image.operations ++ [format: format],
              dirty: image.dirty |> Map.put(:path, "#{rootname}#{ext}") |> Map.put(:format, downcase_format)}
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
  Sets the gravity of the image
  """
  def gravity(image, params) do
    %{image | operations: image.operations ++ [gravity: params]}
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
      larger_scale = max(scale_x, scale_y)
      cols = (larger_scale * (cols + 0.5)) |> Float.round
      rows = (larger_scale * (rows + 0.5)) |> Float.round
      image = resize image, (if scale_x >= scale_y, do: "#{cols}", else: "x#{rows}")

      if width != cols || height != rows do
        extent(image, params)
      else
        image
      end
    else
      image
    end
  end

  def auto_orient(image) do
    %{image | operations: image.operations ++ ["auto-orient": nil]}
  end

  def custom(image, action, options \\ nil) do
    %{image | operations: image.operations ++ [{action, options}]}
  end
end
