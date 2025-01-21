#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec  5 20:19:27 2023

@author: Serge Gielkens
"""

import sys
import os
import argparse
import pathlib

import laspy

laz_dir = 'laz'

pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd

parser = argparse.ArgumentParser(description="Convert LAS to LAZ")

parser.add_argument("-i", "--input", help="input directory containing LAS files, by default the current directory")
parser.add_argument("-o", "--output", help="output directory to save the compressed LAZ files, by default ./laz of the current directory")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")

args = parser.parse_args()

input_path = ''
output_path = ''

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


if args.output == None:
    output_path = dir_path + '/' + laz_dir
else:
    output_path = args.output

output_dir = pathlib.Path(output_path)

if not output_dir.is_dir():
    output_dir.mkdir()
else:
    if any(os.scandir(output_path)):
        print("Output directory is not empty: " + output_path + ". Quitting." )
        sys.exit(1)

for las_file in input_dir.iterdir():
    las_name = las_file.name
    
    if not las_name.endswith(".las"):
        print("Unexpected file type: " + las_name)
        sys.exit(1)
    
    las_in = laspy.open(las_file)
    
    laz_name = las_name.removesuffix(".las")
    laz_name = laz_name + ".laz"
    laz_file = output_dir / laz_name
        
    laz_out = laspy.open(laz_file, mode="w", header=las_in.header)

    nr_points_in = las_in.header.point_count

    with las_in:
        with laz_out:
            for points in las_in.chunk_iterator(1_000_000):
                 laz_out.write_points(points)

# Test
    laz_in = laspy.open(laz_file)
    nr_points_out = laz_in.header.point_count
    if nr_points_in != nr_points_out:
        print( "Number of points " + str(nr_points_in) + " in LAS file:" )
        print( str(las_file) + "\n" )
        print( "differs from number of points " + str(nr_points_out) + " in LAZ file:" )
        print( str(laz_file) + "\n")
        

