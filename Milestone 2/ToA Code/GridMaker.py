import math

TDoAs = []
row = []


def calc_mic1(x,y): #0,0 
    distance = (math.sqrt((x**2)+(y**2)))/100
    time = distance/343
    return time

def calc_mic2(x,y): #0,50 
    distance = (math.sqrt((x**2)+((50-y)**2)))/100
    time = distance/343
    return time

def calc_mic3(x,y): #50,0 
    distance = (math.sqrt(((50-x)**2)+(y**2)))/100
    time = distance/343
    return time

def calc_mic4(x,y): #50,50 
    distance = (math.sqrt(((50-x)**2)+((50-y)**2)))/100
    time = distance/343
    return time


for x in range(0,6):
    row.clear()
    for y in range(0,6):
        time1 = calc_mic1(x,y)
        TDoA12 = round(calc_mic2(x,y),6)#-time1
        TDoA13 = round(calc_mic3(x,y),6)#-time1
        TDoA14 = round(calc_mic4(x,y),6)#-time1
        list = [TDoA12,TDoA13,TDoA14]
        row.append(list)
    TDoAs.append(row)
    print(TDoAs[x])
print("\n \n")

print(TDoAs)

