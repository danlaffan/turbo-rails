# frozen_string_literal: true

rails_root = Rails.root.to_s.split(/\/(spec|test)\/dummy/).first

say "Import Turbo"
Dir.glob("#{rails_root}/**/app/javascript/application.js").each do |app_js_file|
  # append_to_file "#{rails_root}app/javascript/application.js", %(import "@hotwired/turbo-rails"\n)
  append_to_file app_js_file, %(import "@hotwired/turbo-rails"\n)
end

say "Pin Turbo"
Dir.glob("#{rails_root}/**/config/importmap.rb").each do |importmap_rb_file|
  append_to_file "#{importmap_rb_file}", %(pin "@hotwired/turbo-rails", to: "turbo.js"\n)
end
