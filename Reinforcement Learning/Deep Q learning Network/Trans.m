function [Qipan,blank,blank_p] = Trans(x,blank,blank_p,Qipan)

Num = size(Qipan,2);

if x < 1 || x >= Num || blank == x
    return;
end

if abs(mod(x-1,M)-mod(blank-1,M))>1
    return;
end

Qipan(blank) = Qipan(x);
Qipan(x) = 0;
blank_p = blank;
blank = x;




end