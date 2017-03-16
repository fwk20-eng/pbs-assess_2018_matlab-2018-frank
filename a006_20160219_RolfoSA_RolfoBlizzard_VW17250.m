% Project Notes
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
%%
function a006_20160219_Rolfo_RolfoBlizzard_VW17250
clear; close all; %initialising data for each run
for loadConfig = 0:1%Goes through fully loaded & topdeck loaded
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
    %% 20141115-Wits-PBS-assess-SGCOAL-Afrit-45cubesidetipinterlink-Volvo_FM64T3HTX
    runNotes = {''};
    rev = 'engTest';
    projectKey = '20160219_RolfoBlizzard-VW17250'; %Include an underscore as the final character 
    date = '2016-10-31';
    rootPath = 'C:\Dropbox\Projects\P006_20160219_RolfoBlizzard-VW17250\Results\';%end with a \ ALWAYS. This is where the file will be saved
    runsPath = 'C:\Dropbox\witsPBS\Runs';
    %% Generating project folders/filenames
    switch loadConfig
        case 0
            matModKey = '_FL';
            savePath = sprintf('%s%s%s%s',rootPath, date, '_FL_v', rev);
            runKey = sprintf('%s%s%s',projectKey,'_FL_v', rev);
        case 1
            matModKey = '_TD';
            savePath = sprintf('%s%s%s%s',rootPath, date, '_TD_v', rev);
            runKey = sprintf('%s%s%s',projectKey,'_TD_v',rev);
    end
    fileName = strcat(runKey, '_summary.xlsx');
    checkOverwrite(savePath, fileName);%Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
    %% Combination configuration
    Ldesired = 1; %pbs level desired
    groupingHeadings = {'steer' 'drive' 'trailer'}; %label the axle groups
    grouping = {[1]; [2]; [3:4]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
    loadshare1 = [1 1 0.5 0.5]; % normal loadsharing numbers
    loadshare2 = [1 1 0.5 0.5]; % startability loadsharing numbers
    mAxle = [750 1200 650 650];
    xAxle = [0 3.56 8.65 10.35]; % distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
    zAxle = [0.487 0.487 0.376 0.376]; % trucksim model
    Ndrive = [2]; % driven axles
    nSteer = 1; % number of steer axles for stfd
    rollCoupled = [true];
    loadCoupled = [true];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
    %% Hitch Inputs (Longitudinal position from steer axle and height from floor)
    l = [3.110];
    h = [1.300];
    %% Sprung Mass and CoG for Lead and Trailer units
    mChas = [3695 7500]; %
    xChas = [0.896 4.68667]; %
    zChas = [1.264 1.47429]; %
    %% Unit 1 payload mass and CoG
    dLoad{:,1} = {'Driver' 'Fuel'};
    mLoad{:,1} = [75 399.4]'; %
    xLoad{:,1} = [-0.218 3.5515]'; %it is identical referencing to trucksim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
    zLoad{:,1} = [1.815 0.5916]'; %
    %% Unit 2 payload mass and CoG
    switch loadConfig
        case 0 % fully loaded
            dLoad{:,2} = {'Full Load'};
            mLoad{:,2} = [13417]; %
            xLoad{:,2} = [6.660]'; %
            zLoad{:,2} = [2.223]'; %
        case 1 % topdeck loaded
            dLoad{:,2} = {'Top Deck Load'};
            mLoad{:,2} = [7914]; %
            xLoad{:,2} = [5.699]'; %
            zLoad{:,2} = [3.182]'; %
    end
%% --------------------------------------------------------------------------------------
%	Additional inputs
%----------------------------------------------------------------------------------------
    Area = 2.507*4.590;
    Ltot = 19148;          % [mm] see the generated GA
    VehWidthLoad = 2550;   % [mm] total width - @ trailer axle width
    VehWidthUnload = 2550; % [mm] total width - @ trailer axle width
    SteerWidth = 2428; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
%% --------------------------------------------------------------------------------------
%	Engine properties
%----------------------------------------------------------------------------------------
    gears = [8.03 5.06 3.09 1.96 1.31 1];
    eff_gear = [0.96 0.96 0.96 0.96 0.96 0.96];
    eff_diff = 0.97;
    dif = 5.59; %standard diff ratio
    
    gearsStart = gears; %Gears for startability - used if crawler gear available
    eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
    eff_diffStart = 0.97; %Diff ratio for startability - used if dual differential
    difStart = 5.59; %Diff ratio for startability - used if dual differential
   
    Torquerpm = [900 1100 1300 1500 1600 1700 1900 2100 2300 2500];
    TorqueNm =  [624 835 900 900 900 888 846 786 739 725];
    
    rr = 0.521; %rolling radius m
    Ie = 2.75; %engine inertia kg/m^2
    It = 14*14; %tyre inertia kg/m^2
    gearshiftregime = 2; % 1 for every gear 2 for every second
    
    changeT = 2500; %Torque where torque*rpm is max
%----------------------------------------------------------------------------------------
%	Calculated engine properties
%----------------------------------------------------------------------------------------
    engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve
    
    if (max(TorqueNm)/2) < min(TorqueNm)
        engageTNm = max(TorqueNm)/2; %Torque engagement Nm - half of maximum torque as an estimate unless the min torque is lower than this
    else
        engageTNm = min(TorqueNm);
    end
%% --------------------------------------------------------------------------------------
%	Setting matlab keys for run
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
            savePath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad,...
            Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
            Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
            isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isRemoveMFiles, runNotes);   
end
end

%% PREVIOUS RUNS
