function [SRTt, SRTtrrcu] = SRTt_solve(nLastAxle,nSteer,limSRT,SRTrollThresh, mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKey, plotOn, isSave, Dummy)

if nargin == 0  % i.e. program run directly from here
    % Example inputs:
    % -----------------------------------------------------------------
    nLastAxle = 6;
    nSteer = 1;
    limSRT = 0.35;
    SRTrollThresh = 30; % roll angle threshold after which the unit is considered to have rolled over
    mSprung = [15480       24200];
    HcgSprung = [1.6894    1.8001];
    rollCoupled = [false];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)
    savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20160419-Wits-PBS-assess-Rolfo-Hercules3A-VolvoFM400FM62TR3LA';
    runsPath = 'C:\Users\A0006942\Documents\TruckSim_Data - 8.1 convert to 8.2a\Runs';
    runKey ='Rolfo-Hercules3A-VolvoFM400FM62TR3LA';
    plotOn = true;
    % -----------------------------------------------------------------
end

nVehUnits = length(mSprung);

if Dummy.isDummyAxle
    % If there is a dummy axle, you need to pass through the indices of the valid axles
    [Data, error] = readDataWithDummyAxles(matKey, {'Roll' 'AyBf_SM' 'Fz_L' 'Roll_Tab'}, ...
        {nVehUnits nVehUnits Dummy.isRealAxleIndex 1}, {'_' '' '' ''}, [], savePath, runsPath, runKey, [0 0 1 0]);
else
    [Data, error] = readData(matKey, {'Roll' 'AyBf_SM' 'Fz_L' 'Roll_Tab'}, [nVehUnits nVehUnits nLastAxle 1], ...
        {'_' '' '' ''}, [], savePath, runsPath, runKey,[0 0 1 0]);
end

if error == 1
    ind=min(find(Data{1}>=0));
    Time    = Data{1}(ind:end);      % convert to vector
    Roll    = Data(2,:);
    AyBf_SM = Data(3,:);
    Fz_L    = Data(4,:);
    Roll_Tab= Data{5}(ind:end);
    AY=sind(Roll_Tab);
else
    return                  % data not loaded correctly
end

for i = 1:nVehUnits
    Roll{i} = Roll{i}(ind:end); % Discard data when time < 0
    AyBf_SM{i} = AyBf_SM{i}(ind:end); % Discard data when time < 0
end
for i = 1:nLastAxle
    Fz_L{i} = Fz_L{i}(ind:end); % Discard data when time < 0
end

for i = 1:nVehUnits %check if rollover angle reached
    if sum((Roll{i}-Roll_Tab) >= SRTrollThresh)
        indroll(i)=find((Roll{i}-Roll_Tab) >= SRTrollThresh,1);
        Rollunit(i,:)=Roll{i};
    else
        indroll(i)=length(Roll{i});
    end
end

j=0; %check if all wheels in the air
for i = (nSteer+1):1:nLastAxle
    j=j+1;
    if isempty(find((Fz_L{i} <= 0),1))
        indFz(j)=length(Fz_L{i});
    else
        indFz(j)=find((Fz_L{i} <= 0),1);
    end
end
indFzall=max(indFz);

i1st = 1;
iLast = i1st;
iC = 1;
SRTrcu = [];
while i1st <= nVehUnits
    while (iLast < nVehUnits) && rollCoupled(iLast)   % find first and last units of this coupled set
        iLast = iLast + 1;
    end
    ind(iC)=[min([indFzall indroll(i1st:iLast)])];
    SRTreason(iC)=1; %SRTreason -> 1 for angle, 2 for lift of tyres and 3 for decrease of lat accel
    if ind(iC)==indFzall
        SRTreason(iC)=2;
    end
    AYrcu{iC} = zeros(ind(iC),1); % create AY data for this RCU
    denom = 0;
    for i = i1st:iLast
        if sum(i == dollys(:)) == 0 % only include unit if not in dollys vector (see C11.3(c)(i, ii & iii) of NTC standards) % evaluated here and not above in case dolly is in the middle of rrcu (i.e. C-dolly)
            AYrcu{iC} = AYrcu{iC} + mSprung(i).*HcgSprung(i).*(AY(1:ind(iC))+AyBf_SM{i}(1:ind(iC)));
            denom = denom + mSprung(i)*HcgSprung(i);
        end
    end
    AYrcu{iC} = AYrcu{iC}/denom./cosd(Roll_Tab(1:ind(iC)));
    SRTrcu(iC) = max(AYrcu{iC});
    if SRTrcu(iC)~= AYrcu{iC}(end)
        SRTreason(iC)=3;
    end
    iC = iC + 1;
    i1st  = iLast  + 1;
    iLast = i1st;
end

[SRTt indiC]= min(SRTrcu); %indiC is the unit that rolls over
SRTtrrcu = SRTrcu(end);

% plotting
if plotOn
    figure('name', 'SRT')
    
    hold on
    axis([floor(Time(min(ind))/2) ceil(Time(max(ind))) 0 ceil((SRTt+0.01)*10)/10])  %set axis
    
    legTitles = {};
    for i = 1:length(AYrcu)
        plot(Time(1:ind(i)), AYrcu{i}(1:ind(i)), 'Color', getColour(i));
        legTitles = [legTitles; ['roll-coupled unit ' int2str(i)]];
    end
    
    PBSlimX = [0 Time(end)];
    PBSlimY = [limSRT limSRT];
    plot(PBSlimX, PBSlimY, '--r')
    
    legTitles = [legTitles; 'min requirement'];
    
    PBSlimX = [0 Time(end)];
    PBSlimY = [SRTt SRTt];
    plot(PBSlimX, PBSlimY, '--k')
    
    legTitles = [legTitles; 'SRT achieved'];
    
    xlabel('Time [s]')
    ylabel('Lateral Acceleration [g]')
    
    text([floor(Time(min(ind))/2)+1], floor(SRTt*100)/100+0.01,['SRT = ' num2str(floor(SRTt*100)/100) ' g'])
    text([floor(Time(min(ind))/2)+1], floor(SRTt*100)/100-0.01,['SRTrrcu = ' num2str(floor(SRTtrrcu*100)/100) ' g'])
    
    if (SRTreason(indiC)==1),
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when threshold roll angle reached'])
    elseif (SRTreason(indiC)==2),
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when all non-steer tyres in the air'])
    else
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when lateral acceleration decreases with roll angle'])
    end
    
    legend(legTitles, 'Location', 'Best');
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'SRTt_time')
    end
    
    title('Static Rollover Threshold')
    hold off
end