require 'test_helper'

class IntegrationTest < Minitest::Test
  def test_puma
    Dir.chdir(fixture_path("rack/hello_world")) do |dir|
      WaitForIt.new("bundle exec puma", options) do |spawn|
        spawn.wait('"barnes.gauges":', 1)
        expect_spawn_to_contain(spawn, '"threads.spawned":0')
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

  def expect_spawn_to_contain(spawn, string)
    assert_equal true, !!spawn.contains?(string), "Expected #{spawn.log.read} to contain #{string.inspect} but it did not"
  end
end
