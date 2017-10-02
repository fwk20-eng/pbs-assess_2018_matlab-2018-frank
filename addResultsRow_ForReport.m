function [C] = addResultsRow_ForReport(C, title, units, value, level, lims)

lenC = size(C,1);
C(lenC+1,1:4) = {title, units, value, level};

for i = 1:size(lims,1)             % size returns num of rows for dim 1
    for j = 1:size(lims,2)         % size returns num of cols for dim 2
        C(lenC+i,4+j) = lims(i,j);
    end
end

end