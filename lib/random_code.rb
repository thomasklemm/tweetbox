class RandomCode
  def code(n=16)
    Array.new(n){rand(36).to_s(36)}.join
  end
end
