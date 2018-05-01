%% Function Description
%
% Extracts the axle loads from TruckSim
%
%% Inputs
%
% * variable: description
%
%% Outputs
%% Outputs
%
% * variable: description
%
%% Change Log
%
% [0.1.0] - 2017-06-26
%
% *Added*
%
% * First code

%% Test parameters
% nAxles = 5;
% matKey = 'AXLE';
% Project.savePath = 'D:\Personal\Work\WITS PBS\Test Runs\AXLE';
% Project.runKey = 'AXLE_TEST';
% Project.runsPath = 'C:\Dropbox\Wits_TruckSimPBS_8.2a\Runs';
% Is.plotOn = 1;
% Is.save = 0;

function [Axle] = assessAXLE(Axle, MatKey, Project, Is, Dummy)

if Dummy.isDummyAxle
    % If a dummy axle is present, the number of axles will not match the last axle index
    [Data, errorx] = readSimulationVariables_WithDummyAxles(MatKey, {'Fz_AXL'}, {Dummy.isRealAxleIndex}, {''}, [], Project.savePath, Project.truckSimRunsDirectory,...
        Project.runKey, [1]);
else
    % Extract the required data
    [Data, errorx] = readSimulationVariables(MatKey, {'Fz_AXL'}, [Axle.NumberOff], {''}, [], Project.savePath, Project.truckSimRunsDirectory,...
        Project.runKey, [1]);
end
% Initialising the cell array of strings for the axle loads
fzAxle = {};
Axle.truckSimLoads = [];

if errorx == 1
    time    = Data{1};      % convert to vector
    for iAxle = 1 : Axle.NumberOff
        fzAxle{iAxle}  = Data{2,iAxle};    % convert to vector
        % Average the last 500 data points to get the axle load
        Axle.truckSimLoads(iAxle) = mean(fzAxle{iAxle}(end-500:end));
    end
else
    return                  % data not loaded correctly
end

if Is.plotOn
    figure('name', 'AXLE_LOADS')
    hold on
    
    legTitles = {};
    
    for iAxle = 1 : Axle.NumberOff
        plot(time, fzAxle{iAxle}, 'Color', getColour(iAxle));  % plot next line
        legTitles = [legTitles; ['Axle ' int2str(iAxle)]];
    end
    
    xlabel('Time [sec]')
    ylabel('Axle Load [kg]')
    
    legend(legTitles, 'Location', 'Best');
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, 'AXLE')
    end
    
    title('TruckSim Axle Loads')
    hold off
end

end