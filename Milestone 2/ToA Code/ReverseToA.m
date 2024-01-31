x = 12;
y = 20;

d_TL = sqrt((x^2)+((50-y)^2));
d_TR = sqrt(((50-x)^2)+((50-y)^2));
d_BL = sqrt((x^2)+(y^2));
d_BR = sqrt(((50-x)^2)+(y^2));

d_TL = (d_TL*10)/343;
d_TR = (d_TR*10)/343;
d_BL = (d_BL*10)/343;
d_BR = (d_BR*10)/343;

