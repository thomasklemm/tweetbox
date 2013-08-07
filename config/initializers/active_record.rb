module ActiveRecord
  class Base
    def to_s
      "#{self.class} #{self[:id]}"
    end
  end

  module Associations
    class HasManyThroughAssociation
      def insert_record(record, validate = true, raise = false)
        ensure_not_nested

        if record.new_record?
          if raise
            record.save!(:validate => validate)
          else
            return unless record.save(:validate => validate)
          end
        end

        save_through_record(record)
        # Causes update counter twice
        # update_counter(1)
        record
      end
    end
  end
end
