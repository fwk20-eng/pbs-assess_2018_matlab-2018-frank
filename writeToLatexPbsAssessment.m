%% Function Description
%
% This code generates the required latex tables and writes the Latex report
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

function writeToLatexPbsAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
    fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Topdeck)

[Table.vehicleSummary, Axle.DescriptionCell] = generateTableVehicleSummary(Tyre, Axle);
Table.axleGroupLoads = generateTableAxleGroupLoads(Axle, Axle1, AxleU1);
Table.unloadedSprungMassDetails = generateTableUnloadedSprungMassDetails(Sprung);
Table.unsprungMassDetails = generateTableUnsprungMassDetails(Axle);
Table.payloadDetails = generateTablePayloadDetails(Sprung, PayloadLaden, 'Fully Laden Payload Details',...
    'FullyLadenPayloadDetails');
if Is.carCarrier
    Table.payloadDetailsTopdeck = generateTablePayloadDetails(Sprung, Topdeck.PayloadLaden, ...
        'Top Deck Laden Payload Details','TopDeckLadenPayloadDetails');
end
Table.suspensionDetails = generateTableSuspensionDetails(Axle);
Table.suspensionProperties = generateTableSuspensionProperties(Axle);
Table.hitchDetails = generateTableHitchDetails(Hitch);
Table.primeMoverSummary = generateTablePrimeMoverSummary(Engine, Sprung);
Table.engineTorqueCurve = generateTableEngineTorqueCurve(Engine);
Table.gearboxTransmission = generateTableGearboxTransmission(Engine);
Table.ladenReferencePoints = generateTableReferencePoints(Report.ladenReferencePointNames, ...
    Dimensions.RefPointsLadenCell, Sprung, Combination,...
    'Reference Points for Laden Combination','ReferencePointsForLadenCombination');
Table.unladenReferencePoints = generateTableReferencePoints(Report.unladenReferencePointNames, ...
    Dimensions.RefPointsUnladenCell, Sprung, Combination,...
    'Reference Points for Unladen Combination','ReferencePointsForUnladenCombination');
% Passing back multiple tables, hence pass the structure through and do not create a structure within a structure as
% then the code will not be able to write the tables
ComTable = generateTableCommissioning(Axle, Sprung, Tyre, Hitch, Combination);

% Generate results tables
Report.pbsResultsTable = generateTableResults(fullName, Lim, LimReport, rounder(resultsPbs, Is), Report, nLevels, Is);
baselineResults = getBaselineResults(Report.baselinePbsCombination);
Report.pbsBaselineResultsTable = generateBaselineResults(baselineResults, Lim, nLevels, Is);
if Is.carCarrier
    Report.pbsResultsTableTopdeck = generateBaselineResults(rounder(Topdeck.resultsPbs, Is), Lim, nLevels, Is);
end

% Set-up the paths for copying to the assessment folder
pbsAssessCopyToFullPath = strcat(Project.runFolderPath, '\PBS_Assessment_Report');
pbsAssessFiguresCopyFromFullPath = strcat(Project.savePath,'\', Project.runKey, '_figures');
pbsAssessFiguresCopyToFullPath =  strcat(pbsAssessCopyToFullPath, '\fig');

pbsAssessGACopyFromFullPath = strcat(Project.resultsFolderPath, '\_GA_Images');
    
% Remove the PBS assessment folder if it already exists
if exist(pbsAssessCopyToFullPath, 'dir')
    rmdir(pbsAssessCopyToFullPath, 's');
end

% Copy the PBS assessment template across
copyfile(Project.pbsAssessmentTemplatePath, pbsAssessCopyToFullPath);

% Copy across the assessment figures
copyfile(pbsAssessFiguresCopyFromFullPath, pbsAssessFiguresCopyToFullPath);
copyfile(pbsAssessGACopyFromFullPath, pbsAssessFiguresCopyToFullPath);

% Copying the additional summary image from the topdeck laden assessment for car-carriers
if Is.carCarrier
    pbsAssessFiguresTopdeckCopyFromFullPath = strcat(Topdeck.Project.savePath,'\', Topdeck.Project.runKey, '_figures');
    copyfile(strcat(pbsAssessFiguresTopdeckCopyFromFullPath,'\summary.pdf'), strcat(pbsAssessFiguresCopyToFullPath,...
        '\summaryTopdeck.pdf'));
end

% Generate the latex tables and save in the PBS assessment tex folder
generateLatexTablesForPBSreport(Table, '5-1-CombinationTables.tex', pbsAssessCopyToFullPath);

% Generate commissioning tables in a seperate tex tile
generateLatexTablesForPBSreport(ComTable, '6-1-CommissioningTables', pbsAssessCopyToFullPath);

% Modify the PBS assessment parameters and save to a new file
Report.pbsAssessmentMainTexFilePath = strcat(pbsAssessCopyToFullPath, '\PBS_Assessment.tex');
Report.pbsAssessmentResultsTexFilePath = strcat(pbsAssessCopyToFullPath, '\tex\2-1-CombinationResults.tex');

% Renamed tex filename for assessment
date = strsplit(datestr(now,'yyyy-mm-dd'),'-');

renamedTexFileName = strcat(date{1}, date{2}, date{3}, '_WITS_PBS-Assessment_', Project.key, '_V',...
    Report.reportRevision);
Report.pbsAssessmentRenamedTexFilePath = strcat(pbsAssessCopyToFullPath, '\', renamedTexFileName, '.tex');

%% Combining parameters for the report where necessary
% Generate the overhang modification array
for iUnit = 1:Sprung.numberOffUnits
    
    if iUnit == 1
        frontOverhangDescription = '\\newcommand\{\\pmFrontOverhang\}';
        rearOverhangDescription = '\\newcommand\{\\pmRearOverhang\}';
    else
        frontOverhangDescription = ['\\newcommand\{\\tl' num2words((iUnit - 1), 'case', 'sentence') 'FrontOverhang\}'];
        rearOverhangDescription = ['\\newcommand\{\\tl' num2words((iUnit - 1), 'case', 'sentence') 'RearOverhang\}'];
    end
    
    if Combination.frontalOverhangs(iUnit) == 0
        frontOverhang = [num2str(Combination.frontalOverhangs(iUnit)) '~mm (no overhang)'];        
    else
        frontOverhang = [num2str(Combination.frontalOverhangs(iUnit)) '~mm (' ...
        num2str(Combination.frontalOverhangsRelativeToDatum(iUnit)) '~mm forward of the hitch point)'];
    end
    
    if Combination.rearOverhangs(iUnit) == 0
        rearOverhang = [num2str(Combination.rearOverhangs(iUnit)) '~mm (no overhang)'];        
    else
        rearOverhang = [num2str(Combination.rearOverhangs(iUnit)) '~mm (' ...
        num2str(Combination.rearOverhangsRelativeToDatum(iUnit)) '~mm rear of the hitch point)'];
    end
    
    if iUnit == 1 % Create
        overhangDetails = {...
        frontOverhangDescription, frontOverhang;
        rearOverhangDescription, rearOverhang};
    else % Append
        overhangDetails = [overhangDetails;
        {frontOverhangDescription, frontOverhang};
        {rearOverhangDescription, rearOverhang}];
    end
end

% Add additional report modifiers according to extracted PBS data
additionalModifiers = {...
    '\\newcommand\{\\combOverallLength\}', strcat(num2str(Combination.totalLength*0.001, '%0.3f'), '~m');
    '\\newcommand\{\\combMaxHt\}', strcat(num2str(max(Combination.maxHeight)*0.001, '%0.3f'), '~m');
    '\\newcommand\{\\combMaxWidth\}', strcat(num2str(max(Combination.maxWidth)*0.001, '%0.3f'), '~m');
    '\\newcommand\{\\desiredPBSLevel\}', num2str(Combination.pbsLevelDesired);
    '\\newcommand\{\\combAxles\}', num2str(Axle.NumberOff);
    '\\newcommand\{\\combGCM\}', strcat(num2str(sum(Axle1)), '~kg');
    '\\newcommand\{\\combPayload\}', strcat(num2str(sum(cell2mat(PayloadLaden.MassCell).*...
    cell2mat(Combination.includedPayloads))), '~kg');
    '\\newcommand\{\\combVehStr}', convertToRegExSafeText(Combination.combinationVehicleString);
    '\\newcommand\{\\combClassification\}', Combination.combinationClassification;
    '\\newcommand\{\\combPbsLevelExec\}', Combination.pbsPerformanceResult;
    '\\newcommand\{\\combPbsLevel\}', Combination.pbsPerformanceResult;
    };

additionalModifiers = [additionalModifiers; overhangDetails];

Report.modifiers = [Report.modifiers; additionalModifiers];
    
% Edit PBS assessment and save tex file with the correct name as per project
editPbsAssessmentReport(Report, Is);

end