function [Time, AYrcu, SRTt, indiC, ind, SRTreason,  SRTtrrcu] = ...
    assessSRTtWithSRTrrcu(Data, error, SRTrollThresh, nVehUnits, Axle, Hitch, Combination, mSprung, HcgSprung)
%% Sort the data into variables if successfully extracted
if error == 1
    ind=min(find(Data{1}>=0)); %Starting index for where data is non-zero
    Time    = Data{1}(ind:end);      % convert to vector
    Roll    = Data(2,:);
    Ay_tsim = Data(3,:);
    Fz_L    = Data(4,:);
    Roll_Tab= Data{5}(ind:end);
    AY=sind(Roll_Tab);
else
    return                  % data not loaded correctly
end

%% Remove data for time < 0
for i = 1:nVehUnits
    Roll{i} = Roll{i}(ind:end); % Discard data when time < 0
    Ay_tsim{i} = Ay_tsim{i}(ind:end); % Discard data when time < 0
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
for i = (Axle.NumberOffSteer+1):1:Axle.NumberOff
    j=j+1;
    if isempty(find((Fz_L{i} <= 0),1))
        indFz(j)=length(Fz_L{i});
    else
        indFz(j)=find((Fz_L{i} <= 0),1);
    end
end

% The highest index of Fz=0 will indicate the time of liftoff
indFzall=max(indFz);

%% Initialise the variables
i1st = 1;
iLast = i1st;
iC = 1; % Variable for rcu
SRTrcu = [];

%% Reasons for liftoff
% 1 --> Angle of the unit relative to the tilt-table is > 30 degrees
% 2 --> All tyres (except on the steer axle) have lifted off
% 3 --> Lateral acceleration is decreasing with an increasing tilt-table angle

%% Loop through all of the roll-coupled units
while i1st <= nVehUnits
    
    % find first and last units of this coupled set
    while (iLast < nVehUnits) && Hitch.RollCoupledArray(iLast)
        iLast = iLast + 1;
    end
    
    % Store a cell where each row is a roll coupled unit and i1st, iLast
    rrcuUnits{iC} = {i1st, iLast};
    
    % Find the lowest index where a rollover condition has been achieved
    ind(iC)=[min([indFzall indRoll(i1st:iLast)])];
    
    % Assume rollover is due to the angle of the unit relative to the tilt-table as the initialisation condition
    SRTreason(iC)=1;
    
    % Check if the axles lift off first
    if ind(iC)==indFzall
        % If all of the axles lift off first then indicate that rollover is due to all of the axles lifting off
        SRTreason(iC)=2;
    end
    
    %
    AYrcu{iC} = zeros(ind(iC),1); % create AY data for this RCU
    denom = 0;
    
    % Loop through the units in the roll-coupled unit and generate the numerator and denominator as per equation C11.2a
    for i = i1st:iLast
        % only include a unit if it is not in the dollys vector (see C11.3(c)(i, ii & iii) of NTC standards)
        % evaluated here and not above in case dolly is in the middle of rrcu (i.e. C-dolly)
        
        if sum(i == Combination.dollys(:)) == 0
            % Calculate the lateral acceleration of the roll coupled unit according to equation C11.2a (dolly's are ignored as per NTC rules)
            AYrcu{iC} = AYrcu{iC} + mSprung(i).*HcgSprung(i).*(AY(1:ind(iC))+Ay_tsim{i}(1:ind(iC)));
            denom = denom + mSprung(i)*HcgSprung(i);
        end
    end
    
    AYrcu{iC} = AYrcu{iC}/denom./cosd(Roll_Tab(1:ind(iC)));
    SRTrcu(iC) = max(AYrcu{iC});
    
    % If the static rollover threshold of the roll coupled unit at the end of the simulation is not equal to the maximum SRT, then the lateral acceleration has decreased with an increasing tilt-table angle and thus condition 3 for rollover has been met. Change the SRT reason to suit.
    if SRTrcu(iC)~= AYrcu{iC}(end)
        SRTreason(iC)=3;
    end
    
    iC = iC + 1;
    i1st  = iLast  + 1;
    iLast = i1st;
    
end

[SRTt indiC]= min(SRTrcu); %indiC is the roll coupled unit that rolls over
% Store the rearmost roll-coupled unit SRT result
SRTtrrcu = SRTrcu(end);

end