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

    ALIAS_WRAPPER = %{require.registerAlias("%s","%s")\n}

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

        nested_requires = resolve_requires(input)
        required = required + nested_requires

        alias_data = register_alias(input)
        data = (MODULE_WRAPPER % [ input[:name], input[:data] ]) + alias_data
        
        { data: data, required: required }
      else
        input[:data]
      end
    end

    private

    def resolve_requires(input)
      requires = []
      input[:data].scan(/require\(["'](.+)["']\)/).flatten.each do |require_path|
        if PathUtils.relative_path?(require_path)
          path = PathUtils.join(File.dirname(input[:name]), require_path)
          requires << input[:environment].resolve(path)[0]
        else
          requires << input[:environment].resolve(require_path)
        end
      end
      Set.new(requires)
    end

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
      return false if input[:name] == 'commonjs-require'
      EXTENSIONS.include?(File.extname(input[:name])) ||
      input[:data] =~ /\w+.exports\s?=/ ||
      input[:data] =~ /Object.defineProperty\(exports,\s*"__esModule"/
    end
  end
end