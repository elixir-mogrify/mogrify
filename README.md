# Mogrify

An Elixir wrapper for ImageMagick command line.

## Requirements

You must have ImageMagick installed of course.

## Installation

Add this to your `mix.exs` file, then run `mix do deps.get, deps.compile`:

```elixir
  {:mogrify, "~> 0.1"}
```

## Examples

Thumbnailing:

```elixir
  import Mogrify

  # This does operations on an original image:
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
  IO.inspect image # => %Image{path: "input.jpg", ext: ".jpg", format: "jpeg", height: "292", width: "300"}
```

Custom (raw) commands:
```elixir
  import Mogrify

  #custom/2 accepts any string of parameters that the mogrify CLI tool will accept
  image = open("input.jpg") |> custom(~s(-resize "600x" -unsharp 2x0.5+0.7+0 -quality 98))
