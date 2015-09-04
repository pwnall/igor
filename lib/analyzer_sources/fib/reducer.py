from __future__ import division
import glob
import json
import os.path

golden_files = glob.glob('cases/*.out')
wins = 0
for golden_file in sorted(golden_files):
    test_name = os.path.basename(golden_file)
    output_file = '/usr/testguest/' + test_name
    if not os.path.isfile(output_file):
        print(test_name + ' not produced by test program\n')
        continue

    with open(golden_file, 'r') as golden:
        golden_data = golden.read()
    with open(output_file, 'r') as output:
        output_data = output.read()
    if golden_data == output_data:
        wins += 1
        print(test_name + ' matches expected output\n')
    else:
        print(test_name + ' does not match expected output\n')

score = wins / len(golden_files)
grades = { 'Problem 1': score }

with open('output', 'w') as scores:
    scores.write(json.dumps(grades))
