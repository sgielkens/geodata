# -*- coding: utf-8 -*-
"""
Created on Fri Nov 10 15:25:36 2023

@author: SCANTEAM
"""

import os
#import re

pwd = os.path.dirname(os.path.realpath(__file__))
dir_path = pwd + "/.."

input_path = dir_path + "/input"

dir_list = os.listdir(dir_path)
#print(dir_list)

#p = re.compile('.*Track10.*')

#for path in os.scandir(dir_path):
#     if path.is_file():
#         print(path.name)
#    m = p.match(path.name)
#    if m:
#        print(m)
#    else:
#        print("No match")



import zipfile

#with zipfile.ZipFile(dir_path + "/zip/py_test.zip", mode="r") as archive:
#    archive.printdir()

        
import pathlib

directory = pathlib.Path(input_path)

#with zipfile.ZipFile(dir_path + "/zip/maak_dir.zip", mode="w") as archive:
#    for file_path in directory.iterdir():
#        m = p.match(file_path.name)
#        if m:
#            archive.write(file_path, arcname=file_path.name)

#tellers = []
tellers = {}
            
for file_path in directory.iterdir():
    woord = file_path.name
#    print(woord)
    lettergreep = woord.split('_')
    
    track_naam = lettergreep[3]
    track_nummer = int(track_naam.lstrip("Track"))
#    print(track_nummer)

    camera = lettergreep[4]
#    print(camera)
    if camera.endswith(".txt"):
        camera = camera.removesuffix(".txt")
        camera = camera + "_int_ort"
        
    if camera.endswith(".csv"):
        camera = camera.removesuffix(".csv")
        camera = camera + "_ext_ort"
      
      
    if not track_naam in tellers:
        tellers[track_naam] = {}
        tellers[track_naam]["totaal"] = 0
        
    tellers[track_naam]["totaal"] += 1
    
    if not camera in tellers[track_naam]:
        tellers[track_naam][camera] = 0
        
    tellers[track_naam][camera] += 1
    
    
            
    zip_bestand = dir_path + "/zip/fotos_" + track_naam + ".zip"
    
    if os.path.exists(zip_bestand):
        zip_modus = 'a'
    else:
        zip_modus = 'w'
        
    with zipfile.ZipFile(zip_bestand, mode = zip_modus) as archive:
        archive.write(file_path, arcname=file_path.name)


# Controle

for track, aantallen in tellers.items():
    for camera, aantal in aantallen.items():
        if not camera.endswith("_ort") and not camera == "totaal":
            nr_fotos = aantal
            break
    
#print(nr_fotos)    

  
for track, aantallen in tellers.items():
    print(track + ': ' + str( aantallen["totaal"] ) + ' bestanden in totaal')
    
    stop = False
    
    aantal_int_ort = 0
    aantal_ext_ort = 0
    
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

        elif aantal != nr_fotos:
            print( "Aantal foto's " + str(aantal) + " van " + camera + " verschilt van " + str(nr_fotos) )
            stop = True
        
    if aantal_int_ort != 9:
        print( track + ": expected 9 internal orientation txt files but found " + str(aantal_int_ort) )
        stop = True
            
    if aantal_ext_ort != 9:
        print( track + ": expected 9 external orientation csv files but found " + str(aantal_ext_ort) )
        stop = True
            
    print("")
    
    if stop == True:
        print(track + ": unexpected number of files. See the logging above")
        break
    
    
