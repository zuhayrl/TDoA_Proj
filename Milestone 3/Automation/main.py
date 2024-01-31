import os
import subprocess
import time

os.system('python3 mic1.py & python3 mic2.py')
#os.system("echo start")
time.sleep(3)
os.system("sshpass -p 'zuhayr01' scp zuhayr@raspberrypi1:file_test1.wav audio_files & sshpass -p 'zuhayr01' scp zuhayr@raspberrypi2:file_test2.wav audio_files")