# Mogrify

An Elixir wrapper for ImageMagick command line.

## Requirements

You must have ImageMagick installed of course.

## Installation

Add this to your `mix.exs` file, then run `mix do deps.get, deps.compile`:

```elixir
  {:mogrify, "~> 0.2"}
```

## Examples

Thumbnailing:

```elixir
  import Mogrify

  # This does operations on an original image:
  open("input.jpg") |> resize("100x100")
  # This doesn't:
  open("input.jpg") |> copy |> resize("100x100") |> save("/your/path/here")
  # Resize to fill
  open("input.jpg") |> copy |> resize_to_fill("450x300")
  # Resize to limit
  open("input.jpg") |> copy |> resize_to_limit("200x200")
  # Extent
  open("input.jpg") |> copy |> extent("500x500")
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
  IO.inspect(image) # => %Image{path: "input.jpg", ext: ".jpg", format: "jpeg", height: "292", width: "300"}
```

## License

Mogrify source code is licensed under the [MIT License](LICENSE.md).
