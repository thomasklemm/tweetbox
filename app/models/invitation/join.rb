class Invitation::Join < Invitation::Base
  def save
    if valid?
      persist!
      true
    else
      false
    end
  end
end
