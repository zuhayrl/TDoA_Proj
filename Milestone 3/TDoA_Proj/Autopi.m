clear mypi;
mypi = raspi('172.20.10.5','zuhayr','zuhayr01');

system(mypi,'python3 test.py')
getFile(mypi,'/home/zuhayr/file_test2.wav','C:\Users\zuhay\Documents\TDoA_Proj')
clear mypi;