module Sass::Script::Value
  # A SassScript object representing a null value.
  class Null < Base
    # Creates a new null value.
    def initialize
      super nil
    end

    # @return [Boolean] `false` (the Ruby boolean value)
    def to_bool
      false
    end

    # @return [Boolean] `true`
    def null?
      true
    end

    # @return [String] '' (An empty string)
    def to_s(opts = {})
      ''
    end

    def to_sass(opts = {})
      'null'
    end

    # Returns a string representing a null value.
    #
    # @return [String]
    def inspect
      'null'
    end
  end
end
