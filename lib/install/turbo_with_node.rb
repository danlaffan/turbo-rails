# frozen_string_literal: true

rails_root = Rails.root.to_s.split(/\/(spec|test)\/dummy/).first
js_entrypoint_path = Rails.root.join("app/javascript/application.js")

if js_entrypoint_path.exist?
  say "Import Turbo"
  append_to_file "#{rails_root}/app/javascript/application.js", %(import "@hotwired/turbo-rails"\n)
else
  say "You must import @hotwired/turbo-rails in your JavaScript entrypoint file", :red
end

say "Install Turbo"
run "yarn add @hotwired/turbo-rails"
