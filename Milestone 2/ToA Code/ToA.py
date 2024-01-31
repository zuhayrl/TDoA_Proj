#Time of Arrival Calculations
#EEE3097S
import math

#define grid
# 50 cm by 50 cm 1 cm blocks
# mic in each corner

#   (0,50)      (50,50)
#
#
#   (0,0)       (50,0)

#Test Values in ms
#TL = 0.000729
#TR = 0.000977
#BL = 0.001175
#BR = 0.001344

TL = 0.000942
TR = 0.001411
BL = 0.000679
BR = 0.001251


#mic distances multiply by 100 to convert to cm
#TL = float(input("Time to Top Left: "))
TL = 343*TL*100
#TR = float(input("Time to Top Right: "))
TR = 343*TR*100
#BL = float(input("Time to Bottom Left: "))
BL = 343*BL*100
#BR = float(input("Time to Bottom Right: "))
BR = 343*BR*100


# X COORDINATES======================================================
# Using top two 

for x in range(0,51):

    #print(x)

    if (((50-x)**2) < (TR**2)) and ((x**2)<(TL**2)):
        eqL = round(math.sqrt((TL**2)-(x**2)))
        eqR = round(math.sqrt((TR**2)-((50-x)**2)))

        if eqL == eqR:
            x_top = x
            break;


# Using top two 

for x in range(0,51):

    #print(x)

    if (((50-x)**2) < (BR**2)) and ((x**2)<(BL**2)):
        eqL = round(math.sqrt((BL**2)-(x**2)))
        eqR = round(math.sqrt((BR**2)-((50-x)**2)))

        if eqL == eqR:
            x_bottom = x
            break;



# Y COORDINATES =======================================================
# Using left two 

for y in range(0,51):

    #print(y)

    if (((50-y)**2) < (TL**2)) and ((y**2)<(BL**2)):
        eqB = round(math.sqrt((BL**2)-(y**2)))
        eqT = round(math.sqrt((TL**2)-((50-y)**2)))

        if eqB == eqT:
            y_left = y
            break;

# Using right two 

for y in range(0,51):

    #print(y)

    if (((50-y)**2) < (TR**2)) and ((y**2)<(BR**2)):
        eqB = round(math.sqrt((BR**2)-(y**2)))
        eqT = round(math.sqrt((TR**2)-((50-y)**2)))

        if eqB == eqT:
            y_right = y
            break;

#coords
y=(y_left+y_right)/2
x=(x_top+x_bottom)/2

print("The coordinates are: x= " + str(x) + ", cm   y= " + str(y) + " cm")    