%% Function Description
%
% Extracts the axle loads from TruckSim

%% Change Log

%% [0.2.0] - 2018-08-08
%
% * Added *
%
% * Standalone operation capability

%% [0.1.0] - 2017-06-26
%
% * Added *
%
% * First code

function [Axle] = assessAXLE(Axle, MatKey, Project, Is, Dummy)

%% --------------------------------------------
% **      ** Standalone operation **
%----------------------------------------------

% To use this script in standalone operation, input the parameters in this section and run the
% script

if nargin == 0
  
  % Combination parameters 
  Axle.NumberOff = 9;
  
  % Mat file location 
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'AXLE', 'a06c5423'};
  
  % Booleans that may change 
  Is.plotOn = 1;
  
  % Booleans that should remain constant
  Is.save = 0;
  Dummy.isDummyAxle = 0;
  
  % Inconsequential parameters
  % The values of these parameters do not matter if you are not saving the plot
  Project.runKey = 'AXLE_TEST';
  Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\AXLE';
  
end

%% --------------------------------------------
%      ** Read in data **
%----------------------------------------------

% If a dummy axle is present, the number of axles will not match the last axle index
% Dummy axle - no longer required in 2018 with the universal solver

if Dummy.isDummyAxle
  
  [Data, errorx] = readSimulationVariables_WithDummyAxles(...
    MatKey,... mat file key
    {'Fz_AXL'},... base variable names
    {Dummy.isRealAxleIndex},... number of variables
    {''},... string seperator
    [],... vehicle units to skip
    Project.savePath,... savepath for the matlab files
    Project.truckSimRunsDirectory,... trucksim run directory
    Project.runKey,... project unique identifier key
    [1]); % variable naming technique
  
else
  % No dummy axles

  [Data, errorx] = readSimulationVariables(...
    MatKey,... mat file key
    {'Fz_AXL'},... base variable names
    [Axle.NumberOff],... number of variables
    {''},... string seperator
    [],... vehicle units to skip
    Project.savePath,... savepath for the matlab files
    Project.truckSimRunsDirectory,... trucksim run directory
    Project.runKey,... project unique identifier key
    [1]); % variable naming technique
end

% Initialising the cell array of strings for the axle loads
fzAxle = {};
Axle.truckSimLoads = [];

if errorx == 1
  % Extract data to variables if no errors were present in reading the files
  
  time    = Data{1}; % convert to vector       
  
  for iAxle = 1 : Axle.NumberOff
    
    fzAxle{iAxle}  = Data{2,iAxle}; % convert to vector
    
    % Average the last 500 data points to get the axle load
    Axle.truckSimLoads(iAxle) = mean(fzAxle{iAxle}(end-500:end));
  end
  
else
  % data not loaded correctly
  return
end

%% --------------------------------------------
%      ** Plot the axle loads **
%----------------------------------------------
if Is.plotOn
  
  figure('name', 'AXLE_LOADS')
  hold on
  
  legTitles = {};
  
  for iAxle = 1 : Axle.NumberOff
    plot(time, fzAxle{iAxle}, 'Color', getColour(iAxle));
    legTitles = [legTitles; ['Axle ' int2str(iAxle)]];
  end
  
  xlabel('Time [sec]')
  ylabel('Axle Load [kg]')
  
  legend(legTitles, 'Location', 'Best');
  
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');
  
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'AXLE')
  end
  
  title('TruckSim Axle Loads')
  hold off
  
end

end