# -*- coding: utf-8 -*-
"""
Created on Tue Nov 28 16:54:13 2023

@author: Serge Gielkens
"""

import os
import sys
import argparse
import pathlib

import sqlite3
import datetime
import time

import fiona
from shapely.geometry import shape
import geopandas as gpd

zip_dir = 'track_duration'
scan_db = 'scan.db'

def unix_timestamp(tuple_timestamp):
    elementen = tuple_timestamp.split(',')

    jaar = int(elementen[0])
    maand = int(elementen[1])
    dag = int(elementen[2])
    uur = int(elementen[3])
    minuut = int(elementen[4])
    seconde = int(elementen[5])

    datum_tijd = datetime.datetime(jaar, maand, dag, uur, minuut, seconde)
    unix_timestamp = time.mktime(datum_tijd.timetuple())

    return unix_timestamp


pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd

parser = argparse.ArgumentParser(description="Extract track information from a TRK project")

parser.add_argument("-i", "--input", help="input directory pointing to a TRK job, by default the current directory")
parser.add_argument("-o", "--output", help="output directory for the duration per track, by default ./track_duration of the current directory")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")

args = parser.parse_args()

input_path = ''
output_path = ''

if args.verbose:
    print("Verbosity turned on")


if args.input is None:
    input_path = pwd
else:
    input_path = args.input

input_dir = pathlib.Path(input_path)

if not input_dir.is_dir():
    print("Input directory does not exist: " + input_path)
    sys.exit(1)


if args.output is None:
    output_path = dir_path + '/' + zip_dir
else:
    output_path = args.output

output_dir = pathlib.Path(output_path)

if not output_dir.is_dir():
    output_dir.mkdir()
else:
    if any(os.scandir(output_path)):
        print("Output directory is not empty: " + output_path + ". Quitting." )
        sys.exit(1)

info_track = {}


# Determine duration of tracks

for file_path in input_dir.iterdir():
    if not file_path.is_dir():
        continue

    file_naam = file_path.name
    if not ( file_naam.startswith('Track') and file_naam.endswith('.scan') ):
        continue

    track_name = file_naam.removesuffix(".scan")

    scan_file = file_path / scan_db
    if not scan_file.is_file():
        print("Track: " + file_naam + " has no scan.db file " + scan_db)
        sys.exit(1)

    info_track[track_name] = {}

    con = sqlite3.connect(file_path / scan_db)
    cur = con.cursor()

    res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StartRecording'")
    start_timestamp = res.fetchone()
    start_unix_timestamp = unix_timestamp(start_timestamp[0])

    info_track[track_name]["start"] = start_unix_timestamp

    res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StopRecording'")
    stop_timestamp = res.fetchone()
    stop_unix_timestamp = unix_timestamp(stop_timestamp[0])

    info_track[track_name]["stop"] = stop_unix_timestamp

    duration_unix_seconds = stop_unix_timestamp - start_unix_timestamp
    info_track[track_name]["duration"] = duration_unix_seconds

    con.close()


# Determine length of tracks

job_name = input_dir.name
job_name = job_name.rstrip(os.sep)
job_name = job_name.removesuffix(".job")

shape_name = job_name + ".shp"

shape_dir = input_dir.parent / "Export/SHP"
if not shape_dir.is_dir():
    print("Shape directory: " + str(shape_dir) + " does not exist")
    sys.exit(1)

shape_file = shape_dir / shape_name
if not shape_file.is_file():
    print("Shape file: " + str(shape_file) + " does not exist")
    sys.exit(1)

with fiona.open(shape_file) as shapefile:
    for record in shapefile:
        track_name = record["properties"]["TrackName"]

        if not track_name in info_track:
            print("Shape file: " + str(shape_file) + " contains track " + track_name + " without scan")
            sys.exit(1)

        geometry = shape(record['geometry'])

        # Shape files from TRK are WGS84,i.e. in angular units
        track_line = gpd.GeoSeries(geometry, crs='EPSG:4326')
        # Convert to RDNAP, i.e. planar CRS for correct length calculation
        track_line = track_line.to_crs('EPSG:28992')

        info_track[track_name]["length"] = track_line.length[0]


for track in info_track:
    if info_track[track].get("length") is None:
        print("Track: " + track + " not present in shape file " + str(shape_file))
        sys.exit(1)

    velocity_ms = info_track[track]["length"] / info_track[track]["duration"]
    velocity_kmh = velocity_ms * 3.6

    info_track[track]["velocity_ms"] = velocity_ms
    info_track[track]["velocity_kmh"] = velocity_kmh

for track in info_track:
    velocity_kmh_rounded = round(info_track[track]["velocity_kmh"], 1)
    print( "Track: " + track + " was acquired at average speed of " + str(velocity_kmh_rounded) + ' km/h' )


