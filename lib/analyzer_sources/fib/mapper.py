import os
import sys

os.rename('/usr/testhost/cases/' + os.environ['ITEM'] + '.in', './input')
os.environ['ITEM'] = '0'
os.environ['ITEMS'] = '0'
os.chmod('./input', 0o777)
os.chmod('./code.py', 0o777)
os.setgid(65534)
os.setuid(65534)
sys.path.insert(0, os.getcwd())


# DO NOT MOVE THE IMPORT STATEMENT TO THE TOP OF THE FILE!
from code import Fib

with open('input', 'r') as f:
    n = int(f.readline())
result = Fib.fib(n)
with open('output', 'w') as f:
    f.write(str(result) + "\n")
