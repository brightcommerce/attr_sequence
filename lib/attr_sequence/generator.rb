module AttrSequence
  class Generator
    attr_reader :record, :scope, :column, :start_at, :skip

    def initialize(record, options = {})
      @record = record
      @scope = options[:scope]
      @column = options[:column].to_sym
      @start_at = options[:start_at]
      @skip = options[:skip]
    end

    def set
      return if number_set? || skip?
      lock_table
      record.send(:"#{column}=", next_number)
    end

    def number_set?
      !record.send(column).nil?
    end

    def skip?
      skip && skip.call(record)
    end

    def next_number
      next_number_in_sequence.tap do |number|
        number += 1 until unique?(number)
      end
    end

    def next_number_in_sequence
      start_at = self.start_at.respond_to?(:call) ? self.start_at.call(record) : self.start_at
      return start_at unless last_record = find_last_record
      max(last_record.send(column) + 1, start_at)
    end

    def unique?(number)
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where("NOT number = ?", record.number) if record.persisted?
        rel.where(column => number)
      end.count == 0
    end

  private

    def lock_table
      if postgresql?
        record.class.connection.execute("LOCK TABLE #{record.class.table_name} IN EXCLUSIVE MODE")
      end
    end

    def postgresql?
      defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
        record.class.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    end

    def base_relation
      record.class.base_class.unscoped
    end

    def find_last_record
      build_scope(*scope) do
        base_relation.
        where("#{column.to_s} IS NOT NULL").
        order("#{column.to_s} DESC")
      end.first
    end

    def build_scope(*columns)
      rel = yield
      columns.each { |c| rel = rel.where(c => record.send(c.to_sym)) }
      rel
    end

    def max(*values)
      values.to_a.max
    end
  end
end
