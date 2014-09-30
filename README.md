# Mogrify

An Elixir wrapper for ImageMagick command line.

## Requirements

You must have ImageMagick installed of course.

## Installation

Add this to your `mix.exs` file, then run `mix do deps.get, deps.compile`:

```elixir
  {:mogrify,  github: "route/mogrify"}
```

## Examples

Thumbnailing:

```elixir
  import Mogrify

  # This does operations on original image:
  open("input.jpg") |> resize("100x100")
  # This doesn't:
  open("input.jpg") |> copy |> resize("100x100") |> save("/your/path/here")
```

Converting:

```elixir
  import Mogrify

  image = open("input.jpg") |> format("png")
  IO.inspect(image) # => %Image{path: "input.png", ext: ".png", format: "png", height: "292", width: "300"}
```

Getting info:

```elixir
  import Mogrify

  image = open("input.jpg") |> verbose
  IO.inspect image # => %Image{path: "input.png", ext: ".jpg", format: "jpeg", height: "292", width: "300"}
```
