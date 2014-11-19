require 'thread'

class Fib
  def self.fib(n)
    Thread.new { loop { sleep 10 } }
    q = Queue.new
    q.pop
  end
end

