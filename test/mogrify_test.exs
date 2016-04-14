defmodule MogrifyTest do
  import Mogrify
  alias Mogrify.Image

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "fixtures/bender.jpg")
  @fixture_with_space Path.join(__DIR__, "fixtures/ben der.jpg")

  setup do
    tmp_copy = open(@fixture) |> copy

    on_exit fn ->
      File.cp tmp_copy.path, @fixture
    end
  end

  test ".open" do
    image = open("./test/fixtures/bender.jpg")
    assert %Image{path: @fixture, ext: ".jpg"} = image

    image = open(@fixture)
    assert %Image{path: @fixture, ext: ".jpg"} = image
  end

  test ".open with space" do
    image = open("./test/fixtures/ben der.jpg")
    assert %Image{path: @fixture_with_space, ext: ".jpg"} = image

    image = open(@fixture_with_space)
    assert %Image{path: @fixture_with_space, ext: ".jpg"} = image
  end

  test ".save" do
    path = Path.join(System.tmp_dir, "1.jpg")

    image = open(@fixture) |> save(path)

    assert File.regular?(path)
    assert %Image{path: path} = image
    File.rm!(path)
  end

  test ".copy" do
    image = open(@fixture) |> copy
    tmp_dir = System.tmp_dir |> Regex.escape
    slash = if String.ends_with?(tmp_dir, "/"), do: "", else: "/"
    assert Regex.match?(~r(#{tmp_dir}#{slash}\d+-bender\.jpg), image.path)
  end

  test ".verbose" do
    image = open(@fixture)
    assert %Image{format: "jpeg", height: "292", width: "300"} = verbose(image)
  end

  test ".format" do
    image = open(@fixture) |> copy |> format("png") |> verbose
    assert %Image{ext: ".png", format: "png", height: "292", width: "300"} = image
  end

  test ".resize" do
    image = open(@fixture) |> copy |> resize("100x100")
    assert %Image{width: "100", height: "97"} = image
  end

  test ".resize_to_fill" do
    image = open(@fixture) |> copy |> resize_to_fill("450x300")
    assert %Image{width: "450", height: "300"} = image
  end

  test ".resize_to_limit" do
    image = open(@fixture) |> copy |> resize_to_limit("200x200")
    assert %Image{width: "200", height: "195"} = image
  end

  test ".extent" do
    image = open(@fixture) |> copy |> extent("500x500")
    assert %Image{width: "500", height: "500"} = image
  end
end
