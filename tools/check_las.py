#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 20 15:18:56 2025

@author: Serge Gielkens
"""

import sys
import os
import argparse
import pathlib

import laspy

pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd

parser = argparse.ArgumentParser(description="Check LAS/LAZ files")

parser.add_argument("-i", "--input", help="input directory containing LAS or LAZ files, by default the current directory")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")

args = parser.parse_args()

input_path = ''

if args.verbose:
    print("Verbosity turned on")


if args.input == None:
    input_path = pwd
else:
    input_path = args.input

input_dir = pathlib.Path(input_path)

if not input_dir.is_dir():
    print("Input directory does not exist: " + input_path)
    sys.exit(1)


#for las_file in input_dir.iterdir():
for root, dirs, files in os.walk(input_path):
    print ( "root: " + root)
    
    for las_name in files:
                
        if not ( las_name.endswith(".las") or las_name.endswith(".laz") ):
            if args.verbose:
                print("Unexpected file type: " + las_name)
            continue

        las_file = os.path.join(root, las_name)
                
        las_in = laspy.open(las_file)
        nr_points_in = las_in.header.point_count
    
        print ( "Las file: " + las_file)
        print( "Number of points " + str(nr_points_in) + "\n")


        

