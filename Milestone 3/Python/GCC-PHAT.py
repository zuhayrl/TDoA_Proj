#If this is your first time using this you need to pip install numpy and scipy
from scipy.io import wavfile
import numpy as np
from scipy.signal import savgol_filter


#Defining the GCC-PHAT function
def gcc_phat(sig, refsig, fs=48000, max_tau=None, interp=16):
    # make sure the length for the FFT is larger or equal than len(sig) + len(refsig)
    n = sig.shape[0] + refsig.shape[0]

    # Generalized Cross Correlation Phase Transform
    SIG = np.fft.rfft(sig, n=n)
    REFSIG = np.fft.rfft(refsig, n=n)
    R = SIG * np.conj(REFSIG)

    cc = np.fft.irfft((R/np.abs(R)), n=(interp * n))

    max_shift = int(interp * n / 2)
    if max_tau:
        max_shift = np.minimum(int(interp * fs * max_tau), max_shift)

    cc = np.concatenate((cc[-max_shift:], cc[:max_shift+1]))

    # find max cross correlation index
    shift = np.argmax(np.abs(cc)) - max_shift

    tau = shift / float(interp * fs)
    
    return tau

#Defining the splitting of the 2 sets of data per file
def read_split ():
#Importing the data files (If you use this on your own computer change the filepath to your own)
    file_path = r"C:\Users\User\Desktop\Academics\EEE 3097S\Milestone 3\file_test1.wav"
    Fs1, data1 = wavfile.read(file_path)
    file_path = r"C:\Users\User\Desktop\Academics\EEE 3097S\Milestone 3\file_test2.wav"
    Fs2, data2 = wavfile.read(file_path)

    #Splitting the data
    arr1,arr2 = zip(*data1)
    arr3,arr4 = zip(*data2)
    return arr1,arr2,arr3,arr4


#Defining the noise reduction part
def noise_reduction(sig):
    # Parameters for the Savitzky-Golay filter
    window_length = 3  # Window length of the filter
    polyorder = 2  # Polynomial order used to fit the samples
    #Noise reduction
    # Apply Savitzky-Golay filter for smoothing (window size and polynomial order can be adjusted)
    sig_filtered = savgol_filter(sig, window_length=window_length, polyorder=polyorder)
    return sig_filtered
    



#TODO: Assign the correct microphone to the correct data


#Separating and reading the data
refsig,sig1,sig2,sig3 = read_split()

refsig_filtered = noise_reduction(refsig)
sig1_filtered = noise_reduction(sig1)
sig2_filtered = noise_reduction(sig2)
sig3_filtered = noise_reduction(sig3)

#Performing the GCC_PHAT
#Values to be used for triangulation (Honestly idk which mic is which)


#tau = gcc_phat(refsig_filtered,refsig_filtered)
tau1 = gcc_phat(sig1_filtered,refsig_filtered)
tau2 = gcc_phat(sig2_filtered,refsig_filtered)
tau3 = gcc_phat(sig3_filtered,refsig_filtered)

#Pringing the GCC-PHAT values
#print("Checking if the GCC-PHAT actually works (Meant to be 0.0) = ",tau)
#print("Estimated delay1 = ",tau1)
#print("Estimated delay2 = ",tau2)
#print("Estimated delay3 = ",tau3)



