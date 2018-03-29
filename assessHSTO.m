function [maxOfftrack] = assessHSTO(Axle, Combination, Project, MatKey, Is, Dummy)

if nargin == 0  % i.e. program run directly from here
    Axle.NumberOff = 19;
    Combination.totalLength = 41.205;
    Project.savePath = 'C:\Users\A0006942\Documents\PBS calculation results\20151209-Wits-PBS assess-Unitrans-AfritBABquad-Volvo FH86T6HT ver1';
    Project.truckSimRunsPath = 'C:\Users\Public\Documents\TruckSim_Data\Runs';
    Project.runKey ='AfritBABquad-Volvo FH86T6HT';
    Is.plotOn = true;
end

if Dummy.isDummyAxle
    % If a dummy axle is present, the number of axles will not match the last axle index
    [Data, error] = readSimulationVariables(MatKey, {'X_A1' 'Y_A1' ['X_A' int2str(Dummy.isRealAxleIndex(end))] ['Y_A' int2str(Dummy.isRealAxleIndex(end))]}, ones(1,4), {'' '' '' ''}, [],  Project.savePath, Project.truckSimRunsPath, Project.runKey, [0 0 0 0]);
else
    [Data, error] = readSimulationVariables(MatKey, {'X_A1' 'Y_A1' ['X_A' int2str(Axle.NumberOff)] ['Y_A' int2str(Axle.NumberOff)]}, ones(1,4), {'' '' '' ''}, [],  Project.savePath, Project.truckSimRunsPath, Project.runKey, [0 0 0 0]);
end

if error == 1
    Time    = Data{1};      % convert to vectors
    X_A1    = Data{2};
    Y_A1    = Data{3};
    X_Last  = Data{4};
    Y_Last  = Data{5};
else
    return                  % data not loaded correctly
end

Ytangent = Y_A1(end);

maxOfftrack = -Ytangent;     %theoretical minimum value
indMaxOff = 0;
for i=1:length(Y_Last)
    offtrack = Y_Last(i)-Ytangent;
    if (X_Last(i) >= 122-Combination.totalLength) && (offtrack > maxOfftrack)        %end of test section %highest value so far
        maxOfftrack = offtrack;
        indMaxOff = i;
    end
end


if Is.plotOn
    figure('name', 'HSTO')
    
    hold on
    plot(X_A1, Y_A1, 'Color', getColour(1))
    plot(X_Last, Y_Last, 'Color', getColour(2))
    plot(X_Last(indMaxOff), Y_Last(indMaxOff), 'or')
    plot([0 max(X_A1)], [Ytangent Ytangent], '--r')
    text(0, 0.2,['HSTO = ' num2str(ceil(maxOfftrack*10)/10) ' m'])
    legTitles = {'steer axle'; 'last axle'; 'peak overshoot'};
    axis([-50 200 -1.5 1.2])
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('X [m]')
    ylabel('Y [m]')
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'HSTO');
    end
    
    title('High-Speed Transient Offtracking')
    hold off
end



