require 'rmagick'

module Metaimg
  class Thumbnail
    SIZE = 200
    UNKNOWN_IMG_PATH = File.expand_path('../../../assets/images/unknown.png', __FILE__)

    def initialize(thumbnail_dir_path)
      @thumbnail_dir_path = thumbnail_dir_path
      FileUtils.mkdir(@thumbnail_dir_path) unless File.exist?(@thumbnail_dir_path)
    end

    def thumbnail_path(sha256, track)
      source_path = track.paths(sha256)[0]
      return unknown_thumbnail_path if source_path == nil
      thum_path = make_path(sha256)
      generate_thumbnail(sha256, source_path) unless File.exist?(thum_path)
      thum_path
    end

    private

    def make_path(filename)
      @thumbnail_dir_path + '/' + filename + '.jpg'
    end

    def unknown_thumbnail_path
      path = make_path('unknown')
      generate_thumbnail('unknown', UNKNOWN_IMG_PATH) unless File.exist?(path)
      path
    end

    def generate_thumbnail(thumbnail_filename, source_path)
      original = Magick::ImageList.new(source_path)
      min_length = [original.columns, original.rows].min
      sq = original.crop(Magick::CenterGravity, 0, 0, min_length, min_length)
      sq.resize_to_fit(SIZE, SIZE).write(make_path(thumbnail_filename))
    end
  end
end
