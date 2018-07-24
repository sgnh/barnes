require 'test_helper'

class IntegrationTest < Minitest::Test
  def test_puma
    Dir.chdir(fixture_path("rack/hello_world")) do |dir|
      WaitForIt.new("bundle exec puma", options) do |spawn|
        spawn.wait('"barnes.gauges":', 1)
        expect_spawn_to_contain(spawn, '"threads.spawned":0')
        expect_spawn_to_contain(spawn, '"using.puma":1')
      end
    end
  end

  def test_no_puma
    Dir.chdir(fixture_path("rack/no_puma")) do |dir|
      WaitForIt.new("bundle exec rackup", options) do |spawn|
        spawn.wait('"barnes.gauges":', 1)
        spawn_should_not_contain(spawn, '"using.puma":1')
      end
    end
  end

  def options
    port    = next_open_port
    options = {}
    options[:env] = {
      "DYNO"         => "web.1",
      "PORT"         => port,
      "BARNES_DEBUG" => "1"
    }
    options[:wait_for] = "Use Ctrl-C to stop"
    options
  end

  def spawn_should_not_contain(spawn, string)
    expect_spawn_to_contain(spawn, string, does_contain: false)
  end

  def expect_spawn_to_contain(spawn, string, does_contain: true)
    assert_equal does_contain, !!spawn.contains?(string), "Expected #{spawn.log.read} to contain #{string.inspect} but it did not"
  end
end
