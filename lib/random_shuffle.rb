module RandomShuffle
  # Shuffles the array in place.
  #
  # The function produces a random permutation of the original array.
  def self.shuffle!(array)
    0.upto(array.length - 1) do |i|
      j = i + rand(array.length - i)
      array[i], array[j] = array[j], array[i]
    end
    array
  end
end
