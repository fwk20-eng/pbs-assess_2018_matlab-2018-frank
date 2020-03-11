%% Function Description
%
% This function reads in a textfile and reads in each line into a cell in a cell arrays
%
%% Inputs
%
% * filepath: Path to the excel file where the data is to be written.
% * filename: Filename of the excel file where the data is to be written.
% * parsPath: Path to the pars file where the vehicle parameters are stored.
% * parsName: Name of the pars file where the vehicle parameters are stored.
%
%% Change Log
%
% [0.11.0] 2017-10-04
%
% *Added*
%
% * Check to ensure that the LST parameters are correct
%
%
% [0.10.0] 2017-09-07
%
% * Fixed steer axle extraction
%
% [0.9.0] 2017-08-20
%
% * Added support for dolly combinations
%
% [0.8.0] 2017-08-01
%
% * Automatically determine the vehicle string from the extracted TruckSim data
%
% [0.7.0] 2017-06-04
%
% *Fixed*
%
% * Corrected extraction of suspension name from compliance rather than kinematics
%
% *Added*
% * Damper model
%
% [0.6.0] 2017-06-03
%
% * Support for dummy axles
%
% [0.5.0] 217-05-25
%
% *Fixed*
%
% * Moved all of the information extracted elsewhere to this function file to centralise the data extraction
%
% [0.4.0] - 2017-05-03
%
% *Added*
%
% * Automate LaTeX Tables for reporting
%
% [0.3.0] - 2017-05-01
%
% *Fixed*
%
% * Units converted to suit the PostProcessor requirements
%
% [0.2.0] - 2017-04-29
%
% *Added*
%
% * Converted script to a function for use in any PostProcess file
%
% [0.1.0] - 2017-04-18
%
% *Added*
%
% * Global Matlab script: readLinesFromFile
% * Global Matlab script: indexTextArray
% * Read data from par file into a cell array of strings based on selected unit and axle variables
% * Generate a new cell array for the unit variables containing the value for each unit, the measurement units and
%   variable name.
% * Generate a new cell array for the axle variables containing the value for each axle, the measurement units and
%   variable name.
% * Generate vehicle configuration
% * Generated post process variables

function [Tyre, Axle, Hitch, Sprung, Dimensions, PayloadLaden, PayloadUnladen, Dummy, Combination] = ...
    runTruckSimDataExtraction(ParDetails, Is, Combination)
%% Reading par file data
endParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.endParLadenFileName);
endParLadenFileData = readLinesFromFile(endParLadenFileFullPath);

if Is.lsunt
    endParUnladenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.endParUnladenFileName);
    endParUnladenFileData = readLinesFromFile(endParUnladenFileFullPath);
end
% Details such as model names etc will need to be extracted from the _all par file
allParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParLadenFileName);
allParLadenFileData = readLinesFromFile(allParLadenFileFullPath);

if Is.lsunt
    allParUnladenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParUnladenFileName);
    allParUnladenFileData = readLinesFromFile(allParUnladenFileFullPath);
end

%% Calculations with existing data
Combination.frontalAreaForDrag = max(Combination.maxWidth)*0.001*max(Combination.maxHeight)*0.001; % [m]

%% Warning messages
disp('** Note: code works for standard combinations with a single lead unit only');
disp('** Note: code works for driven axles in the 1st or 2nd axle group only');
disp('** Note: the code assumes all axles in the first axle group are steered');
disp('** Note: code assumes 0 dual spacing indicates single tyres');

%% Extract sprung mass properties
Sprung.DescriptionArray = extractSprungMassDescriptionArray(allParLadenFileData);
Sprung.MassArray = getVariableValuesFromPar(endParLadenFileData, '^M_SU');
Sprung.MassCoGxPosition = getVariableValuesFromPar(endParLadenFileData, '^LX_CG_SU');
Sprung.MassCoGzPosition = getVariableValuesFromPar(endParLadenFileData, '^H_CG_SU');
Sprung.MassCoGyPosition = getVariableValuesFromPar(endParLadenFileData, '^Y_CG_SU');
Sprung.MOIx = getVariableValuesFromPar(endParLadenFileData,'^IXX_SU');
Sprung.MOIy = getVariableValuesFromPar(endParLadenFileData,'^IYY_SU');
Sprung.MOIz = getVariableValuesFromPar(endParLadenFileData,'^IZZ_SU');

Sprung.numberOffUnits = length(Sprung.MassArray);

% Converting to the correct units for the Post Processor
Sprung.MassCoGxPosition = Sprung.MassCoGxPosition .* 0.001;
Sprung.MassCoGzPosition = Sprung.MassCoGzPosition .* 0.001;

%% Extract axle properties for post processor

% Extracting raw axle data
dummy = getVariableValuesFromPar(endParLadenFileData, '^M_US');
Axle.UnsprungMassArray=dummy(1:3:end)+dummy(2:3:end)++dummy(3:3:end);
Axle.XPositionArray = getVariableValuesFromPar(endParLadenFileData, '^LX_AXLE');
Axle.ZPositionArray = getVariableValuesFromPar(endParLadenFileData, '^H_CG_AXLE');

% Axle track regular expression modified to ensure no erroneous values from initialisation equations
Axle.TrackWidthArray = getVariableValuesFromPar(endParLadenFileData, '^L_TRACK\(\d,\d\)\s');

% Determine which axles are driven, this will not work if there are driven axles other than on the prime mover
axlePowertrainTorqueLogicArray = getVariableValuesFromPar(endParLadenFileData, '^R_DRIVE_SC');

% Extract tyre properties and determine which units are dolly's
[ExtractedTyreData, Combination.dollys] = extractTyreAllParData(allParLadenFileData, Sprung);

%% Extracting dataset names
% Axle type
GetAxleDescription.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleDescription.key = 'LOG_ENTRY Used Dataset: Animator: Shape File Link;';
GetAxleDescription.keySeperator = '} ';
Axle.type = extractAxleAllParData(allParLadenFileData, GetAxleDescription, Sprung);

% Axle compliance dataset name
GetAxleSuspensionModel.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSuspensionModel.key = 'LOG_ENTRY Used Dataset: Suspension: Solid Axle Compliance, Springs, and Dampers;';
GetAxleSuspensionModel.keySeperator = '} ';
Axle.complianceDatasetName = extractAxleAllParData(allParLadenFileData, GetAxleSuspensionModel, Sprung);

% Axle kinematic dataset name
GetAxleSuspensionKinematicsModel.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', ...
    'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSuspensionKinematicsModel.key = 'LOG_ENTRY Used Dataset: Suspension: Solid Axle System Kinematics;';
GetAxleSuspensionKinematicsModel.keySeperator = '} ';
Axle.suspensionKinematicsDatasetName = extractAxleAllParData(allParLadenFileData,...
    GetAxleSuspensionKinematicsModel, Sprung);

% Axle spring dataset name and spring type
GetAxleSpringDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSpringDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Spring;';
GetAxleSpringDatasets.keySeperator = '} ';
Axle.springDatasetName = extractAxleAllParData(allParLadenFileData, GetAxleSpringDatasets, Sprung);

% Axle damper dataset name
GetAxleSpringDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSpringDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Spring;';
GetAxleSpringDatasets.keySeperator = '} ';
Axle.springDatasetName = extractAxleAllParData(allParLadenFileData, GetAxleSpringDatasets, Sprung);

% Axle damper dataset name
GetAxleDamperDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleDamperDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Shock Absorber;';
GetAxleDamperDatasets.keySeperator = '} ';
Axle.damperDatasetName = extractAxleAllParData(allParLadenFileData, GetAxleDamperDatasets, Sprung);

% Axle roll centre height
GetAxleRollCentre.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleRollCentre.key = 'LOG_ENTRY Used Dataset: Suspension: Lateral Movement Due to Roll and Jounce;';
GetAxleRollCentre.keySeperator = '; ';
Axle.rollCentreDatasetName = extractAxleAllParData(allParLadenFileData, GetAxleRollCentre, Sprung);

% Axle track width
GetAxleTrack.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleTrack.key = 'L_TRACK';
GetAxleTrack.keySeperator = ' ';
Axle.trackWidth = extractAxleAllParData(allParLadenFileData, GetAxleTrack, Sprung);

% Axle auxiliary roll moment
GetAxleAuxRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', 'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleAuxRoll.key = 'MX_AUX_COEFFICIENT';
GetAxleAuxRoll.keySeperator = ' ';
Axle.auxRollMoment = extractAxleAllParData(allParLadenFileData, GetAxleAuxRoll, Sprung);

% Steer/Roll Ratio
GetAxleSteerRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSteerRoll.key = 'SUSP_AXLE_ROLL_STEER_COEFFICIENT';
GetAxleSteerRoll.keySeperator = ' ';
Axle.steerRollRatio = extractAxleAllParData(allParLadenFileData, GetAxleSteerRoll, Sprung);

% Generate dummy axle arrays based on the axle compliance dataset names to help filter the subsequent axle arrays
[Dummy] = findDummyAxles(Axle.complianceDatasetName);

%% Processing dummy axles if they exist in the combination
if Dummy.isDummyAxle
    Axle.complianceDatasetName = removeDummyAxlesFromCombinationCell(Axle.complianceDatasetName, Dummy.isRealAxleCell);
    Axle.type = removeDummyAxlesFromCombinationCell(Axle.type, Dummy.isRealAxleCell);
    Axle.suspensionKinematicsDatasetName = removeDummyAxlesFromCombinationCell(Axle.suspensionKinematicsDatasetName,...
        Dummy.isRealAxleCell);
    Axle.springDatasetName = removeDummyAxlesFromCombinationCell(Axle.springDatasetName, Dummy.isRealAxleCell);
    Axle.damperDatasetName = removeDummyAxlesFromCombinationCell(Axle.damperDatasetName, Dummy.isRealAxleCell);
    Axle.rollCentreDatasetName = removeDummyAxlesFromCombinationCell(Axle.rollCentreDatasetName, Dummy.isRealAxleCell);
    Axle.trackWidth = removeDummyAxlesFromCombinationCell(Axle.trackWidth, Dummy.isRealAxleCell);
    Axle.auxRollMoment = removeDummyAxlesFromCombinationCell(Axle.auxRollMoment, Dummy.isRealAxleCell);
    Axle.steerRollRatio = removeDummyAxlesFromCombinationCell(Axle.steerRollRatio, Dummy.isRealAxleCell);
    Axle.UnsprungMassArray = removeDummyAxlesFromArray(Axle.UnsprungMassArray, Dummy.isRealAxleArray);
    Axle.XPositionArray = removeDummyAxlesFromArray(Axle.XPositionArray, Dummy.isRealAxleArray);
    Axle.ZPositionArray = removeDummyAxlesFromArray(Axle.ZPositionArray, Dummy.isRealAxleArray);
    Axle.TrackWidthArray = removeDummyAxlesFromArray(Axle.TrackWidthArray, Dummy.isRealAxleArray);
    % When converting the powertrain torque array, only the axles on the first unit are considered
    axlePowertrainTorqueLogicArray = removeDummyAxlesFromArray(axlePowertrainTorqueLogicArray, ...
        cell2mat(Dummy.isRealAxleCell{1}));
    
    ExtractedTyreData.Sizes = removeDummyAxlesFromCombinationCell(ExtractedTyreData.Sizes, Dummy.isRealAxleCell);
    ExtractedTyreData.Datasets = removeDummyAxlesFromCombinationCell(ExtractedTyreData.Datasets, Dummy.isRealAxleCell);
end

%% Extracting additional data from the dataset names once they have been processed for dummy axles
Axle.loadRatings = extractParameterFromDatasetName(Axle.complianceDatasetName, '\[', '\][');
Axle.stabiliserModel = extractParameterFromDatasetName(Axle.complianceDatasetName, '\][', '\]');
Axle.rimMaterial = extractParameterFromDatasetName(Axle.suspensionKinematicsDatasetName);
% *Note:* there are 2 iterations of spring for each axle. This is because TruckSim makes contingency for having a
% different left and right spring. Thus will only take the first indice where multiple indices are found.
Axle.springType = extractParameterFromDatasetName(Axle.springDatasetName);

Axle.suspensionKinematicsReportName = editCombinationCellSplitText(Axle.suspensionKinematicsDatasetName,...
    {' (',' ['}, 1);
Axle.complianceReportName = editCombinationCellSplitText(Axle.complianceDatasetName,...
    {' (',' ['}, 1);

Axle.springReportModel = editCombinationCellSplitText(Axle.springDatasetName, {' (', ' ['}, 1);
Axle.damperReportModel = editCombinationCellSplitText(Axle.damperDatasetName, {' (', ' ['}, 1);

Axle.rollCentreHeight = editCombinationCellRegexpBetweenText(Axle.rollCentreDatasetName, ':\s+', '\smm');
%% Additional axle and tyre properties
% The axles are first split into units, and then into groups within that unit to form the correct Axle.Grouping variable
[Axle.Grouping, Axle.UnitAndGroup, Axle.UnitCellArray] = computeAxleGrouping(endParLadenFileData, ...
    Axle.XPositionArray, 2000, Dummy);

Axle.NumberOff = length(Axle.TrackWidthArray);
% If torque is transferred to the axle from the powertrain, its logic matrix value is set to 1
axlePowertrainTorqueLogicArray(axlePowertrainTorqueLogicArray > 0) = 1;
% Only the first 2 axle groups are considered to possibly have driven axles
drivenAxles = cell2mat(Axle.Grouping(1:2)') .* axlePowertrainTorqueLogicArray;
Axle.Driven = drivenAxles(drivenAxles ~= 0);
% disp('** Note: code works for driven axles in the 1st or 2nd axle group only');

% Determine which axles are steered
Axle.NumberOffSteer = length(Axle.Grouping{1});
% disp('** Note: the code assumes all axles in the first axle group are steered');

% Tyre sizes
Tyre.sizes = ExtractedTyreData.Sizes;

% Find the rolling radius from the first instance of rolling radius (steer tyre)## Should techically be the drive tyre
tyreRollingRadiusArray = getVariableValuesFromPar(endParLadenFileData, '^RRE(');

firstDriveTyreIndex = Axle.NumberOffSteer * 2 + 1; % Assuming single tyres for the steer axle

Tyre.RollingRadius = tyreRollingRadiusArray(firstDriveTyreIndex);

% Tyre widths no need to process for dummy axles, as the steer axle should always be axle 1
GetTyreWidth.dataSetKeyCell = {'ENTER_PARSFILE Tires\Tire', ...
    'EXIT_PARSFILE Tires\Tire'};
GetTyreWidth.key = 'Y_LENGTH';
GetTyreWidth.keySeperator = ' ';
Tyre.width = extractAxleAllParData(allParLadenFileData, GetTyreWidth, Sprung);

% Calculating the overall steer axle width
Axle.SteerAxleOverallWidth = Axle.TrackWidthArray(1) + str2double(Tyre.width{1}{1});

% Converting to the correct units for the Post Processor
Axle.XPositionArray = Axle.XPositionArray .* 0.001;
Axle.ZPositionArray = Axle.ZPositionArray .* 0.001;
Tyre.RollingRadius = Tyre.RollingRadius .* 0.001;

%% Dummy axle check for number of tyres
% Find number of tyres from number of tyre model instances in the par file
Tyre.NumberOff = length(getVariableValuesFromPar(endParLadenFileData, '^OPT_TIRE_MODEL'));
if Dummy.isDummyAxle
    nDummyAxles = sum(Dummy.isRealAxleArray(:)) == 0;
    % The dummy tyre dataset is for single tyres therefore 2 tyres per axle
    nDummyTyres = 2 * nDummyAxles;
    Tyre.NumberOff = Tyre.NumberOff - nDummyTyres;
end

%% Extract hitch properties
[Hitch] = extractHitchData(endParLadenFileData, allParLadenFileData, Combination);

% Converting to the correct units for the Post Processor
Hitch.XPositionArray = Hitch.XPositionArray .* 0.001;
Hitch.ZPositionArray = Hitch.ZPositionArray .* 0.001;

%% Extract payload properties including mass in kg and description
[PayloadLaden] = extractPayload(endParLadenFileData, allParLadenFileData, Sprung.numberOffUnits);

% Converting to the correct units for the Post Processor
% It is assumed that all payloads are located along the longitudinal centreline (y = 0)
PayloadLaden.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGxPositionCell, 'UniformOutput', 0);
PayloadLaden.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGzPositionCell, 'UniformOutput', 0);

if Is.lsunt
    [PayloadUnladen] = extractPayload(endParUnladenFileData, allParUnladenFileData, Sprung.numberOffUnits);
    PayloadUnladen.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGxPositionCell, 'UniformOutput', 0);
    PayloadUnladen.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGzPositionCell, 'UniformOutput', 0);
else
    % Need to manually create the unladen payload cell to allow for the axle load calculation to work
    nUnits = length(Combination.includedPayloads);
    for iUnit = 1 : nUnits
        iUnladenPayload = 0;
        
        % Initialising unladen cell
        PayloadUnladen.MassCell{iUnit} = [];
        PayloadUnladen.CoGxPositionCell{iUnit} = [];
        PayloadUnladen.CoGyPositionCell{iUnit} = [];
        PayloadUnladen.CoGzPositionCell{iUnit} = [];
        PayloadUnladen.MOIxCell{iUnit} = [];
        PayloadUnladen.MOIyCell{iUnit} = [];
        PayloadUnladen.MOIzCell{iUnit} = [];
        PayloadUnladen.DescriptionCell{iUnit} = {};
        
        nPayloads = length(Combination.includedPayloads{iUnit});
        for iPayload = 1 : nPayloads
            % Include a payload in the unladen condition if it is fuel/driver or permanent payload
            if ~Combination.includedPayloads{iUnit}(iPayload)
                % Move to next payload
                iUnladenPayload = iUnladenPayload + 1;
                PayloadUnladen.MassCell{iUnit} = [PayloadUnladen.MassCell{iUnit} ...
                    PayloadLaden.MassCell{iUnit}(iPayload)];
                PayloadUnladen.CoGxPositionCell{iUnit} = [PayloadUnladen.CoGxPositionCell{iUnit} ...
                    PayloadLaden.CoGxPositionCell{iUnit}(iPayload)];
                PayloadUnladen.CoGyPositionCell{iUnit} = [PayloadUnladen.CoGyPositionCell{iUnit} ...
                    PayloadLaden.CoGyPositionCell{iUnit}(iPayload)];
                PayloadUnladen.CoGzPositionCell{iUnit} = [PayloadUnladen.CoGzPositionCell{iUnit} ...
                    PayloadLaden.CoGzPositionCell{iUnit}(iPayload)];
                PayloadUnladen.MOIxCell{iUnit} = [PayloadUnladen.MOIxCell{iUnit} ...
                    PayloadLaden.MOIxCell{iUnit}(iPayload)];
                PayloadUnladen.MOIyCell{iUnit} = [PayloadUnladen.MOIyCell{iUnit} ...
                    PayloadLaden.MOIyCell{iUnit}(iPayload)];
                PayloadUnladen.MOIzCell{iUnit} = [PayloadUnladen.MOIzCell{iUnit} ...
                    PayloadLaden.MOIzCell{iUnit}(iPayload)];
                PayloadUnladen.DescriptionCell{iUnit} = [PayloadUnladen.DescriptionCell{iUnit} ...
                    PayloadLaden.DescriptionCell{iUnit}(iPayload)];
            end
        end
    end
end
%% Extract reference points
% Reference points are extracted into a cell where each row is a unit. Column 1 = X, Column 2 = Y, Column 3 = Z. Each
% column is a column array of the X, Y or Z reference points for that particular unit.
Dimensions.RefPointsLadenCell = extractReferencePoints(allParLadenFileData, Sprung, Combination);

if Is.lsunt
    Dimensions.RefPointsUnladenCell = extractReferencePoints(allParUnladenFileData, Sprung, Combination);
end

%% Extract LST parameters to ensure that the correct inputs have been used

if Is.lst || Is.lsunt
    yawUnit = getDatasetNameFromPar(allParLadenFileData, 'DEFINE_OUTPUT Yaw_Lin', {'= ', ';'});
    Combination.yawUnit = str2num(yawUnit{1}{1}(end));
    
    %% Warning message for incorrect Yaw Unit
    if Combination.yawUnit ~= Sprung.numberOffUnits
        warnAxleLoad = questdlg(['The incorrect unit has been chosen in LST manoeuvre, unit should be: ' num2str(Combination.yawUnit)],...
            'Yes', 'End Assessment', 'End Assessment');
        
        switch warnAxleLoad
            case 'Yes'
                uiwait(msgbox('Please note that the LST results may not be correct'));
            case 'End Assessment'
                uiwait(msgbox('The assessment will now be ended with a manually initialised error'));
                error('Manually initiated error in order to jump out of the script');
        end
    end
    
    %% Check centre of last axle group
    centreOfLastAxleGroup = getDatasetNameFromPar(allParLadenFileData, 'DEFINE_OUTPUT X_ALin', {'= ', ';'});
    centreOfLastAxleGroup = strsplit(centreOfLastAxleGroup{1}{1}, {'(', '/2', ')'});
    Combination.centreOfLastAxleGroup = centreOfLastAxleGroup{2};
    
    % Determine the actual centre of axle group
    lastAxleGroupIndices = Axle.Grouping{end};
    nAxlesInLastGroup = length(lastAxleGroupIndices);
    
    switch nAxlesInLastGroup
        case 1
            centreAxleIndices = 1;
        case 2
            centreAxleIndices = [1,2];
        case 3
            centreAxleIndices = 2;
        case 4
            centreAxleIndices = [2,3];
    end
    
    nCentreAxles = length(centreAxleIndices);
    centreAxleString ='';
    
    for iAxle = 1 : nCentreAxles
        
        if iAxle == 1
            centreAxleString =  ['X_A', num2str(lastAxleGroupIndices(centreAxleIndices(iAxle)))];
        else
            centreAxleString = [centreAxleString, '+', 'X_A', num2str(lastAxleGroupIndices(centreAxleIndices(iAxle)))];
        end
    end
    %% Warning message for incorrect axles
    if ~strcmp(centreAxleString, Combination.centreOfLastAxleGroup)
        warnAxleLoad = questdlg(['The incorrect axles have been chosen in LST manoeuvre, axles should be: ' centreAxleString],...
            'Yes', 'End Assessment', 'End Assessment');
        
        switch warnAxleLoad
            case 'Yes'
                uiwait(msgbox('Please note that the LST results may not be correct'));
            case 'End Assessment'
                uiwait(msgbox('The assessment will now be ended with a manually initialised error'));
                error('Manually initiated error in order to jump out of the script');
        end
    end
    
    Combination.widthAtLastAxleGroup = getDatasetNameFromPar(allParLadenFileData, 'DEFINE_OUTPUT TLin', {'= ', ';'});
end

if Is.fullPBS
    %% Determining the vehicle string
    Combination = computeVehicleString(Axle, Tyre, Hitch, Sprung, Combination);
    
    %% Determining the vehicle classification
    Combination = computeVehicleClassification(Axle, Tyre, Hitch, Sprung, Combination);
end
end