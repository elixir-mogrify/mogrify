import Mogrify.Detect

excluded = [:skip]

excluded =
  if has_imagemagick?() do
    excluded = if has_pango?(), do: excluded ++ [:pango], else: excluded
    if has_plasma?(), do: excluded ++ [:plasma], else: excluded
  else
    [:skip, :pango, :plasma]
  end

ExUnit.start(exclude: excluded)
