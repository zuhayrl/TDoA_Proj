%mic positions
mic1_x1 = 0;
mic1_y1 = 0;

mic2_x2 = 0;
mic2_y2 = 0.5;

mic3_x3 = 0.5;
mic3_y3 = 0;

mic4_x4 = 0.5;
mic4_y4 = 0.5;

%c = 343;

%The x and y coordinates of the source point
source_x = 0.2;
source_y = 0.12;

%source_x = rand()*0.5;
%source_y = rand()*0.5;
disp(source_x)
disp(source_y)

mic1 = sqrt((source_x^2)+(source_y^2));
mic2 = sqrt((source_x^2)+((mic2_y2-source_y)^2));
mic3  = sqrt(((mic3_x3-source_x)^2)+(source_y^2));
mic4 = sqrt(((mic4_x4-source_x)^2)+((mic4_y4-source_y)^2));

c = 343;

mic1 = (mic1)/c;    %Top right
mic2 = (mic2)/c;    %Top left
mic3 = (mic3)/c;    %Bottom left
mic4 = (mic4)/c;    %Bottom right

mic_array = [mic1; mic2; mic3; mic4];

%reference_mic = min(mic_array);

TDoA_mic1 = (mic1-mic1);  
TDoA_mic2 = (mic2-mic1);
TDoA_mic3 = (mic3-mic1);
TDoA_mic4 = (mic4-mic1);

TDoA_mic1_ms = TDoA_mic1 * 1000;
TDoA_mic2_ms = TDoA_mic2 * 1000; 
TDoA_mic3_ms = TDoA_mic3 * 1000; 
TDoA_mic4_ms = TDoA_mic4 * 1000; 


load chirp;

%Generating a reference chirp signal and other 3 signals
refsig = y;
refsig = delayseq(refsig,TDoA_mic1_ms,Fs);
sig1 = delayseq(refsig,TDoA_mic2_ms,Fs);
sig2 = delayseq(refsig,TDoA_mic3_ms,Fs);
sig3 = delayseq(refsig,TDoA_mic4_ms,Fs);

%sig1 = awgn(sig1,7);
%sig2 = awgn(sig2,2);
%sig3 = awgn(sig3,9);
%refsig = awgn(refsig,15);


%Noise generation and signal offset
sig1 = awgn(sig1,rand()*10) - rand;
sig2 = awgn(sig2,rand()*10) + rand;
sig3 = awgn(sig3,rand()*10) - rand;
refsig = awgn(refsig,rand()*10) + rand;

% Noise reduction using a Savitzky–Golay filter
sig1 = smoothdata(sig1,"sgolay");
sig2 = smoothdata(sig2,"sgolay");
sig3 = smoothdata(sig3,"sgolay");
refsig = smoothdata(refsig,"sgolay");

%Plotting the noisy + offset + filtered signal 
subplot(4,1,1)
plot(refsig)
subplot(4,1,2)
plot(sig1)
subplot(4,1,3)
plot(sig2)
subplot(4,1,4)
plot(sig3)

%Time delay estimation
tau_est12 = gccphat(sig1,refsig,Fs);
tau_est13 = gccphat(sig2,refsig,Fs);
tau_est14 = gccphat(sig3,refsig,Fs);

%Putting the delays into an array
%plot(sig);
%disp(delays);

TDoA_Grid=[ 0 mic1_x1 mic1_y1;
           tau_est12/1000 mic2_x2 mic2_y2; 
           tau_est13/1000 mic3_x3 mic3_y3; 
           tau_est14/1000 mic4_x4 mic4_y4];

calculated_point = MULocate(TDoA_Grid);
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

function locSource = MULocate(evVal)
    c = 343;
    TDoA12 = evVal(2,1) - evVal(1,1);
    TDoA13 = evVal(3,1) - evVal(1,1);
    TDoA14 = evVal(4,1) - evVal(1,1);

    A = [
        evVal(2,2) - evVal(1,2), evVal(2,3) - evVal(1,3), -TDoA12 * c;
        evVal(3,2) - evVal(1,2), evVal(3,3) - evVal(1,3), -TDoA13 * c;
        evVal(4,2) - evVal(1,2), evVal(4,3) - evVal(1,3), -TDoA14 * c;
    ];

    b1 = -(TDoA12 * c)^2 - evVal(1,2)^2 - evVal(1,3)^2 + evVal(2,2)^2 + evVal(2,3)^2;
    b2 = -(TDoA13 * c)^2 - evVal(1,2)^2 - evVal(1,3)^2 + evVal(3,2)^2 + evVal(3,3)^2;
    b3 = -(TDoA14 * c)^2 - evVal(1,2)^2 - evVal(1,3)^2 + evVal(4,2)^2 + evVal(4,3)^2;
    b = [ 
        b1; 
        b2;
        b3;
    ];
    
    revVal = sortrows(evVal, 1);
    point_1= abs(revVal(1,1)) * 1000;
    point_2 = abs(revVal(2,1)) * 1000;
    point_3 = abs(revVal(3,1)) * 1000;
    point_4 = abs(revVal(4,1)) * 1000;


 
        locSource = 0.5 .* lsqr(A, b);
    
    disp(locSource);
end