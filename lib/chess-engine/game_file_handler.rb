# frozen_string_literal: true

require 'yaml'

module ChessEngine
  class GameFileHandler
    def initialize(save_dir)
      @save_dir = save_dir
    end

    def all_saves
      Dir["#{@save_dir}/*.yaml"].sort_by { |save| File::Stat.new(save).ctime }
    end

    def all_pgns
      Dir["#{@save_dir}/*.pgn"].sort_by { |save| File::Stat.new(save).ctime }
    end

    def delete_oldest_save
      File.delete(all_saves.first)
    end

    def load_save_by_id(id)
      load_save(all_saves[id - 1])
    end

    def load_pgn_by_id(id)
      load_pgn(all_pgns[id - 1])
    end

    def load_pgn(path)
      raise ArgumentError "#{path} doesn't exist" unless File.exist?(path)
      raise ArgumentError "#{path} is not a PGN file" unless File.extname(path) == '.pgn'

      File.read(path)
    end

    def load_save(path)
      raise ArgumentError "#{path} doesn't exist" unless all_saves.include?(path)

      file = File.read(path)
      YAML.load(file)
    end

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend ClassMethods
    end

    def save_exists?(save_name)
      all_saves.map { |save| self.class.file_name(save) }.include?(save_name)
    end

    def file_name(path)
      File.basename(path, '.*')
    end
  end
end
