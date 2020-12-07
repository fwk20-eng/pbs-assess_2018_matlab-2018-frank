%% Function Description
%
% Computes the longitudinal performance of a vehicle combination according to PBS standards

%% Change Log

%% [3.1.0] - 2020-09-30 FK
%
% * Corrected that maxLatError looks at negative values too.

%% [3.1.0] - 2018-08-09
%
% *Added*
%
% * Standalone operation

%% [3.0.0] - unknown
%
% *Added*
%
% * Only consider values after zero time to prevent picking up exagerated initialisations values
% * Put the error back if LatError is less than 25mm.

%% [2.0.0] - 2016-11-04
%
% *Added*
%
% * Removed error if LatError is less than 25 mm. 2016/11/04 FK

%% [1.0.0] - unknown
%
% *Added*
%
% * First changelog
%

function [RA, maxLatError] = assessRA(Combination, Hitch, Project, MatKey, Is, mSprung, HcgSprung)
%% --------------------------------------------
%      ** Standalone operation **
%----------------------------------------------
if nargin == 0  % i.e. program run directly from here
  
  %      ** Combination parameters **
  %----------------------------------------------
  Combination.dollys = [];
  
  Hitch.RollCoupledArray = [1 1];
  
  Sprung.MassArray = [5759, 3390, 3690];
  Sprung.MassCoGxPosition = [0.879, 4.494, 5.052];
  Sprung.MassCoGzPosition = [1.125, 1.394, 1.481];
  
  PayloadLaden.MassCell = {[75, 411.6, 176.4], 21350, 31450};
  PayloadLaden.CoGxPositionCell = {[-0.218, 1.917, 1.917], 2.478, 4.485};
  PayloadLaden.CoGzPositionCell = {[1.815, 0.67, 0.67], 2.071, 2.008};
  
  %      ** Mat file location **
  %----------------------------------------------
  Project.truckSimRunsDirectory = 'D:\Dropbox\Wits_TruckSim_PBS_2018\Results';
  MatKey = {'RA', '3f610832'};
  
  %      ** Booleans that may change **
  %----------------------------------------------
  Is.plotOn = 1;
  Is.skipManoeuvreChecks = 0;
  
  %      ** Booleans that should remain constant **
  %----------------------------------------------
  Is.save = 0;
  
  %      ** Inconsequential parameters **
  %----------------------------------------------
  % The values of these parameters do not matter if you are not saving the plot
  Project.runKey = 'RA_TEST';
  Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\RA';
  
  % Determine sprung mass properties of each vehicle unit
  %----------------------------------------------
  [mSprung, ~, HcgSprung] = computeSprungCoG(Sprung.MassArray, Sprung.MassCoGxPosition,...
    Sprung.MassCoGzPosition, PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell,...
    PayloadLaden.CoGzPositionCell);
  
end

%% --------------------------------------------
%      ** Read data **
%----------------------------------------------
% must use body fixed Ay in accordance with SAE definition
% Ay_61 is a custom acceleration sensor placed at the steer axle CG
%----------------------------------------------
nVehUnits = length(mSprung);

[Data, errorx] = readSimulationVariables(...
  MatKey,...
  {'Ay' 'Ay_S61' 'X_A' 'Y_A' 'LatError'},...
  [nVehUnits 1 1 1 1],...
  {'_' '' '' ''},...
  [],...
  Project.savePath,...
  Project.truckSimRunsDirectory,...
  Project.runKey,...
  [0 3 1 1 0]);

if errorx == 1
  Time    = Data{1};    % convert to vector
  Ay      = Data(2,:);  % This is still a cell array
  AYsteer = Data{3};    % Steer lateral acceleration
  Xaxle   = Data{4};    % convert to vector
  Yaxle   = Data{5};    % convert to vector
  LatError = Data{6};
else
  return                  % data not loaded correctly
end

%% --------------------------------------------
%      ** Check if the manoeuvre is performed within the required parameter limits **
%----------------------------------------------

% find the peak lateral error
%----------------------------------------------
maxLatError = max(abs(LatError));

if ~Is.skipManoeuvreChecks
  
  if maxLatError > 30
    error('%s%0.2f%s','Lateral error is above 30 mm: ', maxLatError, ...
      ' mm -->> Decrease TPREV_CONSTANT, Preview Time of Driver Model');
    
  elseif maxLatError < 25
    error('%s%0.2f%s','Lateral error is below 25 mm: ', maxLatError, ...
      ' mm -->> Increase TPREV_CONSTANT, Preview Time of Driver Model');
  end
  
end

%% --------------------------------------------
%      ** RA Calculation **
%----------------------------------------------

iLast = nVehUnits;
i1st = iLast;

while (i1st > 2) && Hitch.RollCoupledArray(i1st-1)
  i1st = i1st - 1;
end

iRRCU = 1;
AYrrcu = zeros(length(Ay{iLast}),1);
denom = 0;

for i = i1st:iLast
  % only include unit if not in dollys vector (see C12.3(c)(i, ii & iii) of NTC standards)
  % evaluated here and not above in case dolly is in the middle of rrcu (i.e. C-dolly)
  %----------------------------------------------
  if sum(i == Combination.dollys(:)) == 0
    AYrrcu = AYrrcu + mSprung(i).*HcgSprung(i).*Ay{i};
    denom = denom + mSprung(i)*HcgSprung(i);
  end
  
end

AYrrcu = AYrrcu/denom;

% Remove data at time before t = 0 to ignore initialisation values which can be extreme
%----------------------------------------------
zeroTime = find(Time > 0);
zeroTime = zeroTime(1);

% find peak lat accel. of steer (could be on return)
%----------------------------------------------
[maxAYsteer, indMaxAYsteer] = max(abs(AYsteer(zeroTime:end)));  
indMaxAYsteer = zeroTime + indMaxAYsteer;

% find peak lat accel. of rrcu veh unit (could be on return)
%----------------------------------------------
[maxAYrrcu, indMaxAY] = max(abs(AYrrcu(zeroTime:end)));  
indMaxAY = zeroTime + indMaxAY;

% must compare to lat acc. input at the steer axle
%----------------------------------------------
RA = maxAYrrcu/maxAYsteer;   

%% --------------------------------------------
%      ** Plotting **
%----------------------------------------------
if Is.plotOn
  if (isfield(Is,'plotBackground') & Is.plotBackground)
      figure('name', 'RA','visible', 'off');
  else
      figure('name', 'RA');
  end
  hold on
  
% Plot title
%----------------------------------------------  
  title('Rearward Amplification')
  
% Plot lateral acceleration
%----------------------------------------------
  plot(Time, AYsteer, 'Color', getColour(1));  % plot next line
  plot(Time, AYrrcu , 'Color', getColour(2));  % plot next line
  
% Plot peaks
%----------------------------------------------
  plot(Time(indMaxAYsteer),AYsteer(indMaxAYsteer), '*r')    % plot peak
  plot(Time(indMaxAY),AYrrcu(indMaxAY), '*r')    % plot peak
 
% Result text
%----------------------------------------------
  text(0.4, -0.1,['RA = ' num2str(ceil(RA*100)/100)])

% Legend
%----------------------------------------------
  legTitles = {'front steer axle'; 'last unit'; 'peak lat. acc.'};  
  legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
  
% Axis labels
%----------------------------------------------
  xlabel('Time [sec]')
  ylabel('Lateral Acceleration [g]')

% Axis settings
%----------------------------------------------
  axis([0 12 -ceil(abs(AYrrcu(indMaxAY))*5)/5 ceil(abs(AYrrcu(indMaxAY))*5)/5])
  
% Plot settings
%----------------------------------------------
  set(gcf,'PaperPosition',[0 0 16 11])
  set(gca,'Xgrid','on');
  set(gca,'Ygrid','on');

% Save the figure when requested
%----------------------------------------------
  if Is.save
    savePlot(Project.savePath, Project.runKey, 'RA')
  end

  hold off
end
end

