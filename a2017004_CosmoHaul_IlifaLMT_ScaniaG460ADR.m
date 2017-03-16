% Project Notes
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
%%
function a2017004_CosmoHaul_IlifaLMT_ScaniaG460ADR
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked & initialising data for each run & setting format of command window output
tic
%% --------------------------------------------------------------------------------------
%	Booleans
%----------------------------------------------------------------------------------------
isBus = 0; % Set 1 if bus **Must add dangerous goods
isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)
isDanGoods = 1;

isPBS =         1;      isSave =   0;     plotOn =       0;
isFullPBS =     0;      isLog =    0;     plotSummary =  0; %If not full PBS, plotSummary is disabled
isAxleLoads =   0;

isLST =     0;  isYawD =  0;  isHSTO = 0;   isLong =  1;
isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;

isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder

%% --------------------------------------------------------------------------------------
%	2017004_CosmoHaul_IlifaLMT_ScaniaG460ADR
%----------------------------------------------------------------------------------------
rev = 'F';
projectKey = '2017004_IlifaLMT-ScaniaG460ADR';
rootPath = 'C:\Dropbox\PBS\Projects\P2017004_CosmoHauliers-2AxleMoltenMetalCarrier-ScaniaG460ADR\Results\'; %end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Dropbox\witsPBS_2017-02-15\Runs';
%% --------------------------------------------------------------------------------------
%	Run Details
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Run Notes')
disp('-------------------------------------------------------------------------------------')
runNotes = {'Some parameters still TBC. Parameters have been verified in excel/matlab/trucksim and confirmed to be conservative';...
            'TLIN changed to 2600 to see the difference in results';...
            'Updated the drive ratio for the engine to 3.07 as per correspondance from Scania';...
    } %Do not suppress
%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_', rev);
runKey = sprintf('%s%s%s',projectKey,'_',rev);
fileName = strcat(runKey, '_summary.xlsx');

if isSave
    checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
end
%% --------------------------------------------------------------------------------------
%	Combination configuration
%----------------------------------------------------------------------------------------
Ldesired = 1; %PBS level desired
groupingHeadings = {'Steer' 'Drive' 'Trailer'}; %label the axle groups

grouping = {[1]; [2:3]; [4:5]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
loadshare1 = [1 0.5 0.5 0.5 0.5]; % [%] normal loadsharing numbers
loadshare2 = [1 0.5 0.5 0.5 0.5]; % [%] startability loadsharing numbers

mAxle = [600 1300 1300 817 817]; % [kg]
xAxle = [0 3.1 4.45 8.67 10.030]; % [m] distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
zAxle = [0.511 0.533 0.533 0.531 0.531]; % [m] trucksim model

Ndrive = [2:3]; % driven axles
nSteer = 1; % number of steer axles for stfd

nTyres = 18; % S(s).D(dd)-t(dd)
rr = 0.521; % [m] rolling radius of tyres

rollCoupled = [true];
loadCoupled = [true];

dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
%% --------------------------------------------------------------------------------------
%	Hitch Inputs (Longitudinal position from steer axle and height from	floor): using default Scania hitch position. This is still TBC
%----------------------------------------------------------------------------------------
l = [3.490]; % [m]
h = [1.250]; % [m]
%% --------------------------------------------------------------------------------------
%	Additional inputs: tl_2mc_LiquidMetalTransporter_GeneralArrangement_aia
%----------------------------------------------------------------------------------------
Area = 2.890*3.300;
Ltot = 15473;          % [mm]
VehWidthLoad = 3050;   % [mm] total width taken as conservative value FK used in original report
VehWidthUnload = 3050; % [mm] total width taken as conservative value FK used in original report
SteerWidth = 2382; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
%% --------------------------------------------------------------------------------------
%	Sprung Mass and CoG:
%----------------------------------------------------------------------------------------
mChas = [5530   6366]; %  [kg] ****The sprung mass of the Scania is still TBC**** pm_64tt_ScaniaG460LA_DocumentRolloverCurve_ece has been used as the source for now
xChas = [0.618  4.500]; % [m]
zChas = [1.909  1.800]; % [m]
%% --------------------------------------------------------------------------------------
%	Unit 1 payload mass and CoG
%----------------------------------------------------------------------------------------
uLoad{:,1} = [1 1 1]'; %Set to 0 to remove payload in the unladen condition
dLoad{:,1} = {'Driver'      '200L Fuel left'    '400L Fuel right'};
mLoad{:,1} = [75            166                 333]'; % [kg]
xLoad{:,1} = [-0.218        1.723               1.847]'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
zLoad{:,1} = [1.815         0.635               0.635]'; % [m]
%% --------------------------------------------------------------------------------------
%	Unit 2 payload mass and CoG: Liquid metal payload from original report by F.K
%----------------------------------------------------------------------------------------
uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
dLoad{:,2} = {'Liquid Metal Payload'};
mLoad{:,2} = [22612]'; % [kg]
xLoad{:,2} = [4.5]'; % [m]
zLoad{:,2} = [1.877]'; % [m]
%% --------------------------------------------------------------------------------------
%	Engine properties
% Engine: Scania DC13-106-460-Euro3 engine
% Gearbox: Scania GRS905 gearbox
%----------------------------------------------------------------------------------------
changeT = 1897; %RPM where power is max, change down RPM

gears =     [16.406	13.281	11.32	9.164	7.194	5.823	4.632	3.75	3.016	2.444	1.918	1.553	1.235	1];
eff_gear =  [0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97	0.97];
eff_diff = 0.97; %differential ratio
dif = 3.07; %differential ratio

gearsStart = gears; %Gears for startability - used if crawler gear available
eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
difStart = dif; %Diff ratio for startability - used if dual differential

Torquerpm = [1005	1356	1401	1465	1558	1603	1662	1771	1802	1897];
TorqueNm =  [2251	2251	2177	2100	2000	1951	1899	1800	1772	1700];
%----------------------------------------------------------------------------------------
%   Calculated engine properties
%----------------------------------------------------------------------------------------
Ie = 2.75; %engine inertia kg/m^2
It = nTyres*14; %tyre inertia kg/m^2

gearshiftregime = 2; % 1 for every gear 2 for every second

engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

if (max(TorqueNm)/2) < min(TorqueNm)
    engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
else
    engageTNm = min(TorqueNm);
end

%% --------------------------------------------------------------------------------------
%   Setting matlab keys for run
%----------------------------------------------------------------------------------------
matKeyYawD = 'YawD';
matKeyRA = 'RA';
matKeyHSTO = 'RA';
matKeySRTt = 'Tilt';
matKeyTASP = 'TASP';
matKeyLSTurn = 'LST';
matKeyLSTurnu = 'LSunT'; %unloaded is always the same in all cases

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
PostProcessMultiChoice(plotOn, plotSummary, isBus, isDanGoods, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,...
    savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
    Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
    Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
    isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isLog, isRemoveMFiles, runNotes);
toc
end

%% PREVIOUS RUNS
