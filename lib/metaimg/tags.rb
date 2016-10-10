require 'sequel'

module Metaimg
  class Tags
    SHA256Tag = Struct.new(:sha256, :point, :date)
    SymbolTag = Struct.new(:symbol, :point, :date)

    def initialize(db_file_path)
      @tags = init_table(db_file_path)
    end

    def find_symbol_tags(sha256)
      @tags.where( :sha256 => sha256 ).where { point > 0 }.map do |h|
        SymbolTag.new(h[:symbol], h[:point], h[:last_update])
      end
    end

    def find_sha256_tags(symbol)
      @tags.where( :symbol => symbol ).where { point > 0 }.map do |h|
        SHA256Tag.new(h[:sha256], h[:point], h[:last_update])
      end
    end

    def symbol_tags
      elements = [
        :symbol,
        Sequel.function(:sum, :point),
        Sequel.function(:max, :last_update)
      ]
      @tags.select(*elements).group_by(:symbol).map do |h|
        SymbolTag.new(h[:symbol], h[:'sum(`point`)'], h[:'max(`last_update`)'])
      end
    end

    def increase_tag(sha256, symbol, additional_point)
      target = @tags.where( :sha256 => sha256, :symbol => symbol )
      if target.empty?
        @tags.insert(
          :sha256 => sha256, :symbol => symbol, :point => additional_point,
          :last_update => Time.now
        )
      else
        target.update(
          :point => Sequel[:point] + additional_point,
          :last_update => Time.now
        )
      end
    end

    private

    def init_table(db_file_path)
      db = Sequel.sqlite(db_file_path)
      unless db.table_exists?(:tags)
        db.create_table :tags do
          primary_key :id
          String :sha256, :index => true
          String :symbol, :index => true
          Integer :point
          Time :last_update
        end
      end
      db[:tags]
    end
  end
end
