# Form objects handle complex form logic
# more easily than fat controllers
module Reformer
  extend ActiveSupport::Concern

  included do
    include Virtus

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    # Forms are never themselves persisted
    def persisted?
      false
    end
  end
end
