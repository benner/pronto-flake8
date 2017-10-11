require 'pronto'
require 'shellwords'

module Pronto
  # Flake8 Pronto Runner. Entry point is run
  class Flake8 < Runner
    CONFIG_FILE = '.pronto_flake8.yml'.freeze
    CONFIG_KEYS = %w[flake8_executable].freeze
    PYTHON_FILE_EXTENSION = '.py'.freeze

    def initialize(patches, commit = nil)
      super(patches, commit)
      read_config
    end

    def flake8_executable
      @flake8_executable || 'flake8'.freeze
    end

    def files
      return [] if @patches.nil?

      @files ||= begin
       @patches
         .select { |patch| patch.additions > 0 }
         .map(&:new_file_full_path)
         .compact
     end
    end

    def patch_line_for_offence(path, lineno)
      patch_node = @patches.find do |patch|
        patch.new_file_full_path.to_s == path
      end

      return if patch_node.nil?

      patch_node.added_lines.find do |patch_line|
        patch_line.new_lineno == lineno
      end
    end

    def read_config
      config_file = File.join(git_repo_path, CONFIG_FILE)
      return unless File.exist?(config_file)
      config = YAML.load_file(config_file)

      CONFIG_KEYS.each do |config_key|
        next unless config[config_key]
        send("#{config_key}=", config[config_key])
      end
    end

    def run
      if files.any?
        messages(run_flake8)
      else
        []
      end
    end

    def run_flake8
      Dir.chdir(git_repo_path) do
        python_files = filter_python_files(files)
        file_paths_str = python_files.join(' ')
        if !file_paths_str.empty?
          parse_output `#{flake8_executable} #{file_paths_str}`
        else
          []
        end
      end
    end

    def filter_python_files(all_files)
      all_files.select { |file_path| file_path.to_s.end_with? PYTHON_FILE_EXTENSION}
               .map { |py_file| py_file.to_s.shellescape } 
    end

    def parse_output(executable_output)
      lines = executable_output.split("\n")
      lines.map { |line| parse_output_line(line) }
    end

    def parse_output_line(line)
      splits = line.strip.split(':')
      message = splits[3].strip
      {
        file_path: splits[0],
        line_number: splits[1].to_i,
        column_number: splits[2].to_i,
        message: message,
        level: violation_level(message)
      }
    end

    def violation_level(flake8_message)
      message = flake8_message.strip
      first_letter = message[0]
      # W is warning, C is for McCabe Complexity
      if %w[W C].include? first_letter
        'warning'
      else
        'error'
      end
    end

    def messages(json_list)
      json_list.map do |error|
        patch_line = patch_line_for_offence(error[:file_path],
                                            error[:line_number])
        next if patch_line.nil?
        description = error[:message]
        path = patch_line.patch.delta.new_file[:path]
        Message.new(path,
                    patch_line,
                    error[:level].to_sym,
                    description,
                    nil,
                    self.class)
      end
    end

    def git_repo_path
      @git_repo_path ||= Rugged::Repository.discover(File.expand_path(Dir.pwd)).workdir
    end
  end
end
