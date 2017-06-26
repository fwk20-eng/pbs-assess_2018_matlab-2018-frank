%% Function Description
% 
% Describe the function here
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
% [0.1.0] - 2017-01-01
% 
% *Added*
% 
% * First code
function checkedIs = checkBooleans(Is)

% No need for Is.save any longer since the runs need to be saved. To prevent the need of going back to modify all the
% code where Is.save is used, it is permanetly set to true here.
Is.save =          1;
%% Run-checks, resetting booleans if necessary
if Is.fullPBS == 1 %Turns on all PBS manoeuvres
    Is.lst = 1;      Is.yawD = 1;     Is.hsto = 1;     Is.long = 1;
    Is.lsunt = 1;    Is.ra = 1;       Is.tasp = 1;     Is.srt = 1;
    Is.report = 1;
    Is.plotOn = 1;
    Is.plotSummary = 1;
end

if ~Is.fullPBS
    Is.plotSummary = 0; % Turns off plot summary if not a full PBS assessment
    Is.report = 0; % Do not write a report unless a full assessment is being run
end

checkedIs = Is;

end