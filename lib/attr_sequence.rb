require 'attr_sequence/attr_sequence'
require 'attr_sequence/configuration'
require 'attr_sequence/version'

module AttrSequence
  extend ActiveSupport::Autoload

  @@configuration = nil

  def self.configure
    @@configuration = Configuration.new
    yield(configuration) if block_given?
    configuration
  end

  def self.configuration
    @@configuration || configure
  end

  def self.method_missing(method_sym, *arguments, &block)
    if configuration.respond_to?(method_sym)
      configuration.send(method_sym)
    else
      super
    end
  end

  def self.respond_to?(method_sym, include_private = false)
    if configuration.respond_to?(method_sym, include_private)
      true
    else
      super
    end
  end
end
