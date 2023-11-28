# -*- coding: utf-8 -*-
"""
Created on Fri Nov 10 15:25:36 2023

@author: Serge Gielkens
"""

import os
import sys
import argparse

import pathlib
import zipfile
#import re

zip_dir = 'zipped'

pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd

#p = re.compile('.*Track10.*')

#for path in os.scandir(dir_path):
#     if path.is_file():
#         print(path.name)
#    m = p.match(path.name)
#    if m:
#        print(m)
#    else:
#        print("No match")

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--input", help="input directory containing photos with orientation, by default the current directory")
parser.add_argument("-o", "--output", help="output directory to save the zip files per track, by default ./zipped of the current directory")
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


tellers = {}

for file_path in input_dir.iterdir():
    woord = file_path.name
    lettergreep = woord.split('_')

    if len(lettergreep) < 3:
        print("Unexpected format of file name: " + woord + ". Quitting.")
        sys.exit(1)

    track_naam = lettergreep[3]
    track_nummer = int(track_naam.lstrip("Track"))

    camera = lettergreep[4]
    if camera.endswith(".txt"):
        camera = camera.removesuffix(".txt")
        camera = camera + "_int_ort"
    elif camera.endswith(".csv"):
        camera = camera.removesuffix(".csv")
        camera = camera + "_ext_ort"
    elif not woord.endswith(".jpg"):
        print("Unexpected format of file name: " + woord + ". Quitting.")
        sys.exit(1)


    if not track_naam in tellers:
        tellers[track_naam] = {}
        tellers[track_naam]["totaal"] = 0

    tellers[track_naam]["totaal"] += 1

    if not camera in tellers[track_naam]:
        tellers[track_naam][camera] = 0

    tellers[track_naam][camera] += 1



    zip_bestand = output_path + "/fotos_" + track_naam + ".zip"

    if os.path.exists(zip_bestand):
        zip_modus = 'a'
    else:
        zip_modus = 'w'

    with zipfile.ZipFile(zip_bestand, mode = zip_modus) as archive:
        archive.write(file_path, arcname=file_path.name)


# Controle

nr_camera_fotos = {}

for track, aantallen in tellers.items():
    for camera, aantal in aantallen.items():
        if not camera.endswith("_ort") and not camera == "totaal":
            nr_camera_fotos[track] = aantal
            break


for track, aantallen in tellers.items():
    print(track + ': ' + str( aantallen["totaal"] ) + ' bestanden in totaal')

    stop = False

    aantal_int_ort = 0
    aantal_ext_ort = 0
    aantal_jpg = 0

    for camera, aantal in aantallen.items():
        if camera == "totaal":
            continue

        if camera.endswith("_ort"):
            if camera.endswith("_int_ort"):
                aantal_int_ort += 1
                if aantal != 1:
                    print(camera + ": expected 1 internal orientation file but found " + aantal)
                    stop = True

            else:
                aantal_ext_ort += 1
                if aantal != 1:
                    print(camera + ": expected 1 external orientation file but found " + aantal)
                    stop = True

        else:
            aantal_jpg += 1
            if aantal != nr_camera_fotos[track]:
                print( "Aantal foto's " + str(aantal) + " van " + camera + " verschilt van " + str(nr_camera_fotos[track]) + " van andere camera\'s")
                stop = True

    if aantal_int_ort != 9:
        print( track + ": expected 9 internal orientation txt files but found " + str(aantal_int_ort) )
        stop = True

    if aantal_ext_ort != 9:
        print( track + ": expected 9 external orientation csv files but found " + str(aantal_ext_ort) )
        stop = True

    if aantal_jpg % 9 != 0:
        print( track + ": number of jpg files " + str(aantal_jpg) + " is not a multiple of 9" )
        stop = True

    print("")

    if stop == True:
        print(track + ": unexpected number of files. See the logging above.")
        break
