# Changelog

## 0.7.3 (2019-08-19)

* Bugfixes
  * Create intermediate missing directories instead of silently failing `save/2` and `create/2`
  * Fix for `custom(image, "annotate", ...)` with multi-word text
  * Skip Pango unit tests if Pango not installed

## 0.7.2 (2019-03-12)

* Enhancements
  * Added `quality/2`

* Bugfixes
  * Fix commands on Windows

## 0.7.0 (2018-12-14)

* Enhancements
  * Added `:buffer` and `:into` options to `create/2` (**not** `save/2`; see [#56](https://github.com/route/mogrify/issues/56)).
    Allows writing to an in-memory buffer, or other Collectable of your choice, instead of a file.
  * Added `Image.buffer` field

* Bugfixes
  * Allow nil `Image.path` with `create/2`, helps when creating images from scratch with Pango

## 0.6.1 (2018-05-08)

* Fix `histogram/1` for RGBA images

## 0.6.0 (2018-04-17)

* Breaking changes
  * Requires Elixir 1.2 or higher

* Enhancements
  * Added support for Pango via `custom(image, "pango", ...)` combined with `create/2`. See README for an example.

## 0.5.6 (2017-08-12)

* Added `histogram/1`

## 0.5.5 (2017-07-27)

* Fix Erlang 19 compiler warning

## 0.5.4 (2017-01-20)

* Fix hang with options without params (such as `-auto-orient`)

## 0.5.3 (2017-01-07)

* Fix Elixir 1.4 warnings
* Fix test failures on OS X

## 0.5.2 (2016-12-31)

* Fix for spaces in file paths

## 0.5.1 (2016-11-19)

* Fix for `custom/3` handling of options and params with whitespace

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
