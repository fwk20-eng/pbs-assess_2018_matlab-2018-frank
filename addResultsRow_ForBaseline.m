function [C] = addResultsRow_ForBaseline(C, value, level)
    lenC = size(C,1);
    C(lenC+1,1:2) = {value, level};
end