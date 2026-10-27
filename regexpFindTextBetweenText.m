%% Function Description
% *regexpFindTextBetweenText* returns the text between a starting and
% ending string. The returned text does not include the starting and ending
% string

%% Inputs
% * string: String in which you would like to search
% * startString: Beginning string
% * endString: End string
% 
%% Outputs
%
% * betweenText: the text found between the start and end string

%% Future Development
% * Fix issue: If there are multiple instances of a pattern, the results are difficult to predict

%% Change Log
% 
% [0.1.0] - 2017-04-17
% 
% Added
% 
% * First edition code

%% Function: regexpFindTextBetweenText
%-------------------------------------------------------------------------
function betweenText = regexpFindTextBetweenText(string, startString, endString)

betweenText = regexp(string, strcat('(?<=', startString, ').*(?=', endString, ')'), 'match');
                                                      
end