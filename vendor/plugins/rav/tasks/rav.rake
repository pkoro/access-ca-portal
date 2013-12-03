# =============================================================================
# A rake task to generate UML-ish graphs of your Rails app
# =============================================================================

desc "Create a diagram of your app's controllers and/or models"
task :visualize do
  load RAILS_ROOT + '/vendor/plugins/rav/lib/rav.rb'

  options = {
    :models      => ENV['MODELS']      != 'no',
    :controllers => ENV['CONTROLLERS'] != 'no'
  }

  filename = ENV['FILENAME'] || 'doc/diagram.png'

  RailsApplicationVisualizer.new(options).output(filename)

  puts "Generated #{filename}."
end
