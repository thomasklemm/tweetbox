class Tokenizer
  # Generates a random alphanumeric string of the given length
  def self.random_token(n=16)
    Array.new(n){rand(36).to_s(36)}.join
  end
end
