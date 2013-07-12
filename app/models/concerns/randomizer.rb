module Randomizer
  # Generates a random alphanumeric string of the given length
  def random_code(n=16)
    Array.new(n){rand(36).to_s(36)}.join
  end
end
