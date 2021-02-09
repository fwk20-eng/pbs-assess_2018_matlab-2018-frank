%% Function Description
%
% Extracts the axle loads from TruckSim

%% Change Log
%% [0.3.0] - 2021-02-09
% * Removed standalone operation capability
%% [0.2.0] - 2018-08-08
% * Added * Standalone operation capability
%% [0.1.0] - 2017-06-26
% * First code
function [Axle] = assessAXLE(Axle, MatKey, Project, Is, Dummy)
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
  if (isfield(Is,'plotBackground') & Is.plotBackground)
    figure('name', 'AXLE_LOADS','visible', 'off');
  else
    figure('name', 'AXLE_LOADS');
  end
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