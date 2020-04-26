function [SW99] = assessTASP(Sprung, Combination, Project, MatKey, Is)

%-------------------------------------------------
%% *** Standalone operation ***
%-------------------------------------------------

if nargin == 0  % i.e. program run directly from here
  
  % ** Combination parameters **
  %-------------------------------------------------
  Sprung.numberOffUnits = 3; % Number of units excluding dollys
  Combination.dollys = [];
  
  % ** Mat file location **
  %-------------------------------------------------
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'TASP', '9a9582dd'};
  
  % ** Booleans that may change **
  %-------------------------------------------------
  Is.plotOn = 1;
  Is.skipManoeuvreChecks = 0;
  
  % ** Booleans that should remain constant **
  %-------------------------------------------------
  Is.save = 0;
  
  % ** Inconsequential parameters **
  % The values of these parameters do not matter if you are not saving the plot
  %-------------------------------------------------
  
  Project.runKey = 'RA_TEST';
  Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\RA';
  
end

%-------------------------------------------------
%% *** Read in data ***
%-------------------------------------------------

[Data, error] = readSimulationVariables(...
  MatKey,...
  {'X_S1' 'X_S2' 'X_S6' 'X_S7' 'X_S8' 'X_S9'...
  'Y_S1' 'Y_S2' 'Y_S6' 'Y_S7' 'Y_S8' 'Y_S9'},...
  Sprung.numberOffUnits*ones(1,12),...
  {'' '' '' '' '' '' '' '' '' '' '' ''},...
  Combination.dollys,...
  Project.savePath,...
  Project.truckSimRunsDirectory,...
  Project.runKey,...
  3*ones(1, 12));

if error == 1
  Time    = Data{1}; % convert to vector
  X_RP1   = Data(2,:); % These are still cell arrays
  X_RP2   = Data(3,:);
  X_RP6   = Data(4,:);
  X_RP7   = Data(5,:);
  X_RP8   = Data(6,:);
  X_RP9   = Data(7,:);
  Y_RP1   = Data(8,:);
  Y_RP2   = Data(9,:);
  Y_RP6   = Data(10,:);
  Y_RP7   = Data(11,:);
  Y_RP8   = Data(12,:);
  Y_RP9   = Data(13,:);
else
  return % data not loaded correctly                  
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

% Note: dollies have no RP outputs

%-------------------------------------------------
%% *** Calculate TASP ***
%-------------------------------------------------

% only consider points between the lead in and lead out sections
LenStart = 200;    % [m] lead in
LenTsect = 1000;   % [m] test section length

iTsect = 1;
while X_RP1{1}(iTsect) < LenStart % find i for start of Tsect
  iTsect = iTsect + 1;
end
iStart = iTsect;

while X_RP1{1}(iTsect) < LenStart+LenTsect % find i for end of Tsect
  iTsect = iTsect + 1;
end
iEnd = iTsect;

% need to create an array of swept path widths for each X position along
% the road
SW = [];
for i = iStart:iEnd
  
  iL = 1;
  for iVU = 1 : Sprung.numberOffUnits
    
    % only evaluated if veh unit number not in dollys vector
    if sum(iVU == Combination.dollys(:)) == 0
      
      % get i for when this RP on this veh unit was at this X position
      iRP1 = indClosestX(i, X_RP1{1}(i), X_RP1{iVU});
      iRP2 = indClosestX(i, X_RP1{1}(i), X_RP2{iVU});
      
      Ltemp(iL) = Y_RP1{iVU}(iRP1); % excursion of RP1 on this vehicle unit
      LxTemp(iL) = X_RP1{iVU}(iRP1);
      iL = iL + 1;
      
      Ltemp(iL) = Y_RP2{iVU}(iRP2); % excursion of RP3 on this vehicle unit
      LxTemp(iL) = X_RP2{iVU}(iRP2);
      iL = iL + 1;
      
    end
    
  end
  
  [L(i-iStart+1), iLmax] = max(Ltemp); % find furthest excursion at this X position along the road
  Lx(i-iStart+1) = LxTemp(iLmax);      % -iStart-1 to start at 1
  
  iR = 1;
  for iVU = 1 : Sprung.numberOffUnits
    
    % only evaluated if veh unit number not in dollys vector
    if sum(iVU == Combination.dollys(:)) == 0
      % get i for when this RP on this veh unit was at this X position
      iRP6 = indClosestX(i, X_RP1{1}(i), X_RP6{iVU});
      iRP7 = indClosestX(i, X_RP1{1}(i), X_RP7{iVU});
      iRP8 = indClosestX(i, X_RP1{1}(i), X_RP8{iVU});
      iRP9 = indClosestX(i, X_RP1{1}(i), X_RP9{iVU});
      
      Rtemp(iR) = Y_RP6{iVU}(iRP6);   % excursion of RP2 on this vehicle unit
      RxTemp(iR) = X_RP6{iVU}(iRP6);
      iR = iR + 1;
      
      Rtemp(iR) = Y_RP7{iVU}(iRP7);   % excursion of RP4 on this vehicle unit
      RxTemp(iR) = X_RP7{iVU}(iRP7);
      iR = iR + 1;
      
      Rtemp(iR) = Y_RP8{iVU}(iRP8);   % excursion of RP6 on this vehicle unit
      RxTemp(iR) = X_RP8{iVU}(iRP8);
      iR = iR + 1;
      
      Rtemp(iR) = Y_RP9{iVU}(iRP9);   % excursion of RP7 on this vehicle unit
      RxTemp(iR) = X_RP9{iVU}(iRP9);
      iR = iR + 1;
    end
    
  end
  
  [R(i-iStart+1), iRmax] = min(Rtemp); % find furthest excursion at this X position along the road
  Rx(i-iStart+1) = RxTemp(iRmax);
  
  SW = [SW (L(end) - R(end))];
  
end

TSW = max(SW);
SW = sort(SW);
SW99 = SW(ceil(length(SW)/100*99)); % get 99th percentile

%-------------------------------------------------
%% *** Plot ***
%-------------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'TASP','visible', 'off');
  else
      figure('name', 'TASP');
  end
  
  hold on
  legTitles = {};
  
  for i = 1 : Sprung.numberOffUnits % plot: X_RP, Y_RP
    
    % only evaluated if veh unit number not in dollys vector
    if sum(i == Combination.dollys(:)) == 0
      plot(X_RP1{i}, Y_RP1{i}, 'Color', getColour(i));
      plot(X_RP2{i}, Y_RP2{i}, 'Color', getColour(i));
      plot(X_RP6{i}, Y_RP6{i}, 'Color', getColour(i));
      plot(X_RP7{i}, Y_RP7{i}, 'Color', getColour(i));
      plot(X_RP8{i}, Y_RP8{i}, 'Color', getColour(i));
      plot(X_RP9{i}, Y_RP9{i}, 'Color', getColour(i));
      
      legTitles = [legTitles; ['unit' int2str(i) '-1']];
      legTitles = [legTitles; ['unit' int2str(i) '-2']];
      legTitles = [legTitles; ['unit' int2str(i) '-3']];
      legTitles = [legTitles; ['unit' int2str(i) '-4']];
      legTitles = [legTitles; ['unit' int2str(i) '-5']];
      legTitles = [legTitles; ['unit' int2str(i) '-6']];
      legTitles = [legTitles; ['unit' int2str(i) '-7']];
      legTitles = [legTitles; ['unit' int2str(i) '-8']];
      legTitles = [legTitles; ['unit' int2str(i) '-9']];
    end
  end
  
  
  
  % plot([min(X_RP1{1}) max(X_RP1{1})], [max(L) max(L)], '--r',...
  % [min(X_RP2{1}) max(X_RP2{1})], [min(R) min(R)], '--r')
  plot(Lx, L, '-r', Rx, R, '-r')
  
  % axis ([floor(min(X_RP1{1})/20)*20 ceil(max(X_RP1{1})/20)*20...
  % floor(min(R)/0.5)*0.5 ceil(max(L)/0.5)*0.5])
  
  axis([0 1400 -2.0 1.5]);
  xlabel('X [m]')
  ylabel('Y [m]')
  text(50,  0.5, ['Total Swept Width TSW = ' num2str(ceil(TSW*10)/10) ' m'])
  text(50, -0.5, ['99th percentile TSW = ' num2str(ceil(SW99*10)/10) ' m'])
  
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');
  
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'TASP')
  end
  
  title('Tracking Ability on a Straight Path')
  hold off
end

%-------------------------------------------------
%% *** Find the closest X ***
% iFollower must be greater than iLead so start at iLead (better than starting from 1)
%-------------------------------------------------
function [i] = indClosestX(iLead, X_Lead, X_follow)
i = iLead;
% find closest point along the road (could be off by 1 point)
while (X_follow(i) < X_Lead) && (i < length(X_follow))
  i = i + 1;
end
