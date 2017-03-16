%% ---------------------------------------------------------------------------------------
%	PROJECT NOTES
%----------------------------------------------------------------------------------------

% Some of the info below still needs to be confirmed by Volvo.

%% ---------------------------------------------------------------------------------------
%	POST PROCESS
%----------------------------------------------------------------------------------------
function a026_Unitrans_Afrit50m3STRT_VolvoFH86T6HT
%% --------------------------------------------------------------------------------------
%	Booleans
%----------------------------------------------------------------------------------------
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked

isBus = 0; % Set 1 if bus **Must add dangerous goods
isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)

plotOn = 1; plotSummary = 1;

isSave = 1; %Set to 0 if you do not want to save to excel
isLog = 1; %Set to 0 to write run notes and revision to text file

isAxleLoads = 1; % Set this to 1 to determine axle loads

isPBS = 1; % Set this to 1 to do a full PBS analysis, 0 will prevent any PBS manoeuvres from being run regardless of the variables below
isFullPBS = 1; % Set this to 1 to do a full PBS analysis, if set to 0 for a partial analysis, choose manoeuvres to run below

isLST =     1;  isYawD =  0;  isHSTO = 0;   isLong =  0;
isLSunT =   1;  isRA =    0;  isTASP = 0;   isSRT =   0;

isRemoveMFiles = 0; %Set this to 0 to remove the request for removing Mat files in the runs folder

%% --------------------------------------------------------------------------------------
%	P021-Wits-PBS-assess-SGCOAL-Afrit-45cubesidetipinterlink-Volvo_FM64T3HBX
%----------------------------------------------------------------------------------------

%% --------------------------------------------------------------------------------------
%	Project folders/filenames settings
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Run Notes')
disp('-------------------------------------------------------------------------------------')
runNotes = {'Using Volvo 8x6 with 4900 mm WB'; 'No tyre relaxation length'} %Do not suppress
rev = '3';
projectKey = 'P026_Unitrans_Afrit50m3STRT_VolvoFH86T6HT'; %Include an underscore as the final character 
dateT = date;
rootPath = 'C:\Dropbox\PBS Technical Library\3 Combinations\P026_Unitrans_Afrit50m3STRT_VolvoFH86T6HT\Results\';%end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Users\Public\Documents\TruckSim_Data\Runs';

%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
savePath = sprintf('%s%s%s%s',rootPath, dateT, '_v', rev);
runKey = sprintf('%s%s%s',projectKey,'_v',rev);% 'PBS Afrit 45 cube w VolvoFM64T3HTX_Rev 9'; %Rev Letter indicates it is a prelim
fileName = strcat(runKey, '_summary.xlsx');

if isSave 
    checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
end
%% --------------------------------------------------------------------------------------
%	Combination configuration
%----------------------------------------------------------------------------------------
Ldesired = 4; %PBS level desired

groupingHeadings = {'Steer' 'Drive' 'Trailer 1' 'Trailer 2' 'Dolley' 'Trailer 3' 'Trailer 4'}; %Label the axle groups
grouping = {[1]; [2:4]; [5:7]; [8:10]; [11:13]; [14:16]; [17:19]}; % Axles numbers in each axle group. Nb cell dim must be greater than mchas dim by 1

loadshare1 = [1 1/3*ones(1,18)]; % Normal loadsharing numbers
loadshare2 = [1 1/3*ones(1,18)]; % Startability loadsharing numbers

mAxle = [895 1300 1300 1300 800*ones(1,15)]; % TruckSim model
xAxle = [0 3.2 4.9 6.27 7.5 8.8 10.1 3.6 4.9 6.2 2.39 3.75 5.11 7.5 8.8 10.1 3.6 4.9 6.2]; % Distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
zAxle = [0.497 0.5334 0.514 0.514 0.535*ones(1,15)]; % TruckSim model

Ndrive=[2:1:4]; % Driven axles
nSteer = 2;     % number of steer axles for STFD

rollCoupled = [true true false true true];
loadCoupled = [true true false true true];

dollys = [4];     % vehicle unit numbers with no reference points (dolly's do not have RPs)%

%% --------------------------------------------------------------------------------------
%	Hitch Inputs
%----------------------------------------------------------------------------------------
l = [4.9 8.6 6.979 4.132 8.6]; % Hps are distance back from 1st axle for l(1) & back from last hp
h=[1.348 1.35 1.35 1.35 1.35]; %

%% --------------------------------------------------------------------------------------
%	Sprung Mass and CoG for Lead and Trailer units
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Sprung Mass and CoG for Lead and Trailer units')
disp('-------------------------------------------------------------------------------------')
mChas = [8335 6900 5900 1400 6900 5900]; %
xChas = [1.862 5.152 3.264 4.132 5.152 3.264]; %
zChas = [1.200 1.622 1.750 0.860 1.622 1.750]; %
%% --------------------------------------------------------------------------------------
%	Unit 1 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 1 Payload')
disp('-------------------------------------------------------------------------------------')
dLoad{:,1} = {'Driver'};
mLoad{:,1} = [75]; %
xLoad{:,1} = -[0.218]'; %
zLoad{:,1} = [1.815]'; %


%% --------------------------------------------------------------------------------------
%	Unit 2 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 2 Payload')
disp('-------------------------------------------------------------------------------------')
[mUnit2, hcogUnit2] = binCoG(2700e-9, 23650, -365, 1689.9, fileName, savePath, runKey, 'Unit2_Payload', plotOn, isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,2} = {'Chromium SG=2.7'};
mLoad{:,2} = [mUnit2]; %
xLoad{:,2} = [6.332/2-0.365]'; %
zLoad{:,2} = [hcogUnit2]'; %

%% --------------------------------------------------------------------------------------
%	Unit 3 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 3 Payload')
disp('-------------------------------------------------------------------------------------')
[mUnit3, hcogUnit3] = binCoG(2700e-9, 23650, 60, 1695.1, fileName, savePath, runKey, 'Unit3_Payload', plotOn, isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,3} = {'Chromium SG=2.7'};
mLoad{:,3} = [mUnit3]; %
xLoad{:,3} = [6.332/2+0.060]'; %
zLoad{:,3} = [hcogUnit3]'; %

%% --------------------------------------------------------------------------------------
%	Unit 5 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 5 Payload')
disp('-------------------------------------------------------------------------------------')
[mUnit5, hcogUnit5] = binCoG(2700e-9, 23650, -365, 1689.9, fileName, savePath, runKey, 'Unit5_Payload', plotOn, isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,5} = {'Chromium SG=2.7'};
mLoad{:,5} = [mUnit5]; %
xLoad{:,5} = [6.332/2-0.365]'; %
zLoad{:,5} = [hcogUnit5]'; %

%% --------------------------------------------------------------------------------------
%	Unit 6 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 6 Payload')
disp('-------------------------------------------------------------------------------------')
[mUnit6, hcogUnit6] = binCoG(2700e-9, 23650, 60, 1695.1, fileName, savePath, runKey, 'Unit6_Payload', plotOn, isSave); %Pulling in the payload from the tipper bin inertia calculator
dLoad{:,6} = {'Chromium SG=2.7'};
mLoad{:,6} = [mUnit6]; %
xLoad{:,6} = [6.332/2+0.060]'; %
zLoad{:,6} = [hcogUnit6]'; %

%% --------------------------------------------------------------------------------------
%	Additional inputs
%----------------------------------------------------------------------------------------
Area = 3.761*2.750; %[m2] Frontal area
Ltot = 41790;          % [mm] ***need to confirm this
VehWidthLoad = 2600;   % [mm] total width - @ trailer axle width
VehWidthUnload = 2600; % [mm] total width - @ trailer axle width
SteerWidth = 2109+385; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))

%% --------------------------------------------------------------------------------------
%	Engine properties
%----------------------------------------------------------------------------------------
gears=[11.73 9.21 7.09 5.57 4.35 3.41 2.70 2.12 1.63 1.28 1.00 0.78]; % ATO3112D
eff_gear=[0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.96];
eff_diff=0.97;
dif=6.18; %diff ratio

gearsStart =     [11.73 9.21 7.09 5.57 4.35 3.41 2.70 2.12 1.63 1.28 1.00 0.78]; %Gears for startability - used if crawler gear available
eff_gearStart =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96]; %Gears for startability - used if crawler gear available
eff_diffStart = 0.97; % Diff ratio for startability - used if crawler gear available
difStart = 6.18; % Diff ratio for startability - used if dual differential ratio is available

Torquerpm=[900:100:1800]; %D16C610
TorqueNm=[2500 2800 2800 2800 2800 2800 2750 2670 2550 2100]; %D16C610

changeT=1700; %Change down rpm Max power 449 kW D16C610

rr = 0.521; % [m] rolling radius
Ie = 3.5; % [kg/m^2] engine inertia 
It = 72*14; % [kg/m^2] tyre inertia
gearshiftregime = 2; % 1 for every gear 2 for every second

%----------------------------------------------------------------------------------------
%	Calculated engine properties
%----------------------------------------------------------------------------------------

engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

if (max(TorqueNm)/2) > min(TorqueNm)
    engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
else
    engageTNm = min(TorqueNm);
end

%Displaying Engine Properties
% disp('-------------------------------------------------------------------------------------')
% disp('	Engine Characteristics')
% disp('-------------------------------------------------------------------------------------')
% RPM_vs_Nm = [Torquerpm' TorqueNm']
% Gear_vs_Efficiency = [gears' eff_gear']
% Diff_vs_Efficiency = [dif eff_diff]
% GearStart_vs_Efficiency = [gearsStart' eff_gearStart']
% DiffStart_vs_Efficiency = [difStart eff_diffStart] %End of display
% changeT
% engageTrpm
% engageTNm

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
    savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad,...
    Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
    Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
    isSRT, isTASP, isLST, isLSunT, isSave, isFullPBS, isLog, isRemoveMFiles, runNotes)
end

%% ---------------------------------------------------------------------------------------
%	PREVIOUS RUNS
%----------------------------------------------------------------------------------------

