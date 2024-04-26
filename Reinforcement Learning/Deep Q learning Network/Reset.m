function [qipan,bk,done] = Reset(M,Num,mode)


if mode==1
    init = [1:Num-1,0];
    qipan = init;
    
    X = [-1,-M,1,M];  
    max_step = randi([400,800]);  
    step = 0;
    bk = Num;
    bk_p = -1;
    
    while step < max_step || qipan(end) ~= 0
        i = randi(4);
        x = bk+X(i);
        [qipan,bk,bk_p] = Trans(x,bk,bk_p,qipan);
    end
else
    qipan = [4	3	0	7	1	5	8	2	6];
    bk = 3;
end


bk_p = -1;
step = 0;  
done = 0;






end