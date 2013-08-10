class Tokenizer
  # Generates a random alphanumeric string of the given length
  def self.random_token(n=16)
    n &&= n.to_i

    if n.try(:even?)
      # SecureRandom.hex(3) returns hexadecimal value of length 6
      SecureRandom.hex(n/2)
    else
      Array.new(n){rand(16).to_s(16)}.join
    end
  end
end
