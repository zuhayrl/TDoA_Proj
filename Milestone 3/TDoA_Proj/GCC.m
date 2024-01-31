%GCC + Noise reduction submodule. Takes in 2 data files and outputs 3 TDoA
%values.


%Reading the Data
[refsig,sig1,sig2,sig3,Fs] = dataRead();

%Sample reference .wav file
%[reference,Fs_chirp] = audioread("reference.wav");

%Generating a reference Chirp
t = 0:1/64e3:4;
reference = chirp(t,20,2,9990);



%Testing with known delays: delete or comment out

%Fs = 64e3;
%t = 0:1/Fs:0.005;
%reference = cos(2*pi*1000*t)';

%Expected_tau_12 = (40- 7)*(1/Fs)
%Expected_tau_13 = (5-7)*(1/Fs)
%Expected_tau_14 = (10-7)*(1/Fs)

%sig1 = delayseq(reference,40);
%sig2 = delayseq(reference,5);
%sig3 = delayseq(reference,10);
%refsig = delayseq(reference,7);

%End of putting expected values


%Noise reduction
%refsig = nReduction(refsig);
%sig1 = nReduction(sig1);
%sig2 = nReduction(sig2);
%sig3 = nReduction(sig3);

%Plotting the recieved signals 
subplot(4,1,1)
plot(refsig)
subplot(4,1,2)
plot(sig1)
subplot(4,1,3)
plot(sig2)
subplot(4,1,4)
plot(sig3)

%From the function I have defined
[tau1,cal1] = tdoa(refsig,reference,Fs);
[tau2,cal2] = tdoa(sig1,reference,Fs);
[tau3,cal3] = tdoa(sig2,reference,Fs);
[tau4,cal4] = tdoa(sig3,reference,Fs);

%To get the TDoA values to be used for triangulation
tau_est12 = (tau2 - cal2*0) - (tau1 - cal1*0)
tau_est13 = (tau3 - cal3*0) - (tau1 - cal1*0)
tau_est14 = (tau4 - cal4*0) - (tau1 - cal1*0)

%Verification Phase

%Plotting the recieved signals 
%subplot(4,1,1)
%plot(refsig)
%subplot(4,1,2)
%plot(sig1)
%subplot(4,1,3)
%plot(sig2)
%subplot(4,1,4)
%plot(sig3)

%User Defined Functions

%Nosie reduction
function signal = nReduction(signal)
    % Noise reduction using a Savitzky–Golay filter
    signal = smoothdata(signal,"sgolay");
end

%Reading the data from the audio file
function [left1,right1,left2,right2,Fs] = dataRead()
    [y,Fs] = audioread("file_test1.wav");
    [z,~] = audioread("file_test2.wav") ;
    left1 = y(:,1);
    right1 = y(:,2);
    left2 = z(:,1);
    right2 = z(:,2);

    %Maybe gonna be used
    %len = length(refsig);
    %sig2 = sig2(1:len);
    %sig3 = sig3(1:len);
end

%Time Delay Estimation
function [tau, cal] = tdoa(sig , ref,Fs)
    peak1 = correlate(sig,ref);
    fl = zeros(1,3*Fs);
    sig_temp = sig;
    f = length(fl);
    sig_temp(peak1:peak1+f-1) = fl;
    peak2 = correlate(sig_temp,ref);
    peaks = [peak1 peak2];
    cal = min(peaks)/Fs;
    tau = max(peaks)/Fs;
end

%Correlation Function
function val = correlate(sig2,sig1)
    [Correlation_arr,lag_arr] = xcorr(sig2,sig1);
    [~,index_of_lag] = max(abs((Correlation_arr)));
    val = lag_arr(index_of_lag);
end 