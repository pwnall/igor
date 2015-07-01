# Grading code for Python submissions.
from __future__ import division
import json
import os
import sys
import unittest

def runner():
    """Wraps sensitive variables in a method scope so they're hard to find."""
    with open('key.b64', 'r') as f:
        key = f.read().strip()
    os.remove('key.b64')

    loader = unittest.TestLoader()
    runner = unittest.TextTestRunner()
    test = loader.discover('.', '*_test.py')
    result = runner.run(test)

    # The grading logic can be tweaked here.
    score = ((result.testsRun - len(result.errors) - len(result.failures)) /
             result.testsRun)
    grades = { 'Problem 1': score }

    sys.stderr.write("\n" + key + "\n" + json.dumps(grades) + "\n")

if __name__ == '__main__':
    runner()
