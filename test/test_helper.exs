import Mogrify.Detect

if has_imagemagick?() && has_pango?() do
  ExUnit.start()
else
  ExUnit.start(exclude: [:pango])
end
