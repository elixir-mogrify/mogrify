# Mogrify

[![Build Status](https://travis-ci.org/route/mogrify.svg?branch=master)](https://travis-ci.org/route/mogrify)

An Elixir wrapper for ImageMagick command line.

Documentation: https://hexdocs.pm/mogrify/

## Requirements

You must have ImageMagick installed of course.

## Installation

Add this to your `mix.exs` file, then run `mix do deps.get, deps.compile`:

```elixir
  {:mogrify, "~> 0.5.2"}
```

## Examples

Thumbnailing:

```elixir
  import Mogrify

  # This does operations on an original image:
  open("input.jpg") |> resize("100x100") |> save(in_place: true)

  # save/1 creates a copy of the file by default:
  image = open("input.jpg") |> resize("100x100") |> save
  IO.inspect(image) # => %Image{path: "/tmp/260199-input.jpg", ext: ".jpg", ...}

  # Resize to fill
  open("input.jpg") |> resize_to_fill("450x300") |> save

  # Resize to limit
  open("input.jpg") |> resize_to_limit("200x200") |> save

  # Extent
  open("input.jpg") |> extent("500x500") |> save

  # Gravity
  open("input.jpg") |> gravity("Center") |> save

```

Converting:

```elixir
  import Mogrify

  image = open("input.jpg") |> format("png") |> save
  IO.inspect(image) # => %Image{path: "/tmp/568550-input.png", ext: ".png", format: "png", height: 292, width: 300}
```

Getting info:

```elixir
  import Mogrify

  image = open("input.jpg") |> verbose
  IO.inspect(image) # => %Image{path: "input.jpg", ext: ".jpg", format: "jpeg", height: 292, width: 300}
```

Creating new images: See [mogrify_draw](https://github.com/zamith/mogrify_draw) for an example of generating a new image from scratch.


## Changelog

See the [changelog](CHANGELOG.md) for important release notes between Mogrify versions.

## License

Mogrify source code is licensed under the [MIT License](LICENSE.md).
