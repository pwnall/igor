class Fib
  @values = {0 => 0, 1 => 1}
  
  def self.fib(n)
    puts "Blah " * 8192
    return @values[n] if @values[n]
    @values[n] = fib(n - 1) + fib(n - 2)
  end
end
