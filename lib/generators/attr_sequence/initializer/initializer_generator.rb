require 'rails/generators'

module AttrSequence
  class InitializerGenerator < ::Rails::Generators::Base

    namespace "attr_sequence:initializer"
    source_root File.join(File.dirname(__FILE__), 'templates')

    def create_initializer_file
      template 'initializer.rb', 'config/initializers/attr_sequence.rb'
    end

  end
end
