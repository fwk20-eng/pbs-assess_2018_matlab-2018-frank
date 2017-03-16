function [C] = getColour(i)

colours = [[.75 0 0]; [0 .75 .75]; [0 .75 0]; [0 0 .75]; [0 1 1]; [0 1 0]; [0 0 1]; [0 0 0]; [.5 0 0]; [0 .5 .5]; [0 .5 0]; [0 0 .5]];

if i <= length(colours)
    C = colours(i, :);
else
    C = [0 0 0]; % default to black
end