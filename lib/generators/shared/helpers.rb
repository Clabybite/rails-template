# lib/generators/shared/helpers.rb
module GeneratorHelpers
    def safe_add_gem(name, version = nil)
        path = root_path("Gemfile")
        gemfile_content = File.exist?(path) ? File.read(path) : ""

        # Normalize quotes in the Gemfile content
        normalized_content = gemfile_content.gsub(/['"]/, '"')

        # Build the gem line to add
        line = %{gem "#{name}"}
        line += %{, "#{version}"} if version

        # Check if the gem already exists (with or without a version)
        existing_gem_match = normalized_content.match(/gem "#{name}"(?:, ["']([^"']+)["'])?/)

        if existing_gem_match
            existing_version = existing_gem_match[1] # Captures the version if present
            if version.nil? || existing_version == version
                say_status "skip", "Gem '#{name}' already exists in Gemfile#{existing_version ? " with version '#{existing_version}'" : ""}.", :blue
                return
            end
        end

        # Append the gem if not found or version differs
        append_to_file path, "\n#{line}\n"
        say_status "info", "Added '#{line}' to Gemfile. Please run `bundle install`.", :yellow
    end
    def root_path(*parts)
        return File.join(destination_root, *parts) if respond_to?(:destination_root)
        File.join(Dir.pwd, *parts)
    end

    def safe_insert_into_file(file, needle:, content:, position: :after)
        file = root_path(file)
        file_content = File.read(file)

        # Normalize quotes and remove all whitespace for comparison
        normalized_file = file_content.gsub(/['"]/, '"').gsub(/\s+/, "").strip


       # Support both a single string or an array of strings/blocks
        contents = content.is_a?(Array) ? content : [content]

        if needle == /\z/ && !file_content.end_with?("\n")
            contents = contents.map { |item| "\n" + item}
        end

        contents.each do |item|
            # Normalize quotes and whitespace in the item
            normalized_item = item.gsub(/['"]/, '"').gsub(/\s+/, "").strip
            next if normalized_file.include?(normalized_item)

            insert_into_file file, position => needle do
            "#{item}\n"
            end
            say_status "insert", "Patched #{file} with: #{item.lines.first.strip}", :green
        end
    end

    def safe_add_gitignore(file = ".gitignore", content:,position: :after)
        safe_insert_into_file(file, needle: /\z/, content: content, position: position)
    end

    def safe_add_route(file = "config/routes.rb", needle:, content:, position: :after)
        file = root_path(file)
        raise "File not found: #{file}" unless File.exist?(file)

        file_content = File.read(file)

        
        # Normalize quotes and remove all whitespace for comparison
        normalized_file = file_content.gsub(/['"]/, '"').gsub(/\s+/, "").strip

        # Support both a single string or an array of strings/blocks
        contents = content.is_a?(Array) ? content : [content]

        contents.each do |item|
            # Normalize quotes and whitespace in the item
            normalized_item = item.gsub(/['"]/, '"').gsub(/\s+/, "").strip
            next if normalized_file.include?(normalized_item)

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
