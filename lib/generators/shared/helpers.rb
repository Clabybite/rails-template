# lib/generators/shared/helpers.rb
module GeneratorHelpers
    def safe_add_gem(name, version = nil)
        path = root_path("Gemfile")
        line = %{gem "#{name}"}
        line += %{, "#{version}"} if version

        if File.exist?(path) && !File.read(path).include?(line)
            append_to_file path, "\n#{line}\n"
            say_status "info", "Added '#{line}' to Gemfile. Please run `bundle install`.", :yellow
        end
    end
    def root_path(*parts)
        return File.join(destination_root, *parts) if respond_to?(:destination_root)
        File.join(Dir.pwd, *parts)
    end

    def safe_insert_into_file(file, needle:, content:, position: :after)
        file = root_path(file)
        file_content = File.read(file)

        if file_content.include?(content.strip)
            say_status "skip", "Already patched #{file}", :blue
        else
            insert_into_file file, position => needle do
            content
            end
        end
    end
    
end
