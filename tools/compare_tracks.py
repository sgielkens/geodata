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

parser.add_argument("-i", "--input", help="input shape file of driven tracks")
parser.add_argument("-d", "--distance", help="distance of buffer, by default 1. This is used as distance to create a buffer around the planned tracks")
parser.add_argument("-m", "--master", help="master shape file of tracks to be driven")
parser.add_argument("-o", "--output", help="output directory to save the generated shape files, by default ./output of the current directory")
parser.add_argument("-r", "--remaining", help="Remainig part of master shape file, i.e. still to be driven or missed tracks")
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


master_name = args.master
master_shape = pathlib.Path(master_name)

if not master_shape.is_file():
    print("Master shape file: " + master_name + " does not exist")
    sys.exit(1)


remaining_name = args.remaining
remaining_shape = pathlib.Path(remaining_name)

if not remaining_shape.is_file():
    print("Remaining shape file: " + remaining_name + " does not exist")
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


# Buffer shape of driven tracks

driven_shape_gdf = gpd.read_file(input_shape, crs='EPSG:4326')
driven_shape_gdf = driven_shape_gdf.to_crs('EPSG:28992')

driven_shape_buffer = driven_shape_gdf.buffer(int(buffer_distance))
driven_shape_buffer_gdf = gpd.GeoDataFrame( geometry = gpd.GeoSeries(driven_shape_buffer) )

driven_name = input_shape.stem
driven_buffered_name = driven_name + "_buffer_" + str(buffer_distance) + ".shp"
driven_buffered_path = output_dir / driven_buffered_name
driven_shape_buffer.to_file(driven_buffered_path)


# Extract features by location ('within')

master_shape_gdf = gpd.read_file(master_shape)
master_shape_gdf = master_shape_gdf.set_crs('EPSG:28992')

master_shape_within = gpd.sjoin(master_shape_gdf, driven_shape_buffer_gdf, how='inner', predicate='within')

master_name = master_shape.stem
master_within_name = master_name + "_within.shp"
master_within_path = output_dir / master_within_name
master_shape_within.to_file(master_within_path)


# Extract features by distance ('contains')

#master_shape_contains = gpd.sjoin(master_shape_gdf, driven_shape_gdf, how='inner', predicate='contains')
#master_shape_contains = gpd.sjoin_nearest(master_shape_gdf, driven_shape_gdf, how='inner', max_distance=3)

#master_within_name = master_name + "_contains.shp"
#master_within_path = output_dir / master_within_name
#master_shape_within.to_file(master_within_path)


# Determine remaining features ('difference')

remaining_shape_gdf = gpd.read_file(remaining_shape)
remaining_shape_gdf = remaining_shape_gdf.set_crs('EPSG:28992')

remaining_shape_new = remaining_shape_gdf.overlay(master_shape_within, how='difference')

remaining_name = remaining_shape.stem
remaining_new_name = remaining_name + "_new.shp"
remaining_new_path = output_dir / remaining_new_name
remaining_shape_new.to_file(remaining_new_path)

