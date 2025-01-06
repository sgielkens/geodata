# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

dir_path = "F:\SGI\Python"
file_naam = "Hengelo 31okt.txt"

invoer = dir_path + "/" + file_naam

import re

# f = open(invoer, "r")

#print(f.readline())
#print(f.readline())

#f.close()

i = 0

#pattern = re.compile('P')

pattern = "^.*sec"

with open(invoer) as f:
    regel = f.readline()
    gevonden = re.match(pattern, regel)
    print(gevonden)
    
    while not gevonden:
        regel = f.readline()
        gevonden = re.match(pattern, regel)
        print(regel)
        print(gevonden)
        
        i += 1
        if i >= 45:
            break
        
    
    


