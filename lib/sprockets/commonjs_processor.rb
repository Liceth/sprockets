# frozen_string_literal: true
require 'byebug'
require 'sprockets/path_utils'

module Sprockets
  class CommonjsProcessor
    VERSION = '1'

    MODULE_WRAPPER = 'require.register("%s",' +
    'function(exports, require, module){' +
    '%s' +
    "})\n"

    ALIAS_WRAPPER = 'require.registerAlias("%s","%s")\\n'

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
      byebug
      if commonjs_module?(input)
        required  = Set.new(input[:metadata][:required])
        required << input[:environment].resolve("commonjs-require.js")[0]
        extra_data = register_alias(input)
        data = MODULE_WRAPPER % [ input[:name], input[:data] ]
        { data: data + extra_data, required: required }
      else
        input[:data]
      end
    end

    private

    def register_alias(input)
      package_name = File.dirname(input[:name])
      dirname = File.dirname(input[:filename])
      filename = File.join(dirname, 'package.json')

      if PathUtils.file?(filename)
        package = JSON.parse(File.read(filename), create_additions: false)
        main = case package['main']
        when String
          package['main'].sub(File.extname(package['main']), "")
        when nil
          'index'
        end
        package_alias = package_name + "/" + main
        ALIAS_WRAPPER % [ package_name, package_alias ]
      else
        ""
      end
    end

    def commonjs_module?(input)
      EXTENSIONS.include?(File.extname(input[:name])) ||
      (input[:data] =~ /module.exports\s?=/ && input[:name] != 'commonjs-require')
    end

    def resolve_asset(asset)
      logical_path = asset.logical_path
      logical_path.sub(File.extname(logical_path), "")
    end
  end
end