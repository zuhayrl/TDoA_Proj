import subprocess
import os

command = "sshpass -p 'zuhayr01' ssh zuhayr@172.20.10.6 arecord -D plughw:0 -c2 -r 64000 -f S32_LE -t wav -q -d 15 file_test1.wav"
#command = "echo pi1"
try:
    subprocess.check_output(command, shell=True)
except subprocess.CalledProcessError as e:
    print("Error: ", e)