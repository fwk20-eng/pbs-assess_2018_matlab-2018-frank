function [Dmin, maxAy] = assessYAWD(Sprung, Project, Is, MatKey)

%-------------------------------------------------
%% *** Standalone operation ***
%-------------------------------------------------

if nargin == 0
  
  % ** Combination parameters **
  %-------------------------------------------------
  Sprung.numberOffUnits = 3;
  
  % ** Mat file location **
  %-------------------------------------------------
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'YawD', 'cbadf1ce'};
  
  % ** Booleans that may change **
  %-------------------------------------------------
  Is.plotOn = 1;
  
  % ** Booleans that should remain constant **
  %-------------------------------------------------
  Is.skipManoeuvreChecks = 0;
  Is.save = 0;
  
  % ** Inconsequential parameters **
  % The values of these parameters do not matter if you are not saving the plot
  %-------------------------------------------------
  Project.runKey ='yawD test';
  Project.savePath = 'C:\Users\deiss\Desktop\Test';
  
end

%-------------------------------------------------
%% *** Read in data ***
%-------------------------------------------------
[Data, errorx] = readSimulationVariables(...
  MatKey,... mat file key
  {'Art_H' 'ArtR_H' 'AVz' 'Ay'},... base variable names
  [Sprung.numberOffUnits-1 Sprung.numberOffUnits-1 Sprung.numberOffUnits 1],... number of variables
  {'' '' '_' ''},... string seperator
  [],... vehicle units to skip
  Project.savePath,... savepath for the matlab files
  Project.truckSimRunsDirectory,... trucksim run directory
  Project.runKey,... project unique identifier key
  [0 0 0 0]); % variable naming technique

if errorx == 1
  Time    = Data{1};      % convert to vector
  Art_H   = Data(2,:);    % This is still a cell array
  ArtR_H  = Data(3,:);    % This is still a cell array
  AVz     = Data(4,:);    % This is still a cell array
  Ay      = Data{5};      % convert to vector
else
  % data not loaded correctly
  return
end

%-------------------------------------------------
%% *** Manoeuvre parameter checks ***
%-------------------------------------------------

maxAy = max(Ay);

if ~Is.skipManoeuvreChecks
  if maxAy < 0.19
    error('%s%0.2f%s','Lateral acceleration is below 0.19 g: ', maxAy,...
      ' g -->> Increase STEER_SW_GAIN manoeuvre not harsh enough');
  elseif maxAy > 0.21
    error('%s%0.2f%s','Lateral acceleration is above 0.21 g: ', maxAy,...
      ' g -->> Decrease STEER_SW_GAIN maoneouvre may be too harsh');
  end
end

%-------------------------------------------------
%% *** Determining worst-case motion variable ***
%-------------------------------------------------

motionVariables = {...
  AVz,... Yaw rate of vehicle units
  Art_H,... Articulation angle of the hitch
  ArtR_H... % Articulation rate of the hitch
}; 

units = [...
  Sprung.numberOffUnits,... number of vehicle units
  (Sprung.numberOffUnits - 1),... number of hitch points
  (Sprung.numberOffUnits - 1)... % number of hitch points
]; 

yLabels = {...
  'Yaw Rate [deg/s]',...
  'Hitch Articulation Angle [deg]',...
  'Hitch Articulation Rate [deg/s]'...
};

unitType = {...
  'unit ',...
  'hitch ',...
  'hitch '
};

for iMotionVar = 1 : numel(motionVariables)
  
  motionVar = motionVariables{iMotionVar};
  nUnits = units(iMotionVar);
  
  % ** Calculate the damping ratio for each unit **
  %-------------------------------------------------
  for iUnit = 1 : nUnits
    
    Yloc = max(motionVar{1}) * (1 - iUnit/(Sprung.numberOffUnits+1));
    [DR(iUnit), ~, ~] = YD(motionVar{iUnit}, Time);
    
  end
  
  motionVarDR(iMotionVar) = min(DR);
  
end

% ** Find the minimum damping ratio index to determine the worst-case motion variable **
%-------------------------------------------------
[minDR, limitMotionVarIndex] = min(motionVarDR);

limMotionVar = motionVariables{limitMotionVarIndex};
nUnits = units(limitMotionVarIndex);

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'YawD','visible', 'off');
  else
      figure('name', 'YawD');
  end
  hold on
  legTitles = {};
  
  for i = 1:nUnits
    plot(Time, limMotionVar{i}, 'Color', getColour(i));   % plot next line
    maxPeak(i) = max(limMotionVar{i});
    legTitles = [legTitles; [unitType{limitMotionVarIndex} int2str(i)]];
  end
  
  xlabel('Time [sec]')
  ylabel(yLabels{limitMotionVarIndex});
  
  legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
end

%-------------------------------------------------
%% *** Calculate yaw damping of the worst-case motion variable ***
%-------------------------------------------------
for i = 1:nUnits
  
  [DR(i), tPeak, valPeak] = YD(limMotionVar{i}, Time);
  Yloc = max(abs(maxPeak)) - (max(abs(maxPeak)) * (i - 1))/5;
  
  % ** Plot the peaks **
  %-------------------------------------------------
  if Is.plotOn
    h_peaks = plot(tPeak, valPeak, '*r', 'Color', getColour(i));
    text(7, Yloc,['D_' num2str(i) ' = ' num2str(floor(DR(i)*100)/100)])
    
    set(get(get(h_peaks,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end
  
end

Dmin = min(DR);

%-------------------------------------------------
%% *** Continue plotting ***
%-------------------------------------------------

if Is.plotOn
  text(3, max(limMotionVar{1})*0.8,['D_m_i_n = ' num2str(floor(Dmin*100)/100)])
  
  temp=axis;
  axis([0 10 (temp(3)+temp(3)*0.1) (temp(4)+temp(4)*0.1)])
  
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');
  
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'YawD')
  end
  
  title('Yaw Damping')
  hold off
end

end

%-------------------------------------------------
%% *** Find the legitimate peaks ***
%-------------------------------------------------
function [DR, tPeak, valPeak] = YD(YR, Time)

% ** Initialisation **
%-------------------------------------------------
iPeak = 1;
valPeakRaw(iPeak) = 0;

%-------------------------------------------------
%% *** Search for peaks ***
%-------------------------------------------------
for i = 1 : (length(YR)-1)
  
  % Find where the plotted value crosses the x-axis. If it crosses the axis, then you are searching
  % for the next peak, so increase the peak number and continue to search for a higher value into
  % the next intersection of the graph with the x-axis.
  %----------------------------------------------
  if (sign(YR(i)) * sign(YR(i+1)) == -1 || sign(YR(i)) == 0)
    
    % The graph crosses the x-axis, so you are now searching for the next peak.
    %----------------------------------------------
    iPeak = iPeak + 1;
    
    % Initialise the peak value as 0 as the graph has just crossed the x-axis
    %----------------------------------------------
    valPeakRaw(iPeak) = 0;
    
  end
  
  if (abs(YR(i+1)) > abs(valPeakRaw(iPeak)))
    % The y-value is higher than the previous and thus it is considered as the peak until a higher
    % point is found
    %----------------------------------------------
    tPeakRaw(iPeak) = Time(i+1);
    valPeakRaw(iPeak) = YR(i+1);
    
  end
  
end

%-------------------------------------------------
%% *** Remove premature peaks ***
% Remove any small peaks at the beginning and end the loop if the full set of peaks is eliminated.
% Using the absolute value accounts for if the peak is negative or positive.
% Make the next peak the first peak if the current peak is less than the next peak, or if it is less
% than limPeak*100% of the maximum peak. Stop moving to the next peak if you reach the last peak.
% Best would be for limPeak to be 0.05 but used 0.06 to get rid of early
% spurious peaks
%-------------------------------------------------
limPeak=0.06;

iA1 = 1; % Index of the first peak

while iA1 <= (numel(valPeakRaw)-1) && ... % Must be the first condition to prevent an index error
    ( (abs(valPeakRaw(iA1)) < abs(valPeakRaw(iA1+1)))...
    || (abs(valPeakRaw(iA1)) < limPeak * max(abs(valPeakRaw))) )...
    
  iA1 = iA1 + 1;

end

A1 = valPeakRaw(iA1);

% If the first peak is not the maximum peak, then the model may be unstable as the yaw is not
% dampening. This error will help prevent an instable model from going unnoticed. Again the absolute
% value accounts for if the first peak is positive or negative.

if max(abs(valPeakRaw)) > abs(A1)
  error('The first peak is not the maximum peak - check model stability');
end

%-------------------------------------------------
%% *** Remove dampened peaks ***
% Loop through all of the raw peak values from the first peak and eliminate any peaks below 5% of
% the maximum peak (cutoff specified by the NTC PBS rules)
%-------------------------------------------------

iClean = 1;

for iRaw = iA1:length(tPeakRaw)
  
  if (abs(valPeakRaw(iRaw)) >= limPeak*abs(A1))
    
    valPeak(iClean) = valPeakRaw(iRaw);
    
    tPeak(iClean)   = tPeakRaw(iRaw);
    
    iClean = iClean + 1;
  end
  
end

%-------------------------------------------------
%% *** Calculate A_bar ***
% See page 65 - PBS Scheme - The Standards and Vehicle Assessment Rules
% DR = Damping Ratio
%-------------------------------------------------

Abar = 0;

if length(valPeak) == 1
  
  % If there is only 1 peak, the damping ratio is recorded as 1
  DR = 1;
  
elseif length(valPeak) < 6
  
  % ** eqn C15 p.65 for less than 6 peaks **
  %-------------------------------------------------
  for i=1:(length(valPeak)-1)
    Abar = Abar + abs(valPeak(i)) / abs(valPeak(i+1));
  end
  
  Abar = Abar/i;
  DR = log(Abar) / sqrt((pi)^2 + log(Abar)^2);
  
else
  
  % ** eqn C14 p.65 for more than 6 peaks **
  %-------------------------------------------------
  for i=1:(length(valPeak)-2)
    Abar = Abar + abs(valPeak(i))/abs(valPeak(i+2));
  end
  Abar = Abar/i;
  DR = log(Abar)/sqrt((2*pi).^2 + log(Abar).^2);
  
end

end
