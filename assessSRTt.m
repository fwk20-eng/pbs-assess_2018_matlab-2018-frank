function [SRTt, SRTtrrcu] = assessSRTt(Combination, Axle, Hitch,  Project, MatKey, Is, Dummy, limSRT, SRTrollThresh, mSprung, HcgSprung)

if nargin == 0  % i.e. program run directly from here
    % Example inputs:
    % -----------------------------------------------------------------
    Axle.NumberOff = 6;
    Axle.NumberOffSteer = 1;
    limSRT = 0.35;
    SRTrollThresh = 30; % roll angle threshold after which the unit is considered to have rolled over
    mSprung = [15480       24200];
    HcgSprung = [1.6894    1.8001];
    Hitch.RollCoupledArray = [false];
    Combination.dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)
    Project.savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20160419-Wits-PBS-assess-Rolfo-Hercules3A-VolvoFM400FM62TR3LA';
    Project.truckSimRunsPath = 'C:\Users\A0006942\Documents\TruckSim_Data - 8.1 convert to 8.2a\Runs';
    Project.runKey ='Rolfo-Hercules3A-VolvoFM400FM62TR3LA';
    Is.plotOn = true;
    % -----------------------------------------------------------------
end

nVehUnits = length(mSprung);

%% Extract the data from the mat file
if Dummy.isDummyAxle
    % If there is a dummy axle, you need to pass through the indices of the valid axles
    [Data, error] = readSimulationVariables_WithDummyAxles(MatKey(1,:), {'Roll' 'Ay_S' 'Fz_L' 'Roll_Tab'}, ...
        {nVehUnits nVehUnits Dummy.isRealAxleIndex 1}, {'_' '' '' ''}, [], Project.savePath, Project.truckSimRunsPath,...
        Project.runKey, [0 2 1 0]);
else
    [Data, error] = readSimulationVariables(MatKey(1,:), {'Roll' 'Ay_S' 'Fz_L' 'Roll_Tab'}, [nVehUnits nVehUnits Axle.NumberOff 1], ...
        {'_' '' '' ''}, [], Project.savePath, Project.truckSimRunsPath, Project.runKey,[0 2 1 0]);
end

[Time, AYrcu, SRTt, indiC, ind, SRTreason, SRTtrrcu] = assessSRTtWithSRTrrcu(Data, error, SRTrollThresh, nVehUnits, Axle, Hitch, Combination,...
                                                mSprung, HcgSprung);

if Is.srtRrcu
    clear SRTtrrcu; % ignore the original SRTrrcu calculated without a stabilising mass
    
    %% Running again with the rearmost roll coupled unit matlab file
    if Dummy.isDummyAxle
        % If there is a dummy axle, you need to pass through the indices of the valid axles
        [Data, error] = readSimulationVariables_WithDummyAxles(MatKey(2,:), {'Roll' 'Ay_S' 'Fz_L' 'Roll_Tab'}, ...
            {nVehUnits nVehUnits Dummy.isRealAxleIndex 1}, {'_' '' '' ''}, [], Project.savePath, Project.truckSimRunsPath,...
            Project.runKey, [0 2 1 0]);
    else
        [Data, error] = readSimulationVariables(MatKey(2,:), {'Roll' 'Ay_S' 'Fz_L' 'Roll_Tab'}, [nVehUnits nVehUnits Axle.NumberOff 1], ...
            {'_' '' '' ''}, [], Project.savePath, Project.truckSimRunsPath, Project.runKey,[0 2 1 0]);
    end
    
    [Time_rrcu, AYrcu_rrcu, ~, ~, ind_rrcu, ~, SRTtrrcu] = assessSRTtWithSRTrrcu(Data, error, SRTrollThresh, ...
                                                                                nVehUnits, Axle, Hitch, Combination,...
                                                                                mSprung, HcgSprung);
  
end

% plotting
if Is.plotOn
    figure('name', 'SRT')
    
    hold on
    
    if Is.srtRrcu
        xMax = max(ceil(Time(max(ind))), ceil(Time_rrcu(max(ind_rrcu))));
        axis([floor(Time(min(ind))/2) xMax 0 ceil((SRTt+0.01)*10)/10])  %set axis
    else
        axis([floor(Time(min(ind))/2) ceil(Time(max(ind))) 0 ceil((SRTt+0.01)*10)/10])  %set axis
    end
    
    legTitles = {};
    
    % Plot the lateral acceleration for all of the roll-coupled units, if rrcu is run, then rrcu must be plotted with
    % the data that was extracted in the rrcu script
    if Is.srtRrcu
        % Plot all units before the rrcu with the original manoeuvre data
        for i = 1:(length(AYrcu) - 1)
            plot(Time(1:ind(i)), AYrcu{i}(1:ind(i)), 'Color', getColour(i));
            legTitles = [legTitles; ['roll-coupled unit ' int2str(i)]];
        end
        % Plot the rrcu with the rrcu data 
        iRrcu = length(AYrcu); % rearmost roll-coupled unit
        plot(Time_rrcu(1:ind_rrcu(iRrcu)), AYrcu_rrcu{i}(1:ind_rrcu(iRrcu)), 'Color', getColour(iRrcu));
        legTitles = [legTitles; ['roll-coupled unit ' int2str(iRrcu)]];
        
    else 
        for i = 1:length(AYrcu)
            plot(Time(1:ind(i)), AYrcu{i}(1:ind(i)), 'Color', getColour(i));
            legTitles = [legTitles; ['roll-coupled unit ' int2str(i)]];
        end
    end
    
    if Is.srtRrcu
        PBSlimX = [0 Time_rrcu(end)];
    else
        PBSlimX = [0 Time(end)]; 
    end
    
    PBSlimY = [limSRT limSRT];
    plot(PBSlimX, PBSlimY, '--r')
    
    legTitles = [legTitles; 'min requirement'];
    
    PBSlimY = [SRTt SRTt];
    plot(PBSlimX, PBSlimY, '--k')
    
    legTitles = [legTitles; 'SRT achieved'];
    
    if Is.srtRrcu
        PBSlimY = [SRTtrrcu SRTtrrcu];
        plot(PBSlimX, PBSlimY, '--y')
        legTitles = [legTitles; 'SRTrrcu achieved'];
    end
    
    xlabel('Time [s]')
    ylabel('Lateral Acceleration [g]')
    
    if (SRTreason(indiC)==1),
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when threshold roll angle reached'])
    elseif (SRTreason(indiC)==2),
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when all non-steer tyres in the air'])
    else
        text([floor(Time(min(ind))/2)+1], 0.02,['SRT when lateral acceleration decreases with roll angle'])
    end
    
    text([floor(Time(min(ind))/2)+1], 0.02+0.06,['SRT = ' num2str(floor(SRTt*100)/100) ' g'])
    
    if Is.srtRrcu
        text([floor(Time(min(ind))/2)+1], 0.02+0.03,['SRTrrcu = ' num2str(floor(SRTtrrcu*100)/100) ' g'])
    end
    
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'SRTt_time')
    end
    
    title('Static Rollover Threshold')
    hold off
end
end
