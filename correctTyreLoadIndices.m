function correctedLoadIndices = correctTyreLoadIndices(Tyre, Axle1)

correctedLoadIndices = Tyre.loadindices;

% Full single tyre load index range
singleLoadIndices = 128:164;

% Maximum load per tyre [kg]
singleCapacity = [...
    1800 1850 1900 1950 2000 2060 2120 2180 2240 2300 ...
    2360 2430 2500 2575 2650 2725 2800 2900 3000 3075 ...
    3150 3250 3350 3450 3550 3650 3750 3875 4000 4125 ...
    4250 4375 4500 4625 4750 4875 5000];

iAxleGlobal = 0;

for iUnit = 1:length(Tyre.loadindices)

    for iAxle = 1:length(Tyre.loadindices{iUnit})

        iAxleGlobal = iAxleGlobal + 1;

        % Do not change load index for dual tyres
        if contains(Tyre.sizes{iUnit}{iAxle}, '(duals')
            continue
        end

        %% Single tyres
        axleLoad = Axle1(iAxleGlobal);

        % Two tyres on the axle
        requiredLoadPerTyre = axleLoad / 2;

        % Minimum LI required for calculated tyre load
        iRequired = find(singleCapacity >= requiredLoadPerTyre, ...
            1, 'first');

        if isempty(iRequired)
            error(['Axle %d requires %.0f kg per tyre, which exceeds ' ...
                'the maximum single tyre load index LI %d.'], ...
                iAxleGlobal, requiredLoadPerTyre, ...
                singleLoadIndices(end));
        end

        requiredSingleLI = singleLoadIndices(iRequired);

        currentSingleLI = ...
            str2double(Tyre.loadindices{iUnit}{iAxle});

        % Only increase the LI if required
        finalSingleLI = max(currentSingleLI, requiredSingleLI);

        correctedLoadIndices{iUnit}{iAxle} = ...
            num2str(finalSingleLI);

    end
end

end