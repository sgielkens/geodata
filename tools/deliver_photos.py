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
import shutil
import glob
#import re

deliver_dir = 'deliver_photos'

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
parser.add_argument("-z", "--zip", help="zip photos per track", action="store_true")

args = parser.parse_args()

input_path = ''
output_path = ''

if args.verbose:
    print("Verbosity turned on")

if args.zip:
    print("Photos will be zipped per track")

if args.input == None:
    input_path = pwd
else:
    input_path = args.input

input_dir = pathlib.Path(input_path)

if not input_dir.is_dir():
    print("Input directory does not exist: " + input_path)
    sys.exit(1)


if args.output == None:
    output_path = dir_path + '/' + deliver_dir
else:
    output_path = args.output

output_dir = pathlib.Path(output_path)

if not output_dir.is_dir():
    output_dir.mkdir()
else:
    if any(os.scandir(output_path)):
        print("Output directory is not empty: " + output_path + ". Quitting." )
        sys.exit(1)

output_log = output_path + ".log"
output_log_file = pathlib.Path(output_log)
if output_log_file.is_file():
    print("Output logfile: " + output_log + " already exists. Quitting")
    sys.exit(1)


ort_parms = 'Image file name;GPS time'
ort_parms = ort_parms + ';Camera x (m);Camera y (m);Camera z (m)'
ort_parms = ort_parms + ';Omega (grad);Phi (grad);Kappa (grad)'
ort_parms = ort_parms + ';m11 (3x3 rotation matrix);m21 (3x3 rotation matrix);m31 (3x3 rotation matrix)'
ort_parms = ort_parms + ';m12 (3x3 rotation matrix);m22 (3x3 rotation matrix);m32 (3x3 rotation matrix)'
ort_parms = ort_parms + ';m13 (3x3 rotation matrix);m23 (3x3 rotation matrix);m33 (3x3 rotation matrix)'

tellers = {}

for file_name in glob.iglob(input_path + '/**', recursive=True):
    file_path = pathlib.Path(file_name)
    if file_path.is_dir():
        continue

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


    if args.zip:
        zip_bestand = output_path + "/fotos_" + track_naam + ".zip"

        if os.path.exists(zip_bestand):
            zip_modus = 'a'
        else:
            zip_modus = 'w'

        with zipfile.ZipFile(zip_bestand, mode = zip_modus) as archive:
            archive.write(file_path, arcname=file_path.name)

    else:
        ext_ort_file = output_path + '/' + lettergreep[0] + '_' + lettergreep[1] + '_' + lettergreep[2] + '.csv'
        if not os.path.exists(ext_ort_file):
            f = open(ext_ort_file,'x')
            f.write(ort_parms)
            f.write('\n')
            f.close()

        if camera.endswith("_ext_ort"):
            with open(file_path, 'r') as f_src:
                with open(ext_ort_file, 'a') as f_dst:
                    shutil.copyfileobj(f_src, f_dst)
        else:
            shutil.copy(file_path, output_path)

# Controle

nr_camera_fotos = {}

for track, aantallen in tellers.items():
    for camera, aantal in aantallen.items():
        if not camera.endswith("_ort") and not camera == "totaal":
            nr_camera_fotos[track] = aantal
            break

f = open(output_log, "x")
stop = False

for track, aantallen in tellers.items():
    print(track + ': ' + str( aantallen["totaal"] ) + ' bestanden in totaal')
    f.write(track + ': ' + str( aantallen["totaal"] ) + ' bestanden in totaal' + "\n")

    aantal_int_ort = 0
    aantal_ext_ort = 0
    aantal_camera = 0
    aantal_jpg = 0

    for camera, aantal in aantallen.items():
        if camera == "totaal":
            continue

        if camera.endswith("_ort"):
            if camera.endswith("_int_ort"):
                aantal_int_ort += 1
                if aantal != 1:
                    print(camera + ": expected 1 internal orientation file but found " + str(aantal) )
                    f.write(camera + ": expected 1 internal orientation file but found " + str(aantal) + "\n")
                    stop = True

            else:
                aantal_ext_ort += 1
                if aantal != 1:
                    print(camera + ": expected 1 external orientation file but found " + str(aantal) )
                    f.write(camera + ": expected 1 external orientation file but found " + str(aantal) + "\n")
                    stop = True

        else:
            aantal_camera += 1
            aantal_jpg += aantal
            if aantal != nr_camera_fotos[track]:
                print( "Aantal foto's " + str(aantal) + " van " + camera + " verschilt van " + str(nr_camera_fotos[track]) + " van andere camera\'s" )
                f.write( "Aantal foto's " + str(aantal) + " van " + camera + " verschilt van " + str(nr_camera_fotos[track]) + " van andere camera\'s" + "\n" )
                stop = True

    if aantal_int_ort != 9:
        print( track + ": expected 9 internal orientation txt files but found " + str(aantal_int_ort) )
        f.write( track + ": expected 9 internal orientation txt files but found " + str(aantal_int_ort) + "\n" )
        stop = True

    if aantal_ext_ort != 9:
        print( track + ": expected 9 external orientation csv files but found " + str(aantal_ext_ort) )
        f.write( track + ": expected 9 external orientation csv files but found " + str(aantal_ext_ort) + "\n" )
        stop = True

# Expected cameras: front left+right, rear left+right, left forward+backward, right forward+backward, sphere
    if aantal_camera != 9:
        print( track + ": expected 9 cameras but found " + str(aantal_camera) )
        f.write( track + ": expected 9 cameras but found " + str(aantal_camera) + "\n" )
        stop = True

    res = aantal_jpg % 9
    if res != 0:
        print( track + ": number of jpg files " + str(aantal_jpg) + " is not a multiple of 9" )
        f.write( track + ": number of jpg files " + str(aantal_jpg) + " is not a multiple of 9" + "\n" )
        stop = True

    print("")
    f.write('\n')

if stop == True:
    print("Unexpected number of files. See the logfile " + output_log)
#        break

f.close()
