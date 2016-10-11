require 'json'
require 'sinatra/base'
require "metaimg/tags"
require "metaimg/track"
require "metaimg/directory"
require "metaimg/thumbnail"

module Metaimg
  class Server < Sinatra::Base
    def self.init(config)
      unless File.exist?(config.metaimg_home_dir)
        FileUtils.mkdir(config.metaimg_home_dir)
      end
      set :tags, Tags.new(config.metaimg_home_dir + '/metaimg.db')
      set :track, Track.new(config.root_dir)
      set :directory, Directory.new(config.root_dir)
      set :thumbnail, Thumbnail.new(config.metaimg_home_dir + '/thumbnails')
      set :port, config.port
      set :bind, '0.0.0.0' unless config.only_local
    end

    not_found do
      'Not found'
    end

    # returns
    # [{
    #   'date': LatestUpDate,
    #   'symbol': Symbol,
    #   'point': AccumPoint
    # }]

    get '/symbols' do
      settings.tags.symbol_tags.map(&:to_h).to_json
    end

    get '/symbols/:sha256' do
      settings.tags.find_symbol_tags(params[:sha256]).map(&:to_h).to_json
    end

    # returns
    # [{
    #   'sha256': SHA256,
    #   'date': LatestUpDate,
    #   'point': AccumPoint
    # }]

    get '/sha256s/:symbol' do
      settings.tags.find_sha256_tags(params[:symbol]).map(&:to_h).to_json
    end

    # returns a thumbnail

    get '/thumbnail/:sha256' do
      sha256 = params[:sha256]
      send_file(settings.thumbnail.thumbnail_path(sha256, settings.track))
    end

    # returns a raw image

    get '/raw/:sha256' do
      sha256 = params[:sha256]
      send_file(settings.track.paths(sha256)[0] || Thumbnail::UNKNOWN_IMG_PATH)
    end

    # returns
    # [{
    #   'date': LastModifiedDate
    #   'name': SubDirName
    # }]

    get '/dirs/**' do
      dir_path = params['splat'][1]
      settings.directory.dirs(dir_path).map(&:to_h).to_json
    end

    # returns
    # [{
    #   'date': LastModifiedDate
    #   'sha256': SHA256
    # }]

    get '/imgs/**' do
      dir_path = params['splat'][1]
      settings.directory.imgs(dir_path, settings.track).map(&:to_h).to_json
    end

    # add a tag

    put '/add/:sha256/:symbol/:point' do
      result = settings.tags.increase_tag(
        params[:sha256], params[:symbol], params[:point].to_i
      )
      if result
        status 200
      else
        status 400
      end
    end
  end
end
