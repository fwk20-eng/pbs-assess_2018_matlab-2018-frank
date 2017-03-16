function [LSSP, TS, FS, MoD, DoM, STFD] = LSTurn_solve(nVehUnits, dollys, VehWidth, SteerWidth, nSteer, muPeakSteer, laden, savePath, runsPath, runKey, matKey, plotOn, isSave)

if nargin == 0  % i.e. program run directly from here
    % Example inputs: 
    % -----------------------------------------------------------------    
    nVehUnits = 3;
    nSteer = 1;
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)%    nSteer = 1;
    VehWidth = 2600;       % [mm] total width
    SteerWidth = 2494;     % [mm] total width
    muPeakSteer = 1;    
    laden = true;
    savePath = 'C:\Users\A0006942\Documents\Delete';
    runsPath = 'C:\Dropbox\trucksimDatabase_JAD\Runs';
    runKey ='Test';
    matKey = 'LST_FL';
    plotOn = true;
    % -----------------------------------------------------------------
end

if laden
    keyword = matKey;
else
    keyword = 'LSunT';  % Low Speed unladen Turn (can't use LSTun because readData would get confused) 
end

[Data, error] = readData(keyword, {'X_RP3' 'X_RP4' 'X_RP5' 'X_RP6' 'X_RP7' 'X_RP8' 'X_RP9' 'X_Lin' 'X_StOut'...
    'Y_RP3' 'Y_RP4' 'Y_RP5' 'Y_RP6' 'Y_RP7' 'Y_RP8' 'Y_RP9' 'Y_Lin' 'Y_StOut' 'Fx_L' 'Fy_L' 'Fz_L' ...
    'Fx_R' 'Fy_R' 'Fz_R'}, ...
    [nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits 1 1 nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits nVehUnits 1 1 ...
    nSteer nSteer nSteer nSteer nSteer nSteer],...
    {'' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''}, dollys, savePath, runsPath, runKey, ...
    [zeros(1,18) ones(1,6)], isSave);   % last entry specifies that tyre forces numbered with a 1 for first entry

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

LSSP = SPW_solve(X_Lin, Y_Lin, X_RP3{1}, Y_RP3{1}, X_RP4{1}, Y_RP4{1}, X_RP5{1}, Y_RP5{1}, 'LSSP', ladentext, savePath, runKey, plotOn, isSave); %inner path at centre of tyre contact (CTC) - RP2, RP4, RP6 is front outer corner

[FS, MoD, DoM] = FS_solve(nVehUnits, dollys, X_StOut, Y_StOut, X_RP3, Y_RP3, X_RP4, Y_RP4, X_RP5, Y_RP5, ladentext, savePath, runKey, plotOn, isSave);

[TS] = TS_solve(nVehUnits, dollys, VehWidth, SteerWidth, X_StOut, Y_StOut, X_RP6, Y_RP6, X_RP7, Y_RP7, X_RP8, Y_RP8, X_RP9, Y_RP9, ladentext, savePath, runKey, plotOn, isSave); 

STFD = STFD_solve(Time, nSteer, muPeakSteer, Fx_L, Fy_L, Fz_L, Fx_R, Fy_R, Fz_R, ladentext, savePath, runKey, plotOn, isSave);

% extra calc to get maximum inner radius of the road
% LSOT = SPW_solve(X_Lin, Y_Lin, X_StOut, Y_StOut, 'Low-Speed Off-tracking (60 m radius)', savePath, runKey, plotOn) %inner path at centre of tyre contact (CTC)
