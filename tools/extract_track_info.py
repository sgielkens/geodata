# -*- coding: utf-8 -*-
"""
Created on Tue Nov 28 16:54:13 2023

@author: Serge Gielkens
"""

import sqlite3
import datetime
import time

con = sqlite3.connect("/home/serge/tmp/Python/track04_scan.db")
cur = con.cursor()

res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StartRecording'")

start_timestamp = res.fetchone()
start_elementen = start_timestamp[0].split(',')

start_jaar = int(start_elementen[0])
start_maand = int(start_elementen[1])
start_dag = int(start_elementen[2])
start_uur = int(start_elementen[3])
start_minuut = int(start_elementen[4])
start_seconde = int(start_elementen[5])

start_datetime = datetime.datetime(start_jaar, start_maand, start_dag, start_uur, start_minuut, start_seconde)
start_unix_timestamp = time.mktime(start_datetime.timetuple())

res = cur.execute("select KEYVALUE from [SCAN.SETTINGS] where SECTION = 'Files' AND KEYNAME = 'StopRecording'")

stop_timestamp = res.fetchone()
stop_elementen = stop_timestamp[0].split(',')

stop_jaar = int(stop_elementen[0])
stop_maand = int(stop_elementen[1])
stop_dag = int(stop_elementen[2])
stop_uur = int(stop_elementen[3])
stop_minuut = int(stop_elementen[4])
stop_seconde = int(stop_elementen[5])

stop_datetime = datetime.datetime(stop_jaar, stop_maand, stop_dag, stop_uur, stop_minuut, stop_seconde)
stop_unix_timestamp = time.mktime(stop_datetime.timetuple())

duur_unix_seconds = stop_unix_timestamp - start_unix_timestamp

print(duur_unix_seconds)


con.close()
