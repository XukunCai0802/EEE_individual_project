function [s_new, bk_new, reward, done] = take_action(s, bk, action, M, Num, dict,done)

X = [-M,M,-1,1];  % move direction
goal = [1:Num-1,0];

x = bk+X(action);

if x<1 || x>Num  % exceed puzzle boundary
    s_new = s;
    bk_new = bk;
    reward = -1000;
    done = 1;
    return
end

if abs(mod(x-1,M)-mod(bk-1,M))>1 % exceed puzzle boundary
    s_new = s;
    bk_new = bk;
    reward = -1000;
    done = 1;
    return
end


s_new = s;
s_new(bk) = s_new(x);
s_new(x) = 0;
bk_new = x;

if isequal(s_new,goal) %complete final position to get maximum reward
    reward = 1000;
    done = 1;
else
    s_new_ind = all(dict(:,1:Num) == s_new,2);
    reward = -dict(s_new_ind,Num+1);
end




end