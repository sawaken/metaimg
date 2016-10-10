require 'yaml'
require 'digest'

module Metaimg
  class Track
    TRACK_FILENAME = '.metaimg_track.yml'
    IGNORED = 'IGNORED'

    def initialize(root_dir)
      @dictionary = Hash.new { |hash, key| hash[key] = [] }
      @reverse_dictionary = {}
      Dir.glob(root_dir + "/**/#{TRACK_FILENAME}") do |path|
        dir_path = File.dirname(path)
        YAML.load(File.read(path)).each do |filename, value|
          next if value == IGNORED
          file_path = dir_path + '/' + filename
          @dictionary[value] << file_path
          @reverse_dictionary[file_path] = value
        end
      end
    end

    def paths(sha256)
      @dictionary[sha256]
    end

    def sha256(path)
      @reverse_dictionary[path]
    end
  end

  class TrackEditor
    def add_dir(dir_path, force = false, recursive = false)
      traverse_imgs(dir_path, recursive) do |ch_dir_path, img_filenames|
        add_files(ch_dir_path, img_filenames, force)
      end
    end

    def add_file(file_path, force = false)
      add_files(File.dirname(file_path), [File.basename(file_path)], force)
    end

    def rm_dir(dir_path, recursive = false)
      traverse_imgs(dir_path, recursive) do |ch_dir_path, img_filenames|
        rm_files(ch_dir_path, img_filenames)
      end
    end

    def rm_file(file_path)
      rm_files(File.dirname(file_path), [File.basename(file_path)])
    end

    def reset_dir(dir_path, recursive = false)
      change_trackfile(dir_path) { Hash.new }
      if recursive
        Dir.glob(dirpath + '/**') { |path| reset_dir(path, recursive) }
      end
    end

    private

    def traverse_imgs(dir_path, recursive, &block)
      img_paths = Dir.glob(dir_path + "/*.{#{Directory::ImgExts.join(',')}}")
      .map { |path| File.expand_path(path) }
      block.call(dir_path, img_paths.map { |path| File.basename(path) })
      if recursive
        Dir.glob(dir_path + '/**') do |ch_dir_path|
          traverse_imgs(ch_dir_path, true, &block)
        end
      end
    end

    def add_files(dir_path, filenames, force)
      change_trackfile(dir_path) do |cur_config|
        filenames.each_with_object(cur_config) do |filename, conf|
          if !conf.key?(filename) || (force && conf[filename] == Track::IGNORED)
            conf[filename] = calc_sha256(dir_path + '/' + filename)
          end
        end
      end
    end

    def rm_files(dir_path, filenames)
      change_trackfile(dir_path) do |cur_config|
        filenames.each_with_object(cur_config) do |filename, conf|
          conf[filename] = Track::IGNORED
        end
      end
    end

    def change_trackfile(dir_path, &block)
      yaml_path = dir_path + '/' + Track::TRACK_FILENAME
      cur_config = File.exist?(yaml_path) ? YAML.load(File.read(yaml_path)) : {}
      alt_config = block.call(cur_config)
      File.write(yaml_path, YAML.dump(alt_config))
    end

    def calc_sha256(file_path)
      Digest::SHA256.file(file_path).hexdigest
    end
  end
end
