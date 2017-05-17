%Changelogs
%Ver 1.0
%   -> First iteration
%Ver 2.0
%   -> Removed error if LatError is less than 25 mm. 2016/11/04 FK
function [RA] = RA_solve(mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKey, plotOn, isSave)

if nargin == 0  % i.e. program run directly from here
    mSprung = [7346        6900        5900        1400        6900        5900];
    HcgSprung = [1.0384    1.6976    1.8001    1.0710    1.6976    1.8001];
    rollCoupled = [true true false true true];
    dollys = [4];     % vehicle unit numbers with no reference points (dolly's do not have RPs) 
    savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20151209-Wits-PBS assess-Unitrans-AfritBABquad-Volvo FH86T6HT ver1';
    runsPath = 'C:\Users\Public\Documents\TruckSim_Data\Runs';
    runKey ='AfritBABquad-Volvo FH86T6HT';
    plotOn = true;
end


nVehUnits = length(mSprung);

[Data, errorx] = readData(matKey, {'AyBf_SM' 'X_A' 'Y_A' 'LatError'}, [nVehUnits 1 1 1], {'' '' '' ''}, [], savePath, runsPath, runKey, [0 1 1 0]); % must use body fixed Ay in accordance with SAE definition
%[Data, error] = readData(matKey, {'Ay_S1'}, [nVehUnits], {''}, [], savePath, runsPath, runKey); % must use body fixed Ay in accordance with SAE definition
% must use body fixed Ay in accordance with SAE definition

if errorx == 1
    Time    = Data{1};      % convert to vector
    Ay      = Data(2,:);    % This is still a cell array 
    Xaxle   = Data{3};      % convert to vector
    Yaxle   = Data{4};      % convert to vector
    LatError = Data{5};
else
    return                  % data not loaded correctly
end

maxLatError = max(LatError); % find the peak lateral error

%Check to ensure that the lateral error is within the correct limits
if maxLatError > 0.030
    error('%s%0.2f%s','Lateral error is above 30 mm: ', maxLatError*1000, ' mm -->> Decrease TPREV_CONSTANT'); %For this to work, the original definition of error had to be changed to errorx
% elseif maxLatError < 0.025
%     error('%s%0.2f%s','Lateral error is below 25 mm: ', maxLatError*1000, ' mm -->> Increase TPREV_CONSTANT, manoeuvre may be too harsh');
end

Yfirstderivative=gradient(Yaxle,Xaxle);
Ysecondderivative=gradient(Yfirstderivative,Xaxle);
roh=((1+Yfirstderivative.^2).^(3/2))./Ysecondderivative;

Xspeed=gradient(Xaxle,Time);
Yspeed=gradient(Yaxle,Time);
v=(Xspeed.^2+Yspeed.^2).^0.5;

AYsteer=(v.^2)./roh/9.81;

% find first and last units of the rearmost coupled set 
% stop at second unit since tractor is not to be included if all units coupled 
% (see C12.3(c)(iv) of NTC standards)
iLast = nVehUnits;
i1st = iLast;
while (i1st > 2) && rollCoupled(i1st-1)
    i1st = i1st - 1;
end

iRRCU = 1;
AYrrcu = zeros(length(Ay{iLast}),1);
denom = 0;
for i = i1st:iLast
    if sum(i == dollys(:)) == 0 % only include unit if not in dollys vector (see C12.3(c)(i, ii & iii) of NTC standards) % evaluated here and not above in case dolly is in the middle of rrcu (i.e. C-dolly)
        AYrrcu = AYrrcu + mSprung(i).*HcgSprung(i).*Ay{i};
        denom = denom + mSprung(i)*HcgSprung(i);      
    end
end
AYrrcu = AYrrcu/denom;

[maxAYsteer, indMaxAYsteer] = max(abs(AYsteer));  % find peak of steer, could be on return
[maxAYrrcu, indMaxAY] = max(abs(AYrrcu));  % find peak of rrcu veh unit, could be on return

RA = maxAYrrcu/maxAYsteer;    % must compare to lat acc. input at the steer axle

if plotOn
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
    legend(legTitles, 'Location', 'Best');
    axis([0 12 -ceil(abs(AYrrcu(indMaxAY))*5)/5 ceil(abs(AYrrcu(indMaxAY))*5)/5])
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'RA')
    end
    
    title('Rearward Amplification')
    hold off
end

