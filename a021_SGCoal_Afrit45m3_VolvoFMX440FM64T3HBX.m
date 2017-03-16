%% ---------------------------------------------------------------------------------------
%	PROJECT NOTES
%----------------------------------------------------------------------------------------

% Some of the info below still needs to be confirmed by Volvo.
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
%% ---------------------------------------------------------------------------------------
%	POST PROCESS
%----------------------------------------------------------------------------------------
function a021_SGCoal_Afrit45m3_VolvoFMX440FM64T3HBX
%% --------------------------------------------------------------------------------------
%	Booleans
%----------------------------------------------------------------------------------------
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked

isBus = 0; % Set 1 if bus **Must add dangerous goods
isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)

isPBS =         1;      isSave =   1;     plotOn =        1;
isFullPBS =     1;      isLog =    1;     plotSummary =   1; %If not full PBS, plotSummary is disabled 
isAxleLoads =   1;
      
isLST =     0;  isYawD =  0;  isHSTO = 0;   isLong =  0;
isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   1;

isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder

%% --------------------------------------------------------------------------------------
%	P021-Wits-PBS-assess-SGCOAL-Afrit-45cubesidetipinterlink-Volvo_FM64T3HBX
%----------------------------------------------------------------------------------------
rev = 'SATBCopyChk'
projectKey = 'P021_sgCoal-Afrit45m3-VolvoFM64T3HBX'; %Include an underscore as the final character 
rootPath = 'C:\Dropbox\PBS Technical Library\3 Combinations\P021_SGCoal-Afrit45m3STI-VolvoFMX440FM64T3HBX\Results\'; %end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Dropbox\witsPBS\Runs';
%% --------------------------------------------------------------------------------------
%	Run Details
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp(strcat('	Run Notes for run titled: ', rev))
disp('-------------------------------------------------------------------------------------')

runNotes = {'--v2--';...
            '--> Updated hitch height to 1392 mm as per FM440 FM64T3HBX {pm_64tt_volvo_fm440fm64t3hbx_weightDimensionCalc_dsc}'
            '--> Hitch position updated to 1425 mm as per 50 mm increments allowed with {pm_64tt_volvo_fm440fm64t3hbx_weightDimensionCalc_dsc} as the baseline position'
            '-> 1920 mm trailer track width - As discussed with York (Albert) and Afrit (Gerrit)';...
            '-> Payload found @ maxiumum volume for Max SG @ 175 mm below top maximum load height';...
            '-> 605 N/mm spring stiffness';...
            '-> Changed to FSTAB 3 and stiffer leaf spring';...
            '-> RSTAB3 stabiliser on drive axle group';...
            '-> RADD-BR suspension model';...
            '-> Fixed ChangeT of 1897 to 1631'...
            } %Do not suppress
%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------
savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_v', rev);
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

mAxle = [750 1300 1300 967*ones(1,3) 967*ones(1,3)];
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
l = [(3.375+1*0.05) 8.840]; % Longitudinal position from steer axle
h = [1.399 1.320]; % Height from floor

%% --------------------------------------------------------------------------------------
%	Sprung Mass and CoG for Lead and Trailer units
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Sprung Mass and CoG for Lead and Trailer units')
disp('-------------------------------------------------------------------------------------')
mChas = [6550 4400 3950]; %
xChas = [0.949 5.269 3.806]; %
zChas = [1.200 1.533 1.615]; %

%% --------------------------------------------------------------------------------------
%	Unit 1 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 1 payload mass and CoG')
disp('-------------------------------------------------------------------------------------')
dLoad{:,1} = {}; % Driver/Fuel is included in sprung mass hence no additional payload
uLoad{:,1} = [0]; % 0 - remove for unladen condition
mLoad{:,1} = []; %
xLoad{:,1} = []; % It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
zLoad{:,1} = []; %

%% --------------------------------------------------------------------------------------
%	Unit 2 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 2: Leader Payload')
disp('-------------------------------------------------------------------------------------')

% [mLead, hcogLead] = binCoG_Afrit45m3(1013e-9, 24804, -100, (1621-133), fileName, savePath, runKey, 'Leader_Payload', plotOn, isSave); %Loaded to max
[mLead, hcogLead] = binCoG_Afrit45m3(1184e-9, 24804, -100, (1621-133), fileName, savePath, runKey, 'Leader_Payload', plotOn, isSave); %Loaded to 200 mm from top
% [mLead, hcogLead] = binCoG_Afrit45m3(800e-9, 19590, -100, (1621-133), fileName, savePath, runKey, 'Leader_Payload', plotOn, isSave); %Load limit for 0.8SG
% [mLead, hcogLead] = binCoG_Afrit45m3(900e-9, 21070, -100, (1621-133), fileName, savePath, runKey, 'Leader_Payload', plotOn, isSave); %Load limit for 0.9SG

dLoad{:,2} = {'Coal'};
uLoad{:,2} = [0]; %0 - remove for unladen condition
mLoad{:,2} = [mLead]; %
xLoad{:,2} = [3.500-0.1]'; %
zLoad{:,2} = [hcogLead]'; %

%% --------------------------------------------------------------------------------------
%	Unit 3 payload mass and CoG
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Unit 3: Follower Payload')
disp('-------------------------------------------------------------------------------------')

% [mFollow, hcogFollow] = binCoG_Afrit45m3(1008e-9, 24677, 465, (1621-133), fileName, savePath, runKey, 'Follower_Payload', plotOn, isSave); %Loaded to max
[mFollow, hcogFollow] = binCoG_Afrit45m3(1178e-9, 24677, 465, (1621-133), fileName, savePath, runKey, 'Follower_Payload', plotOn, isSave); %Loaded to 200 mm from top
% [mFollow, hcogFollow] = binCoG_Afrit45m3(800e-9, 19590, 465, (1621-133), fileName, savePath, runKey, 'Follower_Payload', plotOn, isSave); %Load limit for 0.8SG
% [mFollow, hcogFollow] = binCoG_Afrit45m3(900e-9, 21070, 465, (1621-133), fileName, savePath, runKey, 'Follower_Payload', plotOn, isSave); %Load limit for 0.9G

dLoad{:,3} = {'Coal'};
uLoad{:,3} = [0]; %0 - remove for unladen condition
mLoad{:,3} = [mFollow]; %
xLoad{:,3} = [3.500+0.465]'; %
zLoad{:,3} = [hcogFollow]'; %

%% --------------------------------------------------------------------------------------
%	Additional inputs
%----------------------------------------------------------------------------------------
Area = 3.431*2.600; %[m2] Frontal area
Ltot = 21574;          % [mm] ***need to confirm this
VehWidthLoad = 2600;   % [mm] total width - @ trailer axle width
VehWidthUnload = 2600; % [mm] total width - @ trailer axle width
SteerWidth = 2494; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))

%% --------------------------------------------------------------------------------------
%	Engine properties
%----------------------------------------------------------------------------------------
gears =     [14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00];
eff_gear =  [0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96];
eff_diff = 0.97; % standard diff ratio
dif = 3.09; % standard diff ratio

gearsStart =     [19.38  14.94	11.28	9.04	7.09	5.54	4.35	3.44	2.7     2.08	1.63	1.27	1.00]; %Gears for startability - used if crawler gear available
eff_gearStart =  [0.96   0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96]; %Gears for startability - used if crawler gear available
eff_diffStart = 0.97; % Diff ratio for startability - used if crawler gear available
difStart = 3.09; % Diff ratio for startability - used if dual differential ratio is available

Torquerpm = [600	621		688		749		810		856		901		929		965		996		1053	1394	1461	1540	1631	1714	1811	1860	1911	1951	1997	2033	2085];
TorqueNm =  [1273	1305	1404	1499	1601	1704	1803	1893	1996	2099	2201	2205	2095	1996	1897	1803	1700	1601	1499	1404	1301	1203	1100];

changeT = 1631;%1897; % Torque where torque*rpm is max

rr = 0.521; % [m] rolling radius
Ie = 2.75; % [kg/m^2] engine inertia 
It = 34*14; % [kg/m^2] tyre inertia
gearshiftregime = 2; % 1 for every gear 2 for every second

%----------------------------------------------------------------------------------------
%	Calculated engine properties
%----------------------------------------------------------------------------------------

engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve

if (max(TorqueNm)/2) < min(TorqueNm)
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
            savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
            Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
            Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
            isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isLog, isRemoveMFiles, runNotes);   
end

%% ---------------------------------------------------------------------------------------
%	PREVIOUS RUNS
%----------------------------------------------------------------------------------------

