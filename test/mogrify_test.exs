defmodule MogrifyTest do
  import Mogrify
  alias Mogrify.Image

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "fixtures/bender.jpg")
  @fixture_with_space Path.join(__DIR__, "fixtures/ben der.jpg")
  @fixture_animated Path.join(__DIR__, "fixtures/bender_anim.gif")

  test ".open" do
    image = open("./test/fixtures/bender.jpg")
    assert %Image{path: @fixture, ext: ".jpg"} = image

    image = open(@fixture)
    assert %Image{path: @fixture, ext: ".jpg"} = image
  end

  test ".open when file name has spaces" do
    image = open("./test/fixtures/ben der.jpg")
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

    assert File.regular?(path)
    assert %Image{path: path} = image
    File.rm!(path)
  end

  test ".save when file name has spaces" do
    path = Path.join(System.tmp_dir, "1 1.jpg")

    image = open(@fixture) |> save(path: path)

    assert File.regular?(path)
    assert %Image{path: path} = image
    File.rm!(path)
  end

  test ".save in place" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true) |> verbose
    assert %Image{path: path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".save in place when file name has spaces" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1 1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true) |> verbose
    assert %Image{path: path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".save :in_place ignores :path option" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true, path: "#{path}-ignore") |> verbose
    assert %Image{path: path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".save :in_place ignores :path option when file name has spaces" do
    # setup, make a copy
    path = Path.join(System.tmp_dir, "1 1.jpg")
    open(@fixture) |> save(path: path)

    # test begins
    image = open(path) |> resize("600x600") |> save(in_place: true, path: "#{path}-ignore") |> verbose
    assert %Image{path: path, height: 584, width: 600} = image

    File.rm!(path)
  end

  test ".create" do
    path = Path.join(System.tmp_dir, "1.jpg")
    image = %Image{path: path} |> canvas("white") |> create(path: path)

    assert File.exists?(path)
    assert %Image{path: path} = image

    File.rm!(path)
  end

  test ".create when file name has spaces" do
    path = Path.join(System.tmp_dir, "1 1.jpg")
    image = %Image{path: path} |> canvas("white") |> create(path: path)

    assert File.exists?(path)
    assert %Image{path: path} = image

    File.rm!(path)
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
end
