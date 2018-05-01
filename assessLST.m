function [LSSP, TS, FS, MoD, DoM, STFD] = assessLST(Sprung, Combination, Axle, Project, MatKey, Is,...
    muPeakSteer, laden)

%% Sample run data
if nargin == 0  % i.e. program run directly from here
    % Example inputs: 
    % -----------------------------------------------------------------    
    Sprung.numberOffUnits = 3;
    Axle.NumberOffSteer = 1;
    Combination.dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)%    
    Combination.maxWidth = 2600;       % [mm] total width
    Axle.SteerAxleOverallWidth = 2494;     % [mm] total width
    Axle.NumberOffSteer = 1;
    muPeakSteer = 1;    
    laden = true;
    Project.savePath = 'C:\Users\A0006942\Documents\Delete';
    Project.truckSimRunsDirectory = 'C:\Dropbox\trucksimDatabase_JAD\Runs';
    Project.runKey ='Test';
    MatKey = 'LST_FL';
    Is.plotOn = true;
    % -----------------------------------------------------------------
end

% No longer necessary since the MatKey is 
% if laden
%     keyword = MatKey;
% else
%     keyword = 'LSunT'; % Low Speed unladen Turn (can't use LSTun because readSimulationVariables would get confused) 
% end

% last entry specifies that tyre forces numbered with a 1 for first entry

%% Actual Script
[Data, error] = readSimulationVariables(MatKey, {'X_S3' 'X_S4' 'X_S5' 'X_S6' 'X_S7' 'X_S8' 'X_S9' 'X_Lin' 'X_StOut'...
    'Y_S3' 'Y_S4' 'Y_S5' 'Y_S6' 'Y_S7' 'Y_S8' 'Y_S9' 'Y_Lin' 'Y_StOut' 'Fx_L' 'Fy_L' 'Fz_L' ...
    'Fx_R' 'Fy_R' 'Fz_R'},...
    [Sprung.numberOffUnits*ones(1,7) 1 1 Sprung.numberOffUnits*ones(1,7) 1 1 Axle.NumberOffSteer*ones(1,6)],...
    {'' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''},...
    Combination.dollys, Project.savePath, Project.truckSimRunsDirectory, Project.runKey,...
    [3*ones(1,7) zeros(1,2) 3*ones(1,7) zeros(1,2) ones(1,6)]);

if error == 1
    Time    = Data{1};      % convert to vector
    X_RP3   = Data(2,:);    % cell array
    X_RP4   = Data(3,:);    % cell array
    X_RP5   = Data(4,:);    % cell array
    X_RP6   = Data(5,:);    % cell array    
    X_RP7   = Data(6,:);    % cell array    
    X_RP8   = Data(7,:);    % cell array    
    X_RP9   = Data(8,:);    % cell array        
    X_Lin   = Data{9,:};    % vector
    X_StOut = Data{10,:};    % vector
    Y_RP3   = Data(11,:);    % cell array
    Y_RP4   = Data(12,:);    % cell array
    Y_RP5   = Data(13,:);    % cell array
    Y_RP6   = Data(14,:);    % cell array    
    Y_RP7   = Data(15,:);    % cell array    
    Y_RP8   = Data(16,:);    % cell array    
    Y_RP9   = Data(17,:);    % cell array        
    Y_Lin   = Data{18,:};   % vector
    Y_StOut = Data{19,:};   % vector
    Fx_L    = Data(20,:);   % cell array
    Fy_L    = Data(21,:);   % cell array
    Fz_L    = Data(22,:);   % cell array
    Fx_R    = Data(23,:);   % cell array
    Fy_R    = Data(24,:);   % cell array
    Fz_R    = Data(25,:);   % cell array
else
    return                  % data not loaded correctly
end

% RP locations:
% 1 -- 3
% 2 -- 4
%   -- 5
%  |  |
%  |  |
%   -- 6
%   -- 7
%   -- 8
%   -- 9

if laden==1,
    ladentext='_laden';
else
    ladentext='_unladen';
end

%inner path at centre of tyre contact (CTC) - RP2, RP4, RP6 is front outer corner
LSSP = assessSPW(Project, Is, X_Lin, Y_Lin, X_RP3{1}, Y_RP3{1}, X_RP4{1}, Y_RP4{1}, X_RP5{1}, Y_RP5{1}, 'LSSP',...
    ladentext); 

[FS, MoD, DoM] = assessFS(Sprung, Combination, Is, Project, X_StOut, Y_StOut, X_RP3, Y_RP3, X_RP4, Y_RP4, X_RP5, Y_RP5,...
    ladentext);

[TS] = assessTS(Sprung, Combination, Axle, Project, Is, X_StOut, Y_StOut, X_RP6, Y_RP6, X_RP7, Y_RP7,...
    X_RP8, Y_RP8, X_RP9, Y_RP9, ladentext); 

STFD = assessSTFD(Time, Axle.NumberOffSteer, muPeakSteer, Fx_L, Fy_L, Fz_L, Fx_R, Fy_R, Fz_R, ladentext,...
    Project.savePath, Project.runKey, Is.plotOn, Is.save);

% extra calc to get maximum inner radius of the road
% LSOT = assessSPW(X_Lin, Y_Lin, X_StOut, Y_StOut, 'Low-Speed Off-tracking (60 m radius)', savePath, runKey, plotOn) %inner path at centre of tyre contact (CTC)
