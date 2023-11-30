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

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--input", help="input directory pointing to a TRK job, by default the current directory")
parser.add_argument("-o", "--output", help="output directory to save the duration per track, by default ./track_duration of the current directory")
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

for file_path in input_dir.iterdir():
    if not file_path.is_dir():
        continue

    file_naam = file_path.name
    if not ( file_naam.startswith('Track') and file_naam.endswith('.scan') ):
        continue

    con = sqlite3.connect(file_path / scan_db)
    cur = con.cursor()

    res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StartRecording'")
    start_timestamp = res.fetchone()
    start_unix_timestamp = unix_timestamp(start_timestamp[0])

    res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StopRecording'")
    stop_timestamp = res.fetchone()
    stop_unix_timestamp = unix_timestamp(stop_timestamp[0])

    duur_unix_seconds = stop_unix_timestamp - start_unix_timestamp

    print(duur_unix_seconds)


    con.close()
