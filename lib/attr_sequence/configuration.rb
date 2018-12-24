module AttrSequence
  class Configuration
    def column
      @column ||= :number
    end

    def column=(value)
      @column = value
    end

    def start_at
      @start_at ||= 1
    end

    def start_at=(value)
      @start_at = value
    end
  end
end
