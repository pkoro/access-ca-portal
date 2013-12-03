load RAILS_ROOT + '/config/environment.rb'

require 'erb'

class RailsApplicationVisualizer
  DEFAULT_OPTIONS = {
    :models => true,
    :controllers => true,
  }

  FILENAME_TO_CONSTANT = lambda do |filename|
    Object.const_get(Inflector.camelize(filename.split('/').last.split('.')[0..-2]))
  end

  def initialize(options = {})
    options  = DEFAULT_OPTIONS.merge(options)
    template = File.read(RAILS_ROOT + '/vendor/plugins/rav/diagram.dot.erb')

    @dot = ERB.new(template).result(binding)
  end

  def output(*filenames)
    filenames.each do |filename|
      format = filename.split('.').last
      if format == 'dot'
        File.open(filename, 'w').puts @dot
      else
        IO.popen("dot -T#{format} -o #{filename}", 'w') { |io| io << @dot }                 
      end
    end
  end

  protected

  def models
    Dir.glob('app/models/*.rb').map(&FILENAME_TO_CONSTANT)
  end

  def controllers
    load 'app/controllers/application.rb'
    Dir.glob('app/controllers/*_controller.rb').map(&FILENAME_TO_CONSTANT) << ApplicationController
  end
end
