require 'metaimg/track'
require 'optparse'

module Metaimg
  class TrackCommand < Struct.new(:op, :force, :recursive, :args)
    def self.from_argv(argv)
      com = new(nil, false, false, nil)
      extract_argv(com, argv)
      com
    end

    def self.extract_argv(com, argv)
      opt_parser = OptionParser.new do |parse|
        parse.banner = 'Usage: metaimg-track add|rm|reset [OPTION]... [FILE|DIR]...'
        parse.on_head(
          "\nExamples:",
          '    * track all unregistored image files in the `foo_dir`',
          '        $ metaimg-track add foo_dir',
          '',
          "    * set `#{Track::IGNORED}` for ALL image files in the `foo_dir`",
          '        $ metaimg-track rm foo_dir',
          '',
          "    * clean contents of #{Track::TRACK_FILENAME} for the `foo_dir`",
          '        $ metaimg-track reset foo_dir'
        )
        parse.separator("\nOptions:")
        desc = "force to add targets even if set as `#{Track::IGNORED}`"
        parse.on('-f', desc) do
          com.force = true
        end
        desc = 'recursively apply command to children of directories'
        parse.on('-r', desc) do
          com.recursive = true
        end
      end
      op, *args = opt_parser.parse(argv)
      unless ['add', 'rm', 'reset'].include?(op)
        STDERR.puts "unknown operation `#{op}`"
        exit(1)
      end
      com.op = op
      com.args = args
    rescue OptionParser::InvalidOption => err
      STDERR.puts err.message
      exit(1)
    end

    def run
      editor = TrackEditor.new
      args.each do |path|
        if File.directory?(path)
          case op
          when 'add'   then editor.add_dir(path, force, recursive)
          when 'rm'    then editor.rm_dir(path, recursive)
          when 'reset' then editor.reset_dir(path, recursive)
          end
        elsif File.exist?(path)
          case op
          when 'add'   then editor.add_file(path, force)
          when 'rm'    then editor.rm_file(path)
          when 'reset' then STDERR.puts 'resetting file is not supported'
          end
        else
          STDERR.puts "#{path} does not exist"
        end
      end
    end
  end
end
