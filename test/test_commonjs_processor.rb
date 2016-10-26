# frozen_string_literal: true
require 'minitest/autorun'
require 'sprockets'
require 'sprockets/commonjs_processor'

class TestCommonjsProcessor < MiniTest::Test
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
    assert_match(/this.require.define\({"mod.module":function/, output[:data])
  	assert_match(/module.exports = function\(\){/, output[:data])
  	assert_match(/commonjs.js/, output[:required].first.to_s)
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
    assert_match(/this.require.define\({"mod":function/, output[:data])
    assert_match(/module.exports = function\(\){/, output[:data])
    assert_match(/commonjs.js/, output[:required].first.to_s)
  end

  def test_cache_key
    assert Sprockets::CommonjsProcessor.cache_key
  end
end