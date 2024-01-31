 %mic positions
mic1_x1 = 0;
mic1_y1 = 0;

mic2_x2 = 0;
mic2_y2 = 0.5;

mic3_x3 = 0.5;
mic3_y3 = 0;

mic4_x4 = 0.5;
mic4_y4 = 0.5;

c = 343;

%source_x = 0.01;
%source_y = 0.01;
source_x = rand()*0.5;
source_y = rand()*0.5;
disp(source_x)
disp(source_y)

mic1 = sqrt((source_x^2)+(source_y^2));
mic2 = sqrt((source_x^2)+((mic2_y2-source_y)^2));
mic3  = sqrt(((mic3_x3-source_x)^2)+(source_y^2));
mic4 = sqrt(((mic4_x4-source_x)^2)+((mic4_y4-source_y)^2));

mic1 = ((mic1)/c);    %Top right
mic2 = ((mic2)/c);    %Top left
mic3 = ((mic3)/c);    %Bottom left
mic4 = ((mic4)/c);    %Bottom right

%TDoA_mic1 = (mic1-mic1);  
%TDoA_mic2 = (mic2-mic1);
%TDoA_mic3 = (mic3-mic1);
%TDoA_mic4 = (mic4-mic1);

TDoA_mic1 = (mic1-mic1);
TDoA_mic2 = (mic2-mic1);
TDoA_mic3 = (mic3-mic1);
TDoA_mic4 = (mic4-mic1);

TDoA_Grid=[ TDoA_mic1 mic1_x1 mic1_y1;
           TDoA_mic2 mic2_x2 mic2_y2; 
           TDoA_mic3 mic3_x3 mic3_y3; 
           TDoA_mic4 mic4_x4 mic4_y4];

calculated_point = MULocate(TDoA_Grid);
cla();

%plots the grid on a grid 
ax = gca; 
plot(source_x*100,source_y*100,"x");
hold on
plot(calculated_point(1,1)*100,calculated_point(2,1)*100,"o");
ax.XLim = [-10 60];
ax.YLim = [-10 60];
ax.YTick = -10:2:60;
ax.XTick = -10:2:60;
ax.XGrid = 'on';
ax.YGrid = 'on';

function locSource = MULocate(evVal)
   c = 343;

   disp(evVal);

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
     
    locSource = 0.5 .* lsqr(A, b);
    
    disp(locSource);

end