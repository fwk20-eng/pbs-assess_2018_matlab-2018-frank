%% Function Description
% 
% Describe the function here
% 
%% Inputs
% 
% * variable: description
% 
%% Outputs
% 
% * variable: description
% 
%% Change Log
% 
% [0.1.0] - 2017-01-01
% 
% *Added*
% 
% * First code

function printAxleLoads(Project, Sprung, PayloadLaden, Axle, Hitch, Combination, Is)

if Is.axleLoads
    disp('-------------------------------------------------------------------------------------')
    disp('	Axle Loads')
    disp('-------------------------------------------------------------------------------------')
    % Determine sprung mass properties of each vehicle unit
    [mSprung, XcgSprung, HcgSprung] = computeSprungCoG(Sprung.MassArray, Sprung.MassCoGxPosition, Sprung.MassCoGzPosition,...
        PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell, PayloadLaden.CoGzPositionCell); 
    
    computeLoadDistributionOnAxles(Project.resultsFileName, Project.savePath, Axle.Grouping, Combination.axleGroupingHeadings,...
        Combination.loadshare1, Hitch.LoadCoupledArray, Hitch.XPositionArray, Axle.UnsprungMassArray,...
        Axle.XPositionArray, Axle.ZPositionArray, Hitch.ZPositionArray, mSprung, XcgSprung, HcgSprung, ...
        Sprung.MassArray, Sprung.MassCoGxPosition, PayloadLaden.MassCell, PayloadLaden.CoGxPositionCell, ...
        PayloadLaden.DescriptionCell, Is.save);
end

end