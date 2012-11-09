#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'

class SourcemapTest < Test::Unit::TestCase
  def test_simple_scss_mapping
    assert_parses_with_sourcemap <<SCSS, <<CSS, <<JSON
a {
  foo: bar;
/* SOME COMMENT */
  font-size: 12px;
}
SCSS
a {
  foo: bar;
  /* SOME COMMENT */
  font-size: 12px; }

/*@ sourceMappingURL=test.css.map */
CSS
{
"version": "3",
"mappings": ";EACE,GAAG,EAAE,GAAG;;EAER,SAAS,EAAE,IAAI",
"sources": ["test_simple_scss_mapping_inline.scss"],
"file": "test.css"
}
JSON
  end

  def test_mapping_with_directory
    options = {:filename => "scss/style.scss", :output => "css/style.css"}
    assert_parses_with_sourcemap <<SCSS, <<CSS, <<JSON, options
a {
  foo: bar;
/* SOME COMMENT */
  font-size: 12px;
}
SCSS
a {
  foo: bar;
  /* SOME COMMENT */
  font-size: 12px; }

/*@ sourceMappingURL=style.css.map */
CSS
{
"version": "3",
"mappings": ";EACE,GAAG,EAAE,GAAG;;EAER,SAAS,EAAE,IAAI",
"sources": ["..\\/scss\\/style.scss"],
"file": "style.css"
}
JSON
  end

  unless Sass::Util.ruby1_8?
    def test_simple_charset_scss_mapping
      assert_parses_with_sourcemap <<SCSS, <<CSS, <<JSON
a {
  fóó: bár;
}
SCSS
@charset "UTF-8";
a {
  fóó: bár; }

/*@ sourceMappingURL=test.css.map */
CSS
{
"version": "3",
"mappings": ";;EACE,GAAG,EAAE,GAAG",
"sources": ["test_simple_charset_scss_mapping_inline.scss"],
"file": "test.css"
}
JSON
    end

    def test_different_charset_than_encoding
      assert_parses_with_sourcemap(<<CSS.force_encoding("IBM866"), <<SASS.force_encoding("IBM866"), <<JSON)
@charset "IBM866";
f\x86\x86 {
  \x86: b;
}
CSS
@charset "IBM866";
f\x86\x86 {
  \x86: b; }

/*@ sourceMappingURL=test.css.map */
SASS
{
"version": "3",
"mappings": ";;EAEE,CAAC,EAAE,CAAC",
"sources": ["test_different_charset_than_encoding_inline.scss"],
"file": "test.css"
}
JSON
    end
  end

  def test_import_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
@import {{1}}url(foo){{/1}},{{2}}url(moo)   {{/2}},       {{3}}url(bar) {{/3}};
SCSS
{{1}}@import url(foo){{/1}};
{{2}}@import url(moo){{/2}};
{{3}}@import url(bar){{/3}};

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_interpolation_and_vars_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
$te: "te";
p {
  {{1}}con#{$te}nt{{/1}}: {{2}}"I a#{$te} #{5 + 10} pies!"{{/2}};
}


$name: foo;
$attr: border;
p.#{$name} {
  {{3}}#{$attr}-color{{/3}}: {{4}}blue{{/4}};
  $font-size: 12px;
  $line-height: 30px;
  {{5}}font{{/5}}: {{6}}#{$font-size}/#{$line-height}{{/6}};
}
SCSS
p {
  {{1}}content{{/1}}: {{2}}"I ate 15 pies!"{{/2}}; }

p.foo {
  {{3}}border-color{{/3}}: {{4}}blue{{/4}};
  {{5}}font{{/5}}: {{6}}12px/30px{{/6}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_selectors_properties_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
$width: 2px;
$translucent-red: rgba(255, 0, 0, 0.5);
a {
  .special {
    {{7}}color{{/7}}: {{8}}red{{/8}};
    &:hover {
      {{9}}foo{{/9}}: {{10}}bar{{/10}};
      {{11}}cursor{{/11}}: {{12}}e + -resize{{/12}};
      {{13}}color{{/13}}: {{14}}opacify($translucent-red, 0.3){{/14}};
    }
    &:after {
      {{15}}content{{/15}}: {{16}}"I ate #{5 + 10} pies thick!"{{/16}};
    }
  }
  &:active {
    {{17}}color{{/17}}: {{18}}#010203 + #040506{{/18}};
    {{19}}border{{/19}}: {{20}}$width solid black{{/20}};
  }
/* SOME COMMENT */
  {{1}}font{{/1}}: {{2}}2px/3px {{/2}}{
    {{3}}family{{/3}}: {{4}}fantasy{{/4}};
    {{5}}size{{/5}}: {{6}}1em + (2em * 3){{/6}};
  }
}
SCSS
a {
  /* SOME COMMENT */
  {{1}}font{{/1}}: {{2}}2px/3px{{/2}};
    {{3}}font-family{{/3}}: {{4}}fantasy{{/4}};
    {{5}}font-size{{/5}}: {{6}}7em{{/6}}; }
  a .special {
    {{7}}color{{/7}}: {{8}}red{{/8}}; }
    a .special:hover {
      {{9}}foo{{/9}}: {{10}}bar{{/10}};
      {{11}}cursor{{/11}}: {{12}}e-resize{{/12}};
      {{13}}color{{/13}}: {{14}}rgba(255, 0, 0, 0.8){{/14}}; }
    a .special:after {
      {{15}}content{{/15}}: {{16}}"I ate 15 pies thick!"{{/16}}; }
  a:active {
    {{17}}color{{/17}}: {{18}}#050709{{/18}};
    {{19}}border{{/19}}: {{20}}2px solid black{{/20}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_extend_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
.error {
  {{1}}border{{/1}}: {{2}}1px #f00{{/2}};
  {{3}}background-color{{/3}}: {{4}}#fdd{{/4}};
}
.seriousError {
  @extend .error;
  {{5}}border-width{{/5}}: {{6}}3px{{/6}};
}
SCSS
.error, .seriousError {
  {{1}}border{{/1}}: {{2}}1px #f00{{/2}};
  {{3}}background-color{{/3}}: {{4}}#fdd{{/4}}; }

.seriousError {
  {{5}}border-width{{/5}}: {{6}}3px{{/6}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_for_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
@for $i from 1 through 3 {
  .item-#{$i} { {{1}}width{{/1}}: {{2}}2em * $i{{/2}}; }
}
SCSS
.item-1 {
  {{1}}width{{/1}}: {{2}}2em{{/2}}; }

.item-2 {
  {{1}}width{{/1}}: {{2}}4em{{/2}}; }

.item-3 {
  {{1}}width{{/1}}: {{2}}6em{{/2}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_while_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
$i: 6;
@while $i > 0 {
  .item-#{$i} { {{1}}width{{/1}}: {{2}}2em * $i{{/2}}; }
  $i: $i - 2;
}
SCSS
.item-6 {
  {{1}}width{{/1}}: {{2}}12em{{/2}}; }

.item-4 {
  {{1}}width{{/1}}: {{2}}8em{{/2}}; }

.item-2 {
  {{1}}width{{/1}}: {{2}}4em{{/2}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_each_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
@each $animal in puma, sea-slug, egret, salamander {
  .#{$animal}-icon {
    {{1}}background-image{{/1}}: {{2}}url('/images/#{$animal}.png'){{/2}};
  }
}
SCSS
.puma-icon {
  {{1}}background-image{{/1}}: {{2}}url("/images/puma.png"){{/2}}; }

.sea-slug-icon {
  {{1}}background-image{{/1}}: {{2}}url("/images/sea-slug.png"){{/2}}; }

.egret-icon {
  {{1}}background-image{{/1}}: {{2}}url("/images/egret.png"){{/2}}; }

.salamander-icon {
  {{1}}background-image{{/1}}: {{2}}url("/images/salamander.png"){{/2}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_mixin_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
@mixin large-text {
  font: {
    {{1}}size{{/1}}: {{2}}20px{{/2}};
    {{3}}weight{{/3}}: {{4}}bold{{/4}};
  }
  {{5}}color{{/5}}: {{6}}#ff0000{{/6}};
}

.page-title {
  @include large-text;
  {{7}}padding{{/7}}: {{8}}4px{{/8}};
}

@mixin dashed-border($color, $width: {{24}}1in{{/24}}) {
  border: {
    {{9}}color{{/9}}: {{10}}$color{{/10}};
    {{11}}width{{/11}}: $width;
    {{13}}style{{/13}}: {{14}}dashed{{/14}};
  }
}

p { @include dashed-border(blue); }
h1 { @include dashed-border(blue, {{25}}2in{{/25}}); }

@mixin box-shadow($shadows...) {
  {{18}}-moz-box-shadow{{/18}}: {{19}}$shadows{{/19}};
  {{20}}-webkit-box-shadow{{/20}}: {{21}}$shadows{{/21}};
  {{22}}box-shadow{{/22}}: {{23}}$shadows{{/23}};
}

.shadows {
  @include box-shadow(0px 4px 5px #666, 2px 6px 10px #999);
}
SCSS
.page-title {
  {{1}}font-size{{/1}}: {{2}}20px{{/2}};
  {{3}}font-weight{{/3}}: {{4}}bold{{/4}};
  {{5}}color{{/5}}: {{6}}#ff0000{{/6}};
  {{7}}padding{{/7}}: {{8}}4px{{/8}}; }

p {
  {{9}}border-color{{/9}}: {{10}}blue{{/10}};
  {{11}}border-width{{/11}}: {{24}}1in{{/24}};
  {{13}}border-style{{/13}}: {{14}}dashed{{/14}}; }

h1 {
  {{9}}border-color{{/9}}: {{10}}blue{{/10}};
  {{11}}border-width{{/11}}: {{25}}2in{{/25}};
  {{13}}border-style{{/13}}: {{14}}dashed{{/14}}; }

.shadows {
  {{18}}-moz-box-shadow{{/18}}: {{19}}0px 4px 5px #666666, 2px 6px 10px #999999{{/19}};
  {{20}}-webkit-box-shadow{{/20}}: {{21}}0px 4px 5px #666666, 2px 6px 10px #999999{{/21}};
  {{22}}box-shadow{{/22}}: {{23}}0px 4px 5px #666666, 2px 6px 10px #999999{{/23}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  def test_function_sourcemap
    assert_parses_with_mapping <<'SCSS', <<'CSS'
$grid-width: 20px;
$gutter-width: 5px;

@function grid-width($n) {
  @return $n * $grid-width + ($n - 1) * $gutter-width;
}
sidebar { {{1}}width{{/1}}: {{2}}grid-width(5){{/2}}; }
SCSS
sidebar {
  {{1}}width{{/1}}: {{2}}120px{{/2}}; }

/*@ sourceMappingURL=test.css.map */
CSS
  end

  @private

  ANNOTATION_REGEX = /\{\{(\/?)(\d+)\}\}/

  def build_ranges(text, file_name = nil)
    ranges = []
    start_positions = []
    line = 1
    text.each_line do |line_text|
      match_start = 0
      while match = line_text.match(ANNOTATION_REGEX)
        closing = !match[1].empty?
        annotation_index = Integer(match[2])
        match_offsets = match.offset(0)
        offset = match_offsets[0] + 1 # Offsets are 1-based in source maps.
        assert(!closing || start_positions[annotation_index], "Closing annotation #{annotation_index} found before opening one.")
        position = Sass::Source::Position.new(line, offset)
        if closing
          ranges_for_index = ranges[annotation_index] || []
          ranges_for_index.push(Sass::Source::Range.new(start_positions[annotation_index], position, file_name))
          ranges[annotation_index] = ranges_for_index
          start_positions[annotation_index] = nil
        else
          assert(!start_positions[annotation_index], "Overlapping range annotation #{annotation_index} encountered on line #{line}")
          start_positions[annotation_index] = position
        end
        line_text.slice!(match_offsets[0], match_offsets[1] - match_offsets[0])
      end
      line += 1
    end
    ranges
  end

  def build_mapping_from_annotations(scss, css, source_file_name)
    map = Sass::Source::Map.new
    source_ranges = build_ranges(scss, source_file_name)
    target_ranges = build_ranges(css)
    (0...source_ranges.length).each do |i|
      next if !source_ranges[i]
      assert(source_ranges[i].length == 1, "Not a single source range encountered for annotation #{i}")
      source_range = source_ranges[i][0]
      assert(target_ranges[i], "No target ranges for annotation #{i}")
      target_ranges[i].each { |target_range|  map.data.push(Sass::Source::Map::Mapping.new(source_range, target_range)) }
    end
    map.data.sort! do |x, y|
      result = x.output.start_pos.line <=> y.output.start_pos.line
      next result if result != 0
      x.output.start_pos.offset <=> y.output.start_pos.offset
    end
    map
  end

  def assert_parses_with_mapping(scss, css, options={})
    scss_filename = filename_for_test(:scss)
    mapping = build_mapping_from_annotations(scss, css, scss_filename)
    scss.gsub!(ANNOTATION_REGEX, "")
    css.gsub!(ANNOTATION_REGEX, "")
    rendered, sourcemap = render_with_sourcemap(scss, options)
    assert_equal css.rstrip, rendered.rstrip
    assert_sourcemaps_equal scss, css, mapping, sourcemap
  end

  def assert_positions_equal(expected, actual, lines, message = nil)
    assert_equal(expected.line, actual.line, "#{message ? message + ": " : ""}Expected #{expected.inspect} but was #{actual.inspect}")
    assert_equal(expected.offset, actual.offset, "#{message ? message + ": " : ""}Expected #{expected.inspect} but was #{actual.inspect}\n" + lines[actual.line - 1] + "\n" + ("-" * (actual.offset - 1)) + "^")
  end

  def assert_ranges_equal(expected, actual, lines, prefix)
    assert_positions_equal(expected.start_pos, actual.start_pos, lines, prefix + " start position")
    assert_positions_equal(expected.end_pos, actual.end_pos, lines, prefix + " end position")
    assert_equal(expected.file, actual.file)
  end

  def assert_sourcemaps_equal(scss, css, expected, actual)
    assert_equal(expected.data.length, actual.data.length, dump_sourcemap_as_expectation(actual))
    scss_lines = scss.split(/\n/)
    css_lines = css.split(/\n/)
    (0...expected.data.length).each do |i|
      assert_ranges_equal(expected.data[i].input, actual.data[i].input, scss_lines, "Input")
      assert_ranges_equal(expected.data[i].output, actual.data[i].output, css_lines, "Output")
    end
  end

  def assert_parses_with_sourcemap(scss, css, sourcemap_json, options={})
    rendered, sourcemap = render_with_sourcemap(scss, options)
    assert_equal css.rstrip, rendered.rstrip
    assert_equal sourcemap_json.rstrip, sourcemap.to_json(options[:output] || "test.css")
  end

  def render_with_sourcemap(scss, options={})
    options[:syntax] ||= :scss
    munge_filename options
    engine = Sass::Engine.new(scss, options)
    engine.options[:cache] = false
    sourcemap_path = Sass::Util.sourcemap_name(options[:output] || "test.css")
    engine.render_with_sourcemap File.basename(sourcemap_path)
  end

  # The result is an interleaved array of pairs:
  #
  # [source_start_position_line, source_start_position_column, source_end_position_line, source_end_position_offset],
  # [target_start_position_line, target_start_position_column, target_end_position_line, target_end_position_offset]
  def build_mapping_from_expectation(mappings_array, source_file)
    map = Sass::Source::Map.new
    (0...mappings_array.length).step(2) do |i|
      m = Sass::Source::Map::Mapping.new(
        Sass::Source::Range.new(
          Sass::Source::Position.new(mappings_array[i][0], mappings_array[i][1]),
          Sass::Source::Position.new(mappings_array[i][2], mappings_array[i][3]),
          source_file),
        Sass::Source::Range.new(
          Sass::Source::Position.new(mappings_array[i + 1][0], mappings_array[i + 1][1]),
          Sass::Source::Position.new(mappings_array[i + 1][2], mappings_array[i + 1][3]),
          nil))
      map.data.push(m)
    end
    map
  end

  def dump_sourcemap_as_expectation(sourcemap)
    result = ""
    (0...sourcemap.data.length).each do |i|
      input_start_pos = sourcemap.data[i].input.start_pos;
      input_end_pos = sourcemap.data[i].input.end_pos;
      output_start_pos = sourcemap.data[i].output.start_pos;
      output_end_pos = sourcemap.data[i].output.end_pos;
      result << "[#{input_start_pos.line}, #{input_start_pos.offset}, #{input_end_pos.line}, #{input_end_pos.offset}], [#{output_start_pos.line}, #{output_start_pos.offset}, #{output_end_pos.line}, #{output_end_pos.offset}]#{"," if i != sourcemap.data.length - 1}\n"
    end
    result
  end
end
