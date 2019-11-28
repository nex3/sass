# More Math Functions: Draft 1

*[(Issue)](https://github.com/sass/sass/issues/851)*

This proposal adds the following members to the built-in `sass:math` module.

## Table of Contents
* [Variables](#variables)
  * [`$e`](#e)
  * [`$pi`](#pi)
* [Functions](#functions)
  * [`clamp()`](#clamp)
  * [`hypot()`](#hypot)
  * [Exponentiation](#exponentiation)
    * [`log()`](#log)
    * [`pow()`](#pow)
    * [`sqrt()`](#sqrt)
  * [Trigonometry](#trigonometry)
    * [`cos()`](#cos)
    * [`sin()`](#sin)
    * [`tan()`](#tan)
    * [`acos()`](#acos)
    * [`asin()`](#asin)
    * [`atan()`](#atan)
    * [`atan2()`](#atan2)
      * [Edge cases](#edge-cases)

## Variables

### `$e`

Equal to the value of the mathematical constant `e` with a precision of 10
digits: `2.718281828`.

### `$pi`

Equal to the value of the mathematical constant `pi` with a precision of 10
digits: `3.141592654`.

## Functions

### `clamp()`

```
clamp($min, $number, $max)
```

* If the units of `$min`, `$number`, and `$max` are not [compatible][] with each
  other, throw an error.
* If `$min >= $max`, return `$min`.
* If `$number <= $min`, return `$min`.
* If `$number >= $max`, return `$max`.
* Return `$number`.

[compatible]: ../spec/built_in_modules/math.md#compatible

### `hypot()`

```
hypot($arguments...)
```

* If all arguments are not compatible with each other, throw an error.
* Let the unit of the return value be the same as that of the leftmost argument
  that has a unit. If all arguments are unitless, let the return value be
  unitless.
  * If any argument is `Infinity`, return `Infinity`.
  * Return the square root of the sum of the squares of each argument.

### Exponentiation

#### `log()`

```
log($number, $base: null)
```

* If `$number` has units or `$number < 0`, throw an error.
* If `$base` is null:
  * If `$number == 0`, return `-Infinity` as a unitless number.
  * If `$number == Infinity`, return `Infinity` as a unitless number.
  * Return the [natural log][] of `$number`, as a unitless number.
* Otherwise, if `$base < 0` or `$base == 0` or `$base == 1`, throw an error.
* Otherwise, return the natural log of `$number` divided by the natural log of
  `$base`, as a unitless number.

[natural log]: https://en.wikipedia.org/wiki/Natural_logarithm

#### `pow()`

```
pow($base, $exponent)
```

* If `$base` or `$exponent` has units, throw an error.

* If `$exponent == 0`, return `1` as a unitless number.

* Otherwise, if `$exponent == Infinity`:
  * If `$base == 1` or `$base == -1`, return `NaN` as a unitless number.
  * If `$base < -1` or `$base > 1` and if `$exponent > 0`, *or* if `$base > -1`
    and `$base < 1` and `$exponent < 0`, return `Infinity` as a
    unitless number.
  * Return `0` as a unitless number.

* Otherwise:
  * If `$base < 0` and `$exponent` is not an integer, return `NaN` as a unitless
    number.

  * If `$base == 0` and `$exponent < 0`, or if `$base == Infinity` and
    `$exponent > 0`, return `Infinity` as a unitless number.

  * If `$base == -0` and `$exponent < 0`, or if `$base == -Infinity` and
    `$exponent > 0`:
    * If `$exponent` is an odd integer, return `-Infinity` as a unitless number.
    * Return `Infinity` as a unitless number.

  * If `$base == 0` and `$exponent > 0`, or if `$base == Infinity` and
    `$exponent < 0`, return `0` as a unitless number.

  * If `$base == -0` and `$exponent > 0`, or if `$base == -Infinity` and
    `$exponent < 0`:
    * If `$exponent` is an odd integer, return `-0` as a unitless number.
    * Return `0` as a unitless number.

  * Return `$base` raised to the power of `$exponent`, as a unitless number.

#### `sqrt()`

```
sqrt($number)
```

* If `$number` has units, throw an error.
* If `$number < 0`, return `NaN` as a unitless number.
* If `$number == -0`, return `-0` as a unitless number.
* If `$number == Infinity`, return `Infinity` as a unitless number.
* Return the square root of `$number`, as a unitless number.

### Trigonometry

#### `cos()`

```
cos($number)
```

* If `$number` has units but is not an [angle][], throw an error.
* If `$number` is unitless, treat it as though its unit were rad.
* If `$number == Infinity`, return `NaN` as a unitless number.
* Return the [cosine][] of `$number`, as a unitless number.

[angle]: https://drafts.csswg.org/css-values-4/#angles
[cosine]: https://en.wikipedia.org/wiki/Trigonometric_functions#Right-angled_triangle_definitions

#### `sin()`

```
sin($number)
```

* If `$number` has units but is not an angle, throw an error.
* If `$number` is unitless, treat it as though its unit were rad.
* If `$number == Infinity`, return `NaN` as a unitless number.
* If `$number == -0`, return `-0` as a unitless number.
* Return the [sine][] of `$number`, as a unitless number.

[sine]: https://en.wikipedia.org/wiki/Trigonometric_functions#Right-angled_triangle_definitions

#### `tan()`

```
tan($number)
```

* If `$number` has units but is not an angle, throw an error.
* If `$number` is unitless, treat it as though its unit were rad.
* If `$number == Infinity`, return `NaN` as a unitless number.
* If `$number == -0`, return `-0` as a unitless number.
* If `$number` is equivalent to `90deg +/- 360deg * n`, where `n` is any
  integer, return `Infinity` as a unitless number.
* If `$number` is equivalent to `-90deg +/- 360deg * n`, where `n` is any
  integer, return `-Infinity` as a unitless number.
* Return the [tangent][] of `$number`, as a unitless number.

[tangent]: https://en.wikipedia.org/wiki/Trigonometric_functions#Right-angled_triangle_definitions

#### `acos()`

```
acos($number)
```

* If `$number` has units, throw an error.
* If `$number < -1` or `$number > 1`, return `NaN` as a number in rad.
* If `$number == 1`, return `0rad`.
* Return the [arccosine][] of `$number`, as a number in rad.

[arccosine]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Basic_properties

#### `asin()`

```
asin($number)
```

* If `$number` has units, throw an error.
* If `$number < -1` or `$number > 1`, return `NaN` as a number in rad.
* If `$number == -0`, return `-0rad`.
* Return the [arcsine][] of `$number`, as a number in rad.

[arcsine]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Basic_properties

#### `atan()`

```
atan($number)
```

* If `$number` has units, throw an error.
* If `$number == -0`, return `-0rad`.
* If `$number == -Infinity`, return `-0.5rad * pi`.
* If `$number == Infinity`, return `0.5rad * pi`.
* Return the [arctangent][] of `$number`, as a number in rad.

[arctangent]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Basic_properties

#### `atan2()`

> `atan2($y, $x)` is distinct from `atan($y / $x)` because it preserves the
> quadrant of the point in question. For example, `atan2(1, -1)` corresponds to
> the point `(-1, 1)` and returns `0.75rad * pi`. In contrast, `atan(1 / -1)`
> and `atan(-1 / 1)` resolve first to `atan(-1)`, so both return
> `-0.25rad * pi`.

```
atan2($y, $x)
```

* If `$y` and `$x` are not compatible, throw an error.
* If the inputs match one of the following edge cases, return the provided
  number in rad. Otherwise, return the [2-argument arctangent][] of `$y` and
  `$x`, as a number in rad.

[2-argument arctangent]: https://en.wikipedia.org/wiki/Atan2

##### Edge cases

<table>
  <thead>
    <tr>
      <td colspan="2"></td>
      <th colspan="6" style="text-align: center">X</th>
    </tr>
    <tr>
      <td colspan="2"></td>
      <th>−Infinity</th>
      <th>-finite</th>
      <th>-0</th>
      <th>0</th>
      <th>finite</th>
      <th>Infinity</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="6">Y</th>
      <th>−Infinity</th>
      <td>-0.75 * pi</td>
      <td>-0.5 * pi</td>
      <td>-0.5 * pi</td>
      <td>-0.5 * pi</td>
      <td>-0.5 * pi</td>
      <td>-0.25 * pi</td>
    </tr>
    <tr>
      <th>-finite</th>
      <td>-pi</td>
      <td></td>
      <td>-0.5 * pi</td>
      <td>-0.5 * pi</td>
      <td></td>
      <td>-0</td>
    </tr>
    <tr>
      <th>-0</th>
      <td>-pi</td>
      <td>-pi</td>
      <td>-pi</td>
      <td>-0</td>
      <td>-0</td>
      <td>-0</td>
    </tr>
    <tr>
      <th>0</th>
      <td>pi</td>
      <td>pi</td>
      <td>pi</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>finite</th>
      <td>pi</td>
      <td></td>
      <td>0.5 * pi</td>
      <td>0.5 * pi</td>
      <td></td>
      <td>0</td>
    </tr>
    <tr>
      <th>Infinity</th>
      <td>0.75 * pi</td>
      <td>0.5 * pi</td>
      <td>0.5 * pi</td>
      <td>0.5 * pi</td>
      <td>0.5 * pi</td>
      <td>0.25 * pi</td>
    </tr>
  </tbody>
</table>
