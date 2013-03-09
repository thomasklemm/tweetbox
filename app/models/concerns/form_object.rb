# Form objects handle complex form logic
# more easily than fat controllers
module FormObject
  extend ActiveSupport::Concern

  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # Forms are never themselves persisted
  def persisted?
    false
  end
end
