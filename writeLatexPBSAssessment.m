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
% [0.3.0]
%
% * No longer copy across the PBS template folder since the report can now be made manually and the
% figures and tables be added seperately as the run is done. This is to help with writing of the
% report before the final details are known.
%
% [0.2.0]
%
% *Added*
%
% * Combination properties written to a log file
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function writeLatexPBSAssessment(Project, Combination, ParDetails, Sprung, Axle, Hitch, Engine, Report, Dimensions,...
    fullName, Lim, LimReport, resultsPbs, nLevels, Is, PayloadLaden, Axle1, AxleU1, Tyre, Topdeck)
%% Create the tables for latex and the log file
[Table.vehicleSummary, Axle.DescriptionCell, LogTable.vehicleSummary] = ...
    createTableLatexVehicleSummary(Tyre, Axle);

[Table.unsprungMassDetails, LogTable.unsprungMassDetails] = ...
    createTableLatexUnsprungMassDetails(Axle);

isRedacted = 0;
[Table.suspensionDetails, LogTable.suspensionDetails] = ...
    createTableLatexSuspensionDetails(Axle);

[Table.suspensionProperties, LogTable.suspensionProperties] = ...
    createTableLatexSuspensionProperties(Axle,isRedacted);

[Table.hitchDetails, LogTable.hitchDetails] = ...
    createTableLatexHitchDetails(Hitch);

[Table.unloadedSprungMassDetails, LogTable.unloadedSprungMassDetails] = ...
    createTableLatexUnloadedSprungMassDetails(Sprung);

[Table.payloadDetails, LogTable.payloadDetails] = ...
    createTableLatexPayloadDetails(Sprung, PayloadLaden, 'Fully Laden Payload Details',...
    'FullyLadenPayloadDetails');

if Is.carCarrier
    [Table.payloadDetailsTopdeck, LogTable.payloadDetailsTopdeck] = ...
        createTableLatexPayloadDetails(Sprung, Topdeck.PayloadLaden,...
        'Top Deck Laden Payload Details', 'TopDeckLadenPayloadDetails');
end

[Table.primeMoverSummary, LogTable.primeMoverSummary] = ...
    createTableLatexPrimeMoverSummary(Engine, Sprung);

[Table.engineTorqueCurve, LogTable.engineTorqueCurve] = ...
    createTableLatexEngineTorqueCurve(Engine);

[Table.gearboxTransmission, LogTable.gearboxTransmission] = ...
    createTableLatexGearboxTransmission(Engine);

[Table.ladenReferencePoints, LogTable.ladenReferencePoints] = ...
    createTableLatexReferencePoints(Dimensions.RefPointsLadenCell, Sprung, Combination,...
    'Reference Points for Laden Combination','ReferencePointsForLadenCombination');

%% Add combination tables to the log file
% Create filepath
runLogFileName = strcat('Assessment-Parameters_', Project.revision, '.md');
runLogFileDirectory = Project.runFolderPath;
runLogFilePath = [runLogFileDirectory, '\', runLogFileName];

fid=fopen(runLogFilePath,'w');

% Write the details on manoeuvre criterion
fprintf(fid,'%s\n', '# Control parameters');

if Is.ra
fprintf(fid,'%s\n', ['Lane change manoeuvre maximum lateral error: ', ...
    num2str(Project.raMaxLatError), ' mm']);
end

if Is.yawD
fprintf(fid,'%s\n', ['Yaw damping manoeuvre maximum lateral acceleration: ', ...
    num2str(Project.yawDMaxLatAccel), ' g\n']);
end

fclose(fid);
fprintf(['\n... your log file named ', runLogFileName, ' has been modified\n']);

% Write the tables
createMarkdownFromStructureOfTables(LogTable, runLogFileDirectory, runLogFileName);

if Is.latexReport
    
    % Unladen reference points will not be available unless a standard assessment is being run
    [Table.unladenReferencePoints, LogTable.unladenReferencePoints] = ...
        createTableLatexReferencePoints(Dimensions.RefPointsUnladenCell, Sprung,...
        Combination, 'Reference Points for Unladen Combination','ReferencePointsForUnladenCombination');
    
    % Passing back multiple tables, hence pass the structure through and do not create a structure within a structure as
    % then the code will not be able to write the tables
    
    %% Generate results tables
    Report.pbsResultsTable = createTableLatexResults...
        (fullName, Lim, LimReport, computeRoundedResults(resultsPbs, Is), Report, nLevels, Is);
    baselineResults = getBaselineResults(Report.baselinePbsCombination);
    Report.pbsBaselineResultsTable = createBaselineResults(baselineResults, Lim, nLevels, Is);
    
    if Is.carCarrier
        Report.pbsResultsTableTopdeck = createBaselineResults...
            (computeRoundedResults(Topdeck.resultsPbs, Is), Lim, nLevels, Is);
    end
    
    %% Set-up the paths for copying to the assessment folder
    pbsAssessCopyToFullPath = strcat(Project.runFolderPath, '\PBS_Assessment_Report');
    pbsAssessFiguresCopyFromFullPath = strcat(Project.savePath,'\', Project.runKey, '_figures');
    pbsAssessFiguresCopyToFullPath =  strcat(pbsAssessCopyToFullPath, '\fig');
    
    %% Remove the PBS assessment folder if it already exists
    if exist(pbsAssessCopyToFullPath, 'dir')
        rmdir(pbsAssessCopyToFullPath, 's');
    end
    
    %% Copy the necessary files
    % Copy the tex files required for the PBS assessment report
    copyfile(Project.pbsAssessmentTemplateDirectory, pbsAssessCopyToFullPath);
    
    % Copy across the assessment figures
    copyfile(pbsAssessFiguresCopyFromFullPath, pbsAssessFiguresCopyToFullPath);
    
    % Copying the additional summary image from the topdeck laden assessment for car-carriers
    if Is.carCarrier
        pbsAssessFiguresTopdeckCopyFromFullPath = strcat(Topdeck.Project.savePath,'\',...
            Topdeck.Project.runKey, '_figures');
        copyfile(strcat(pbsAssessFiguresTopdeckCopyFromFullPath,'\summary.pdf'),...
            strcat(pbsAssessFiguresCopyToFullPath, '\summaryTopdeck.pdf'));
    end
    
    %% Generate TableRedacted
    TableRedacted = Table;
    isRedacted = 1;
    [TableRedacted.suspensionProperties, LogTable.suspensionProperties] = ...
        createTableLatexSuspensionProperties(Axle,isRedacted);
    %% Create the necessary latex and log files
    % Generate the latex tables and save in the PBS assessment tex folder
    createLatexTables(Table, '5-1-CombinationTables.tex', pbsAssessCopyToFullPath);
    createLatexTables(TableRedacted, '5-1-CombinationTablesRedacted.tex', pbsAssessCopyToFullPath);
    
    %% Modify the PBS assessment parameters and save to a new file
    % Create the PBS assessment paths
    Report.pbsAssessmentCommands = strcat(pbsAssessCopyToFullPath, ...
        '\sty\PBS_assessment_commands.sty');
    Report.pbsAssessmentResultsTexFilePath = strcat(pbsAssessCopyToFullPath,...
        '\tex\2-1-CombinationResults.tex');
    
    %% Add additional report modifiers according to extracted PBS data
    additionalModifiers = {...
        '\\newcommand\{\\combOverallLength\}', ...
        strcat(num2str(Combination.totalLength*0.001, '%0.3f'), '~m');
        '\\newcommand\{\\combMaxHt\}', ...
        strcat(num2str(max(Combination.maxHeight)*0.001, '%0.3f'), '~m');
        '\\newcommand\{\\combMaxWidth\}', ...
        strcat(num2str(max(Combination.maxWidth)*0.001, '%0.3f'), '~m');
        '\\newcommand\{\\desiredPBSLevel\}', ...
        num2str(Combination.pbsLevelDesired);
        '\\newcommand\{\\combAxles\}', ...
        num2str(Axle.NumberOff);
        '\\newcommand\{\\combGCM\}', ...
        strcat(num2str(sum(Axle1)), '~kg');
        '\\newcommand\{\\combPayload\}', ...
        strcat(num2str(sum(cell2mat(PayloadLaden.MassCell) .* ...
        cell2mat(Combination.includedPayloads))), '~kg');
        '\\newcommand\{\\combVehStr}', ...
        convertToRegExSafeText(Combination.combinationVehicleString);
        '\\newcommand\{\\combClassification\}', ...
        Combination.combinationClassification;
        '\\newcommand\{\\combPbsLevelExec\}', ...
        Combination.pbsPerformanceResult;
        '\\newcommand\{\\combPbsLevel\}', ...
        Combination.pbsPerformanceResult;
        };
    
    Report.modifiers = [Report.modifiers; additionalModifiers];
    
    %% Edit PBS assessment and save tex file with the correct name as per project
    editPbsAssessmentReport(Report, Project, Is);
    
end
end