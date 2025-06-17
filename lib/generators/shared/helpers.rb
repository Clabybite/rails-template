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

       # Support both a single string or an array of strings/blocks
        contents = content.is_a?(Array) ? content : [content]

        contents.each do |item|
            next if file_content.include?(item.strip)
            insert_into_file file, position => needle do
            "#{item}\n"
            end
            say_status "insert", "Patched #{file} with: #{item.lines.first.strip}", :green
        end
    end

    def safe_namespace_route(resource, namespace: :admin)
        path = root_path("config/routes.rb")
        content = File.read(path)

        namespace_block = /^ *namespace :#{namespace} do *$/
        resource_line   = "    resources :#{resource}"

        if content.include?(resource_line.strip)
            say_status :skip, "Already has resources :#{resource} under :#{namespace}", :blue
            return
        end

        if content.match?(namespace_block)
            # Add inside existing namespace block
            insert_into_file path, after: namespace_block do
            "\n#{resource_line}"
            end
        else
            # Create namespace block near end
            insert_into_file path, before: /^end/ do
            <<~RUBY

                namespace :#{namespace} do
                resources :#{resource}
                end

            RUBY
            end
        end
    end


end
