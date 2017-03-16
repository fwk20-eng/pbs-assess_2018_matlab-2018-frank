% Project Notes
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
%%
function a007_RolfoSA_RolfoBlizzard_VW19320
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked & initialising data for each run & setting format of command window output
%% --------------------------------------------------------------------------------------
%	Setting configurations run (0 - Fully loaded; 1 - Topdeck loaded)
%----------------------------------------------------------------------------------------
for loadConfig = 0:1
%% --------------------------------------------------------------------------------------
%	Booleans
%----------------------------------------------------------------------------------------
isBus = 0; % Set 1 if bus **Must add dangerous goods
isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)

isPBS =         1;      isSave =   1;     plotOn =        1;
isFullPBS =     1;      isLog =    1;     plotSummary =   1; %If not full PBS, plotSummary is disabled 
isAxleLoads =   1;
      

isLST =     0;  isYawD =  0;  isHSTO = 0;   isLong =  1;
isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;

isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder
%% Unique variables
KS = 0.2; %[m] - Kingpin shift relative to original position

%% --------------------------------------------------------------------------------------
%	P007-Wits-PBS-assess-RolfoSA-RolfoBlizzard-VW19.320_KingpinShift
%----------------------------------------------------------------------------------------
rev = 'v-KS522-2500A-FO-hh';
projectKey = 'P007_RolfoBlizzard-VW19320';
rootPath = 'C:\Dropbox\PBS Technical Library\3 Combinations\P007_RolfoBlizzard_VWConstellation19.320\Results\';%end with a \ ALWAYS. This is where the file will be saved
runsPath = 'C:\Dropbox\witsPBS\Runs';
%% --------------------------------------------------------------------------------------
%	Run Details
%----------------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------------')
disp('	Run Notes')
disp('-------------------------------------------------------------------------------------')
runNotes = {'hh - Ensuring hitch height of 1233 in reference points makes a difference';...
            'KS - Kingpin Shift';...
            'Shifted hitch position on prime mover to 522 mm forward of the rear drive axle';...
            'Kingpin position on Rolfo Blizzard shifted 200 mm forward';...
            'Using vehicles with 2500 kg mass and front 2 vehicles limited';...
            'Changed ChangeT to 2200 rpm as per discussion with FK today 2016-12-05 ... this needs to be verified with him!';...
            'FO - Front overhang increased by 250 mm - Maximum overhang to increment of 50 mm, limited by MoD'} %Do not suppress
%% --------------------------------------------------------------------------------------
%	Generating project folders/filenames
%----------------------------------------------------------------------------------------         
    switch loadConfig
        case 0
            matModKey = '_FL';
            savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_FL_', rev);
            runKey = sprintf('%s%s%s',projectKey,'_FL_', rev);
        case 1
            matModKey = '_TD';
            savePath = sprintf('%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_TD_', rev);
            runKey = sprintf('%s%s%s',projectKey,'_TD_',rev);
    end
    fileName = strcat(runKey, '_summary.xlsx');
    
    if isSave 
        checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
    end
%% --------------------------------------------------------------------------------------
%	Combination configuration
%----------------------------------------------------------------------------------------
    Ldesired = 1; %pbs level desired
    groupingHeadings = {'steer' 'drive' 'trailer'}; %label the axle groups
    grouping = {[1]; [2]; [3:4]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
    loadshare1 = [1 1 0.5 0.5]; % [%] normal loadsharing numbers
    loadshare2 = [1 1 0.5 0.5]; % [%] startability loadsharing numbers
    mAxle = [750 1200 650 650]; % [kg]
    xAxle = [0 3.56 (8.65+KS) (10.35+KS)]; % [m]  distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
    zAxle = [0.487 0.487 0.376 0.376]; % [m] trucksim model
    Ndrive = [2]; % driven axles
    nSteer = 1; % number of steer axles for stfd
    rollCoupled = [true];
    loadCoupled = [true];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
%% --------------------------------------------------------------------------------------
%	Hitch Inputs (Longitudinal position from steer axle and height from floor)
%---------------------------------------------------------------------------------------- 
    l = [2.838]; % [m] [2.838] [2.938] [3.038]
    h = [1.233]; % [m]
%% --------------------------------------------------------------------------------------
%	Sprung Mass and CoG for Lead and Trailer units
%----------------------------------------------------------------------------------------
    mChas = [4450 7500]; %  [kg]
    xChas = [0.768 (4.68667+KS)]; % [m]
    zChas = [1.2 1.47429]; % [m]
%% --------------------------------------------------------------------------------------
%	Unit 1 payload mass and CoG
%----------------------------------------------------------------------------------------
    uLoad{:,1} = [1 1]'; %Set to 0 to remove payload in the unladen condition
    dLoad{:,1} = {'Driver' 'Fuel'};
    mLoad{:,1} = [75 399.4]'; % [kg]
    xLoad{:,1} = [-0.218 3.5515]'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
    zLoad{:,1} = [1.815 0.5916]'; % [m]
%% --------------------------------------------------------------------------------------
%	Unit 2 payload mass and CoG
%----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded
            vDescription =  {'Ford Expedition (Red.)' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition (Red.)' 'Ford Expedition' 'Ford Expedition'};                 
            vMass   =       [1695    2500    2500    1695   2500    2500]; % [kg] vMass   =       [2250     2638	2638    1432    2638    2638]; % [kg]
            vRx     =       [0.677    0.677   0.677   0.677   0.677   0.677]; % [m]
            vRy     =       [1.430    1.430   1.430   1.430   1.430   1.430]; % [m]
            vRz     =       [1.462    1.462   1.462   1.462   1.462   1.462]; % [m]
            vCoGx   =       [395      5680    11020   375     5630    11120] + KS*1000; % [mm], note KS is in [m]
            vCoGy   =       [0        0       0       0       0       0   ]; % [mm]
            vCoGz   =       [3300     3160    3085    1560    1170    1250]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Fully Laden'}; 
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]
            
%             uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
%             dLoad{:,2} = {'Fully Laden'}; 
%             mLoad{:,2} = [13417]'; % [kg]
%             xLoad{:,2} = [6.800]'; % [m]
%             zLoad{:,2} = [2.223]'; % [m]
            
            if isSave 
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'cc Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'Ford Expedition' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500      2500]; % [kg] vMass   =       [2638     2638      2638]; % [kg]
            vRx     =       [0.677    0.677     0.677]; % [m]
            vRy     =       [1.430    1.430     1.430]; % [m]
            vRz     =       [1.462    1.462     1.462]; % [m]
            vCoGx   =       [395      5680      11020] + KS; % [mm]
            vCoGy   =       [0        0         0    ]; % [mm]
            vCoGz   =       [3300     3160      3085]; % [mm]
            
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy, vCoGz, vPitch);
           
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Top Deck Load'}; 
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]
            
            if isSave 
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'cc Payload');
            end
    end
%% --------------------------------------------------------------------------------------
%	Additional inputs
%----------------------------------------------------------------------------------------
    Area = 2.507*4.590;
    Ltot = 19148;          % [mm] see the generated GA
    VehWidthLoad = 2550;   % [mm] total width - @ trailer axle width
    VehWidthUnload = 2550; % [mm] total width - @ trailer axle width
    SteerWidth = 2391; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
%% --------------------------------------------------------------------------------------
%	Engine properties
%----------------------------------------------------------------------------------------
    gears =     [16.41  13.8    11.28   9.49    7.76    6.53    5.43    4.57    3.59    3.02    2.47    2.08    1.7     1.43    1.19    1];
    eff_gear =  [0.96   0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96    0.96];
    eff_diff = 0.97;
    dif = 3.73; %diff ratio
    
    %Note there is no difference in startability gear/diff for the VW
    %19.320
    gearsStart = gears; %Gears for startability - used if crawler gear available
    eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
    eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
    difStart = dif; %Diff ratio for startability - used if dual differential
   
    Torquerpm = [800    900     1000    1100    1200    1300    1400    1500    1600    1700    1800    1900    2000    2100    2200];
    TorqueNm =  [690    873     1006    1108    1169    1240    1240    1240    1224    1206    1176    1133    1080    1036    976];
    
    rr = 0.509; %rolling radius m
    Ie = 2.75; %engine inertia kg/m^2
    It = 14*14; %tyre inertia kg/m^2
    gearshiftregime = 2; % 1 for every gear 2 for every second
    
    changeT = 2200; %Torque where torque*rpm is max

    %----------------------------------------------------------------------------------------
    %   Calculated engine properties
    %----------------------------------------------------------------------------------------
    engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve
    
    if (max(TorqueNm)/2) < min(TorqueNm)
        engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
    else
        engageTNm = min(TorqueNm);
    end

    %% --------------------------------------------------------------------------------------
    %   Setting matlab keys for run
    %----------------------------------------------------------------------------------------
    matKeyYawD = strcat('YawD', matModKey);
    matKeyRA = strcat('RA', matModKey);
    matKeyHSTO = strcat('RA', matModKey);
    matKeySRTt = strcat('Tilt', matModKey);
    matKeyTASP = strcat('TASP', matModKey);
    matKeyLSTurn = strcat('LST', matModKey);
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
PostProcessMultiChoice(plotOn, plotSummary, isBus, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,... 
            savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
            Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
            Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
            isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isLog, isRemoveMFiles, runNotes);   
end
end

%% PREVIOUS RUNS
