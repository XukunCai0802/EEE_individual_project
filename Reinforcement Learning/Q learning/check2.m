    arr = [1,2,3,4,5,7,8,6];
    n = length(arr);
    inversionCount = 0;

    for i = 1:n-1
        for j = i+1:n
            if arr(i) > arr(j)
                inversionCount = inversionCount + 1;
            end
        end
    end

    % Determine the parity of reversed numbers
    if mod(inversionCount, 2) == 0
        parity = 'even';
    else
        parity = 'odd';
    end

    % display result
    disp(['parity：', parity]);

