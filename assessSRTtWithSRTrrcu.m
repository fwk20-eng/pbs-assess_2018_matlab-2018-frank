function [Time, AYrcu, SRTt, indiC, ind, SRTreason,  SRTtrrcu] = ...
    assessSRTtWithSRTrrcu(Data, error, SRTrollThresh, nVehUnits, Axle, Hitch, Combination, mSprung, HcgSprung)
%% Change Log
% [0.1.1] - 2020-07-14
%
% Code had AY = sind(Roll_Tab) and later divided by cosd. Simplified to AY = tand(Roll_Tab)
% Also replaced Ay_tsim with AY as on tilt table all masses see same AY
%% [0.1.0] - 2020-07-09
%
% Code had AY = sind(Roll_Tab) and later divided by cosd. Simplified to AY = tand(Roll_Tab)
% Also replaced Ay_tsim with AY as on tilt table all masses see same AY
%% Sort the data into variables if successfully extracted
if error == 1
    ind=min(find(Data{1}>=0)); %Starting index for where data is non-zero
    Time    = Data{1}(ind:end);      % convert to vector
    Roll    = Data(2,:);
    Ay_tsim = Data(3,:);
    Fz_L    = Data(4,:);
    Roll_Tab= Data{5}(ind:end);
    AY=tand(Roll_Tab);
else
    return                  % data not loaded correctly
end

%% Remove data for time < 0
for i = 1:nVehUnits
    Roll{i} = Roll{i}(ind:end); % Discard data when time < 0
    Ay_tsim{i} = tand(Roll_Tab(ind:end)); % Discard data when time < 0
end
for i = 1:Axle.NumberOff
    Fz_L{i} = Fz_L{i}(ind:end); % Discard data when time < 0
end

%% check if rollover angle is reached in any of the units
% To do this, determine when the angle between the tilt-table and the vehicle is > 30 degrees
for i = 1:nVehUnits
    if sum((Roll{i}-Roll_Tab) >= SRTrollThresh)
        indRoll(i)=find((Roll{i}-Roll_Tab) >= SRTrollThresh,1);
        Rollunit(i,:)=Roll{i};
    else
        indRoll(i)=length(Roll{i});
    end
end

%% check if all wheels are in the air
% Rollover is also achieved if all the tyres along one side (with the exception of the steer axle) have lifted (Fz = 0)
j=0;
for i = 1:1:Axle.NumberOff
    j=j+1;
    if isempty(find((Fz_L{i} <= 0),1))
        indFz(j)=length(Fz_L{i});
    else
        indFz(j)=find((Fz_L{i} <= 0),1);
    end
end

%% Initialise the variables
iRCUnit = 1;
iLastAxleGroup=1;
iAxleGroup=1;
SRTrcu = [];
%% Reasons for liftoff
% 1 --> Angle of the unit relative to the tilt-table is > 30 degrees
% 2 --> All tyres (except on the steer axle) have lifted off
% 3 --> Lateral acceleration is decreases - not feasible if using Ay_tilt

%% Loop through all of the roll-coupled units
for iUnit=1:nVehUnits
    iAxleGroup=iAxleGroup+1;
    if (iUnit==nVehUnits)||(Hitch.RollCoupledArray(iUnit)==0)
        for jAxleGroup=iLastAxleGroup+1:iAxleGroup %Loop through axle groups in RCUnits and get SRT
            % Should add roll check here and set reason roll with dummy if
            % below gives lower then change reason to lift wheels
            if (exist('dummy','var')==1)
                indexVec(iRCUnit)=max([indFz(Axle.Grouping{jAxleGroup}) dummy]) ;
                dummy=indexVec(iRCUnit);
            else
                indexVec(iRCUnit)=max(indFz(Axle.Grouping{jAxleGroup})) ;
                dummy=indexVec(iRCUnit);
            end
            SRTreason(iRCUnit)=2;
            SRTrcu(iRCUnit)=AY(dummy);
            AYrcu{iRCUnit}=AY;
        end
        ind(iRCUnit) = dummy;
        clear dummy
        iRCUnit=iRCUnit+1;
        iLastAxleGroup=iAxleGroup;
    end
    %
end

[SRTt indiC]= min(SRTrcu); %indiC is the roll coupled unit that rolls over;
% Store the rearmost roll-coupled unit SRT result
SRTtrrcu = SRTrcu(end);
end