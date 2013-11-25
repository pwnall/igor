class Fib(object):
    values = {0: 0, 1: 1}
    
    @staticmethod
    def fib(n):
        if n not in Fib.values:
            Fib.values[n] = Fib.fib(n - 1) + Fib.fib(n - 2)
        return Fib.values[n]
