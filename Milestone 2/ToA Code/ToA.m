TL = 0.000942;
TR = 0.001411;
BL = 0.000679;
BR = 0.001251;

TL = 343*TL*100;
TR = 343*TR*100;
BL = 343*BL*100;
BR = 343*BR*100;


%X coords
for x = 0:+1:50

    eq1 = ((50-x)^2);
    eq2 = (TR^2);
    eq3 = (x^2);
    eq4 = (TL^2);

    if eq1<eq2 && eq3<eq4
        eqL = round(sqrt(eq4-eq3));
        eqR = round(sqrt(eq2-eq1));

        if eqR == eqL
            x_coord = x;
            break;
        end
    end
end

%Y coords
for y = 0:+1:50

    eq1 = ((50-y)^2);
    eq2 = (TL^2);
    eq3 = (y^2);
    eq4 = (BL^2);

    if eq1<eq2 && eq3<eq4
        eqB = round(sqrt(eq4-eq3));
        eqT = round(sqrt(eq2-eq1));

        if eqB == eqT
            y_coord = y;
            break;
        end
    end
end

text = ['The coordinates are: x: ', num2str(x_coord), ' cm    y: ', num2str(y_coord), ' cm'];
disp(text);