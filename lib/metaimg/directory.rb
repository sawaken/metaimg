module Metaimg
  class Directory
    ImgExts = [
      'jpg', 'jpeg', 'JPG', 'JPEG', 'png', 'PNG', 'gif', 'GIF', 'bmp', 'BMP'
    ]
    DirInTheDir = Struct.new(:date, :name)
    ImgInTheDir = Struct.new(:date, :sha256)

    def initialize(root_dir)
      @root_dir = root_dir
    end

    def dirs(dir_path)
      return [] unless showable_path?(dir_path)
      Dir.glob("#{@root_dir}/#{dir_path}/**").flat_map do |path|
        path = File.expand_path(path)
        next [] unless File.directory?(path)
        [DirInTheDir.new(File.mtime(path), File.basename(path))]
      end
    end

    def imgs(dir_path, track)
      return [] unless showable_path?(dir_path)
      paths = Dir.glob("#{@root_dir}/#{dir_path}/**/*.{#{ImgExts.join(',')}}")
      .map { |path| File.expand_path(path) }
      paths.select { |path| track.sha256(path) }.map do |path|
        ImgInTheDir.new(File.mtime(path), track.sha256(path))
      end
    end

    private

    def calc_sha256(img_path)
      Digest::SHA256.file(img_path).hexdigest
    end

    def showable_path?(dir_path)
      File.exist?("#{@root_dir}/#{dir_path}/#{Track::TRACK_FILENAME}")
    end
  end
end
