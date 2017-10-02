function [L] = computePBSLevel(type, X, limits, nLevels)
i = nLevels+1;
check = true;
while (i > 1) && check
    if type == '>'
        check = (X >= limits(i-1));
    elseif type == '<'
        check = (X <= limits(i-1));
    else
        disp('invalid input to computePBSLevel')
    end
    
    if check
        i = i-1;
    end
end

if i > nLevels
    L = 'FAIL';
elseif (limits(1)==limits) %all the limits are the same
    L = 'PASS';
else
    L = strcat('L', num2str(i));
end

end