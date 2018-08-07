%Changelogs
%Ver 1.0
%   -> First iteration
%Ver 2.0
%   -> Removed error if LatError is less than 25 mm. 2016/11/04 FK
% Ver 3.0
%   -> Only consider values after zero time to prevent picking up exageerated initialisations values
function [RA, maxLatError] = assessRA(Combination, Hitch, Project, MatKey, Is, mSprung, HcgSprung)

if nargin == 0  % i.e. program run directly from here
    mSprung = [7346        6900        5900        1400        6900        5900];
    HcgSprung = [1.0384    1.6976    1.8001    1.0710    1.6976    1.8001];
    Hitch.RollCoupledArray = [true true false true true];
    Combination.dollys = [4];     % vehicle unit numbers with no reference points (dolly's do not have RPs) 
    Project.savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20151209-Wits-PBS assess-Unitrans-AfritBABquad-Volvo FH86T6HT ver1';
    Project.truckSimRunsDirectory = 'C:\Users\Public\Documents\TruckSim_Data\Runs';
    Project.runKey ='AfritBABquad-Volvo FH86T6HT';
    Is.plotOn = true;
end


nVehUnits = length(mSprung);

% must use body fixed Ay in accordance with SAE definition
[Data, errorx] = readSimulationVariables(MatKey, {'Ay_S' 'Ay_S61' 'X_A' 'Y_A' 'LatError'},...
  [nVehUnits 1 1 1 1], {'' '' '' ''}, [], Project.savePath, Project.truckSimRunsDirectory,...
  Project.runKey, [2 3 1 1 0]); 

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

maxLatError = max(LatError); % find the peak lateral error

if ~Is.skipManoeuvreChecks
    % Check to ensure that the lateral error is within the correct limits
    % For this to work, the original definition of error had to be changed to errorx
    if maxLatError > 30
        error('%s%0.2f%s','Lateral error is above 30 mm: ', maxLatError, ...
          ' mm -->> Decrease TPREV_CONSTANT'); 
    elseif maxLatError < 25
        error('%s%0.2f%s','Lateral error is below 25 mm: ', maxLatError, ...
          ' mm -->> Increase TPREV_CONSTANT, manoeuvre may be too harsh');
    end
end

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
  
    if sum(i == Combination.dollys(:)) == 0 
        AYrrcu = AYrrcu + mSprung(i).*HcgSprung(i).*Ay{i};
        denom = denom + mSprung(i)*HcgSprung(i);      
    end
    
end

AYrrcu = AYrrcu/denom;

% To prevent the script from picking up discrepencies during the manoeuvre, only values after a
% time value of 0 will be used.

zeroTime = find(Time > 0);
zeroTime = zeroTime(1); 

[maxAYsteer, indMaxAYsteer] = max(abs(AYsteer(zeroTime:end)));  % find peak of steer, could be on return
indMaxAYsteer = zeroTime + indMaxAYsteer;

[maxAYrrcu, indMaxAY] = max(abs(AYrrcu(zeroTime:end)));  % find peak of rrcu veh unit, could be on return
indMaxAY = zeroTime + indMaxAY;

RA = maxAYrrcu/maxAYsteer;    % must compare to lat acc. input at the steer axle

if Is.plotOn
    figure('name', 'RA')

    hold on
    
    plot(Time, AYsteer, 'Color', getColour(1));  % plot next line
    plot(Time, AYrrcu , 'Color', getColour(2));  % plot next line
    plot(Time(indMaxAYsteer),AYsteer(indMaxAYsteer), '*r')    % plot peak
    plot(Time(indMaxAY),AYrrcu(indMaxAY), '*r')    % plot peak

    xlabel('Time [sec]')
    ylabel('Lateral Acceleration [g]')
    
    text(0.4, -0.1,['RA = ' num2str(ceil(RA*100)/100)])
    legTitles = {'steer axle'; 'last unit'; 'peak lat. acc.'};
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    axis([0 12 -ceil(abs(AYrrcu(indMaxAY))*5)/5 ceil(abs(AYrrcu(indMaxAY))*5)/5])
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'RA')
    end
    
    title('Rearward Amplification')
    hold off
end
end

