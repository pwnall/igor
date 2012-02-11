class Fib
  def self.fib(n)
    return n if n <= 1
    fib(n - 1) + fib(n - 2)
  end
end
