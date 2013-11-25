# Unit tests for fib.py Python example.
import unittest
from fib import Fib

class FibTest(unittest.TestCase):
    def test_base(self):
        self.assertEqual(0, Fib.fib(0))
        self.assertEqual(1, Fib.fib(1))
  
    def test_easy(self):
        self.assertEqual(1, Fib.fib(2))
        self.assertEqual(2, Fib.fib(3))
        self.assertEqual(3, Fib.fib(4))
        self.assertEqual(5, Fib.fib(5))
        self.assertEqual(8, Fib.fib(6))
  
    def test_medium(self):
        self.assertEqual(144, Fib.fib(12))
        self.assertEqual(987, Fib.fib(16))
        self.assertEqual(6765, Fib.fib(20))
        self.assertEqual(75025, Fib.fib(25))
        self.assertEqual(832040, Fib.fib(30))
  
    def test_hard(self):
        self.assertEqual(354224848179261915075, Fib.fib(100))
        self.assertEqual(43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875, Fib.fib(1000))

if __name__ == '__main__':
    unittest.main()
