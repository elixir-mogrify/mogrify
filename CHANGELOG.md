# Changelog

## 0.3.1 (2016-06-15)

* Added `gravity/2`, for example: `gravity(image, "Center")`

## 0.3.0 (2016-05-12)

* Breaking changes
  * Mogrify 0.3 now defers commands and bulk executes them when calling `save/2`. You must call `save/2` for any operations to take place.
  * `save(image)` by default creates a temporary file
  * `save(image, in_place: true)` gets the old behavior of overwriting the existing file
  * `save(image, path: "/some/destination.jpg")` lets you specify the path to write the new file

* New functions
  * `auto_orient/1` corresponding to `mogrify -auto-orient`
  * `custom/3` letting you run arbitrary commands, for example: `custom(image, "gaussian-blur", 5)`

* Bugfixes
  * Fixed `mix test` failures on Windows
  * Avoid dirty Git working directory when running `mix test`

* Misc
  * Mogrify is now licensed under the MIT License