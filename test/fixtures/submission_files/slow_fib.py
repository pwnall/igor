class Fib(object):
    @staticmethod
    def fib(n):
        if n <= 1:
            return n
        return Fib.fib(n - 1) + Fib.fib(n - 2)
