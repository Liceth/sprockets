# frozen_string_literal: true
module Sprockets
  class CommonjsProcessor
    VERSION = '1'

    WRAPPER = 'require.register("%s",' +
    'function(exports, require, module){' +
    '%s' +
    "})\n"

    EXTENSIONS = %w{.module .cjs}

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def self.cache_key
      @cache_key ||= "#{name}:#{VERSION}".freeze
    end

    def call(input)
      if commonjs_module?(input)
        required  = Set.new(input[:metadata][:required])
        required << input[:environment].resolve("commonjs-require.js")[0]
        { data: WRAPPER % [ File.basename(input[:name]), input[:data] ], required: required }
      else
        input[:data]
      end
    end

    private

    def commonjs_module?(input)
      EXTENSIONS.include?(File.extname(input[:name])) ||
      (input[:data] =~ /module.exports\s?=/ && input[:name] != 'commonjs-require')
    end
  end
end