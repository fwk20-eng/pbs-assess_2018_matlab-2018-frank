%% ---------------------------------------------------------------------------------------
%	PROJECT NOTES
%----------------------------------------------------------------------------------------
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.

%% ---------------------------------------------------------------------------------------
%	POST PROCESS
%----------------------------------------------------------------------------------------
function a009_20141115_SGCoal_Afrit45m3_VolvoFMX480FM64T3HTX
%% --------------------------------------------------------------------------------------
%	Booleans
%----------------------------------------------------------------------------------------
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked

plotOn = 1; plotSummary = 0;

isBus = 0; % Set 1 if bus **Must add dangerous goods
isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)

isSave = 0; %Set to 0 if you do not want to save to excel

isAxleLoads = 0; % Set this to 1 to determine axle loads

isPBS = 1; % Set this to 1 to do a full PBS analysis, 0 will prevent any PBS manoeuvres from being run regardless of the variables below
isFullPBS = 1; % Set this to 1 to do a full PBS analysis, if set to 0 for a partial analysis, choose manoeuvres to run below


isLST =     0;  isYawD =  0;  isHSTO = 1;   isLong =  0;
isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;

isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder

%% --------------------------------------------------------------------------------------
%	20141115-Wits-PBS-assess-SGCOAL-Afrit-45cubesidetipinterlink-Volvo_FM64T3HTX
%----------------------------------------------------------------------------------------

%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
runNotes = {''};
rev = 'DBC';
projectKey = '20141115_sgCoal-Afrit45m3-VolvoFM64T3HTX'; %Include an underscore as the final character 
date = '2017-02-16';
rootPath = 'C:\Dropbox\PBS\Projects\Database Check\P009_Afrit45m3_VolvoFM64T3HTX\';%end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Dropbox\witsPBS_2017-02-15\Runs';
%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
savePath = sprintf('%s%s%s%s',rootPath, date, '_v', rev);
runKey = sprintf('%s%s%s',projectKey,'_v',rev);% 'PBS Afrit 45 cube w VolvoFM64T3HTX_Rev 9'; %Rev Letter indicates it is a prelim
fileName = strcat(runKey, '_summary.xlsx');

if isSave 
    checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
end
%% --------------------------------------------------------------------------------------
%	Combination configuration
%----------------------------------------------------------------------------------------
Ldesired = 1; %PBS level desired

groupingHeadings = {'Steer' 'Drive' 'Lead Trailer' 'Follower Trailer'}; %Label the axle groups
grouping = {[1]; [2:3]; [4:6]; [7:9]}; % Axles numbers in each axle group. Nb cell dim must be greater than mchas dim by 1

loadshare1 = [1 0.5 0.5 (1/3)*ones(1,6)]; % Normal loadsharing numbers
loadshare2 = [1 0.5 0.5 (1/3)*ones(1,6)]; % Startability loadsharing numbers

mAxle = [750 1300 1300 951*ones(1,3) 954*ones(1,3)];
xAxle = [0 3.2 4.57 6.89 8.25 9.61 3.99 5.35 6.710]; % Distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
zAxle = [0.497 0.514 0.514 0.514*ones(1,3) 0.514*ones(1,3)]; % TruckSim model

Ndrive = [2:3]; % Driven axles
nSteer = 1; % number of steer axles for STFD

rollCoupled = [true true];
loadCoupled = [true true];

dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)%

%% --------------------------------------------------------------------------------------
%	Hitch Inputs
%----------------------------------------------------------------------------------------
l = [3.35 8.840]; % Longitudinal position from steer axle
h = [1.399 1.320]; % Height from floor

%% --------------------------------------------------------------------------------------
%	Sprung Mass and CoG for Lead and Trailer units
%----------------------------------------------------------------------------------------
mChas = [5967 4400 3950]; % 
xChas = [1.097 5.269 3.806]; %
zChas = [1.200 1.533 1.615]; %

%% --------------------------------------------------------------------------------------
%	Unit 1 payload mass and CoG
%----------------------------------------------------------------------------------------
dLoad{:,1} = {'Driver'};
mLoad{:,1} = [75]'; %
xLoad{:,1} = [-0.218]'; %It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
zLoad{:,1} = [1.815]'; %

%% --------------------------------------------------------------------------------------
%	Unit 2 payload mass and CoG
%----------------------------------------------------------------------------------------
[mLead, hcogLead] = binCoG_Afrit45m3(1140e-9, 24885, -100, (1621-133), fileName, savePath, runKey, 'Leader_Payload', isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,2} = {'Coal'};
mLoad{:,2} = [mLead]; %
xLoad{:,2} = [3.500-0.1]'; %
zLoad{:,2} = [hcogLead]'; %

%% --------------------------------------------------------------------------------------
%	Unit 3 payload mass and CoG
%----------------------------------------------------------------------------------------
[mFollow, hcogFollow] = binCoG_Afrit45m3(1133e-9, 24730, 465, (1621-133), fileName, savePath, runKey, 'Follower_Payload', isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,3} = {'Coal'};
mLoad{:,3} = [mFollow]; %
xLoad{:,3} = [3.500+0.465]'; %
zLoad{:,3} = [hcogFollow]'; %

%% --------------------------------------------------------------------------------------
%	Additional inputs
%----------------------------------------------------------------------------------------
Area = 3.431*2.600; %[m2] Frontal area
Ltot = 21574;          % [mm] see the generated GA
VehWidthLoad = 2600;   % [mm] total width - @ trailer axle width
VehWidthUnload = 2600; % [mm] total width - @ trailer axle width
SteerWidth = 2494; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))

%% --------------------------------------------------------------------------------------
%	Engine properties
%----------------------------------------------------------------------------------------
gears =     [14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00];
eff_gear =  [0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96];
eff_diff = 0.97; % standard diff ratio
dif = 3.46; % standard diff ratio

gearsStart =     [19.38  14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
eff_gearStart =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96]; %Gears for startability - used if crawler gear available
eff_diffStart = 0.97; % Diff ratio for startability - used if crawler gear available
difStart = 3.46; % Diff ratio for startability - used if dual differential ratio is available

Torquerpm = [600     699     761     818     857     899     925     950     962     979     995     1038	1397	1459	1532	1611	1696	1781	1834	1880	1919	1962	1998	2035	2100];
TorqueNm =  [1253	1400	1500	1600	1700	1800	1900	2000	2100	2200	2300	2400	2400	2300	2200	2100	2000	1900	1800	1700	1600	1500	1400	1300	1169];
engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

changeT = 1696; % Torque where torque*rpm is max

rr = 0.521; % [m] rolling radius
Ie = 2.75; % [kg/m^2] engine inertia 
It = 34*14; % [kg/m^2] tyre inertia
gearshiftregime = 2; % 1 for every gear 2 for every second

if (max(TorqueNm)/2) < min(TorqueNm)
    engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
else
    engageTNm = min(TorqueNm);
end

%% --------------------------------------------------------------------------------------
%	Setting matlab keys for run
%----------------------------------------------------------------------------------------
matKeyYawD = 'YawD';
matKeyRA = 'RA';
matKeyHSTO = 'RA';
matKeySRTt = 'Tilt';
matKeyTASP = 'TASP';
matKeyLSTurn = 'LST';
matKeyLSTurnu = 'LSunT';

%% --------------------------------------------------------------------------------------
%	Run-checks, resetting booleans if necessary
%----------------------------------------------------------------------------------------
if isFullPBS == 1 %Turns on all PBS manoeuvres 
	isLST = 1;      isYawD = 1;     isHSTO = 1;     isLong = 1;
	isLSunT = 1;    isRA = 1;       isTASP = 1;     isSRT = 1;
end

if ~isFullPBS
    plotSummary = false; %Turns off plot summary if not a full PBS assessment
end

%% --------------------------------------------------------------------------------------
%	Passing variables to PostProcess
%----------------------------------------------------------------------------------------
PostProcessMultiChoice(plotOn, plotSummary, isBus, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,... 
            savePath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad,...
            Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
            Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
            isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isRemoveMFiles, runNotes);   
end

%% ---------------------------------------------------------------------------------------
%	PREVIOUS RUNS
%----------------------------------------------------------------------------------------

