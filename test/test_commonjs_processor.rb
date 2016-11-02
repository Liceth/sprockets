# frozen_string_literal: true
require 'sprockets_test'
require 'sprockets/commonjs_processor'
require 'byebug'

class TestCommonjsProcessor < Sprockets::TestCase
  def test_wrap_commonjs_module_in_file_with_module_ext
  	environment = Sprockets::Environment.new
  	environment.append_path(File.expand_path('../../lib/assets', __FILE__))

    input = {
      content_type: 'application/javascript',
      data: "module.exports = function(){ alert('Long live the Programs!');};",
      metadata: {},
      load_path: File.expand_path("../fixtures", __FILE__),
      name: "mod.module",
      cache: Sprockets::Cache.new,
      environment: environment
    }

    assert output = Sprockets::CommonjsProcessor.call(input)
    assert_match(/require.register\("mod.module",function/, output[:data])
  	assert_match(/module.exports = function\(\){/, output[:data])
  	assert_match(/commonjs-require.js/, output[:required].first.to_s)
  end

  def test_wrap_commonjs_module_in_file_with_module_export
    environment = Sprockets::Environment.new
    environment.append_path(File.expand_path('../../lib/assets', __FILE__))

    input = {
      content_type: 'application/javascript',
      data: "module.exports = function(){ alert('Long live the Programs!');};",
      metadata: {},
      load_path: File.expand_path("../fixtures", __FILE__),
      name: "mod",
      cache: Sprockets::Cache.new,
      environment: environment
    }

    assert output = Sprockets::CommonjsProcessor.call(input)
    assert_match(/require.register\("mod",function/, output[:data])
    assert_match(/module.exports = function\(\){/, output[:data])
    assert_match(/commonjs-require.js/, output[:required].first.to_s)
  end

  def test_folder_require
    environment = Sprockets::Environment.new
    environment.append_path(File.expand_path('../../lib/assets', __FILE__))
    environment.append_path(fixture_path('default'))

    input = {
      content_type: 'application/javascript',
      data: 'require("commonjs")',
      metadata: {},
      load_path: File.expand_path("../fixtures", __FILE__),
      name: "main",
      cache: Sprockets::Cache.new,
      environment: environment
    }

    assert output = Sprockets::CommonjsProcessor.call(input)
    assert_match(/require\("commonjs\/main"\)/, output)
  end

  def test_file_require
    environment = Sprockets::Environment.new
    environment.append_path(File.expand_path('../../lib/assets', __FILE__))
    environment.append_path(fixture_path('default'))

    input = {
      content_type: 'application/javascript',
      data: 'require("commonjs/other")',
      metadata: {},
      load_path: File.expand_path("../fixtures", __FILE__),
      name: "main",
      cache: Sprockets::Cache.new,
      environment: environment
    }

    assert output = Sprockets::CommonjsProcessor.call(input)
    assert_match(/require\("commonjs\/other"\)/, output)
  end

  def test_cache_key
    assert Sprockets::CommonjsProcessor.cache_key
  end
end