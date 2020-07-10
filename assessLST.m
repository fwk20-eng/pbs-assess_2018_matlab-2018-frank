function [LSSP, TS, FS, MoD, DoM, STFD] = assessLST(Sprung, Combination, Axle, Project,...
  MatKey, Is, MU_PEAK_STEER, laden)
%-------------------------------------------------
%% *** Standalone operation ***
% To use this script in standalone operation, input the parameters in this section and run the
% script
%-------------------------------------------------

if nargin == 0
  % ** Combination parameters **
  %-------------------------------------------------
  Combination.dollys = [];
  Combination.maxWidth = 2600;
  
  Sprung.numberOffUnits = 3;
  
  Axle.NumberOffSteer = 1;
  Axle.SteerAxleOverallWidth = 2494;
  
  laden = 1;
  
  MU_PEAK_STEER = 0.8;
  
  % Mat file location
  %-------------------------------------------------
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'LST', '45531827'};
  
  % Booleans that may change
  %-------------------------------------------------
  Is.plotOn = 0;
  
  % Booleans that should remain constant
  %-------------------------------------------------
  Is.save = 0;
  Dummy.isDummyAxle = 0;
  
  % Inconsequential parameters
  % The values of these parameters do not matter if you are not saving the plot
  %-------------------------------------------------
  Project.runKey = 'AXLE_TEST';
  Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\AXLE';
end

%-------------------------------------------------
%% Read in Data
%-------------------------------------------------

[Data, error] = readSimulationVariables(...
  MatKey,...
  {'X_S3' 'X_S4' 'X_S5' 'X_S6' 'X_S7' 'X_S8' 'X_S9'...
  'X_Lin' 'X_StOut'...
  'Y_S3' 'Y_S4' 'Y_S5' 'Y_S6' 'Y_S7' 'Y_S8' 'Y_S9'...
  'Y_Lin' 'Y_StOut'...
  'Fx_L' 'Fy_L' 'Fz_L' ...
  'Fx_R' 'Fy_R' 'Fz_R'},...
  [Sprung.numberOffUnits*ones(1,7)...
  1 1 ...
  Sprung.numberOffUnits*ones(1,7)...
  1 1 ...
  Axle.NumberOffSteer*ones(1,6)],...
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

%-------------------------------------------------
%% Graph text
% The graph text will change to laden or unladen depending on the loading condition of the
% combination
%-------------------------------------------------

if laden==1
  ladentext='-laden';
else
  ladentext='-unladen';
end

%-------------------------------------------------
%% Assess the low-speed standards
%-------------------------------------------------

%inner path at centre of tyre contact (CTC) - RP2, RP4, RP6 is front outer corner
LSSP = assessSPW(Project, Is, X_Lin, Y_Lin, X_RP3{1}, Y_RP3{1}, X_RP4{1}, Y_RP4{1}, X_RP5{1},...
  Y_RP5{1}, 'LSSP', ladentext);

[FS, MoD, DoM] = assessFS(Sprung, Combination, Is, Project, X_StOut, Y_StOut, X_RP3, Y_RP3,...
  X_RP4, Y_RP4, X_RP5, Y_RP5, ladentext);

[TS] = assessTS(Sprung, Combination, Axle, Project, Is, X_StOut, Y_StOut, X_RP6, Y_RP6, X_RP7,...
  Y_RP7, X_RP8, Y_RP8, X_RP9, Y_RP9, ladentext);

STFD = assessSTFD(Time, Axle.NumberOffSteer, MU_PEAK_STEER, Fx_L, Fy_L, Fz_L, Fx_R, Fy_R, Fz_R,...
  ladentext, Project.savePath, Project.runKey, Is.plotOn, Is.save);

%-------------------------------------------------
%% Print results if standalone operation
%-------------------------------------------------

if nargin == 0
  
  disp('==============================');
  disp('LST PBS Performance');
  disp('==============================');
  disp(['LSSP: ', num2str(LSSP), ' m']);
  disp(['TS: ', num2str(TS), ' m']);
  disp(['FS: ', num2str(FS), ' m']);
  disp(['MoD: ', num2str(MoD), ' m']);
  disp(['DoM: ', num2str(DoM), ' m']);
  disp(['STFD: ', num2str(TS), ' m']);
  
end

end

% extra calc to get maximum inner radius of the road
% LSOT = assessSPW(X_Lin, Y_Lin, X_StOut, Y_StOut, 'Low-Speed Off-tracking (60 m radius)',...
% savePath, runKey, plotOn) %inner path at centre of tyre contact (CTC)
