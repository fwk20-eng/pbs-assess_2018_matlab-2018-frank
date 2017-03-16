% Project Notes

%%
function a025_20160930_Lohr_LongCombo_VolvoFH440FH64T3HA
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked & initialising data for each run & setting format of command window output
%% --------------------------------------------------------------------------------------
%	Setting configurations run (0 - Fully loaded; 1 - Topdeck loaded)
%----------------------------------------------------------------------------------------
for loadConfig = 1:1
    %% --------------------------------------------------------------------------------------
    %	Booleans
    %----------------------------------------------------------------------------------------
    isBus = 0; % Set 1 if bus **Must add dangerous goods
    isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)
    
    isPBS =         1;      isSave =   1;     plotOn =        1;
    isFullPBS =     1;      isLog =    1;     plotSummary =   1; %If not full PBS, plotSummary is disabled
    isAxleLoads =   1;
    
    
    isLST =     1;  isYawD =  0;  isHSTO = 0;   isLong =  0;
    isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;
    
    isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder
    
    %% --------------------------------------------------------------------------------------
    %	P025-Wits-PBS-assess-LohrLongCombo_VolvoFH64T3HA
    %----------------------------------------------------------------------------------------
    % v_1A 10 2500 kg vehicles
    % v_1B reduced vehicles 3 & 6 to 2100 kg
    % v_1C used above to iterate to 3 & 6 to be 2075.3 kg
    % v_1D DoM was 0.308059692382813 carried vehicle 600 forward.
    % v_1E Repeated but with carried vehicle 550 forward DoM 0.278387069702148   
    % v_1F used above to iterate to vehicle 500 forward DoM 0.248958587646484
    % v_1G full PBS
    % v_2A 10 2500 kg vehicles
    % v_2B reduced vehicles 3 & 6 to 2425 kg
    % v_2C used above to iterate to 3 & 6 to be 2437.9 kg    
    % v_2D full PBS analysis        
    rev = 'v_2D';
    projectKey = 'P025_LohrLongCombo_VolvoFH64T3HA';
    rootPath = 'C:\Dropbox\PBS Technical Library\3 Combinations\P025_LohrLongCombo_VolvoFH64T3HA\Results\';%end with a \ ALWAYS. This is where the file will be saved
    runsPath = 'C:\Dropbox\trucksimDatabase_JAD\Runs';
    %% --------------------------------------------------------------------------------------
    %	Run Details
    %----------------------------------------------------------------------------------------
    disp('-------------------------------------------------------------------------------------')
    disp('	Run Notes')
    disp('-------------------------------------------------------------------------------------')
    runNotes = {...
                %'Axle loads only first iteraion: 2500 kg vehicles';...
                %'Axle loads only second iteration: Reduce vehicle mass of carried vehicles 3 and 6 to 2425 kg';...
                %'Axle loads only third iteration: Reduce vehicle mass of carried vehicles 3 and 6 to 2437.9 kg';...
                'Full PBS fourth iteration: 1 vehicle 500 mm forward (2185) and 1 vehicle 500 back (1946) on leader ';...
                '';...
                        } %Do not suppress
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
    Ldesired = 2; %pbs level desired
    groupingHeadings = {'steer' 'drive' 'leader trailer' 'follower trailer'}; %label the axle groups
    grouping = {[1]; [2:3]; [4:5]; [6:7]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
    loadshare1 = [1 0.5 0.5 0.5 0.5 0.5 0.5]; % [%] normal loadsharing numbers
    loadshare2 = [1 0.5 0.5 0.5 0.5 0.5 0.5]; % [%] startability loadsharing numbers
    mAxle = [750 1300 1300 900 900 900 900]; % [kg]
    xAxle = [0 3.2 4.57 9.1-1.31/2 9.1+1.31/2 9.1-1.31/2 9.1+1.31/2]; % [m] distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp) Using Follower 2A
    zAxle = [0.497 0.507 0.507 0.363 0.363 0.363 0.363]; % [m] trucksim model
    Ndrive = [2:3]; % driven axles
    nSteer = 1; % number of steer axles for stfd
    rollCoupled = [true true];
    loadCoupled = [true true];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
    %% --------------------------------------------------------------------------------------
    %	Hitch Inputs (Longitudinal position from steer axle and height from floor)
    %----------------------------------------------------------------------------------------
    l = [3.375 11.650]; % [m]
    h = [1.250 0.470]; % [m]
    %% --------------------------------------------------------------------------------------
    %	Sprung Mass and CoG for Lead and Trailer units
    %----------------------------------------------------------------------------------------
    mChas = [5822   7950    6900]; %  [kg]
    xChas = [0.893  5.952   6.820]; % [m]
    zChas = [1.2    1.280   1.280]; % [m]
    %% --------------------------------------------------------------------------------------
    %	Unit 1 payload mass and CoG
    %----------------------------------------------------------------------------------------
    uLoad{:,1} = [1 1]'; %Set to 0 to remove payload in the unladen condition
    dLoad{:,1} = {'75kg Driver (cab over)' '825 litre diesel'};
    mLoad{:,1} = [75 686]'; % [kg]    
    xLoad{:,1} = [-0.218 1.902]'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
    zLoad{:,1} = [1.815 0.653]'; % [m]    
    %% --------------------------------------------------------------------------------------
    %	Unit 2 payload mass and CoG
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded
            %vDescription =  {'SUV' 'SUV' '2075.3 kg SUV' 'SUV' 'SUV' '2075.3 kg SUV'};
            %vMass   =       [2500     2500    2075.3    2500  2500    2075.3]; % [kg] 
            vDescription =  {'SUV' 'SUV' 'SUV' 'SUV' 'SUV' 'SUV'};
            vMass   =       [2500     2500    2437.9  2500  2500    2437.9]; % [kg] 
            vRx     =       [0.677    0.677   0.677   0.677 0.677   0.677 ]; % [m]
            vRy     =       [1.430    1.430   1.430   1.430 1.430   1.430 ]; % [m]
            vRz     =       [1.462    1.462   1.462   1.462 1.462   1.462 ]; % [m]
            vCoGx   =       [-104     5229    10558   -70   4742    11450 ]; % [mm]
            vCoGy   =       [0        0       0       0     0       0     ]; % [mm]
            vCoGz   =       [3570     3587    3608    2021  1218    1631  ]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Leader Laden'};
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]            
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Leader FL Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'SUV' 'SUV' 'SUV' };
            vMass   =       [2500     2500    2500    ]; % [kg] 
            vRx     =       [0.677    0.677   0.677   ]; % [m]
            vRy     =       [1.430    1.430   1.430   ]; % [m]
            vRz     =       [1.462    1.462   1.462   ]; % [m]
            vCoGx   =       [-104     5229    10558   ]; % [mm]
            vCoGy   =       [0        0       0       ]; % [mm]
            vCoGz   =       [3570     3587    3608    ]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy, vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Leader Top Deck Load'};
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Leader TD Payload');
            end
    end
    
    %% --------------------------------------------------------------------------------------
    %	Unit 3 payload mass and CoG
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded
            vDescription =  {'SUV' 'SUV' 'SUV' 'SUV'};
            vMass   =       [2500     2500    2500    2500    ]; % [kg]
            vRx     =       [0.677    0.677   0.677   0.677   ]; % [m]
            vRy     =       [1.430    1.430   1.430   1.430   ]; % [m]
            vRz     =       [1.462    1.462   1.462   1.462   ]; % [m]
            vCoGx   =       [6240     11633   6285    11678   ]; % [mm]
            vCoGy   =       [0        0       0       0       ]; % [mm]
            vCoGz   =       [3550     3436    1458    1481    ]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,3} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,3} = {'Follower Laden'};
            mLoad{:,3} = [totalMass]'; % [kg]
            xLoad{:,3} = [CoGx*0.001]'; % [m]
            zLoad{:,3} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Follower FL Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'SUV' 'SUV'};
            vMass   =       [2500     2500    ];    % [kg]
            vRx     =       [0.677    0.677   ];   % [m]
            vRy     =       [1.430    1.430   ];   % [m]
            vRz     =       [1.462    1.462   ];   % [m]
            vCoGx   =       [6240     11633   ]; % [mm]
            vCoGy   =       [0        0       ]; % [mm]
            vCoGz   =       [3550     3436    ]; % [mm]
            
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy, vCoGz, vPitch);
            
            uLoad{1,3} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{1,3} = {'Follower Top Deck Load'};
            mLoad{1,3} = [totalMass]'; % [kg]
            xLoad{1,3} = [CoGx*0.001]'; % [m]
            zLoad{1,3} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Follower TD Payload');
            end
    end
    %% --------------------------------------------------------------------------------------
    %	Additional inputs
    %----------------------------------------------------------------------------------------
    Area = 2.6*4.600;
    Ltot = 29797;          % [mm] see the PBS summary with trailer configuration A
    VehWidthLoad = 2600;   % [mm] total width - @ trailer axle width
    VehWidthUnload = 2600; % [mm] total width - @ trailer axle width
    SteerWidth = 2494; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
    %% --------------------------------------------------------------------------------------
    %	Engine properties Volvo AT2612F Gearbox / D13A400 Engine
    %----------------------------------------------------------------------------------------
    gears =     [14.94 11.28 9.04 7.09 5.54 4.35 3.44 2.7 2.08 1.63 1.27 1];
    eff_gear =  [0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97];
    eff_diff = 0.97;
    dif = 3.090; %diff ratio
    
    %Note there is no difference in startability gear/diff for the VW
    %19.320
    gearsStart = gears; %Gears for startability - used if crawler gear available
    eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
    eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
    difStart = dif; %Diff ratio for startability - used if dual differential
    
    Torquerpm = [600 700 800 900 1000 1050 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100];
    TorqueNm =  [1275 1425 1575 1800 2100 2200 2200 2200 2200 2200 2050 1920 1800 1715 1500 1275 1075];
    
    rr = 0.509; %rolling radius m
    Ie = 2.75; %engine inertia kg/m^2
    It = 26*14; %tyre inertia kg/m^2
    gearshiftregime = 2; % 1 for every gear 2 for every second
    
    changeT = 1800; %Torque where torque*rpm is max
    
    %----------------------------------------------------------------------------------------
    %   Calculated engine properties
    %----------------------------------------------------------------------------------------
    engageTrpm = Torquerpm(1); %Torque engagement rpm - between 800 & 1000 when clutch is fully released - look @ start of where graph is drawn **Should be the first point on the curve
    
    if (max(TorqueNm)/2) > min(TorqueNm)
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
