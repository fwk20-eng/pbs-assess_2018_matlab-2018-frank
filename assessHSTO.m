%% Function Description
%
% Evaluates the HSTO PBS performance of a combination

%% Change Log
% [1.0.0] - 2018-08-08
%
% *Added*
%
% * First change log
% * Added standalone functionality
% * Removed the combination total length requirement as it does not seem to be required unless the
% combination overshoots on the return to a greater degree than its initial overshoot. The original
% code would not work for this either. This needs to be checked with Frank.

function [maxOfftrack] = assessHSTO(Axle, Project, MatKey, Is, Dummy)
%% --------------------------------------------
%      ** Standalone operation **
%----------------------------------------------
% To use this script in standalone operation, input the parameters in this section and run the
% script
%----------------------------------------------
if nargin == 0  % i.e. program run directly from here
  % Combination parameters
  %----------------------------------------------
  Axle.NumberOff = 9;
  
  % Mat file location=
  %----------------------------------------------
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'RA', '3f610832'};
  
  % Booleans that may change
  %----------------------------------------------
  Is.plotOn = 1;
  
  % Booleans that should remain constant
  %----------------------------------------------
  Is.save = 0;
  Dummy.isDummyAxle = 0;
  
  % Inconsequential parameters
  %----------------------------------------------
  % The values of these parameters do not matter if you are not saving the plot
  %----------------------------------------------
  Project.runKey = 'HSTO_TEST';
  Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\HSTO';
  
end

if Dummy.isDummyAxle
  % If a dummy axle is present, the number of axles will not match the last axle index - this is no
  % longer required in 2018
  %----------------------------------------------
  [Data, error] = readSimulationVariables(...
    MatKey,...
    {'X_A1' 'Y_A1' ['X_A' int2str(Dummy.isRealAxleIndex(end))]...
    ['Y_A' int2str(Dummy.isRealAxleIndex(end))]},...
    ones(1,4),...
    {'' '' '' ''},...
    [],...
    Project.savePath,...
    Project.truckSimRunsDirectory,...
    Project.runKey,...
    [0 0 0 0]);
else
  % No dummy axles
  %----------------------------------------------  
  [Data, error] = readSimulationVariables(...
    MatKey,...
    {'X_A1' 'Y_A1' ['X_A' int2str(Axle.NumberOff)] ['Y_A' int2str(Axle.NumberOff)]},...
    ones(1,4),...
    {'' '' '' ''},...
    [],...
    Project.savePath,...
    Project.truckSimRunsDirectory,...
    Project.runKey,...
    [0 0 0 0]);
end

if error == 1
  Time    = Data{1};      % convert to vectors
  X_A1    = Data{2};
  Y_A1    = Data{3};
  X_Last  = Data{4};
  Y_Last  = Data{5};
else
  return                  % data not loaded correctly
end

%% --------------------------------------------
%      ** Calculation of HSTO **
%----------------------------------------------
Ytangent = Y_A1(end);

maxOfftrack = -Ytangent;     % theoretical minimum value
indMaxOff = 0;

for i = 1:length(Y_Last)
  
  offtrack = Y_Last(i) - Ytangent;
  
  if offtrack > maxOfftrack
    maxOfftrack = offtrack;
    indMaxOff = i;
  end
  
end

%% --------------------------------------------
%      ** Plotting the graph **
%----------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'HSTO','visible', 'off');
  else
      figure('name', 'HSTO');
  end
  hold on
  plot(X_A1, Y_A1, 'Color', getColour(1))
  plot(X_Last, Y_Last, 'Color', getColour(2))
  
  plot(X_Last(indMaxOff), Y_Last(indMaxOff), 'or')
  plot([0 max(X_A1)], [Ytangent Ytangent], '--r')
  text(0, 0.2,['HSTO = ' num2str(ceil(maxOfftrack*10)/10) ' m'])
  legTitles = {'steer axle'; 'last axle'; 'peak overshoot'};
  axis([-50 200 -1.5 1.2])
  
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');
  xlabel('X [m]')
  ylabel('Y [m]')
  legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
  
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'HSTO');
  end
  
  title('High-Speed Transient Offtracking')
  hold off
end

end



