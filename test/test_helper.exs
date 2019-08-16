import Mogrify.Detect

excluded =
  if has_imagemagick?() && has_pango?() do
    [:skip]
  else
    [:skip, :pango]
  end

ExUnit.start(exclude: excluded)
