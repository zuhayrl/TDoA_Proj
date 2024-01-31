% clear previous pi connections
%clear mypi;
% connect to pi
mypi1 = raspi('172.20.10.5','zuhayr','zuhayr01');
disp(mypi1)
%system(mypi,'ls')
%raspilist
% Create a figure with UIAxes
fig = uifigure('Name', 'Sound Source Localization');

% Create a layout for buttons and axes
mainLayout = uigridlayout(fig, [1, 3]);
mainLayout.RowHeight = {30}; % Adjust the height as needed
mainLayout.ColumnWidth = {'1x', '1x', '1x'}; % Adjust column widths as needed

% Create UIAxes
ax = uiaxes(mainLayout);
ax.Layout.Row = [1,7];
ax.Layout.Column = [1, 3]; % Span multiple columns
ax.XLim = [0 50];
ax.YLim = [0 50];
xlabel(ax, 'X-axis');
ylabel(ax, 'Y-axis');
grid(ax, 'on');

% Create buttons
startButton = uibutton(mainLayout, 'push', 'Text', 'Calculate');
recordButton = uibutton(mainLayout, 'push', 'Text', 'Record');
clearButton = uibutton(mainLayout, 'push', 'Text', 'Clear');
exitButton = uibutton(mainLayout, 'push', 'Text', 'Exit');

% Set button positions and callbacks
recordButton.Layout.Row = 8;
recordButton.Layout.Column = 1;
recordButton.ButtonPushedFcn = @(btn, event) recordButtonCallback(mypi1);

startButton.Layout.Row = 8;
startButton.Layout.Column = 2;
startButton.ButtonPushedFcn = @(btn, event) startButtonCallback(btn, ax);

clearButton.Layout.Row = 8;
clearButton.Layout.Column = 3;
clearButton.ButtonPushedFcn = @(btn, event) clearButtonCallback(ax);

exitButton.Layout.Row = 8;
exitButton.Layout.Column = 4;
exitButton.ButtonPushedFcn = @(btn, event) exitButtonCallback(fig);

% Function to plot the sound source
function recordButtonCallback(mypi1)
disp('start sound')
    system(mypi1,'python3 main.py')
    %getFile(mypi,'/home/zuhayr/file_ref1.wav','C:\Users\zuhay\Documents\TDoA_Proj')
    %getFile(mypi,'/home/zuhayr/file_ref2.wav','C:\Users\zuhay\Documents\TDoA_Proj')
    getFile(mypi1,'/home/zuhayr/file_test1.wav','C:\Users\zuhay\Documents\TDoA_Proj')
    getFile(mypi1,'/home/zuhayr/file_test2.wav','C:\Users\zuhay\Documents\TDoA_Proj')
    disp('files copied')


end

function startButtonCallback(btn, ax)
    %Generating a reference Chirp
    Fs = 64000;
    t = 0:1/Fs:3;
    reference = chirp(t,20,2,9990);

    %%IM CHANGING THIS SECTION
    
    cal_x = 0.2;
    cal_y = 0.2;
    %% mic positions
    mic1_x1 = 0;
    mic1_y1 = 0;

    mic2_x2 = 0;
    mic2_y2 = 0.5;
    
    mic3_x3 = 0.5;
    mic3_y3 = 0;
    
    mic4_x4 = 0.5;
    mic4_y4 = 0.5;
    
    c =343;
    
    
    %Calculate the ideal ToA of each mic 
    ex_tau1 = sqrt((mic1_x1-cal_x)^2+(mic1_y1-cal_y)^2)/c; 
    ex_tau2 = sqrt((mic2_x2-cal_x)^2+(mic2_y2-cal_y)^2)/c; 
    ex_tau3 = sqrt((mic3_x3-cal_x)^2+(mic3_y3-cal_y)^2)/c; 
    ex_tau4 = sqrt((mic4_x4-cal_x)^2+(mic4_y4-cal_y)^2)/c; 
    
    
    %%CALIBRATION
    
    
    %%TDOA
    
    [refsig, sig1,sig2,sig3, Fs] = dataRead();
    subplot(2,1,1)
    plot(refsig)
    refsig = nReduction(refsig);
    subplot(2,1,2)
    plot(refsig)

    %From the function I have defined
    [tau1,cal_1] = tdoa(refsig,reference,Fs);
    [tau2,cal_2] = tdoa(sig1,reference,Fs);
    [tau3,cal_3] = tdoa(sig2,reference,Fs);
    [tau4,cal_4] = tdoa(sig3,reference,Fs);
    
    err_1 = cal_1 - ex_tau1
    err_2 = cal_2 - ex_tau2
    err_3 = cal_3 - ex_tau3
    err_4 = cal_4 - ex_tau4
    
    tau_est12 = (tau2 - err_2) - (tau1 - err_1)
    tau_est13 = (tau3 - err_3) - (tau1 - err_1)
    tau_est14 = (tau4 - err_4) - (tau1 - err_1)

    TDoA_Grid=[ 0 0 0;
           tau_est12/2 0.5 0; 
           tau_est13/2 0 0.5; 
           tau_est14/2 0.5 0.5;];

       %Triagulation
    calculated_point = MULocate(TDoA_Grid);
    x = calculated_point(1,1)*100
    y = calculated_point(2,1)*100
    %x=20;
    %y=20;
    
    if 0 <= x && x <= 50 && 0 <= y && y <= 50
        plot(ax, x, y, 'bx', 'MarkerSize', 10, 'DisplayName', 'Sound source');
        legend(ax);
    else
        errordlg('Invalid input. X and Y values must be within the specified range.');
    end
end

% Function to clear the grid
function clearButtonCallback(ax)
    cla(ax);  % Clear the axes
end

% Function to close the figure
function exitButtonCallback(fig)
    delete(fig);
end

function signal = nReduction(signal)
    % Noise reduction using a Savitzky–Golay filter
    signal = smoothdata(signal,"sgolay");
end

%Reading the data from the audio file
%Reading the data from the audio file
function [left1,right1,left2,right2,Fs] = dataRead()
    [y,Fs] = audioread("file_test1.wav");
    [z,~] = audioread("file_test2.wav") ;
    left1 = y(:,1);
    right1 = y(:,2);
    left2 = z(:,1);
    right2 = z(:,2);

    %Maybe gonna be used
    len = length(left1);
    left1 = left1(100000:len);
	left2 = left2(100000:len);
	right1 = right1(100000:len);
	right2 = right2(100000:len);
    %sig3 = sig3(1:len);
end

%Time Delay Estimation
function [tau,cal] = tdoa(sig , ref,Fs)
    try
        peak1 = correlate(sig,ref);
        fl = zeros(1,3*Fs);
        sig_temp = sig;
        f = length(fl);
        sig_temp(peak1:peak1+f-1) = fl;
        peak2 = correlate(sig_temp,ref);
        peaks = [peak1 peak2];
	    cal = min(peaks)/Fs;
        tau = max(peaks)/Fs;

    catch 
        errordlg('Started Recording Too Soon. Try Again');
    end 
end

%Correlation Function
function val = correlate(sig2,sig1)
    [Correlation_arr,lag_arr] = xcorr(sig2,sig1);
    [~,index_of_lag] = max(abs((Correlation_arr)));
    val = lag_arr(index_of_lag);
end 

%% Triagulation function
function locSource = MULocate(TDoA_Grid)
 
c = 343;
 % Linear Solution

    TDoA12 = TDoA_Grid(2,1) - TDoA_Grid(1,1);
    TDoA13 = TDoA_Grid(3,1) - TDoA_Grid(1,1);
    TDoA14 = TDoA_Grid(4,1) - TDoA_Grid(1,1);

    A = [
        TDoA_Grid(2,2) - TDoA_Grid(1,2), TDoA_Grid(2,3) - TDoA_Grid(1,3), -TDoA12 * c;
        TDoA_Grid(3,2) - TDoA_Grid(1,2), TDoA_Grid(3,3) - TDoA_Grid(1,3), -TDoA13 * c;
        TDoA_Grid(4,2) - TDoA_Grid(1,2), TDoA_Grid(4,3) - TDoA_Grid(1,3), -TDoA14 * c;
    ];

    b1 = -(TDoA12 * c)^2 - TDoA_Grid(1,2)^2 - TDoA_Grid(1,3)^2 + TDoA_Grid(2,2)^2 + TDoA_Grid(2,3)^2;
    b2 = -(TDoA13 * c)^2 - TDoA_Grid(1,2)^2 - TDoA_Grid(1,3)^2 + TDoA_Grid(3,2)^2 + TDoA_Grid(3,3)^2;
    b3 = -(TDoA14 * c)^2 - TDoA_Grid(1,2)^2 - TDoA_Grid(1,3)^2 + TDoA_Grid(4,2)^2 + TDoA_Grid(4,3)^2;
    b = [ 
        b1; 
        b2;
        b3;
    ];
     
    x_lin = 0.5 .* lsqr(A, b);
%Initial estimate for Taylor series 
p_1 = TDoA_Grid(1, 2:3);  % Use the first row of TDoA_Grid for p_1
dummy = TDoA_Grid(2:end, 2:3);  % Ex
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
