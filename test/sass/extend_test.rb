#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'

class ExtendTest < Test::Unit::TestCase
  def test_basic
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }
CSS
.foo {a: b}
.bar {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }
CSS
.bar {@extend .foo}
.foo {a: b}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.bar {
  c: d; }
CSS
.foo {a: b}
.bar {c: d; @extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.bar {
  c: d; }
CSS
.foo {a: b}
.bar {@extend .foo; c: d}
SCSS
  end

  def test_indented_syntax
    assert_equal <<CSS, render(<<SASS, :syntax => :sass)
.foo, .bar {
  a: b; }
CSS
.foo
  a: b
.bar
  @extend .foo
SASS

    assert_equal <<CSS, render(<<SASS, :syntax => :sass)
.foo, .bar {
  a: b; }
CSS
.foo
  a: b
.bar
  @extend \#{".foo"}
SASS
  end

  def test_multiple_targets
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.blip .foo, .blip .bar {
  c: d; }
CSS
.foo {a: b}
.bar {@extend .foo}
.blip .foo {c: d}
SCSS
  end

  def test_multiple_extendees
    assert_equal <<CSS, render(<<SCSS)
.foo, .baz {
  a: b; }

.bar, .baz {
  c: d; }
CSS
.foo {a: b}
.bar {c: d}
.baz {@extend .foo; @extend .bar}
SCSS
  end

  def test_multiple_extends_with_single_extender_and_single_target
    assert_extends('.foo .bar', '.baz {@extend .foo; @extend .bar}',
      '.foo .bar, .baz .bar, .foo .baz, .baz .baz')
    assert_extends '.foo.bar', '.baz {@extend .foo; @extend .bar}', '.foo.bar, .baz'
  end

  def test_multiple_extends_with_multiple_extenders_and_single_target
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .baz .bar, .foo .bang, .baz .bang {
  a: b; }
CSS
.foo .bar {a: b}
.baz {@extend .foo}
.bang {@extend .bar}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar.baz, .baz.bang, .foo.bang {
  a: b; }
CSS
.foo.bar {a: b}
.baz {@extend .foo}
.bang {@extend .bar}
SCSS
  end

  def test_chained_extends
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar, .baz, .bip {
  a: b; }
CSS
.foo {a: b}
.bar {@extend .foo}
.baz {@extend .bar}
.bip {@extend .bar}
SCSS
  end

  def test_dynamic_extendee
    assert_extends '.foo', '.bar {@extend #{".foo"}}', '.foo, .bar'
    assert_extends('[baz^="blip12px"]', '.bar {@extend [baz^="blip#{12px}"]}',
      '[baz^="blip12px"], .bar')
  end

  def test_nested_target
    assert_extends '.foo .bar', '.baz {@extend .bar}', '.foo .bar, .foo .baz'
  end

  def test_target_with_child
    assert_extends '.foo .bar', '.baz {@extend .foo}', '.foo .bar, .baz .bar'
  end

  def test_class_unification
    assert_unification '.foo.bar', '.baz {@extend .foo}', '.foo.bar, .bar.baz' 
    assert_unification '.foo.baz', '.baz {@extend .foo}', '.baz' 
  end

  def test_id_unification
    assert_unification '.foo.bar', '#baz {@extend .foo}', '.foo.bar, .bar#baz'
    assert_unification '.foo#baz', '#baz {@extend .foo}', '#baz'
    assert_unification '.foo#baz', '#bar {@extend .foo}', '.foo#baz'
  end

  def test_universal_unification_with_simple_target
    assert_unification '.foo', '* {@extend .foo}', '.foo, *'
    assert_unification '.foo', '*|* {@extend .foo}', '.foo, *|*'
    assert_unification '.foo.bar', '* {@extend .foo}', '.bar'
    assert_unification '.foo.bar', '*|* {@extend .foo}', '.bar'
    assert_unification '.foo.bar', 'ns|* {@extend .foo}', '.foo.bar, ns|*.bar'
  end

  def test_universal_unification_with_namespaceless_universal_target
    assert_unification '*.foo', '* {@extend .foo}', '*'
    assert_unification '*.foo', '*|* {@extend .foo}', '*'
    assert_unification '*|*.foo', '* {@extend .foo}', '*|*.foo, *'
    assert_unification '*|*.foo', '*|* {@extend .foo}', '*|*'
    assert_unification '*.foo', 'ns|* {@extend .foo}', '*.foo, ns|*'
    assert_unification '*|*.foo', 'ns|* {@extend .foo}', '*|*.foo, ns|*'
  end

  def test_universal_unification_with_namespaced_universal_target
    assert_unification 'ns|*.foo', '* {@extend .foo}', 'ns|*'
    assert_unification 'ns|*.foo', '*|* {@extend .foo}', 'ns|*'
    assert_unification 'ns1|*.foo', 'ns2|* {@extend .foo}', 'ns1|*.foo'
    assert_unification 'ns|*.foo', 'ns|* {@extend .foo}', 'ns|*'
  end

  def test_universal_unification_with_namespaceless_element_target
    assert_unification 'a.foo', '* {@extend .foo}', 'a'
    assert_unification 'a.foo', '*|* {@extend .foo}', 'a'
    assert_unification '*|a.foo', '* {@extend .foo}', '*|a.foo, a'
    assert_unification '*|a.foo', '*|* {@extend .foo}', '*|a'
    assert_unification 'a.foo', 'ns|* {@extend .foo}', 'a.foo, ns|a'
    assert_unification '*|a.foo', 'ns|* {@extend .foo}', '*|a.foo, ns|a'
  end

  def test_universal_unification_with_namespaced_element_target
    assert_unification 'ns|a.foo', '* {@extend .foo}', 'ns|a'
    assert_unification 'ns|a.foo', '*|* {@extend .foo}', 'ns|a'
    assert_unification 'ns1|a.foo', 'ns2|* {@extend .foo}', 'ns1|a.foo'
    assert_unification 'ns|a.foo', 'ns|* {@extend .foo}', 'ns|a'
  end

  def test_element_unification_with_simple_target
    assert_unification '.foo', 'a {@extend .foo}', '.foo, a'
    assert_unification '.foo.bar', 'a {@extend .foo}', '.foo.bar, a.bar'
    assert_unification '.foo.bar', '*|a {@extend .foo}', '.foo.bar, *|a.bar'
    assert_unification '.foo.bar', 'ns|a {@extend .foo}', '.foo.bar, ns|a.bar'
  end

  def test_element_unification_with_namespaceless_universal_target
    assert_unification '*.foo', 'a {@extend .foo}', '*.foo, a'
    assert_unification '*.foo', '*|a {@extend .foo}', '*.foo, a'
    assert_unification '*|*.foo', 'a {@extend .foo}', '*|*.foo, a'
    assert_unification '*|*.foo', '*|a {@extend .foo}', '*|*.foo, *|a'
    assert_unification '*.foo', 'ns|a {@extend .foo}', '*.foo, ns|a'
    assert_unification '*|*.foo', 'ns|a {@extend .foo}', '*|*.foo, ns|a'
  end

  def test_element_unification_with_namespaced_universal_target
    assert_unification 'ns|*.foo', 'a {@extend .foo}', 'ns|*.foo, ns|a'
    assert_unification 'ns|*.foo', '*|a {@extend .foo}', 'ns|*.foo, ns|a'
    assert_unification 'ns1|*.foo', 'ns2|a {@extend .foo}', 'ns1|*.foo'
    assert_unification 'ns|*.foo', 'ns|a {@extend .foo}', 'ns|*.foo, ns|a'
  end

  def test_element_unification_with_namespaceless_element_target
    assert_unification 'a.foo', 'a {@extend .foo}', 'a'
    assert_unification 'a.foo', '*|a {@extend .foo}', 'a'
    assert_unification '*|a.foo', 'a {@extend .foo}', '*|a.foo, a'
    assert_unification '*|a.foo', '*|a {@extend .foo}', '*|a'
    assert_unification 'a.foo', 'ns|a {@extend .foo}', 'a.foo, ns|a'
    assert_unification '*|a.foo', 'ns|a {@extend .foo}', '*|a.foo, ns|a'
    assert_unification 'a.foo', 'h1 {@extend .foo}', 'a.foo'
  end

  def test_element_unification_with_namespaced_element_target
    assert_unification 'ns|a.foo', 'a {@extend .foo}', 'ns|a'
    assert_unification 'ns|a.foo', '*|a {@extend .foo}', 'ns|a'
    assert_unification 'ns1|a.foo', 'ns2|a {@extend .foo}', 'ns1|a.foo'
    assert_unification 'ns|a.foo', 'ns|a {@extend .foo}', 'ns|a'
  end

  def test_attribute_unification
    assert_unification '[foo=bar].baz', '[foo=baz] {@extend .baz}', '[foo=bar].baz, [foo=bar][foo=baz]'
    assert_unification '[foo=bar].baz', '[foo^=bar] {@extend .baz}', '[foo=bar].baz, [foo=bar][foo^=bar]'
    assert_unification '[foo=bar].baz', '[foot=bar] {@extend .baz}', '[foo=bar].baz, [foo=bar][foot=bar]'
    assert_unification '[foo=bar].baz', '[ns|foo=bar] {@extend .baz}', '[foo=bar].baz, [foo=bar][ns|foo=bar]'
    assert_unification '%-a [foo=bar].bar', '[foo=bar] {@extend .bar}', '-a [foo=bar]'
  end

  def test_pseudo_unification
    assert_unification ':foo.baz', ':foo(2n+1) {@extend .baz}', ':foo.baz, :foo:foo(2n+1)'
    assert_unification ':foo.baz', '::foo {@extend .baz}', ':foo.baz, :foo::foo'
    assert_unification '::foo.baz', '::bar {@extend .baz}', '::foo.baz'
    assert_unification '::foo.baz', '::foo(2n+1) {@extend .baz}', '::foo.baz'
    assert_unification '::foo.baz', '::foo {@extend .baz}', '::foo'
    assert_unification '::foo(2n+1).baz', '::foo(2n+1) {@extend .baz}', '::foo(2n+1)'
    assert_unification ':foo.baz', ':bar {@extend .baz}', ':foo.baz, :foo:bar'
    assert_unification '.baz:foo', ':after {@extend .baz}', '.baz:foo, :foo:after'
    assert_unification '.baz:after', ':foo {@extend .baz}', '.baz:after, :foo:after'
    assert_unification ':foo.baz', ':foo {@extend .baz}', ':foo'
  end

  def test_pseudoelement_remains_at_end_of_selector
    assert_extends '.foo::bar', '.baz {@extend .foo}', '.foo::bar, .baz::bar'
    assert_extends 'a.foo::bar', '.baz {@extend .foo}', 'a.foo::bar, a.baz::bar'
  end

  def test_pseudoclass_remains_at_end_of_selector
    assert_extends '.foo:bar', '.baz {@extend .foo}', '.foo:bar, .baz:bar'
    assert_extends 'a.foo:bar', '.baz {@extend .foo}', 'a.foo:bar, a.baz:bar'
  end

  def test_not_remains_at_end_of_selector
    assert_extends '.foo:not(.bar)', '.baz {@extend .foo}', '.foo:not(.bar), .baz:not(.bar)'
  end

  def test_pseudoelement_goes_lefter_than_pseudoclass
    assert_extends '.foo::bar', '.baz:bang {@extend .foo}', '.foo::bar, .baz:bang::bar'
    assert_extends '.foo:bar', '.baz::bang {@extend .foo}', '.foo:bar, .baz:bar::bang'
  end

  def test_pseudoelement_goes_lefter_than_not
    assert_extends '.foo::bar', '.baz:not(.bang) {@extend .foo}', '.foo::bar, .baz:not(.bang)::bar'
    assert_extends '.foo:not(.bang)', '.baz::bar {@extend .foo}', '.foo:not(.bang), .baz:not(.bang)::bar'
  end

  def test_negation_unification
    assert_unification ':not(.foo).baz', ':not(.bar) {@extend .baz}', ':not(.foo).baz, :not(.foo):not(.bar)'
    assert_unification ':not(.foo).baz', ':not(.foo) {@extend .baz}', ':not(.foo)'
    assert_unification ':not([a=b]).baz', ':not([a = b]) {@extend .baz}', ':not([a=b])'
  end

  def test_comma_extendee
    assert_equal <<CSS, render(<<SCSS)
.foo, .baz {
  a: b; }

.bar, .baz {
  c: d; }
CSS
.foo {a: b}
.bar {c: d}
.baz {@extend .foo, .bar}
SCSS
  end

  def test_redundant_selector_elimination
    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .x, .y {
  a: b; }
CSS
.foo.bar {a: b}
.x {@extend .foo, .bar}
.y {@extend .foo, .bar}
SCSS
  end

  ## Long Extendees

  def test_long_extendee
    assert_extends '.foo.bar', '.baz {@extend .foo.bar}', '.foo.bar, .baz'
  end

  def test_long_extendee_requires_all_selectors
    assert_warning(<<MESSAGE) { assert_extends '.foo', '.baz {@extend .foo.bar}', '.foo' }
WARNING on line 2 of test_long_extendee_requires_all_selectors_inline.scss:
  Missing selector .foo.bar not found for @extend of .baz.
  This will become an error in a future release.
  To allow this condition, change to:
    @extend .foo.bar !optional
MESSAGE
  end

  def test_long_extendee_matches_supersets
    assert_extends '.foo.bar.bap', '.baz {@extend .foo.bar}', '.foo.bar.bap, .bap.baz'
  end

  def test_long_extendee_runs_unification
    assert_extends 'ns|*.foo.bar', 'a.baz {@extend .foo.bar}', 'ns|*.foo.bar, ns|a.baz'
  end

  ## Long Extenders

  def test_long_extender
    assert_extends '.foo.bar', '.baz.bang {@extend .foo}', '.foo.bar, .bar.baz.bang'
  end

  def test_long_extender_runs_unification
    assert_extends 'ns|*.foo.bar', 'a.baz {@extend .foo}', 'ns|*.foo.bar, ns|a.bar.baz'
  end

  def test_long_extender_aborts_unification
    assert_extends 'a.foo#bar', 'h1.baz {@extend .foo}', 'a.foo#bar'
    assert_extends 'a.foo#bar', '.bang#baz {@extend .foo}', 'a.foo#bar'
  end

  ## Nested Extenders

  def test_nested_extender
    assert_extends '.foo', 'foo bar {@extend .foo}', '.foo, foo bar'
  end

  def test_nested_extender_runs_unification
    assert_extends '.foo.bar', 'foo bar {@extend .foo}', '.foo.bar, foo bar.bar'
  end

  def test_nested_extender_aborts_unification
    assert_extends 'baz.foo', 'foo bar {@extend .foo}', 'baz.foo'
  end

  def test_nested_extender_alternates_parents
    assert_extends('.baz .bip .foo', 'foo .grank bar {@extend .foo}',
      '.baz .bip .foo, .baz .bip foo .grank bar, foo .grank .baz .bip bar')
  end

  def test_nested_extender_unifies_identical_parents
    assert_extends('.baz .bip .foo', '.baz .bip bar {@extend .foo}',
      '.baz .bip .foo, .baz .bip bar')
  end

  def test_nested_extender_unifies_common_substring
    assert_extends('.baz .bip .bap .bink .foo', '.brat .bip .bap bar {@extend .foo}',
      '.baz .bip .bap .bink .foo, .baz .brat .bip .bap .bink bar, .brat .baz .bip .bap .bink bar')
  end

  def test_nested_extender_unifies_common_subseq
    assert_extends('.a .x .b .y .foo', '.a .n .b .m bar {@extend .foo}',
      '.a .x .b .y .foo, .a .x .n .b .y .m bar, .a .n .x .b .y .m bar, .a .x .n .b .m .y bar, .a .n .x .b .m .y bar')
  end

  def test_nested_extender_chooses_first_subseq
    assert_extends('.a .b .c .d .foo', '.c .d .a .b .bar {@extend .foo}',
      '.a .b .c .d .foo, .a .b .c .d .a .b .bar')
  end

  def test_nested_extender_counts_extended_subselectors
    assert_extends('.a .bip.bop .foo', '.b .bip .bar {@extend .foo}',
      '.a .bip.bop .foo, .a .b .bip.bop .bar, .b .a .bip.bop .bar')
  end

  def test_nested_extender_counts_extended_superselectors
    assert_extends('.a .bip .foo', '.b .bip.bop .bar {@extend .foo}',
      '.a .bip .foo, .a .b .bip.bop .bar, .b .a .bip.bop .bar')
  end

  def test_nested_extender_with_child_selector
    assert_extends '.baz .foo', 'foo > bar {@extend .foo}', '.baz .foo, .baz foo > bar'
  end

  def test_nested_extender_finds_common_selectors_around_child_selector
    assert_extends 'a > b c .c1', 'a c .c2 {@extend .c1}', 'a > b c .c1, a > b c .c2'
    assert_extends 'a > b c .c1', 'b c .c2 {@extend .c1}', 'a > b c .c1, a > b c .c2'
  end

  def test_nested_extender_doesnt_find_common_selectors_around_adjacent_sibling_selector
    assert_extends 'a + b c .c1', 'a c .c2 {@extend .c1}', 'a + b c .c1, a + b a c .c2, a a + b c .c2'
    assert_extends 'a + b c .c1', 'a b .c2 {@extend .c1}', 'a + b c .c1, a a + b c .c2'
    assert_extends 'a + b c .c1', 'b c .c2 {@extend .c1}', 'a + b c .c1, a + b c .c2'
  end

  def test_nested_extender_doesnt_find_common_selectors_around_sibling_selector
    assert_extends 'a ~ b c .c1', 'a c .c2 {@extend .c1}', 'a ~ b c .c1, a ~ b a c .c2, a a ~ b c .c2'
    assert_extends 'a ~ b c .c1', 'a b .c2 {@extend .c1}', 'a ~ b c .c1, a a ~ b c .c2'
    assert_extends 'a ~ b c .c1', 'b c .c2 {@extend .c1}', 'a ~ b c .c1, a ~ b c .c2'
  end

  def test_nested_extender_with_early_child_selectors_doesnt_subseq_them
    assert_extends('.bip > .bap .foo', '.grip > .bap .bar {@extend .foo}',
      '.bip > .bap .foo, .bip > .bap .grip > .bap .bar, .grip > .bap .bip > .bap .bar')
    assert_extends('.bap > .bip .foo', '.bap > .grip .bar {@extend .foo}',
      '.bap > .bip .foo, .bap > .bip .bap > .grip .bar, .bap > .grip .bap > .bip .bar')
  end

  def test_nested_extender_with_child_selector_unifies
    assert_extends '.baz.foo', 'foo > bar {@extend .foo}', '.baz.foo, foo > bar.baz'

    assert_equal <<CSS, render(<<SCSS)
.baz > .foo, .baz > .bar {
  a: b; }
CSS
.baz > {
  .foo {a: b}
  .bar {@extend .foo}
}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .foo > .baz {
  a: b; }
CSS
.foo {
  .bar {a: b}
  > .baz {@extend .bar}
}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .foo .bip > .baz {
  a: b; }
CSS
.foo {
  .bar {a: b}
  .bip > .baz {@extend .bar}
}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo .bip .bar, .foo .bip .foo > .baz {
  a: b; }
CSS
.foo {
  .bip .bar {a: b}
  > .baz {@extend .bar}
}
SCSS

    assert_extends '.foo > .bar', '.bip + .baz {@extend .bar}', '.foo > .bar, .foo > .bip + .baz'
    assert_extends '.foo + .bar', '.bip > .baz {@extend .bar}', '.foo + .bar, .bip > .foo + .baz'
    assert_extends '.foo > .bar', '.bip > .baz {@extend .bar}', '.foo > .bar, .bip.foo > .baz'
  end

  def test_nested_extender_with_trailing_child_selector
    assert_raise(Sass::SyntaxError, "bar > can't extend: invalid selector") do
      render("bar > {@extend .baz}")
    end
  end

  def test_nested_extender_with_sibling_selector
    assert_extends '.baz .foo', 'foo + bar {@extend .foo}', '.baz .foo, .baz foo + bar'
  end

  def test_nested_extender_with_hacky_selector
    assert_extends('.baz .foo', 'foo + > > + bar {@extend .foo}',
      '.baz .foo, .baz foo + > > + bar, foo .baz + > > + bar')
    assert_extends '.baz .foo', '> > bar {@extend .foo}', '.baz .foo, > > .baz bar'
  end

  def test_nested_extender_merges_with_same_selector
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .foo .baz {
  a: b; }
CSS
.foo {
  .bar {a: b}
  .baz {@extend .bar} }
SCSS
  end

  def test_nested_extender_with_child_selector_merges_with_same_selector
    assert_extends('.foo > .bar .baz', '.foo > .bar .bang {@extend .baz}',
      '.foo > .bar .baz, .foo > .bar .bang')
  end

  # Combinator Unification

  def test_combinator_unification_for_hacky_combinators
    assert_extends '.a > + x', '.b y {@extend x}', '.a > + x, .a .b > + y, .b .a > + y'
    assert_extends '.a x', '.b > + y {@extend x}', '.a x, .a .b > + y, .b .a > + y'
    assert_extends '.a > + x', '.b > + y {@extend x}', '.a > + x, .a .b > + y, .b .a > + y'
    assert_extends '.a ~ > + x', '.b > + y {@extend x}', '.a ~ > + x, .a .b ~ > + y, .b .a ~ > + y'
    assert_extends '.a + > x', '.b > + y {@extend x}', '.a + > x'
    assert_extends '.a + > x', '.b > + y {@extend x}', '.a + > x'
    assert_extends '.a ~ > + .b > x', '.c > + .d > y {@extend x}', '.a ~ > + .b > x, .a .c ~ > + .d.b > y, .c .a ~ > + .d.b > y'
  end

  def test_combinator_unification_double_tilde
    assert_extends '.a.b ~ x', '.a ~ y {@extend x}', '.a.b ~ x, .a.b ~ y'
    assert_extends '.a ~ x', '.a.b ~ y {@extend x}', '.a ~ x, .a.b ~ y'
    assert_extends '.a ~ x', '.b ~ y {@extend x}', '.a ~ x, .a ~ .b ~ y, .b ~ .a ~ y, .b.a ~ y'
    assert_extends 'a.a ~ x', 'b.b ~ y {@extend x}', 'a.a ~ x, a.a ~ b.b ~ y, b.b ~ a.a ~ y'
  end

  def test_combinator_unification_tilde_plus
    assert_extends '.a.b + x', '.a ~ y {@extend x}', '.a.b + x, .a.b + y'
    assert_extends '.a + x', '.a.b ~ y {@extend x}', '.a + x, .a.b ~ .a + y, .a.b + y'
    assert_extends '.a + x', '.b ~ y {@extend x}', '.a + x, .b ~ .a + y, .b.a + y'
    assert_extends 'a.a + x', 'b.b ~ y {@extend x}', 'a.a + x, b.b ~ a.a + y'
    assert_extends '.a.b ~ x', '.a + y {@extend x}', '.a.b ~ x, .a.b ~ .a + y, .a.b + y'
    assert_extends '.a ~ x', '.a.b + y {@extend x}', '.a ~ x, .a.b + y'
    assert_extends '.a ~ x', '.b + y {@extend x}', '.a ~ x, .a ~ .b + y, .a.b + y'
    assert_extends 'a.a ~ x', 'b.b + y {@extend x}', 'a.a ~ x, a.a ~ b.b + y'
  end

  def test_combinator_unification_angle_sibling
    assert_extends '.a > x', '.b ~ y {@extend x}', '.a > x, .a > .b ~ y'
    assert_extends '.a > x', '.b + y {@extend x}', '.a > x, .a > .b + y'
    assert_extends '.a ~ x', '.b > y {@extend x}', '.a ~ x, .b > .a ~ y'
    assert_extends '.a + x', '.b > y {@extend x}', '.a + x, .b > .a + y'
  end

  def test_combinator_unification_double_angle
    assert_extends '.a.b > x', '.b > y {@extend x}', '.a.b > x, .b.a > y'
    assert_extends '.a > x', '.a.b > y {@extend x}', '.a > x, .a.b > y'
    assert_extends '.a > x', '.b > y {@extend x}', '.a > x, .b.a > y'
    assert_extends 'a.a > x', 'b.b > y {@extend x}', 'a.a > x'
  end

  def test_combinator_unification_double_plus
    assert_extends '.a.b + x', '.b + y {@extend x}', '.a.b + x, .b.a + y'
    assert_extends '.a + x', '.a.b + y {@extend x}', '.a + x, .a.b + y'
    assert_extends '.a + x', '.b + y {@extend x}', '.a + x, .b.a + y'
    assert_extends 'a.a + x', 'b.b + y {@extend x}', 'a.a + x'
  end

  def test_combinator_unification_angle_space
    assert_extends '.a.b > x', '.a y {@extend x}', '.a.b > x, .a.b > y'
    assert_extends '.a > x', '.a.b y {@extend x}', '.a > x, .a.b .a > y'
    assert_extends '.a > x', '.b y {@extend x}', '.a > x, .b .a > y'
    assert_extends '.a.b x', '.a > y {@extend x}', '.a.b x, .a.b .a > y'
    assert_extends '.a x', '.a.b > y {@extend x}', '.a x, .a.b > y'
    assert_extends '.a x', '.b > y {@extend x}', '.a x, .a .b > y'
  end

  def test_combinator_unification_plus_space
    assert_extends '.a.b + x', '.a y {@extend x}', '.a.b + x, .a .a.b + y'
    assert_extends '.a + x', '.a.b y {@extend x}', '.a + x, .a.b .a + y'
    assert_extends '.a + x', '.b y {@extend x}', '.a + x, .b .a + y'
    assert_extends '.a.b x', '.a + y {@extend x}', '.a.b x, .a.b .a + y'
    assert_extends '.a x', '.a.b + y {@extend x}', '.a x, .a .a.b + y'
    assert_extends '.a x', '.b + y {@extend x}', '.a x, .a .b + y'
  end

  def test_combinator_unification_nested
    assert_extends '.a > .b + x', '.c > .d + y {@extend x}', '.a > .b + x, .c.a > .d.b + y'
    assert_extends '.a > .b + x', '.c > y {@extend x}', '.a > .b + x, .c.a > .b + y'
  end

  def test_combinator_unification_with_newlines
    assert_equal <<CSS, render(<<SCSS)
.a >
.b
+ x, .c.a > .d.b + y {
  a: b; }
CSS
.a >
.b
+ x {a: b}
.c
> .d +
y {@extend x}
SCSS
  end

  # Loops

  def test_extend_self_loop
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
.foo {a: b; @extend .foo}
SCSS
  end

  def test_basic_extend_loop
    assert_equal <<CSS, render(<<SCSS)
.bar, .foo {
  a: b; }

.foo, .bar {
  c: d; }
CSS
.foo {a: b; @extend .bar}
.bar {c: d; @extend .foo}
SCSS
  end

  def test_three_level_extend_loop
    assert_equal <<CSS, render(<<SCSS)
.baz, .bar, .foo {
  a: b; }

.foo, .baz, .bar {
  c: d; }

.bar, .foo, .baz {
  e: f; }
CSS
.foo {a: b; @extend .bar}
.bar {c: d; @extend .baz}
.baz {e: f; @extend .foo}
SCSS
  end

  def test_nested_extend_loop
    assert_equal <<CSS, render(<<SCSS)
.bar, .bar .foo {
  a: b; }
  .bar .foo {
    c: d; }
CSS
.bar {
  a: b;
  .foo {c: d; @extend .bar}
}
SCSS
  end

  def test_multiple_extender_merges_with_superset_selector
    assert_equal <<CSS, render(<<SCSS)
a.bar.baz, a.foo {
  a: b; }
CSS
.foo {@extend .bar; @extend .baz}
a.bar.baz {a: b}
SCSS
  end

  def test_control_flow_if
    assert_equal <<CSS, render(<<SCSS)
.true, .also-true {
  color: green; }

.false, .also-false {
  color: red; }
CSS
.true  { color: green; }
.false { color: red;   }
.also-true {
  @if true { @extend .true;  }
  @else    { @extend .false; }
}
.also-false {
  @if false { @extend .true;  }
  @else     { @extend .false; }
}
SCSS
  end

  def test_control_flow_for
    assert_equal <<CSS, render(<<SCSS)
.base-0, .added {
  color: green; }

.base-1, .added {
  display: block; }

.base-2, .added {
  border: 1px solid blue; }
CSS
.base-0  { color: green; }
.base-1  { display: block; }
.base-2  { border: 1px solid blue; }
.added {
  @for $i from 0 to 3 {
    @extend .base-\#{$i};
  }
}
SCSS
  end

  def test_control_flow_while
    assert_equal <<CSS, render(<<SCSS)
.base-0, .added {
  color: green; }

.base-1, .added {
  display: block; }

.base-2, .added {
  border: 1px solid blue; }
CSS
.base-0  { color: green; }
.base-1  { display: block; }
.base-2  { border: 1px solid blue; }
.added {
  $i : 0;
  @while $i < 3 {
    @extend .base-\#{$i};
    $i : $i + 1;
  }
}
SCSS
  end

  def test_basic_placeholder_selector
    assert_extends '%foo', '.bar {@extend %foo}', '.bar'
  end

  def test_unused_placeholder_selector
    assert_equal <<CSS, render(<<SCSS)
.baz {
  color: blue; }
CSS
%foo {color: blue}
%bar {color: red}
.baz {@extend %foo}
SCSS
  end

  def test_placeholder_descendant_selector
    assert_extends '#context %foo a', '.bar {@extend %foo}', '#context .bar a'
  end

  def test_semi_placeholder_selector
    assert_equal <<CSS, render(<<SCSS)
.bar .baz {
  color: blue; }
CSS
#context %foo, .bar .baz {color: blue}
SCSS
  end

  def test_placeholder_selector_with_multiple_extenders
    assert_equal <<CSS, render(<<SCSS)
.bar, .baz {
  color: blue; }
CSS
%foo {color: blue}
.bar {@extend %foo}
.baz {@extend %foo}
SCSS
  end

  def test_placeholder_selector_as_modifier
    assert_equal <<CSS, render(<<SCSS)
a.baz.bar {
  color: blue; }
CSS
a%foo.baz {color: blue}
.bar {@extend %foo}
div {@extend %foo}
SCSS
  end

  def test_placeholder_interpolation
    assert_equal <<CSS, render(<<SCSS)
.bar {
  color: blue; }
CSS
$foo: foo;

%\#{$foo} {color: blue}
.bar {@extend %foo}
SCSS
  end

  def test_media_in_placeholder_selector
    assert_equal <<CSS, render(<<SCSS)
.baz {
  c: d; }
CSS
%foo {bar {@media screen {a: b}}}
.baz {c: d}
SCSS
  end

  # Regression Tests

  def test_newline_near_combinator
    assert_equal <<CSS, render(<<SCSS)
.a +
.b x, .a +
.b .c y, .c .a +
.b y {
  a: b; }
CSS
.a +
.b x {a: b}
.c y {@extend x}
SCSS
  end

  def test_duplicated_selector_with_newlines
    assert_equal(<<CSS, render(<<SCSS))
.example-1-1,
.example-1-2,
.my-page-1 .my-module-1-1,
.example-1-3 {
  a: b; }
CSS
.example-1-1,
.example-1-2,
.example-1-3 {
  a: b;
}

.my-page-1 .my-module-1-1 {@extend .example-1-2}
SCSS
  end

  def test_nested_selector_with_child_selector_hack_extendee
    assert_extends '> .foo', 'foo bar {@extend .foo}', '> .foo, > foo bar'
  end

  def test_nested_selector_with_child_selector_hack_extender
    assert_extends '.foo .bar', '> foo bar {@extend .bar}', '.foo .bar, > .foo foo bar, > foo .foo bar'
  end

  def test_nested_selector_with_child_selector_hack_extender_and_extendee
    assert_extends '> .foo', '> foo bar {@extend .foo}', '> .foo, > foo bar'
  end

  def test_nested_selector_with_child_selector_hack_extender_and_sibling_selector_extendee
    assert_extends '~ .foo', '> foo bar {@extend .foo}', '~ .foo'
  end

  def test_nested_selector_with_child_selector_hack_extender_and_extendee_and_newline
    assert_equal <<CSS, render(<<SCSS)
> .foo, > flip,
> foo bar {
  a: b; }
CSS
> .foo {a: b}
flip,
> foo bar {@extend .foo}
SCSS
  end

  def test_extended_parent_and_child_redundancy_elimination
    assert_equal <<CSS, render(<<SCSS)
a b, d b, a c, d c {
  a: b; }
CSS
a {
  b {a: b}
  c {@extend b}
}
d {@extend a}
SCSS
  end

  def test_extend_redundancy_elimination_when_it_would_reduce_specificity
    assert_extends 'a', 'a.foo {@extend a}', 'a, a.foo'
  end

  def test_extend_redundancy_elimination_when_it_would_preserve_specificity
    assert_extends '.bar a', 'a.foo {@extend a}', '.bar a'
  end

  def test_extend_redundancy_elimination_never_eliminates_base_selector
    assert_extends 'a.foo', '.foo {@extend a}', 'a.foo, .foo'
  end

  def test_extend_cross_branch_redundancy_elimination
    assert_equal <<CSS, render(<<SCSS)
a c d, b c a d {
  a: b; }
CSS
%x c %y {a: b}
a, b {@extend %x}
a d {@extend %y}
SCSS

    assert_equal <<CSS, render(<<SCSS)
e a c d, a c e d, e b c a d, b c a e d {
  a: b; }
CSS
e %z {a: b}
%x c %y {@extend %z}
a, b {@extend %x}
a d {@extend %y}
SCSS
  end

  def test_extend_warns_when_base_class_not_found
    assert_warning(<<MESSAGE) { render(".foo { @extend .base; }") }
WARNING on line 1 of test_extend_warns_when_base_class_not_found_inline.scss:
  Missing selector .base not found for @extend of .foo.
  This will become an error in a future release.
  To allow this condition, change to:
    @extend .base !optional
MESSAGE
  end

  def test_extend_does_not_warn_when_base_class_is_found
    assert_no_warnings { render(".base {a:b;} .foo { @extend .base; }") }
  end

  def test_extend_does_not_warn_when_optional
    assert_no_warnings { render(".foo { @extend .base !optional; }") }
  end

  def test_extend_does_not_warn_when_optional_in_sass
    assert_no_warnings { render(<<SASS, :syntax => :sass) }
.foo
  @extend .base !optional
SASS
  end

  private

  def assert_unification(selector, extension, unified)
    # Do some trickery so the first law of extend doesn't get in our way.
    assert_extends(
      "%-a #{selector}",
      extension + " -a {@extend %-a}",
      unified.split(', ').map {|s| "-a #{s}"}.join(', '))
  end

  def assert_extends(selector, extension, result)
    assert_equal <<CSS, render(<<SCSS)
#{result} {
  a: b; }
CSS
#{selector} {a: b}
#{extension}
SCSS
  end

  def render(sass, options = {})
    options = {:syntax => :scss}.merge(options)
    munge_filename options
    Sass::Engine.new(sass, options).render
  end
end
