load('data.mat')
Checkmatrix = 10^8*dict(:,1)+10^7*dict(:,2)+10^6*dict(:,3)+10^5*dict(:,4)+10^4*dict(:,5)+10^3*dict(:,6)+10^2*dict(:,7)+10*dict(:,8)+dict(:,9);
save("check.ma","Checkmatrix");
number_to_find = 12345678;
is_number_found = ismember(number_to_find, Checkmatrix);
if is_number_found
    disp(['ture ', num2str(number_to_find)]);
    [positon] = find(Checkmatrix == number_to_find);
    disp([num2str(positon)]);
else
    disp(['false ', num2str(number_to_find)]);
end
