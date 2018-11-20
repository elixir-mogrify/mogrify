defmodule MogrifyTest do
  import Mogrify
  alias Mogrify.Image
  use Mogrify.Options

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "fixtures/bender.jpg")
  @fixture_with_space Path.join(__DIR__, "fixtures/image with space in name/ben der.jpg")
  @fixture_animated Path.join(__DIR__, "fixtures/bender_anim.gif")
  @fixture_rgbw Path.join(__DIR__, "fixtures/rgbw.png")
  @fixture_rgbwa Path.join(__DIR__, "fixtures/rgbwa.png")
  @temp_test_directory "#{System.tmp_dir}/mogrify test folder" |> Path.expand
  @temp_image_with_space Path.join(@temp_test_directory, "1 1.jpg")

  test ".open" do
    image = open("./test/fixtures/bender.jpg")
    assert %Image{path: @fixture, ext: ".jpg"} = image

    image = open(@fixture)
    assert %Image{path: @fixture, ext: ".jpg"} = image
  end

  test ".open when file name has spaces" do
    image = open("./test/fixtures/image with space in name/ben der.jpg")
    assert %Image{path: @fixture_with_space, ext: ".jpg"} = image

    image = open(@fixture_with_space)
    assert %Image{path: @fixture_with_space, ext: ".jpg"} = image
  end

  test ".open when file does not exist" do
    assert_raise File.Error, fn ->
      open("./test/fixtures/does_not_exist.jpg")
    end
  end

  test ".save" do
    path = Path.join(System.tmp_dir, "1.jpg")

    image = open(@fixture) |> save(path: path)

    assert File.regular?(path) == true
    assert %Image{path: ^path} = image
    File.rm!(path)
  end

  test ".save when file name has spaces" do
    File.mkdir_p!(@temp_test_directory)

    image = open(@fixture) |> save(path: @temp_image_with_space)

    assert File.regular?(@temp_image_with_space) == true
    assert %Image{path: @temp_image_with_space} = image

    File.rm_rf!(@temp_test_directory)
  end

  test ".save in place" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true) |> verbose
    assert %Image{path: ^path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".save in place when file name has spaces" do
    # setup, make a copy
    File.mkdir_p!(@temp_test_directory)
    open(@fixture) |> save(path: @temp_image_with_space)

    # test begins
    image = open(@temp_image_with_space) |> resize("600x600") |> save(in_place: true) |> verbose
    assert %Image{path: @temp_image_with_space, height: 584, width: 600} = image

    File.rm_rf!(@temp_test_directory)
  end

  test ".save :in_place ignores :path option" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true, path: "#{path}-ignore") |> verbose
    assert %Image{path: ^path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".save :in_place ignores :path option when file name has spaces" do
    # setup, make a copy
    File.mkdir_p!(@temp_test_directory)
    open(@fixture) |> save(path: @temp_image_with_space)

    # test begins
    image = open(@temp_image_with_space) |> resize("600x600") |> save(in_place: true, path: "#{@temp_image_with_space}-ignore") |> verbose
    assert %Image{path: @temp_image_with_space, height: 584, width: 600} = image

    File.rm_rf!(@temp_test_directory)
  end

  test ".create" do
    path = Path.join(System.tmp_dir, "1.jpg")
    image = %Image{path: path} |> canvas("white") |> create(path: path)

    assert File.exists?(path) == true
    assert %Image{path: ^path} = image

    File.rm!(path)
  end

  test ".create when file name has spaces" do
    File.mkdir_p!(@temp_test_directory)
    image = %Image{path: @temp_image_with_space} |> canvas("white") |> create(path: @temp_image_with_space)

    assert File.exists?(@temp_image_with_space) == true
    assert %Image{path: @temp_image_with_space} = image

    File.rm_rf!(@temp_test_directory)
  end

  test "pango success" do
    path = Path.join(System.tmp_dir, "1.jpg")
    image = %Image{path: path} |> custom("pango", ~S(<span foreground="yellow">hello test</span>)) |> create(path: path)

    assert File.exists?(path) == true
    assert %Image{path: ^path} = image

    File.rm!(path)
  end

  test "pango by using single quotes" do
    path = Path.join(System.tmp_dir, "1.jpg")
    image = %Image{path: path} |> custom("pango", ~S('<span foreground="yellow">hello test</span>')) |> create(path: path)

    assert File.exists?(path) == true
    assert %Image{path: ^path} = image

    File.rm!(path)
  end

  test "pango by wrapping in <markup /> tags" do
    path = Path.join(System.tmp_dir, "1.jpg")
    image = %Image{path: path} |> custom("pango", ~S(<markup><span foreground="yellow">hello test</span></markup>')) |> create(path: path)

    assert File.exists?(path) == true
    assert %Image{path: ^path} = image

    File.rm!(path)
  end

  test "pango with invalid markup" do
    path = Path.join(System.tmp_dir, "1.jpg")
    %Image{path: path} |> custom("pango", ~S(<span foreground="yellow">hello test)) |> create(path: path)

    assert File.exists?(path) == false
  end

  test "binary output" do
    binary_image =
      %Image{}
      |> custom("pango", ~S(<span foreground="yellow">hello test</span>))
      |> custom("stdout", "png:-")
      |> create(buffer: true)

    assert is_binary(binary_image)
  end

  test ".copy" do
    image = open(@fixture) |> copy
    tmp_dir = System.tmp_dir |> Regex.escape
    slash = if String.ends_with?(tmp_dir, "/"), do: "", else: "/"
    assert Regex.match?(~r(#{tmp_dir}#{slash}\d+-bender\.jpg), image.path)
  end

  test ".copy when file name has spaces" do
    image = open(@fixture_with_space) |> copy
    tmp_dir = System.tmp_dir |> Regex.escape
    slash = if String.ends_with?(tmp_dir, "/"), do: "", else: "/"
    assert Regex.match?(~r(#{tmp_dir}#{slash}\d+-ben\sder\.jpg), image.path)
  end

  test ".verbose" do
    image = open(@fixture)
    assert %Image{format: "jpeg", height: 292, width: 300, animated: false} = verbose(image)
  end

  test ".verbose when file name has spaces" do
    image = open(@fixture_with_space)
    assert %Image{format: "jpeg", height: 292, width: 300, animated: false} = verbose(image)
  end

  test ".verbose animated" do
    image = open(@fixture_animated)
    assert %Image{format: "gif", animated: true} = verbose(image)
  end

  test ".verbose should not change file modification time" do
    %{mtime: old_time} = File.stat! @fixture

    :timer.sleep(1000)
    open(@fixture) |> verbose

    %{mtime: new_time} = File.stat! @fixture
    assert old_time == new_time
  end

  test ".verbose frame_count" do
    assert %Image{frame_count: 1} = open(@fixture) |> verbose
    assert %Image{frame_count: 2} = open(@fixture_animated) |> verbose
  end

  test ".format" do
    image = open(@fixture) |> format("png") |> save |> verbose
    assert %Image{ext: ".png", format: "png", height: 292, width: 300} = image
  end

  test ".format updates format after save" do
    image = open(@fixture) |> format("png") |> save
    assert %Image{ext: ".png", format: "png"} = image
  end

  test ".resize" do
    image = open(@fixture) |> resize("100x100") |> save |> verbose
    assert %Image{width: 100, height: 97} = image
  end

  test ".resize_to_fill" do
    image = open(@fixture) |> resize_to_fill("450x300") |> save |> verbose
    assert %Image{width: 450, height: 300} = image
  end

  test ".resize_to_limit" do
    image = open(@fixture) |> resize_to_limit("200x200") |> save |> verbose
    assert %Image{width: 200, height: 195} = image
  end

  test ".extent" do
    image = open(@fixture) |> extent("500x500") |> save |> verbose
    assert %Image{width: 500, height: 500} = image
  end

  test ".custom with plus-form of a command" do
    image_minus = open(@fixture) |> custom("raise", 50) |> save |> verbose
    image_plus  = open(@fixture) |> custom("+raise", 50) |> save |> verbose
    %{size: size_minus} = File.stat! image_minus.path
    %{size: size_plus}  = File.stat! image_plus.path
    assert size_minus != size_plus
  end

  test ".custom with explicit minus-form of a command" do
    image_implicit = open(@fixture) |> custom("raise", 50) |> save |> verbose
    image_explicit = open(@fixture) |> custom("-raise", 50) |> save |> verbose
    %{size: size_implicit} = File.stat! image_implicit.path
    %{size: size_explicit} = File.stat! image_explicit.path
    assert size_implicit == size_explicit
  end

  test ".histogram with no transparency" do
    hist = open(@fixture_rgbw) |> histogram |> Enum.sort_by( fn %{"hex" => hex} -> hex end )
    expected = [
      %{"alpha" => 255, "blue" => 255, "count" => 400, "green" => 0, "hex" => "#0000FF", "red" => 0},
      %{"alpha" => 255, "blue" => 0, "count" => 225, "green" => 255, "hex" => "#00FF00", "red" => 0},
      %{"alpha" => 255, "blue" => 0, "count" => 525, "green" => 0, "hex" => "#FF0000", "red" => 255},
      %{"alpha" => 255, "blue" => 255, "count" => 1350, "green" => 255, "hex" => "#FFFFFF", "red" => 255}
    ]
    assert hist == expected
  end

  test ".histogram with transparency" do
    hist = open(@fixture_rgbwa) |> histogram |> Enum.sort_by( fn %{"hex" => hex} -> hex end )
    expected = [
      %{"alpha" => 189, "blue" => 255, "count" => 400, "green" => 0, "hex" => "#0000FFBD", "red" => 0},
      %{"alpha" => 189, "blue" => 0, "count" => 225, "green" => 255, "hex" => "#00FF00BD", "red" => 0},
      %{"alpha" => 189, "blue" => 0, "count" => 525, "green" => 0, "hex" => "#FF0000BD", "red" => 255},
      %{"alpha" => 189, "blue" => 255, "count" => 1350, "green" => 255, "hex" => "#FFFFFFBD", "red" => 255}
    ]
    assert hist == expected
  end

  test "allows to pass options to command throw add_option" do
    rotate_image = open(@fixture) |> add_option(option_rotate("-90>"))

    assert rotate_image.operations == [{"-rotate", "-90>"}]
  end

  test "raise ArgumentError when no argument is passed to option when is required " do
    assert_raise ArgumentError, "the option rotate need arguments. Be sure to pass arguments to option_rotate(arg)", fn ->
      open(@fixture) |> add_option(option_rotate())
    end
  end

  test "raise ArgumentError when no argument is passed to option when is required and return correct message for options with plus sign" do
    assert_raise ArgumentError, "the option gamma need arguments. Be sure to pass arguments to option_plus_gamma(arg)", fn ->
      open(@fixture) |> add_option(option_plus_gamma())
    end
  end

  test "raise ArgumentError when no argument is passed to option when is required and return correct message for options name with hyphens in the middle of the name" do
    assert_raise ArgumentError, "the option gaussian_blur need arguments. Be sure to pass arguments to option_gaussian_blur(arg)", fn ->
      open(@fixture) |> add_option(option_gaussian_blur())
    end
  end

  @tag timeout: 5000
  test ".auto_orient should not hang" do
    open(@fixture) |> auto_orient |> save
  end
end
