%% Function Description
% 
% This function aims to convert raw text into regEx safe expressions where exit strings (/) are placed in the correct
% places
% 
%% Inputs
% 
% * variable: description
% 
%% Outputs
% 
% * variable: description
% 
%% Change Log
% 
% [0.1.0] - 2017-08-01
% 
% *Added*
% 
% * First code

function regExSafeText = convertToRegExSafeText(rawText)

    regExSafeText = rawText;
    regExSafeText = strrep(regExSafeText,'\','\\');
    regExSafeText = strrep(regExSafeText,'(','\(');
    regExSafeText = strrep(regExSafeText,')','\)');
    regExSafeText = strrep(regExSafeText,'{','\{');
    regExSafeText = strrep(regExSafeText,'}','\}');
    regExSafeText = strrep(regExSafeText,'[','\[');
    regExSafeText = strrep(regExSafeText,']','\]');

end