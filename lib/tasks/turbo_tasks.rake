# frozen_string_literal: true

# +rails_root+ is used instead of +Rails.root+ so that we can focus the installer's
# attention on the correct destination, particularly when installing into a RailsEngine.
rails_root = Pathname.new(Rails.root.to_s.split(%r{\/(spec|test)\/dummy}).first)

def turbo_namespace_from_task(task_name)
  task_name.name.split(/turbo:install/).first
end

def run_turbo_install_template(namespace, path)
  system "#{RbConfig.ruby} ./bin/rails #{namespace}app:template LOCATION=#{File.expand_path("../install/#{path}.rb", __dir__)}"
end

def redis_installed?
  system('which redis-server > /dev/null')
end

def switch_on_redis_if_available(namespace)
  if redis_installed?
    Rake::Task["#{namespace}turbo:install:redis"].invoke
  else
    puts "Run turbo:install:redis to switch on Redis and use it in development for turbo streams"
  end
end

namespace :turbo do
  desc "Install Turbo into the app"
  task :install do |task|
    namespace = turbo_namespace_from_task(task)
    if rails_root.join("config/importmap.rb").exist?
      Rake::Task["#{namespace}turbo:install:importmap"].invoke
    elsif rails_root.join("package.json").exist?
      Rake::Task["#{namespace}turbo:install:node"].invoke
    else
      puts "You must either be running with node (package.json) or importmap-rails (config/importmap.rb) to use this gem."
    end
  end

  namespace :install do
    desc "Install Turbo into the app with asset pipeline"
    task :importmap do |task|
      namespace = turbo_namespace_from_task(task)
      run_turbo_install_template(namespace, "turbo_with_importmap")
      switch_on_redis_if_available(namespace)
    end

    desc "Install Turbo into the app with webpacker"
    task :node do |task|
      namespace = turbo_namespace_from_task(task)
      run_turbo_install_template(namespace, "turbo_with_node")
      switch_on_redis_if_available(namespace)
    end

    desc "Switch on Redis and use it in development"
    task :redis do |task|
      namespace = turbo_namespace_from_task(task)
      run_turbo_install_template(namespace, "turbo_needs_redis")
    end
  end
end
