% Project Notes
%This edition is used to test out generating all of the inputs for the
%project in a single place, eliminating Excel from the process.
%%
function a2017004_CosmoHaul_IlifaLMT_ScaniaG460ADR_rptEdition
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked & initialising data for each run & setting format of command window output
%% --------------------------------------------------------------------------------------
%	Unit 1 Excel Inputs
%----------------------------------------------------------------------------------------
oneAxleGroupDescr =     {'Steer',   'Drive'}; %[-] description of each axle group
oneAxleGroupLoad =      {5340,      2981}; %[kg] load on each axle group
oneAxleGrouping =       {(1)        [2,      3]}; %[-] group the axles together if in an axle group
oneAxleDistr =          {(1)        [0.5,    0.5]}; %[-] load distribution for each axle in the axle group

oneAxlePowerDistr =     {(0)        [0.5,    0.5]};
oneDynLoadTransCoef =   {'N/A'      [0.5,    0.5]};
oneLoadTransBrakeTorq = {'N/A'      [0,      0]};
oneStaticLoadCoeff =    {'N/A'      [0.5,    0.5]};

oneAxleDescr =          {'Steer',   'Drive Front',    'Drive Rear'}; %[-] description of the axles
oneAxleUnsprung =       [600,        1300,            1300]; %[kg] unsprung mass of the axles
oneAxleX =              [0,          3.1,             4.45]; %[m] x location of the axles

oneSprungDescr =        'Unit 1';
oneR =                  [0.791, 1.802, 1.802]; %[m] Radius of gyration about the x y z axis
oneCoGy =               0; %[m] y position of the centre of gravity %oneCoGx is calculated based on the theoretical wheelbase
oneCoGz =               1.909; %[m] z position of the centre of gravity

steerTorque = '1/25 (Typical)';
maxPower = 20000; %[kW]

oneHitch = '5thWheel';

%	Unit 1 Suspension Kinematics
%----------------------------------------------------------------------------------------
oneSuspKin{1} = {   'Scania AM920';...%Suspension Manufacturer and Model
                    2;...%Spin Inertia
                    2.067;......%[m] Wheel centre distance
                    0;...%Lateral Coordinate of axle centre
                    '27 (above)';...%[mm] Roll centre (Y movement as a function of roll & jounce)
                    '-0.087 deg/deg'};%Steer/Roll coefficient
                
oneSuspKin{2} = {   'Scania ADA 1303';...%Suspension Manufacturer and Model
                    2;...%Spin Inertia
                    1.830;...%[m] Wheel centre distance
                    0;...%Lateral Coordinate of axle centre
                    '180 (below)';...%[mm] Roll centre (Y movement as a function of roll & jounce)
                    '-0.070 deg/deg'};%%Steer/Roll coefficient 

oneSuspKin{3} = {   'Scania ADA 1303';...%Suspension Manufacturer and Model
                    2;...%Spin Inertia
                    1.830;...%Wheel centre distance
                    0;...%Lateral Coordinate of axle centre
                    '180 (below)';...%[mm] Roll centre (Y movement as a function of roll & jounce)
                    '-0.070 deg/deg'};  
                
%	Unit 1 Compensation (Springs)
%----------------------------------------------------------------------------------------                    
oneSuspSpring{1} = {    'Scania AM920';...%Suspension Manufacturer and Model
                        'Steel';...%Suspension spring type
                        '387 N/mm 2000 N Friction';...%Suspension spring model
                        1/1};%Trailing arm (dist to spring / dist to axle) = spring compression/jounce ratio

oneSuspSpring{2} = {    'Scania ADA 1303';...%Suspension Manufacturer and Model
                        'Air';...%Suspension spring type
                        'Scania ADA 1303';...%Suspension spring model
                        1025/625};%Trailing arm (dist to spring / dist to axle) = spring compression/jounce ratio
                    
oneSuspSpring{3} = {    'Scania ADA 1303';...%Suspension Manufacturer and Model
                        'Air';...%Suspension spring type
                        'Scania ADA 1303';...%Suspension spring model
                        1025/625};%Trailing arm (dist to spring / dist to axle) = spring compression/jounce ratio
                                        
%	Unit 1 Compensation (Dampers)
%----------------------------------------------------------------------------------------                     
oneSuspDamp{1} = {  'Scania LV26';...%Suspension Manufacturer and Model
                    'Scania LV26';...%Model parameters
                    88;...%[deg] damper angle
                    1/1;...%Trailing arm (dist to damper / dist to axle)
                    '+250, -250'};%Jounce/Rebound stops
                
oneSuspDamp{2} = {  'Scania LH114';...%Suspension Manufacturer and Model
                    'Scania LH114';...%Model parameters
                    89;... %[deg] damper angle
                    856/625;...%Trailing arm (dist to damper / dist to axle)
                    '+250, -250'};%Jounce/Rebound stops

oneSuspDamp{3} = {  'Scania LH114';...%Suspension Manufacturer and Model
                    'Scania LH114';...%Model parameters
                    89;... %[deg] damper angle
                    856/625;...%Trailing arm (dist to damper / dist to axle)
                    '+250, -250'};%Jounce/Rebound stops
                
%	Unit 1 Compensation (Aux. roll moment)
%----------------------------------------------------------------------------------------
oneSuspAux = {3421, 13727, 13727};...%Auxiliary roll moment

%	Unit 1 Compensation (Suspension component track)
%----------------------------------------------------------------------------------------
oneSuspTrack{1} = { 800;...%Spring track
                    800;...%Damper track
                    800;...%Jounce stop track (usually matches the spring track)
                    800};%Rebound stop track (usually matches the damper track)

oneSuspTrack{2} = { 704;...%Spring track
                    961;...%Damper track
                    704;...%Jounce stop track (usually matches the spring track)
                    961};%Rebound stop track (usually matches the damper track)
                
oneSuspTrack{3} = { 704;...%Spring track
                    961;...%Damper track
                    704;...%Jounce stop track (usually matches the spring track)
                    961};%Rebound stop track (usually matches the damper track)
                    

%% --------------------------------------------------------------------------------------
%	Excel Calculations
%----------------------------------------------------------------------------------------
% Calculating the tare and sprung axle mass for each axle
%----------------------------------------------------------------------------------------
for i = 1:length(oneAxleGroupDescr)
    oneAxleTare{i} = oneAxleGroupLoad{i}.*oneAxleDistr{i};
end

oneAxleTare = cell2mat(oneAxleTare); %Converting back to a matrix to 
oneAxleSprung = oneAxleTare-oneAxleUnsprung;

% Calculating the sprung mass of the unit
%----------------------------------------------------------------------------------------
oneSprungMass = sum(oneAxleSprung);

% Calculating the Inertia of the unit
%----------------------------------------------------------------------------------------
oneI = oneSprungMass.*oneR.^2; % [kg.m^2] Moment of inertia about the x y z axis

% Calculating the CoGx based on the theoretical wheelbase
%----------------------------------------------------------------------------------------
oneWB = sum(cell2mat(oneAxleDistr).*oneAxleX); % Calculating the wheelbase

if length(oneAxleGrouping{1}) == 1
    oneCoGx = sum(oneAxleX.*oneAxleSprung)/oneSprungMass;
else
    oneCoGx = 'Need to add code for multiple steer axles';
end

oneCoG = [oneCoGx, oneCoGy, oneCoGz]; %[m] Centre of gravity about the x y z axis (y = 0 by default)


% 
% %% --------------------------------------------------------------------------------------
% %	Booleans
% %----------------------------------------------------------------------------------------
% isBus = 0; % Set 1 if bus **Must add dangerous goods
% isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)
% 
% isPBS =         1;      isSave =   1;     plotOn =       1;
% isFullPBS =     1;      isLog =    1;     plotSummary =  1; %If not full PBS, plotSummary is disabled
% isAxleLoads =   1;
% 
% 
% isLST =     1;  isYawD =  0;  isHSTO = 0;   isLong =  0;
% isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;
% 
% isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder
% 
% %% --------------------------------------------------------------------------------------
% %	2017004_CosmoHaul_IlifaLMT_ScaniaG460ADR
% %----------------------------------------------------------------------------------------
% rev = '01';
% projectKey = '2017004_IlifaLMT-ScaniaG460ADR';
% rootPath = 'C:\Dropbox\PBS\Projects\P2017004_CosmoHauliers-2AxleMoltenMetalCarrier-ScaniaG460ADR\Results\'; %end with a \ ALWAYS. This is where the file will be saved
% runsPath = 'C:\Dropbox\witsPBS_2017-02-15\Runs';
% %% --------------------------------------------------------------------------------------
% %	Run Details
% %----------------------------------------------------------------------------------------
% disp('-------------------------------------------------------------------------------------')
% disp('	Run Notes')
% disp('-------------------------------------------------------------------------------------')
% runNotes = {'Place run notes here';...
%     } %Do not suppress
% %% --------------------------------------------------------------------------------------
% %	Generating project folders/filenames
% %----------------------------------------------------------------------------------------
% savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_', rev);
% runKey = sprintf('%s%s%s',projectKey,'_',rev);
% fileName = strcat(runKey, '_summary.xlsx');
% 
% if isSave
%     checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
% end
% %% --------------------------------------------------------------------------------------
% %	Combination configuration
% %----------------------------------------------------------------------------------------
% Ldesired = 1; %PBS level desired
% groupingHeadings = {'Steer' 'Drive' 'Trailer'}; %label the axle groups
% 
% grouping = {[1]; [2:3]; [4:5]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
% loadshare1 = [1 0.5 0.5 0.5 0.5]; % [%] normal loadsharing numbers
% loadshare2 = [1 0.5 0.5 0.5 0.5]; % [%] startability loadsharing numbers
% 
% mAxle = [600 1300 1300 817 817]; % [kg]
% xAxle = [0 3.1 4.45 8.67 10.030]; % [m] distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
% zAxle = [0.510 0.533 0.533 0.531 0.531]; % [m] trucksim model
% 
% Ndrive = [2:3]; % driven axles
% nSteer = 1; % number of steer axles for stfd
% 
% rollCoupled = [true];
% loadCoupled = [true];
% 
% dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
% %% --------------------------------------------------------------------------------------
% %	Hitch Inputs (Longitudinal position from steer axle and height from floor)
% %----------------------------------------------------------------------------------------
% l = [3.490]; % [m]
% h = [1.250]; % [m]
% %% --------------------------------------------------------------------------------------
% %	Sprung Mass and CoG
% %----------------------------------------------------------------------------------------
% mChas = [5121   6366]; %  [kg] ****The sprung mass of the Scania is still TBC****
% xChas = [0.281  4.500]; % [m]
% zChas = [1.909  1.800]; % [m]
% %% --------------------------------------------------------------------------------------
% %	Unit 1 payload mass and CoG - Driver and fuel included in the
% %----------------------------------------------------------------------------------------
% uLoad{:,1} = [1 1 1]'; %Set to 0 to remove payload in the unladen condition
% dLoad{:,1} = {'Driver'      '200L Fuel left'    '400L Fuel right'};
% mLoad{:,1} = [75            166                 333]'; % [kg]
% xLoad{:,1} = [-0.218        1.723               1.847]'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
% zLoad{:,1} = [1.815         0.635               0.635]'; % [m]
% %% --------------------------------------------------------------------------------------
% %	Unit 2 payload mass and CoG
% %----------------------------------------------------------------------------------------
% uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
% dLoad{:,2} = {'Leader Fully Laden'};
% mLoad{:,2} = [totalMass]'; % [kg]
% xLoad{:,2} = [CoGx*0.001]'; % [m]
% zLoad{:,2} = [CoGz*0.001]'; % [m]
% %% --------------------------------------------------------------------------------------
% %	Additional inputs
% %----------------------------------------------------------------------------------------
% Area = 2.890*3.300;
% Ltot = 29480;          % [mm] see the PBS summary with trailer configuration B
% VehWidthLoad = 2550;   % [mm] total width - @ trailer axle width
% VehWidthUnload = 2550; % [mm] total width - @ trailer axle width
% SteerWidth = 2494; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
% %% --------------------------------------------------------------------------------------
% %	Engine properties Volvo AT2612F Gearbox / D13A400 Engine
% %----------------------------------------------------------------------------------------
% gears =     [14.94 11.28 9.04 7.09 5.54 4.35 3.44 2.7 2.08 1.63 1.27 1];
% eff_gear =  [0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97];
% eff_diff = 0.97;
% dif = 3.090; %diff ratio
% 
% %Note there is no difference in startability gear/diff for the VW
% %19.320
% gearsStart = gears; %Gears for startability - used if crawler gear available
% eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
% eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
% difStart = dif; %Diff ratio for startability - used if dual differential
% 
% Torquerpm = [600 698 769 836 903 950 998 1045 1399 1466 1553 1663 1773 1844 1891 1943 1986  2041 2088];
% TorqueNm =  [1268 1402 1504 1601 1708 1805 1901 2003 2003 1901 1805 1703 1601 1499 1402  1300 1199 1097 1000];
% 
% rr = 0.509; %rolling radius m
% Ie = 2.75; %engine inertia kg/m^2
% It = 14*14; %tyre inertia kg/m^2
% gearshiftregime = 2; % 1 for every gear 2 for every second
% 
% changeT = 1773; %Torque where torque*rpm is max
% 
% %----------------------------------------------------------------------------------------
% %   Calculated engine properties
% %----------------------------------------------------------------------------------------
% engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve
% 
% if (max(TorqueNm)/2) < min(TorqueNm)
%     engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
% else
%     engageTNm = min(TorqueNm);
% end
% 
% %% --------------------------------------------------------------------------------------
% %   Setting matlab keys for run
% %----------------------------------------------------------------------------------------
% matKeyYawD = strcat('YawD', matModKey);
% matKeyRA = strcat('RA', matModKey);
% matKeyHSTO = strcat('RA', matModKey);
% matKeySRTt = strcat('Tilt', matModKey);
% matKeyTASP = strcat('TASP', matModKey);
% matKeyLSTurn = strcat('LST', matModKey);
% matKeyLSTurnu = 'LSunT'; %unloaded is always the same in all cases
% 
% %% --------------------------------------------------------------------------------------
% %	Run-checks, resetting booleans if necessary
% %----------------------------------------------------------------------------------------
% if isFullPBS == 1 %Turns on all PBS manoeuvres
%     isLST = 1;      isYawD = 1;     isHSTO = 1;     isLong = 1;
%     isLSunT = 1;    isRA = 1;       isTASP = 1;     isSRT = 1;
% end
% 
% if ~isFullPBS
%     plotSummary = false; %Turns off plot summary if not a full PBS assessment
% end
% 
% %% --------------------------------------------------------------------------------------
% %	Passing variables to PostProcess
% %----------------------------------------------------------------------------------------
% PostProcessMultiChoice(plotOn, plotSummary, isBus, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,...
%     savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
%     Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
%     Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
%     isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isLog, isRemoveMFiles, runNotes);
end

%% PREVIOUS RUNS
