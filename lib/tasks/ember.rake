namespace :ember do
  desc 'Build the ember application using the RAILS_ENV variable'
  task :build do
    require 'ember/source'

    if(Rails.env.production?)
      puts 'building ember for production'
      FileUtils.cp Ember::Source.bundled_path_for('ember.min.js'), 'public/javascripts/vendor/ember.js'
    else
      puts 'building ember for development'
      FileUtils.cp Ember::Source.bundled_path_for('ember.js'), 'public/javascripts/vendor/ember.js'
    end

    puts `ember build`

    if(Rails.env.production?)
      puts 'minifying application.js'
      rewrite_file('public/javascripts/application.js') {|f| Uglifier.compile(f)}
    end
  end

  def rewrite_file(file, &block)
    source = File.read(file)
    File.write(file, block.call(source))
  end

end
