% Project Notes
% -> Copied from Rolfo Superlong
% To Do:
%   [X] Update the combination variables
%   [X] Update the Paths to the correct project folders
%   [X] Update the engine parameters
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
%%
function a2017003_MAN_UnipowerFlexiporter_VW17250
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
    
    isPBS =         1;      isSave =   1;     plotOn =       1;
    isFullPBS =     1;      isLog =    1;     plotSummary =  1; %If not full PBS, plotSummary is disabled
    isAxleLoads =   1;
    
    
    isLST =     1;  isYawD =  0;  isHSTO = 0;   isLong =  0;
    isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;
    
    isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder
    
    %% --------------------------------------------------------------------------------------
    %	Q2017003-Wits-PBS-assess-MAN-UniPowerFlexiPorterMk2-VW17.250
    %----------------------------------------------------------------------------------------
    rev = 'H';
    projectKey = '2017003_UniPowerFlexiPorterMk2-VW17.250';
    rootPath = 'C:\Dropbox\PBS\Projects\P2017003_MAN-UnipowerFlexiporterMk2-VWConstellation17.250\Results\'; %end with a \ ALWAYS. This is where the file will be saved
    runsPath = 'C:\Dropbox\witsPBS_2017-02-15\Runs';
    %% --------------------------------------------------------------------------------------
    %	Run Details
    %----------------------------------------------------------------------------------------
    disp('-------------------------------------------------------------------------------------')
    disp('	Run Notes')
    disp('-------------------------------------------------------------------------------------')
    runNotes = {'Baseline VW17.250';...
                'Baseline FlexiPorter Mk2 from VolvoFM330 project';...
                'FlexiPorter Mk2 reference points updated to match drawing';...
                'Updated the wheel centre heights to be at the design load';...
                'Updated the wheel centre heights to be at the design load for the trailer';...
                'Updated the wheel centre heights to be at the design load for the trailer in Matlab';...
                        } %Do not suppress
    %% --------------------------------------------------------------------------------------
    %	Generating project folders/filenames
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0
            matModKey = '_FL';
            savePath = sprintf('%s%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_', rev, '_FL');
            runKey = sprintf('%s%s%s',projectKey,'_FL_', rev);
        case 1
            matModKey = '_TD';
            savePath = sprintf('%s%s%s%s%s',rootPath, datestr(now,'yyyy-mm-dd'), '_', rev, '_TD');
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
    groupingHeadings = {'Steer' 'Drive' 'Trailer'}; %label the axle groups
    grouping = {[1]; [2]; [3:4]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
    loadshare1 = [1 1 0.5 0.5]; % [%] normal loadsharing numbers
    loadshare2 = [1 1 0.5 0.5]; % [%] startability loadsharing numbers
    mAxle = [750 1200 750 750]; % [kg]
    xAxle = [0 3.56 4.57 8.925 10.275]; % [m] distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp)
    zAxle = [0.520 0.533 0.438 0.438]; % [m] trucksim model
    Ndrive = [2]; % driven axles
    nSteer = 1; % number of steer axles for stfd
    rollCoupled = [true];
    loadCoupled = [true];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
    %% --------------------------------------------------------------------------------------
    %	Hitch Inputs (Longitudinal position from steer axle and height from floor)
    %----------------------------------------------------------------------------------------
    l = [3.110]; % [m]
    h = [1.300]; % [m]
    %% --------------------------------------------------------------------------------------
    %	Sprung Mass and CoG for Lead and Trailer units
    %----------------------------------------------------------------------------------------
    mChas = [3695       7367]; %  [kg]
    xChas = [0 .896     6.512]; % [m]
    zChas = [1.264      1.334]; % [m]
    %% --------------------------------------------------------------------------------------
    %	Unit 1 payload mass and CoG - Driver and fuel included in the 
    %----------------------------------------------------------------------------------------
    uLoad{:,1} = [1 1]'; %Set to 0 to remove payload in the unladen condition
    dLoad{:,1} = {'Driver'  'Fuel'};
    mLoad{:,1} = [75        399.4]'; % [kg]
    xLoad{:,1} = [-0.218    3.552]'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
    zLoad{:,1} = [1.815     0.5916]'; % [m]
    %% --------------------------------------------------------------------------------------
    %	Unit 2 payload mass and CoG
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded [Flexiporter mk2 load distribution.pdf]
            vDescription =  {'Ford Expedition' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500    2500      2500      2500    2500].*(2400/2500); % [kg]
            vRx     =       [0.677    0.677   0.677     0.677     0.677   0.677]; % [m]
            vRy     =       [1.430    1.430   1.430     1.430     1.430   1.430]; % [m]
            vRz     =       [1.462    1.462   1.462     1.462     1.462   1.462]; % [m]
            vCoGx   =       [-115     6720    11390     2575      5935    11325]; % [mm]
            vCoGy   =       [0        0       0         0         0       0]; % [mm]
            vCoGz   =       [3345     3425    3330      2195      1120    1330]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Fully Laden'};
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]            
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'FL Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'Ford Expedition' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500    2500].*(2400/2500); % [kg]
            vRx     =       [0.677    0.677   0.677]; % [m]
            vRy     =       [1.430    1.430   1.430]; % [m]
            vRz     =       [1.462    1.462   1.462]; % [m]
            vCoGx   =       [-115     6720    11390]; % [mm]
            vCoGy   =       [0        0       0]; % [mm]
            vCoGz   =       [3345     3425    3330]; % [mm]
            
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy, vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Top Deck Loaded Only'};
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'TD Payload');
            end
    end
    %% --------------------------------------------------------------------------------------
    %	Additional inputs
    %----------------------------------------------------------------------------------------
    Area = 2.600*4.600;    % [m] [Flexiporter mk2 load distribution_vw17.250.pdf]
    Ltot = 19396;          % [mm] [Flexiporter mk2 load distribution_vw17.250.pdf]
    VehWidthLoad = 2600;   % [mm] total width - @ trailer axle width
    VehWidthUnload = 2600; % [mm] total width - @ trailer axle width
    SteerWidth = 2428; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
    %% --------------------------------------------------------------------------------------
    %	Engine properties VW 17.250 with dual differential
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
