function [C] = AppenderBaseline(C, value, level)
lenC = size(C,1);
C(lenC+1,1:2) = {value, level};

end