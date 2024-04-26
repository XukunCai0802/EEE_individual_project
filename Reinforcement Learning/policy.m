function action=policy(s,epslion,Q,ACTIONS,dict)
        if rand > epslion
            s_ind = all(dict(:,1:Num) == s,2);
             [~,a] = max(Q(s_ind,:));
        else
            a = randi(length(ACTIONS));
        end
        action = ACTIONS(a);
end