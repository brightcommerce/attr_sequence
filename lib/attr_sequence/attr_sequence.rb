require_relative './generator'
require 'active_support/concern'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module AttrSequence
  extend ActiveSupport::Concern

  SequenceColumnExists = Class.new(StandardError)

  class_methods do
    # Public: Defines ActiveRecord callbacks to set a sequential number scoped
    # on a specific class.
    #
    # Can be called multiple times to add hooks for different column names.
    #
    # options - The Hash of options for configuration:
    #           :scope    - The Symbol representing the columm on which the
    #                       number should be scoped (default: nil)
    #           :column   - The Symbol representing the column that stores the
    #                       number (default: :number)
    #           :start_at - The Integer value at which the sequence should
    #                       start (default: 1)
    #           :skip     - Skips the number generation when the lambda
    #                       expression evaluates to nil. Gets passed the
    #                       model object
    #
    # Examples
    #
    #   class Answer < ActiveRecord::Base
    #     include AttrSequence
    #     belongs_to :question
    #     attr_sequence scope: :question_id
    #   end
    #
    # Returns nothing.
    def attr_sequence(options = {})
      unless defined?(sequence_options)
        mattr_accessor :sequence_options, instance_accessor: false
        self.sequence_options = []

        before_save :set_numbers
      end

      default_options = {column: AttrSequence.column, start_at: AttrSequence.start_at}
      options = default_options.merge(options)
      column_name = options[:column]

      if sequence_options.any? {|options| options[:column] == column_name}
        raise(SequenceColumnExists, <<-MSG.squish)
          Tried to set #{column_name} as a sequence but there was already a
          definition here. Did you accidentally call attr_sequence multiple
          times on the same column?
        MSG
      else
        sequence_options << options
      end
    end
  end

  private

  def set_numbers
    self.class.base_class.sequence_options.each do |options|
      AttrSequence::Generator.new(self, options).set
    end
  end
end
