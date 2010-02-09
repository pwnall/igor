class TestShuffle < Test::Unit::TestCase
  def setup
    @array = (1..100).to_a
  end
  
  def check_perm(array)
    assert_equal((1..100).to_a, array.sort,
                 'Not a permutation of the original')
  end
  
  def test_shuffle
    arrays = []
    1000.times do
      array2 = @array.dup
      RandomShuffle.shuffle! array2
      check_perm array2
      assert !arrays.include?(array2), 'Randomness not strong enough'
      arrays << array2
    end
  end
end
