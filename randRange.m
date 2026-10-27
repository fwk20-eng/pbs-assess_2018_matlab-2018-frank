%This function will generate a random single precisionvariable within the 
%range of variables a (lower end) and b (upper end). 

function [randNum] = randRange(a, b)
    randNum = a + (b-a)*rand('single');  
end