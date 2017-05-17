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

function [Tyre, Axle, Hitch, Sprung, Dimensions, PayloadLaden, PayloadUnladen] = getTruckSimSimulationData(ParDetails) 
%% Adding paths to required functions
% addpath('C:\Dropbox\_Personal\Programming\Global_Matlab_Toolbox');
%% Test Data (once a function, uncomment the nargin argument)
%-------------------------------------------------------------------------
% if nargin == 0
%% Semi-trailer

% % % Do not end folder path with a \
%     ParDetails.parFileFolderPath = 'C:\Dropbox\PBS\MatLab\TruckSim Data Extraction\Validation\PBS Assessment Files and Results_Cosmopolitan Hauliers';
% % Do not begin filename with a \
%     ParDetails.endParLadenFileName = 'Run218_end.par';
%     ParDetails.allParLadenFileName = 'Run218_all.par';
%     
%     ParDetails.endParUnladenFileName = 'Run220_end.par';
%     ParDetails.allParUnladenFileName = 'Run220_all.par';
    
% end

%% B-Double

% % Do not end folder path with a \
%     ParDetails.parFileFolderPath = 'C:\Dropbox\PBS\MatLab\TruckSim Data Extraction\Validation\PBS Assessment Files and Results_SG Coal 50 m3 SATB STI Volvo FH440';
% % Do not begin filename with a \
%     ParDetails.endParLadenFileName = 'Run216_end.par';
%     ParDetails.allParLadenFileName = 'Run216_all.par';
%     
%     ParDetails.endParUnladenFileName = 'Run217_end.par';
%     ParDetails.allParUnladenFileName = 'Run217_all.par';

%% Reading par file data
%-------------------------------------------------------------------------
endParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.endParLadenFileName);
endParLadenFileData = readLinesFromFile(endParLadenFileFullPath);

endParUnladenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.endParUnladenFileName);
endParUnladenFileData = readLinesFromFile(endParUnladenFileFullPath);

% Details such as model names etc will need to be extracted from the _all par file
allParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParLadenFileName);
allParLadenFileData = readLinesFromFile(allParLadenFileFullPath);

allParUnladenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParUnladenFileName);
allParUnladenFileData = readLinesFromFile(allParUnladenFileFullPath);

%% Generate the remaining Post Process variables
%-------------------------------------------------------------------------
%% Extract sprung mass properties
Sprung.DescriptionArray = getSprungMassDescriptionArray(allParLadenFileData);
Sprung.MassArray = getVariableValuesFromPar(endParLadenFileData, '\<M_SU');
Sprung.MassCoGxPosition = getVariableValuesFromPar(endParLadenFileData, '\<LX_CG_SU');
Sprung.MassCoGzPosition = getVariableValuesFromPar(endParLadenFileData, '\<H_CG_SU');
Sprung.MassCoGyPosition = getVariableValuesFromPar(endParLadenFileData, '\<Y_CG_SU');
Sprung.MOIx = getVariableValuesFromPar(endParLadenFileData,'\<IXX_SU');
Sprung.MOIy = getVariableValuesFromPar(endParLadenFileData,'\<IYY_SU');
Sprung.MOIz = getVariableValuesFromPar(endParLadenFileData,'\<IZZ_SU');

Sprung.numberOffUnits = length(Sprung.MassArray);

% Converting to the correct units for the Post Processor
Sprung.MassCoGxPosition = Sprung.MassCoGxPosition.*0.001;
Sprung.MassCoGzPosition = Sprung.MassCoGzPosition.*0.001;

%% Extract axle properties.
Axle.UnsprungMassArray = getVariableValuesFromPar(endParLadenFileData, '\<M_US');
Axle.XPositionArray = getVariableValuesFromPar(endParLadenFileData, '\<LX_AXLE');
Axle.ZPositionArray = getVariableValuesFromPar(endParLadenFileData, '\<H_CG_AXLE');
% Axle track regular expression modified to ensure no erroneous values from initialisation equations
Axle.TrackWidthArray = getVariableValuesFromPar(endParLadenFileData, '\<L_TRACK\(\d,\d\)\s');

% The axles are first split into units, and then into groups within that unit to form the correct Axle.Grouping variable

[Axle.Grouping, Axle.UnitAndGroup, Axle.UnitCellArray] = getAxleGrouping(endParLadenFileData, Axle.XPositionArray, 2000);

%Axle.Grouping = getAxleGrouping(Axle.XPositionArray, 2000);
Axle.NumberOff = length(Axle.UnsprungMassArray);

% Determine which axles are driven, this will not work if there are driven axles other than on the prime mover
axlePowertrainTorqueLogicArray = getVariableValuesFromPar(endParLadenFileData, '\<R_DRIVE_SC');
% If torque is transferred to the axle from the powertrain, its logic matrix value is set to 1
axlePowertrainTorqueLogicArray(axlePowertrainTorqueLogicArray > 0) = 1;
drivenAxles = cell2mat(Axle.Grouping(1:2)') .* axlePowertrainTorqueLogicArray;
Axle.Driven = drivenAxles(drivenAxles ~= 0);
disp('Note: code works for driven axles in the 1st or 2nd axle group only');

% Determine which axles are steered
Axle.NumberOffSteer = length(Axle.Grouping(1));
disp('Note: the code assumes all axles in the first axle group are steered');

% Converting to the correct units for the Post Processor
Axle.XPositionArray = Axle.XPositionArray .* 0.001;
Axle.ZPositionArray = Axle.ZPositionArray .* 0.001;

%% Extract tyre properties
% Find number of tyres from number of tyre model instances in the par file
Tyre.NumberOff = length(getVariableValuesFromPar(endParLadenFileData, '\<OPT_TIRE_MODEL'));

% Find the rolling radius from the first instance of rolling radius (steer tyre)
tyreRollingRadiusArray = getVariableValuesFromPar(endParLadenFileData, '\<RRE');

Tyre.RollingRadius = tyreRollingRadiusArray(1);

Tyre.WidthArray = getVariableValuesFromPar(allParLadenFileData, '\<SET_THICKNESS_SGUI');

Axle.SteerAxleOverallWidth = Axle.TrackWidthArray(1) + Tyre.WidthArray(1);

% Converting to the correct units for the Post Processor
Tyre.RollingRadius = Tyre.RollingRadius .* 0.001;

%% Extract hitch properties

[Hitch] = getHitchData(endParLadenFileData, allParLadenFileData);

% Converting to the correct units for the Post Processor
Hitch.XPositionArray = Hitch.XPositionArray .* 0.001;
Hitch.ZPositionArray = Hitch.ZPositionArray .* 0.001;

%% Extract payload properties including mass in kg and description
[PayloadLaden] = determinePayloadCell(endParLadenFileData, allParLadenFileData, Sprung.numberOffUnits);
                                          
[PayloadUnladen] = determinePayloadCell(endParUnladenFileData, allParUnladenFileData, Sprung.numberOffUnits);                                          

% Converting to the correct units for the Post Processor
PayloadLaden.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGxPositionCell, 'UniformOutput', 0);
PayloadLaden.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadLaden.CoGzPositionCell, 'UniformOutput', 0);

PayloadUnladen.CoGxPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGxPositionCell, 'UniformOutput', 0);
PayloadUnladen.CoGzPositionCell = cellfun(@(x) x .* 0.001, PayloadUnladen.CoGzPositionCell, 'UniformOutput', 0);

%% Extract reference points
% Reference points are extracted into a cell where each row is a unit. Column 1 = X, Column 2 = Y, Column 3 = Z. Each
% column is a column array of the X, Y or Z reference points for that particular unit.
Dimensions.RefPointsLadenCell = getReferencePoints(endParLadenFileData, Sprung.numberOffUnits);
Dimensions.RefPointsUnladenCell = getReferencePoints(endParUnladenFileData, Sprung.numberOffUnits);

%% Determining maximum vehicle width in the laden and unladen condition condition
% The maximim width of the vehicle is found from the reference point at the widest point on the combination.

Dimensions.MaxWidthLaden = getMaxVehicleWidth(Dimensions.RefPointsLadenCell, Sprung.numberOffUnits);
Dimensions.MaxWidthUnladen = getMaxVehicleWidth(Dimensions.RefPointsUnladenCell, Sprung.numberOffUnits);

end