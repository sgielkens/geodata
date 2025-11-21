import os
import re
import sys
import sqlite3
import datetime

# build exe:
# pip install pyinstaller
# pyinstaller -F extract_tracks.py

if len(sys.argv) < 2:
    sys.exit('extract_tracks [_rec dir]')

out_dir = sys.argv[1]
dir = re.sub('_rec', '.PegasusProject', out_dir, flags=re.IGNORECASE)

filenames = []

for root, dirs, files in os.walk(dir):
    for name in files:
        if name == 'scan.db':
            filenames.append(os.path.join(root, name))

d = {}

for file in filenames:
    con = sqlite3.connect(file)
    cur = con.cursor()
    cur.execute('SELECT KEYVALUE FROM [SCAN.SETTINGS] WHERE KEYNAME=\'StartRecording\' OR KEYNAME=\'StopRecording\' OR KEYNAME=\'countFrames\';')
    result = cur.fetchall()
    if len(result) == 3:
        d[re.findall(r'\d+', os.path.basename(os.path.dirname(file)))[0]] = result
    con.close()

d = dict(sorted(d.items(), key=lambda x: int(x[0])))

with open(os.path.join(out_dir, 'leica_tracks.csv'), 'w') as f:
    f.write('track;start;stop;count\n')
    for track, (start, stop, count) in d.items():
        f.write('{};{};{};{}\n'.format(track, int(datetime.datetime.strptime(start[0], '%Y,%m,%d,%H,%M,%S').timestamp()), int(datetime.datetime.strptime(stop[0], '%Y,%m,%d,%H,%M,%S').timestamp()), count[0]))