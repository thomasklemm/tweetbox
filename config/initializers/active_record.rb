module ActiveRecord
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

module ActiveRecordExtension
  extend ActiveSupport::Concern

  # add your instance methods here
  def to_s
    "#{self.class} #{self[:id]}"
  end

  # add your static(class) methods here
  module ClassMethods
    def random
      order("RANDOM()").first
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
