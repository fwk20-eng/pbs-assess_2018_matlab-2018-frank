%% Function Description
%
% The purpose of this script is to determine the overall PBS performance level of the combination and generate a string
% for writting into the PBS assessment report.
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
% [0.1.0] - 2017-08-01
%
% *Added*
%
% * First code

function Combination = createPBSPerformanceString(Combination, resultsWithLevel)

nPerformanceMeasures = length(resultsWithLevel);
% Generate an index of the Levels
for iPM = 2 : nPerformanceMeasures
    
    pbsLevel = resultsWithLevel{iPM, 4};
    
    if strcmp(pbsLevel, 'PASS')
        listOfPbsLevels(iPM-1, 1) = 1;
    elseif strcmp(pbsLevel,'FAIL')
        listOfPbsLevels(iPM-1, 1) = 5;
    else
        pbsLevel = strsplit(pbsLevel, 'L');
        pbsLevel = str2num(pbsLevel{2});
        listOfPbsLevels(iPM-1, 1) = pbsLevel;
    end
    
end

% Determine the worst case PBS performance measure
worstPbsLevel = max(listOfPbsLevels);

limitingIndices = find(listOfPbsLevels == worstPbsLevel);
% Increase index by 1 to account for the row of headings
limitingIndices = limitingIndices + 1;

% Find descriptions of each of the performance measures at the worst Level
limitingPerformanceDescriptions = resultsWithLevel(limitingIndices);

%Create latex code for each performance measure
for iPM = 1 : length(limitingPerformanceDescriptions)
    switch limitingPerformanceDescriptions{iPM}
        case 'Startability'
            limitingPerformanceCode{iPM,1} = '\gls{sta}';
        case 'Gradeability A'
            limitingPerformanceCode{iPM,1} = '\gls{graa}';
        case 'Gradeability B'
            limitingPerformanceCode{iPM,1} = '\gls{grab}';
        case 'Acceleration Capability'
            limitingPerformanceCode{iPM,1} = '\gls{acc}';
        case 'Static Rollover Threshold - Tilt Table'
            limitingPerformanceCode{iPM,1} = '\gls{srt}';
        case 'Static Rollover Threshold - Tilt Table (rrcu)'
            limitingPerformanceCode{iPM,1} = '\gls{srt}';
        case 'Yaw Damping Coefficient - 100 km/h'
            limitingPerformanceCode{iPM,1} = '\gls{ydc}';
        case 'Rearward Amplification'
            limitingPerformanceCode{iPM,1} = '\gls{ra}';
        case 'High-Speed Transient Offtracking'
            limitingPerformanceCode{iPM,1} = '\gls{hsto}';
        case 'Tracking Ability on a Straight Path'
            limitingPerformanceCode{iPM,1} = '\gls{tasp}';
        case 'Low-Speed Swept Path'
            limitingPerformanceCode{iPM,1} = '\gls{lssp}';
        case 'Tail Swing'
            limitingPerformanceCode{iPM,1} = '\gls{ts}';
        case 'Frontal Swing'
            limitingPerformanceCode{iPM,1} = '\gls{fs}';
        case 'Maximum of Difference'
            limitingPerformanceCode{iPM,1} = '\gls{mod}';
        case 'Difference of Maxima'
            limitingPerformanceCode{iPM,1} = '\gls{dom}';
        case 'Steer-Tyre Friction Demand'
            limitingPerformanceCode{iPM,1} = '\gls{stfd}';
        case 'Low-Speed Swept Path - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{lssp}';
        case 'Tail Swing - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{ts}';
        case 'Frontal Swing - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{fs}';
        case 'Maximum of Difference - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{mod}';
        case 'Difference of Maxima - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{dom}';
        case 'Steer-Tyre Friction Demand - Unladen'
            limitingPerformanceCode{iPM,1} = '\gls{stfd}';
    end
end

% Remove duplicates in the case both laden and unladen fail
limitingPerformanceCode = unique(limitingPerformanceCode);
nLimitingMeasures = length(limitingPerformanceCode);

if worstPbsLevel == 5
    Combination.pbsPerformanceResult = 'Failed due to not satisfying the required';
elseif worstPbsLevel ~=1
    Combination.pbsPerformanceResult = ['Level ' num2str(worstPbsLevel) ' conformance, limited by'];
end

if worstPbsLevel ~= 1
    for iPM = 1 : nLimitingMeasures
        
        if iPM == 1
            Combination.pbsPerformanceResult = [Combination.pbsPerformanceResult ' ' limitingPerformanceCode{iPM}];
        elseif iPM == nLimitingMeasures
            Combination.pbsPerformanceResult = [Combination.pbsPerformanceResult ' and ' limitingPerformanceCode{iPM}];
        else
            Combination.pbsPerformanceResult = [Combination.pbsPerformanceResult ', ' limitingPerformanceCode{iPM}];
        end
        
    end
    
    Combination.pbsPerformanceResult = [Combination.pbsPerformanceResult ' performance'];
elseif worstPbsLevel == 1
    Combination.pbsPerformanceResult = 'Level 1 conformance for all performance measures';
end

Combination.pbsPerformanceResult = convertToRegExSafeText(Combination.pbsPerformanceResult);
end