APP_PATH = File.join(File.dirname(File.expand_path(__FILE__)), '..')

working_directory APP_PATH
pid APP_PATH + "/tmp/unicorn.pid"

listen 8080
