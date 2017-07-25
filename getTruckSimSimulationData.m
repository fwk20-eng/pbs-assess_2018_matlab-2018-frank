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
% * [x] grouping
% * [x] mAxle [M_US]
% * [x] xAxle [LX_AXLE]
% * [x] zAxle [H_CG_AXLE]
% * [x] Ndrive
% * [x] nSteer
% * [x] nTyres [OPT_TIRE_MODEL]
% * [x] rr [RRE]
% * [x] rollCoupled
% * [x] loadCoupled - hard coded to be true for all hitch points for now.
% * [?] dollys - I have not done a dolly project yet. Will add this functionality once I have completed one.
% * [x] l - hitch longitudinal position [LX_H]
% * [x] h - hitch height [H_H] % [H_H_FRONT]
% * [?] Area [Z_LENGTH (MAX) * Y_LENGTH (MAX)] - Will manually enter this for now
% * [x] Ltot [This will need to be manually entered]
% * [x] VehWidthLoad - Find max width from the reference points at laden condition
% * [x] VehWidthUnload - Find max width from the reference points at the unladen condition
% * [x] SteerWidth
% * [x] mChas [M_SU]
% * [x] xChas [LX_CG_SU]
% * [x] zChas [H_CG_SU]
% * [x] dLoad - all units
% * [x] mLoad - all units [M_PL]
% * [x] xLoad - all units [LX_CG_PL]
% * [x] zLoad - all units [H_CG_PL]

function [Tyre, Axle, Hitch, Sprung, Dimensions, PayloadLaden, PayloadUnladen, Dummy] = ...
    getTruckSimSimulationData(ParDetails, Is, Combination)
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

%% Extract sprung mass properties
Sprung.DescriptionArray = getSprungMassDescriptionArray(allParLadenFileData);
Sprung.MassArray = getVariableValuesFromPar(endParLadenFileData, '^M_SU');
Sprung.MassCoGxPosition = getVariableValuesFromPar(endParLadenFileData, '^LX_CG_SU');
Sprung.MassCoGzPosition = getVariableValuesFromPar(endParLadenFileData, '^H_CG_SU');
Sprung.MassCoGyPosition = getVariableValuesFromPar(endParLadenFileData, '^Y_CG_SU');
Sprung.MOIx = getVariableValuesFromPar(endParLadenFileData,'^IXX_SU');
Sprung.MOIy = getVariableValuesFromPar(endParLadenFileData,'^IYY_SU');
Sprung.MOIz = getVariableValuesFromPar(endParLadenFileData,'^IZZ_SU');

Sprung.numberOffUnits = length(Sprung.MassArray);

% Converting to the correct units for the Post Processor
Sprung.MassCoGxPosition = Sprung.MassCoGxPosition.*0.001;
Sprung.MassCoGzPosition = Sprung.MassCoGzPosition.*0.001;

%% Extract axle properties for post processor

% Extracting raw axle data
Axle.UnsprungMassArray = getVariableValuesFromPar(endParLadenFileData, '^M_US');
Axle.XPositionArray = getVariableValuesFromPar(endParLadenFileData, '^LX_AXLE');
Axle.ZPositionArray = getVariableValuesFromPar(endParLadenFileData, '^H_CG_AXLE');

% Axle track regular expression modified to ensure no erroneous values from initialisation equations
Axle.TrackWidthArray = getVariableValuesFromPar(endParLadenFileData, '^L_TRACK\(\d,\d\)\s');

% Determine which axles are driven, this will not work if there are driven axles other than on the prime mover
axlePowertrainTorqueLogicArray = getVariableValuesFromPar(endParLadenFileData, '^R_DRIVE_SC');

% Extract tyre properties
extractedTyreData = getAllParDataForEachAxleFromTyreData(allParLadenFileData, Sprung);

%% Extracting dataset names
% Axle type
GetAxleDescription.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleDescription.key = 'LOG_ENTRY Used Dataset: Animator: Shape File Link;';
GetAxleDescription.keySeperator = '} ';
Axle.type = getAllParDataForEachAxle(allParLadenFileData, GetAxleDescription, Sprung);

% Axle compliance dataset name
GetAxleSuspensionModel.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSuspensionModel.key = 'LOG_ENTRY Used Dataset: Suspension: Solid Axle Compliance, Springs, and Dampers;';
GetAxleSuspensionModel.keySeperator = '} ';
Axle.complianceDatasetName = getAllParDataForEachAxle(allParLadenFileData, GetAxleSuspensionModel, Sprung);

% Axle kinematic dataset name
GetAxleSuspensionKinematicsModel.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', ...
    'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSuspensionKinematicsModel.key = 'LOG_ENTRY Used Dataset: Suspension: Solid Axle System Kinematics;';
GetAxleSuspensionKinematicsModel.keySeperator = '} ';
Axle.suspensionKinematicsDatasetName = getAllParDataForEachAxle(allParLadenFileData,...
    GetAxleSuspensionKinematicsModel, Sprung);

% Axle spring dataset name and spring type
GetAxleSpringDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSpringDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Spring;';
GetAxleSpringDatasets.keySeperator = '} ';
Axle.springDatasetName = getAllParDataForEachAxle(allParLadenFileData, GetAxleSpringDatasets, Sprung);

% Axle damper dataset name
GetAxleSpringDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSpringDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Spring;';
GetAxleSpringDatasets.keySeperator = '} ';
Axle.springDatasetName = getAllParDataForEachAxle(allParLadenFileData, GetAxleSpringDatasets, Sprung);

% Axle damper dataset name
GetAxleDamperDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', ...
    'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleDamperDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Shock Absorber;';
GetAxleDamperDatasets.keySeperator = '} ';
Axle.damperDatasetName = getAllParDataForEachAxle(allParLadenFileData, GetAxleDamperDatasets, Sprung);

% Axle roll centre height
GetAxleRollCentre.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleRollCentre.key = 'LOG_ENTRY Used Dataset: Suspension: Lateral Movement Due to Roll and Jounce;';
GetAxleRollCentre.keySeperator = '; ';
Axle.rollCentreDatasetName = getAllParDataForEachAxle(allParLadenFileData, GetAxleRollCentre, Sprung);

% Axle track width
GetAxleTrack.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleTrack.key = 'L_TRACK';
GetAxleTrack.keySeperator = ' ';
Axle.trackWidth = getAllParDataForEachAxle(allParLadenFileData, GetAxleTrack, Sprung);

% Axle auxiliary roll moment
GetAxleAuxRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', 'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleAuxRoll.key = 'MX_AUX_COEFFICIENT';
GetAxleAuxRoll.keySeperator = ' ';
Axle.auxRollMoment = getAllParDataForEachAxle(allParLadenFileData, GetAxleAuxRoll, Sprung);

% Steer/Roll Ratio
GetAxleSteerRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSteerRoll.key = 'SUSP_AXLE_ROLL_STEER_COEFFICIENT';
GetAxleSteerRoll.keySeperator = ' ';
Axle.steerRollRatio = getAllParDataForEachAxle(allParLadenFileData, GetAxleSteerRoll, Sprung);

% Generate dummy axle arrays based on the axle compliance dataset names to help filter the subsequent axle arrays
[Dummy] = detectDummyAxles(Axle.complianceDatasetName);

% Processing dummy axles if they exist in the combination
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
    
    extractedTyreData.Sizes = removeDummyAxlesFromCombinationCell(extractedTyreData.Sizes, Dummy.isRealAxleCell);
    extractedTyreData.Datasets = removeDummyAxlesFromCombinationCell(extractedTyreData.Datasets, Dummy.isRealAxleCell);
end

%% Extracting additional data from the dataset names once they have been processed for dummy axles
Axle.loadRatings = getAxleParameterTypeFromTruckSimDatasetName(Axle.complianceDatasetName, '\[', '\][');
Axle.stabiliserModel = getAxleParameterTypeFromTruckSimDatasetName(Axle.complianceDatasetName, '\][', '\]');
Axle.rimMaterial = getAxleParameterTypeFromTruckSimDatasetName(Axle.suspensionKinematicsDatasetName);
% *Note:* there are 2 iterations of spring for each axle. This is because TruckSim makes contingency for having a
% different left and right spring. Thus will only take the first indice where multiple indices are found.
Axle.springType = getAxleParameterTypeFromTruckSimDatasetName(Axle.springDatasetName);

Axle.suspensionKinematicsReportName = editCombinationCellSplitText(Axle.suspensionKinematicsDatasetName,...
    {' (',' ['}, 1);
Axle.complianceReportName = editCombinationCellSplitText(Axle.complianceDatasetName,...
    {' (',' ['}, 1);

Axle.springReportModel = editCombinationCellSplitText(Axle.springDatasetName, {' (',' ['}, 1);
Axle.damperReportModel = editCombinationCellSplitText(Axle.damperDatasetName, {' (',' ['}, 1);

Axle.rollCentreHeight = editCombinationCellRegexpBetweenText(Axle.rollCentreDatasetName, ':\s+', '\smm');
%% Additional axle and tyre properties
% The axles are first split into units, and then into groups within that unit to form the correct Axle.Grouping variable
[Axle.Grouping, Axle.UnitAndGroup, Axle.UnitCellArray] = getAxleGrouping(endParLadenFileData, ...
    Axle.XPositionArray, 2000, Dummy);

Axle.NumberOff = length(Axle.UnsprungMassArray);
% If torque is transferred to the axle from the powertrain, its logic matrix value is set to 1
axlePowertrainTorqueLogicArray(axlePowertrainTorqueLogicArray > 0) = 1;
% Only the first 2 axle groups are considered to possibly have driven axles
drivenAxles = cell2mat(Axle.Grouping(1:2)') .* axlePowertrainTorqueLogicArray;
Axle.Driven = drivenAxles(drivenAxles ~= 0);
disp('Note: code works for driven axles in the 1st or 2nd axle group only');

% Determine which axles are steered
Axle.NumberOffSteer = length(Axle.Grouping(1));
disp('Note: the code assumes all axles in the first axle group are steered');

% Tyre sizes
Tyre.sizes = extractedTyreData.Sizes;

% Find the rolling radius from the first instance of rolling radius (steer tyre)## Should techically be the drive tyre
tyreRollingRadiusArray = getVariableValuesFromPar(endParLadenFileData, '^RRE(');
Tyre.RollingRadius = tyreRollingRadiusArray(1);

% Tyre widths no need to process for dummy axles, as the steer axle should always be axle 1
GetTyreWidth.dataSetKeyCell = {'ENTER_PARSFILE Tires\Tire', ...
    'EXIT_PARSFILE Tires\Tire'};
GetTyreWidth.key = 'Y_LENGTH';
GetTyreWidth.keySeperator = ' ';
Tyre.width = getAllParDataForEachAxle(allParLadenFileData, GetTyreWidth, Sprung);

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
[Hitch] = getHitchData(endParLadenFileData, allParLadenFileData);

% Converting to the correct units for the Post Processor
Hitch.XPositionArray = Hitch.XPositionArray .* 0.001;
Hitch.ZPositionArray = Hitch.ZPositionArray .* 0.001;

%% Extract payload properties including mass in kg and description
[PayloadLaden] = determinePayloadCell(endParLadenFileData, allParLadenFileData, Sprung.numberOffUnits);

% Converting to the correct units for the Post Processor
% It is assumed that all payloads are located along the longitudinal centreline (y = 0)
PayloadLaden.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGxPositionCell, 'UniformOutput', 0);
PayloadLaden.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGzPositionCell, 'UniformOutput', 0);

if Is.lsunt
    [PayloadUnladen] = determinePayloadCell(endParUnladenFileData, allParUnladenFileData, Sprung.numberOffUnits);
    PayloadUnladen.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGxPositionCell, 'UniformOutput', 0);
    PayloadUnladen.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGzPositionCell, 'UniformOutput', 0);
else
    % Need to manually crrate the unladen payload cell to allow for the axle load calculation to work
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
Dimensions.RefPointsLadenCell = getReferencePoints(allParLadenFileData, Sprung);

if Is.lsunt
    Dimensions.RefPointsUnladenCell = getReferencePoints(allParUnladenFileData, Sprung);
end
%% Determining maximum vehicle width in the laden and unladen condition condition
% The maximim width of the vehicle is found from the reference point at the widest point on the combination.

% This is now no longer required since the max width is entered manually. The widest point may not necessarily be a
% reference point.

% Dimensions.MaxWidthLaden = getMaxVehicleWidth(Dimensions.RefPointsLadenCell, Sprung.numberOffUnits);
% 
% if Is.lsunt
% Dimensions.MaxWidthUnladen = getMaxVehicleWidth(Dimensions.RefPointsUnladenCell, Sprung.numberOffUnits);
% end
end