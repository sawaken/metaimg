require 'optparse'

module Metaimg
  class ServerConfig < Struct.new(
    :metaimg_home_dir, :root_dir, :port, :only_local
  )
    def self.from_argv(argv)
      config = new(ENV['HOME'] + '/.metaimg', Dir::pwd, 50000, false)
      extract_argv(config, argv)
      config
    end

    def self.extract_argv(config, argv)
      opt_parser = OptionParser.new do |parse|
        desc = 'specify metaimg home directory (default is ~/.metaimg)'
        parse.on('--home=DIR_PATH', desc) do |dir_path|
          config.metaimg_home_dir = dir_path
        end
        desc = 'specify root directory to take image files (default is cur-dir)'
        parse.on('--root=DIR_PATH', desc) do |dir_path|
          config.root_dir = dir_path
        end
        desc = 'specify port for web server to listen'
        parse.on('--port=NUMBER', desc) do |number|
          config.port = number
        end
        desc = 'allow only access from localhost'
        parse.on('--only-local', desc) do
          config.only_local = true
        end
      end
      opt_parser.parse(argv)
    rescue OptionParser::InvalidOption => err
      STDERR.puts err.message
      exit(1)
    end
  end
end
