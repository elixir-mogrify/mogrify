import Mogrify.Detect

excluded = [:skip, :pango, :plasma]
excluded = if has_imagemagick?() and has_pango?(), do: excluded -- [:pango], else: excluded
excluded = if has_imagemagick?() and has_plasma?(), do: excluded -- [:plasma], else: excluded

ExUnit.start(exclude: excluded)
