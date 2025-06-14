# lib/generators/shared/helpers.rb
module GeneratorHelpers
    def safe_add_gem(name, version = nil)
        path = gemfile_path
        line = %{gem "#{name}"}
        line += %{, "#{version}"} if version

        if File.exist?(path) && !File.read(path).include?(line)
            append_to_file path, "\n#{line}\n"
            say_status "info", "Added '#{line}' to Gemfile. Please run `bundle install`.", :yellow
        end
    end
    def gemfile_path
        return File.join(destination_root, "Gemfile") if respond_to?(:destination_root)
        File.join(Dir.pwd, "Gemfile")
    end

end
