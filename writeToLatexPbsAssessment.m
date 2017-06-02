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

[Table.vehicleSummary, Axle.DescriptionCell] = generateTableVehicleSummary(ParDetails, Tyre, Axle);
Table.axleGroupLoads = generateTableAxleGroupLoads(Axle, Axle1, AxleU1);
Table.unloadedSprungMassDetails = generateTableUnloadedSprungMassDetails(Sprung);
Table.unsprungMassDetails = generateTableUnsprungMassDetails(Axle);
Table.payloadDetails = generateTablePayloadDetails(Sprung, PayloadLaden, 'Fully Laden Payload Details',...
    'FullyLadenPayloadDetails');
if Is.carCarrier
    Table.payloadDetailsTopdeck = generateTablePayloadDetails(Sprung, Topdeck.PayloadLaden, ...
        'Top Deck Laden Payload Details','TopDeckLadenPayloadDetails');
end
Table.suspensionDetails = generateTableSuspensionDetails(ParDetails, Axle);
Table.hitchDetails = generateTableHitchDetails(Hitch);
Table.primeMoverSummary = generateTablePrimeMoverSummary(Engine, Sprung);
Table.engineTorqueCurve = generateTableEngineTorqueCurve(Engine);
Table.gearboxTransmission = generateTableGearboxTransmission(Engine);
Table.ladenReferencePoints = generateTableReferencePoints(Report.ladenReferencePointNames, ...
    Dimensions.RefPointsLadenCell, Sprung, Hitch,...
    'Reference Points for Laden Combination','ReferencePointsForLadenCombination');
Table.unladenReferencePoints = generateTableReferencePoints(Report.unladenReferencePointNames, ...
    Dimensions.RefPointsUnladenCell, Sprung, Hitch,...
    'Reference Points for Unladen Combination','ReferencePointsForUnladenCombination');

% Generate results tables
Report.pbsResultsTable = generateTableResults(fullName, Lim, LimReport, rounder(resultsPbs), Report, nLevels, Is);
baselineResults = getBaselineResults(Report.baselinePbsCombination);
Report.pbsBaselineResultsTable = generateBaselineResults(baselineResults, Lim, nLevels, Is);
if Is.carCarrier
    Report.pbsResultsTableTopdeck = generateBaselineResults(Topdeck.resultsPbs, Lim, nLevels, Is);
end

% Set-up the paths for copying to the assessment folder
pbsAssessCopyToFullPath = strcat(Project.savePath, '\PBS_Assessment_', Project.runKey);
pbsAssessFiguresCopyFromFullPath = strcat(Project.savePath,'\', Project.runKey, '_figures');
pbsAssessFiguresCopyToFullPath =  strcat(pbsAssessCopyToFullPath, '\fig');
    
% Remove the PBS assessment folder if it already exists
if exist(pbsAssessCopyToFullPath, 'dir')
    rmdir(pbsAssessCopyToFullPath, 's');
end
% Copy the PBS assessment template across
copyfile(Project.pbsAssessmentTemplatePath, pbsAssessCopyToFullPath);

% Copy across the assessment figures
copyfile(pbsAssessFiguresCopyFromFullPath, pbsAssessFiguresCopyToFullPath);

% Copying the additional summary image from the topdeck laden assessment for car-carriers
if Is.carCarrier
    pbsAssessFiguresTopdeckCopyFromFullPath = strcat(Topdeck.Project.savePath,'\', Topdeck.Project.runKey, '_figures');
    copyfile(strcat(pbsAssessFiguresTopdeckCopyFromFullPath,'\summary.pdf'), strcat(pbsAssessFiguresCopyToFullPath,...
        '\summaryTopdeck.pdf'));
end

% Generate the latex tables and save in the PBS assessment tex folder
generateLatexTablesForPBSreport(Table, 'CombinationTables.tex', pbsAssessCopyToFullPath); %

% Modify the PBS assessment parameters and save to a new file
Report.pbsAssessmentMainTexFilePath = strcat(pbsAssessCopyToFullPath, '\PBS_Assessment.tex');
Report.pbsAssessmentResultsTexFilePath = strcat(pbsAssessCopyToFullPath, '\tex\CombinationResults.tex');

% Add additional report modifiers according to extracted PBS data
additionalModifiers = {...
    '\\newcommand\{\\desiredPBSLevel\}', num2str(Combination.pbsLevelDesired);
    '\\newcommand\{\\client\}', 'still to be extracted';
    '\\newcommand\{\\pmDescr\}', 'still to be extracted';
    '\\newcommand\{\\tlDescr\}', 'still to be extracted';
    '\\newcommand\{\\tlManu\}', 'still to be extracted';
    '\\newcommand\{\\combAxles\}', num2str(Axle.NumberOff);  
    '\\newcommand\{\\combGCM\}', strcat(num2str(sum(Axle1)), '~kg');
    '\\newcommand\{\\combPayload\}', strcat(num2str(sum(cell2mat(PayloadLaden.MassCell).*...
    cell2mat(Combination.includedPayloads))), '~kg');
    };

Report.modifiers = [Report.modifiers; additionalModifiers];
    
% Edit PBS assessment and save tex file with the correct name as per project
editPbsAssessmentReport(Report, Is);

end