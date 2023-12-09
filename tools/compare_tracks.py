#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec  8 19:06:59 2023

@author: Serge Gielkens 
"""

import sys
import os
import argparse
import pathlib

import geopandas as gpd

res_dir = 'output'
buffer_distance = 1

pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd

parser = argparse.ArgumentParser(description="Compare actually driven tracks with planned tracks")

parser.add_argument("-i", "--input", help="input shape file of the planned tracks")
parser.add_argument("-d", "--distance", help="distance of buffer, by default 1. This is used as distance to create a buffer around the planned tracks")
parser.add_argument("-o", "--output", help="output directory to save the generated shape files, by default ./output of the current directory")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")

args = parser.parse_args()

input_path = ''
output_path = ''

if args.verbose:
    print("Verbosity turned on")


input_name = args.input

input_shape = pathlib.Path(input_name)

if not input_shape.is_file():
    print("Shape file: " + input_name + " does not exist")
    sys.exit(1)


if args.output == None:
    output_path = dir_path + '/' + res_dir
else:
    output_path = args.output

output_dir = pathlib.Path(output_path)

if not output_dir.is_dir():
    output_dir.mkdir()
else:
    if any(os.scandir(output_path)):
        print("Output directory is not empty: " + output_path + ". Quitting." )
        sys.exit(1)

if args.distance:
    buffer_distance = args.distance


shape_gdf = gpd.read_file(input_shape)
shape_buffer = shape_gdf.buffer(int(buffer_distance))

shape_buffer.to_file(output_path + '/test.shp')
        