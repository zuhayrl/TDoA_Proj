%% mic positions
mic1_x1 = 0;
mic1_y1 = 0;

mic2_x2 = 0;
mic2_y2 = 0.5;

mic3_x3 = 0.5;
mic3_y3 = 0;

mic4_x4 = 0.5;
mic4_y4 = 0.5;

c = 343;


%% Coordinates
% The x and y coordinates of the source point

source_x = rand()*0.5;
source_y = rand()*0.5;

% Using this grid size means higher accuracy 
%source_x = rand()*0.4;
%source_y = rand()*0.4;

cal_x = 0.25;
cal_y = 0.25;
disp("Expected position")
disp(source_x)
disp(source_y)

%% Ideal ToA
%Calculate the ideal ToA of each mic 
%distances to each mic
mic1 = sqrt((source_x^2)+(source_y^2));
mic2 = sqrt((source_x^2)+((mic2_y2-source_y)^2));
mic3  = sqrt(((mic3_x3-source_x)^2)+(source_y^2));
mic4 = sqrt(((mic4_x4-source_x)^2)+((mic4_y4-source_y)^2));
calib = sqrt(((cal_x)^2)+((cal_y)^2));

%% Mic delays

%cal_time = sqrt((0.25^2)*2)*343; time it should take in seconds
%Expected TDoA is 0 for all the microphones if they were synchronised
%Generating Random delays to simulate the microphone delay
%due to non syncronised behavior
%generate delays due to mic 
mic12_error = rand()*0.00001;
mic34_error = rand()*0.00001; 

%calibration signal times
calib1 = (calib/c)+mic12_error;
calib2 = (calib/c)+mic12_error;
calib3 = (calib/c)+mic34_error;
calib4 = (calib/c)+mic34_error;
ideal_calib_time = calib/c; %ideal calib time
%% Error correction

%error times
error1=calib1-ideal_calib_time;
error2=calib2-ideal_calib_time;
error3=calib3-ideal_calib_time;
error4=calib4-ideal_calib_time;


%times to each mic with sync errors included
mic1 = ((mic1)/c)+mic12_error;    %Top right
mic2 = ((mic2)/c)+mic12_error;    %Top left
mic3 = ((mic3)/c)+mic34_error;    %Bottom left
mic4 = ((mic4)/c)+mic34_error;    %Bottom right

%% TDoA calculations

%calc TDoA error values 
TDoA_error1 = error1-error1;
TDoA_error2 = error2-error1;
TDoA_error3 = error3-error1;
TDoA_error4 = error4-error1;

%Calculate the TDoA in reference to the first mic
TDoA_mic1 = (mic1-mic1)-TDoA_error1;  
TDoA_mic2 = (mic2-mic1)-TDoA_error2;
TDoA_mic3 = (mic3-mic1)-TDoA_error3;
TDoA_mic4 = (mic4-mic1)-TDoA_error4;

%Scale TDoA to be in milliseconds 
TDoA_mic1_ms = TDoA_mic1 * 1000;
TDoA_mic2_ms = TDoA_mic2 * 1000; 
TDoA_mic3_ms = TDoA_mic3 * 1000; 
TDoA_mic4_ms = TDoA_mic4 * 1000; 
ideal_calib_time = ideal_calib_time * 1000; %ideal calib in ms

%% Generate chrip signal and add TDoA delay

%Generate your chirp signal
load chirp;

%Generating a reference chirp signal and other 3 signals
refsig = y;
sig1 = delayseq(refsig,TDoA_mic2_ms,Fs);
sig2 = delayseq(refsig,TDoA_mic3_ms,Fs);
sig3 = delayseq(refsig,TDoA_mic4_ms,Fs);

%sig1 = awgn(sig1,7);
%sig2 = awgn(sig2,2);
%sig3 = awgn(sig3,9);
%refsig = awgn(refsig,15);


%Noise generation and signal offset
disp ("SNR:")
%SNR = rand()*100;
SNR = 65;
disp(SNR)

sig1 = awgn(sig1,SNR);
sig2 = awgn(sig2,SNR);
sig3 = awgn(sig3,SNR);
refsig = awgn(refsig,SNR);

% Noise reduction using a Savitzky–Golay filter
sig1 = smoothdata(sig1,"sgolay");
sig2 = smoothdata(sig2,"sgolay");
sig3 = smoothdata(sig3,"sgolay");
refsig = smoothdata(refsig,"sgolay");

%Plotting the noisy + offset + filtered signal 
%subplot(4,1,1)
%plot(refsig)
%subplot(4,1,2)
%plot(sig1)
%subplot(4,1,3)
%plot(sig2)
%subplot(4,1,4)
%plot(sig3)

%Time delay estimation
tau_est12 = gccphat(sig1,refsig,Fs);
tau_est13 = gccphat(sig2,refsig,Fs);
tau_est14 = gccphat(sig3,refsig,Fs);

%% Triagulation
TDoA_Grid=[ 0 mic1_x1 mic1_y1;
           tau_est12/1000 mic2_x2 mic2_y2; 
           tau_est13/1000 mic3_x3 mic3_y3; 
           tau_est14/1000 mic4_x4 mic4_y4];

%Triagulation
calculated_point = MULocate(TDoA_Grid);

%% Display grid
cla();
%plots the grid on a grid 
ax = gca; 
plot(source_x*100,source_y*100,"x");
hold on
plot(calculated_point(1,1)*100,calculated_point(2,1)*100,"o");
ax.XLim = [0 50];
ax.YLim = [0 50];
ax.YTick = 0:2:50;
ax.XTick = 0:2:50;
ax.XGrid = 'on';
ax.YGrid = 'on';


%% Triagulation function
function locSource = MULocate(TDoA_Grid)
 
c = 343;
 % Linear Solution
p_1 = TDoA_Grid(1, 2:3);  % Use the first row of TDoA_Grid for p_1
dummy = TDoA_Grid(2:end, 2:3);  % Exclude the first row for dummy
A = 2 * [(p_1(1) - dummy(:, 1)), (p_1(2) - dummy(:, 2)), -c * TDoA_Grid(2:end, 1)];
b = (c * TDoA_Grid(2:end, 1)).^2 + norm(p_1)^2 - sum((dummy.^2), 2);
x_lin = pinv(A) * b;

%Initial estimate for Taylor series 
p_T_0 = x_lin; 

% Calculate the time differences of arrival (TDoA) using the initial estimate.
d = c * TDoA_Grid(2:end, 1);
f = zeros(size(d));
del_f = zeros(length(d), 2);

for ii = 1:length(d)
    f(ii) = norm(p_T_0(1:2,:) - dummy(ii, :)') - norm(p_T_0(1:2,:) - p_1');
    del_f(ii, 1) = (p_T_0(1,1) - dummy(ii, 1)) * norm(p_T_0(1:2,:) - dummy(ii, :)')^-1 - (p_T_0(1) - p_1(1)) * norm(p_T_0(1:2,:) - p_1')^-1;
    del_f(ii, 2) = (p_T_0(2,1) - dummy(ii, 2)) * norm(p_T_0(1:2,:) - dummy(ii, :)')^-1 - (p_T_0(2) - p_1(2)) * norm(p_T_0(1:2,:) - p_1')^-1;
end

% Use the Taylor Series method to estimate the source location.
locSource = pinv(del_f) * (d - f) + p_T_0(1:2,:);
end
