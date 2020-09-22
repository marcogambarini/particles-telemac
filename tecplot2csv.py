#!/usr/bin/env python3

# Converts drogue files from tecplot (.dat) format to .csv format
# Useful for visualizing particle paths in Paraview from Telemac3d simulations
# Usage: tecplot2csv.py -i results.dat -o results.csv 
# (user interface is same as sel2vtk and sel2vtk_bin by pprodano)
#
# Marco Gambarini, 09/2020

import csv
import os, sys
 
def createNewFile(output_file, i):
    fileName = 'particleFiles/' + output_file.split('.',1)[0] + str(i) + '.csv'
    with open(fileName, 'w') as ofile:
        ofile.write('x,y,z,label\n')
    return fileName


if len(sys.argv) == 5:
  input_file = sys.argv[2]
  output_file = sys.argv[4]
  t_start = 0
  t_end = 0
else:
  print('Wrong number of Arguments, stopping now...')
  print('Usage:')
  print('tecplot2csv.py -i results.dat -o results.csv')
  sys.exit()
  
    
os.system("cp -r particleFiles oldParticleFiles")
os.system("rm -r particleFiles")
os.system("mkdir particleFiles")
i = 0
with open(input_file, 'r') as ifile:
    reader =csv.reader(ifile)
    next(reader) # skip line
    next(reader) # skip line
    for row in reader:
        if row[0]=='ZONE DATAPACKING=POINT':
            i = i+1
            fileName = createNewFile(output_file, i)
        else:
            writingList = [row[1], row[2], row[3], row[0]]
            with open(fileName, 'a', newline='') as ofile:
                ofile.write((writingList[0] + ',' + writingList[1] + 
                            ',' + writingList[2] + ',' + writingList[3] + '\n'))
print('All files written!')
