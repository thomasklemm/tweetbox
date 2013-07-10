class Code < ActiveRecord::Base
  belongs_to :tweet

  def to_param
    id
  end
end
