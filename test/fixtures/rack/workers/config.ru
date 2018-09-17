$LOAD_PATH.append(File.expand_path(File.join("../../../../lib", __dir__)))

require 'puma'

run ->(env) { [200, {"Content-Type" => "text/html"}, ["Hello World!"]] }
