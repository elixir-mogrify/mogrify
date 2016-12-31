# Changelog

## 0.5.2 (2016-12-31)

* Fix for spaces in file paths.

## 0.5.1 (2016-11-19)

* Fix for `custom/3` handling of options and params with whitespace.

## 0.5.0 (2016-10-14)

* New functions
  * `create/2` uses `convert` CLI tool to create a new image from scratch, without requiring a base image.
  See [mogrify_draw](https://github.com/zamith/mogrify_draw) for an example use case.

* Enhancements
  * `custom/3` supports "plus-form" arguments, e.g. `custom(image, "+raise", 50)`

## 0.4.0 (2016-08-23)

* Breaking changes
  * `Image.width` and `Image.height` are now integers instead of binaries

* Enhancements
  * `verbose/1` no longer modifies the input file
  * Added `Image.frame_count` integer field for animated images, set by `verbose/1`

## 0.3.3 (2016-08-01)

* `verbose/1` now sets the `Image.animated` field for images containing multiple frames

## 0.3.2 (2016-06-30)

* Fixed Elixir 1.3 compiler warnings

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