# frozen_string_literal: true

rails_root = Pathname.new(Rails.root.to_s.split(/\/(spec|test)\/dummy/).first)
cable_config_path = Rails.root.join("config/cable.yml")

if cable_config_path.exist?
  if Rails.root.to_s.match?(/(spec|test)\/dummy/)
    # The target project appears to be a gem or Engine
    say "Enable redis in .gemspec"

    gemspec_file = Dir["#{rails_root}/**/*.gemspec"].first
    gemspec_file_content = File.read(gemspec_file)
    pattern = /dependency ['"]redis['"$]/

    if gemspec_file_content.match?(pattern)
      # Just in case it's there but commented out...
      uncomment_lines gemspec_file, pattern
    else
      gsub_file gemspec_file.to_s, "\nend\n", "\n  # Use Redis for Action Cable\n  spec.add_dependency 'redis', '~> 4.0'\nend\n"
    end
  else
    # The target project appears to be a regular Rails app
    say "Enable redis in Gemfile"

    gem_file = rails_root.join("Gemfile")
    gemfile_content = File.read(gem_file)
    pattern = /gem ['"]redis['"$]/

    if gemfile_content.match?(pattern)
      uncomment_lines gem_file, pattern
    else
      append_file gem_file, "\n# Use Redis for Action Cable\ngem 'redis', '~> 4.0'\n"
    end
  end
  # Implement the changes to the gem setup
  run_bundle

  say "Switch ActionCable to use redis in development mode"
  gsub_file cable_config_path.to_s, /development:\n\s+adapter: async/, "development:\n  adapter: redis\n  url: redis://localhost:6379/1"
else
  say 'ActionCable config file (config/cable.yml) is missing. Uncomment "gem \'redis\'" in your Gemfile and create config/cable.yml to use the Turbo Streams broadcast feature.'
end
