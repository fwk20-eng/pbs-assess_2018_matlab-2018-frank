%% Function Description
% 
% This function ensures that all booleans are correclty set
% 
%% Inputs
% 
% * Is: structure containing all the booleans used
% 
%% Outputs
% 
% * checkedIs: structure containing all corrected booleans 
% 
%% Change Log
%
% [0.2.0] - 2017-10-15
%
% *Added*
%
% * Is.latexReport exist check
%
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

if Is.ra
    Is.SRT = 1; % SRT needs to be run in order to run ra
end

%% Run-checks, resetting booleans if necessary
if Is.fullPBS == 1 %Turns on all PBS manoeuvres
    Is.lst = 1;      Is.yawD = 1;     Is.hsto = 1;     Is.long = 1;  Is.axle = 1;
    Is.lsunt = 1;    Is.ra = 1;       Is.tasp = 1;     Is.srt = 1;
    Is.plotOn = 1;
    Is.plotSummary = 1;
end

if ~Is.fullPBS
    Is.plotSummary = 0; % Turns off plot summary if not a full PBS assessment
    Is.latexReport = 0; % Do not write a report unless a full assessment is being run
end

% If there is no boolean indicating that a report needs to be written, assume that it must be written
if ~isfield(Is, 'latexReport')
    Is.latexReport = 1;
end

% Run the checks if it is not stated that the checks must be skipped
if ~isfield(Is, 'skipManoeuvreChecks')
    Is.skipManoeuvreChecks = 0;
end

checkedIs = Is;

end