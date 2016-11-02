# frozen_string_literal: true
require 'byebug'
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
        data = WRAPPER % [ input[:name], input[:data] ]
        data = normalize_commonjs_requires(input[:environment], data)
        { data: data, required: required }
      else
        normalize_commonjs_requires(input[:environment], input[:data])
      end
    end

    private

    def commonjs_module?(input)
      EXTENSIONS.include?(File.extname(input[:name])) ||
      (input[:data] =~ /module.exports\s?=/ && input[:name] != 'commonjs-require')
    end

    def normalize_commonjs_requires(env, input)
      input.gsub(/require\([""'](.+)[""']\)/) do |file|
        env[$1] ? %Q{require("#{resolve_asset(env[$1])}")} : file 
      end
    end

    def resolve_asset(asset)
      logical_path = asset.logical_path
      logical_path.sub(File.extname(logical_path), "")
    end
  end
end