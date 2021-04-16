# Mogrify

[![Build Status](https://travis-ci.org/route/mogrify.svg?branch=master)](https://travis-ci.org/route/mogrify)
[![Module Version](https://img.shields.io/hexpm/v/mogrify.svg)](https://hex.pm/packages/mogrify)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mogrify/)
[![Total Download](https://img.shields.io/hexpm/dt/mogrify.svg)](https://hex.pm/packages/mogrify)
[![License](https://img.shields.io/hexpm/l/mogrify.svg)](https://github.com/route/mogrify/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/route/mogrify.svg)](https://github.com/route/mogrify/commits/master)

An Elixir wrapper for ImageMagick command line.

Documentation: https://hexdocs.pm/mogrify/

## Requirements

You must have ImageMagick installed of course.

## Installation

Add this to your `mix.exs` file, then run `mix do deps.get, deps.compile`:

```elixir
def deps do
  {:mogrify, "~> 0.8.0"}
end
```

## Configuration

Configure the ImageMagick executable paths (optional):

Configure `mogrify` command:

```elixir
config :mogrify, mogrify_command: [
  path: "mogrify",
  args: []
]
```

Configure `convert` command:

```elixir
config :mogrify, convert_command: [
  path: "convert",
  args: []
]
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
IO.inspect(image) # => %Image{path: "/tmp/568550-input.png", ext: ".png", format: "png"}
```

Getting info:

```elixir
import Mogrify

image = open("input.jpg") |> verbose
IO.inspect(image) # => %Image{path: "input.jpg", ext: ".jpg", format: "jpeg", height: 292, width: 300}
```

Using custom commands to create an image with markup:

```elixir
import Mogrify

%Mogrify.Image{path: "test.png", ext: "png"}
|> custom("size", "280x280")
|> custom("background", "#000000")
|> custom("gravity", "center")
|> custom("fill", "white")
|> custom("font", "DejaVu-Sans-Mono-Bold")
|> custom("pango", ~S(<span foreground="yellow">hello markup world</span>))
|> create(path: ".")
```

Plasma backgrounds:

```elixir
import Mogrify

%Mogrify.Image{path: "test.png", ext: "png"}
|> custom("size", "280x280")
|> custom("seed", 10)
|> custom("plasma", "fractal")
```

Creating new images: See [mogrify_draw](https://github.com/zamith/mogrify_draw) for an example of generating a new image from scratch.

## Changelog

See the [changelog](./CHANGELOG.md) for important release notes between Mogrify versions.

## Copyright and License

Copyright (c) 2014 Dmitry Vorotilin

Mogrify source code is licensed under the [MIT License](./LICENSE.md).
