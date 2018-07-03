$LOAD_PATH.append(File.expand_path(File.join("../../../../lib", __dir__)))

require 'barnes'
require 'puma'

Barnes.start(interval: 1)

run ->(env) { [200, {"Content-Type" => "text/html"}, ["Hello World!"]] }
