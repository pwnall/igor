require 'minitest/autorun'
require './fib.rb'

class FibTest < MiniTest::Unit::TestCase
  def test_base
    assert_equal 0, Fib.fib(0)
    assert_equal 1, Fib.fib(1)
  end
  
  def test_easy
    assert_equal 1, Fib.fib(2)
    assert_equal 2, Fib.fib(3)
    assert_equal 3, Fib.fib(4)
    assert_equal 5, Fib.fib(5)
    assert_equal 8, Fib.fib(6)
  end
  
  def test_medium
    assert_equal 144, Fib.fib(12)
    assert_equal 987, Fib.fib(16)
    assert_equal 6765, Fib.fib(20)
    assert_equal 75025, Fib.fib(25)
    assert_equal 832040, Fib.fib(30)
  end
  
  def test_hard
    assert_equal 354224848179261915075, Fib.fib(100)
    assert_equal 43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875, Fib.fib(1000)
  end
end
