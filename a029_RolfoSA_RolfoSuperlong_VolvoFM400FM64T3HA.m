% Project Notes
% [2017-03-15] Changed the engagement torque to be the lowest between the max torque / 2
% and the minimum torque on the torque curve.
% [2017-03-16] 
%   - Updated the wheelbase to match the new client request of a 8.4 m follower and 9.5 m leader
%   - Updated filename convention so that files are sorted according to their revision number
%%
function a029_RolfoSA_RolfoSuperlong_VolvoFM400FM64T3HA
clear; close all; format longG; set(0,'DefaultFigureWindowStyle','docked'); %Comment out set(0,'DefaultFigureWindowStyle','docked') if you do not want images docked & initialising data for each run & setting format of command window output
%% --------------------------------------------------------------------------------------
%	Setting configurations run (0 - Fully loaded; 1 - Topdeck loaded)
%----------------------------------------------------------------------------------------
for loadConfig = 0:1
    %% --------------------------------------------------------------------------------------
    %	Booleans
    %----------------------------------------------------------------------------------------
    isBus = 0; % Set 1 if bus
    isDanGoods = 0; %Set to 1 if dangerous goods
    isSemi = 1; % Put 1 if it is a semitrailer with front overhang, 0 if no front overhang (this will eliminate MoD and DoM from the Summary Chart & results)
    
    isPBS =         1;      isSave =   1;     plotOn =       1;
    isFullPBS =     1;      isLog =    1;     plotSummary =  1; %If not full PBS, plotSummary is disabled
    isAxleLoads =   1;
    
    
    isLST =     1;  isYawD =  0;  isHSTO = 0;   isLong =  0;
    isLSunT =   0;  isRA =    0;  isTASP = 0;   isSRT =   0;
    
    isRemoveMFiles = 0; %Set this to 0 to remove the request for removing M files in the runs folder
    
    %% --------------------------------------------------------------------------------------
    %	2017001-RolfoSA_RolfoSuperlong_VolvoFM400FM64T3HA
    %----------------------------------------------------------------------------------------
    rev = '8';
    projectKey = 'P029_RolfoSuperlong-VolvoFM64T3HA';
    rootPath = 'C:\Dropbox\PBS\Projects\P2017001_RolfoSA-RolfoSuperlong_VolvoFM64T3HA\Results\'; %end with a \ ALWAYS. This is where the file will be saved
    runsPath = 'C:\Dropbox\witsPBS_2017-02-15\Runs';
    %% --------------------------------------------------------------------------------------
    %	Run Details
    %----------------------------------------------------------------------------------------
    disp('-------------------------------------------------------------------------------------')
    disp('	Run Notes')
    disp('-------------------------------------------------------------------------------------')
    runNotes = {'New Combination C wheelbase trailers';...
                'Please be aware that the payload is currently incorrect as it is still using the original design parameters';...
                        }; %Notes will be saved in Excel results sheet for reference
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
    Ldesired = 2; %pbs level desired
    
    groupingHeadings = {'steer' 'drive' 'Lead Trailer' 'Follower Trailer'}; %label the axle groups
    grouping = {[1]; [2:3]; [4:5]; [6:7]}; % axles numbers in each axle group. nb cell dim must be greater than mchas dim by 1
    loadshare1 = [1 0.5 0.5 0.5 0.5 0.5 0.5]; % [%] normal loadsharing numbers
    loadshare2 = [1 0.5 0.5 0.5 0.5 0.5 0.5]; % [%] startability loadsharing numbers
    
    mAxle = [750 1300 1300 650 650 650 650]; % [kg]
    xAxle = [0 3.2 4.57 (8.4-1.7/2) (8.4+1.7/2) (9.5-1.7/2) (9.5+1.7/2)]; % [m] distances back of axles on 2nd, 3rd etc. vehicle unit are from hitch point (hp) Using Follower 2A
    zAxle = [0.517 0.532 0.532 0.383 0.383 0.387 0.387]; % [m] trucksim model
    
    Ndrive = [2:3]; % driven axles
    nSteer = 1; % number of steer axles for stfd
    
    nTyres = 2+4+4+4+4+4+4;% Number of tyres on the combination
    rr = 0.521; % [m] rolling radius of tyres [Updated 2017-03-07 from 0.509]
    
    rollCoupled = [true true];
    loadCoupled = [true true];
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have rps)%
    %% --------------------------------------------------------------------------------------
    %	Hitch Inputs (Longitudinal position from steer axle and height from floor)
    %----------------------------------------------------------------------------------------
    l = [3.375 10.000]; % [m]
    h = [1.309 1.050]; % [m] [Trailer hitch height adjusted to email from Elio sent 2017-02-02]
    %% --------------------------------------------------------------------------------------
    %	Additional dimensional inputs
    %----------------------------------------------------------------------------------------
    Area = 2.550*4.600;
    Ltot = 28115;          % [mm] see the gaReference points with combination C
    VehWidthLoad = 2550;   % [mm] total width - max vehicle width at the loaded condition
    VehWidthUnload = 2550; % [mm] total width - max vehicle width at the unloaded condition
    SteerWidth = 2494; % [mm] total width @ steer tyre (axle centres + 1 x (tyre width))
    %% --------------------------------------------------------------------------------------
    %	Sprung Mass and CoG for Lead and Trailer units
    %----------------------------------------------------------------------------------------
    mChas = [5011   6200    7700]; %  [kg] [2017-03-07: Updated the sprung mass which was set for Trailer A and not B]
    xChas = [0.855  4.032   4.935]; % [m]
    zChas = [1.2    1.328   1.464]; % [m]
    %% --------------------------------------------------------------------------------------
    %	Unit 1 payload mass and CoG - Driver and fuel included in the 
    %----------------------------------------------------------------------------------------
    uLoad{:,1} = []'; %Set to 0 to remove payload in the unladen condition
    dLoad{:,1} = {};
    mLoad{:,1} = []'; % [kg]
    xLoad{:,1} = []'; % [m] It is identical referencing to TruckSim (does not follow coordinate system but follows the diagram shown in trucksim with rear of the steer axle being positive)
    zLoad{:,1} = []'; % [m]
    %% --------------------------------------------------------------------------------------
    %	Unit 2 payload mass and CoG
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded
            vDescription =  {'Ford Expedition' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500    2500    2500]; % [kg] vMass   =       [2250     2638	2638    1432    2638    2638]; % [kg]
            vRx     =       [0.677    0.677   0.677   0.677]; % [m]
            vRy     =       [1.430    1.430   1.430   1.430]; % [m]
            vRz     =       [1.462    1.462   1.462   1.462]; % [m]
            vCoGx   =       [-152     4240    344     5156]; % [mm]
            vCoGy   =       [0        0       0       0]; % [mm]
            vCoGz   =       [3413     3311    1554    1001]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,2} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,2} = {'Leader Fully Laden'};
            mLoad{:,2} = [totalMass]'; % [kg]
            xLoad{:,2} = [CoGx*0.001]'; % [m]
            zLoad{:,2} = [CoGz*0.001]'; % [m]            
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Leader FL Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500]; % [kg] vMass   =       [2250     2638	2638    1432    2638    2638]; % [kg]
            vRx     =       [0.677    0.677]; % [m]
            vRy     =       [1.430    1.430]; % [m]
            vRz     =       [1.462    1.462]; % [m]
            vCoGx   =       [-152     4240]; % [mm]
            vCoGy   =       [0        0]; % [mm]
            vCoGz   =       [3413     3311]; % [mm]
            
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
    %	Unit 3 payload mass and CoG [2017-03-07: Updated to combination B values]
    %----------------------------------------------------------------------------------------
    switch loadConfig
        case 0 % fully loaded
            vDescription =  {'Ford Expedition (Red.)' 'Ford Expedition' 'Ford Expedition' 'Ford Expedition (Red.)' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500    2500    2500    2500    2500]; % [kg] vMass   =       [2250     2638	2638    1432    2638    2638]; % [kg]
            vRx     =       [0.677    0.677   0.677   0.677   0.677   0.677]; % [m]
            vRy     =       [1.430    1.430   1.430   1.430   1.430   1.430]; % [m]
            vRz     =       [1.462    1.462   1.462   1.462   1.462   1.462]; % [m]
            vCoGx   =       [324      5971    11599   533     6208    11795]; % [mm], note KS is in [m]
            vCoGy   =       [0        0       0       0       0       0   ]; % [mm]
            vCoGz   =       [3226     3219    3141    1524    1149    1209]; % [mm]
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy,vCoGz, vPitch);
            
            uLoad{:,3} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,3} = {'Follower (2A) Fully Laden'};
            mLoad{:,3} = [totalMass]'; % [kg]
            xLoad{:,3} = [CoGx*0.001]'; % [m]
            zLoad{:,3} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Follower FL Payload');
            end
        case 1 % topdeck loaded
            vDescription =  {'Ford Expedition' 'Ford Expedition' 'Ford Expedition'};
            vMass   =       [2500     2500    2500];    % [kg] vMass   =       [2250     2638	2638    1432    2638    2638]; % [kg]
            vRx     =       [0.677    0.677   0.677];   % [m]
            vRy     =       [1.430    1.430   1.430];   % [m]
            vRz     =       [1.462    1.462   1.462];   % [m]
            vCoGx   =       [324      5971    11599];   % [mm]
            vCoGy   =       [0        0       0];       % [mm]
            vCoGz   =       [3226     3219    3141];    % [mm]
            
            vPitch  = zeros(1, length(vMass)); %Rotation of vehicles along the pitch axis [deg] - set to 0 as a standard
            [inputsHeadings, inputs, resultsHeadings, vResults, totalMass, CoGx, CoGz] = combineInertiasR(vMass, vRx, vRy, vRz, vCoGx, vCoGy, vCoGz, vPitch);
            
            uLoad{:,3} = [0]'; %Set to 0 to remove payload in the unladen condition
            dLoad{:,3} = {'Follower (2A) Top Deck Load'};
            mLoad{:,3} = [totalMass]'; % [kg]
            xLoad{:,3} = [CoGx*0.001]'; % [m]
            zLoad{:,3} = [CoGz*0.001]'; % [m]
            
            if isSave
                printResultsInertiaR(fileName, savePath, inputsHeadings, resultsHeadings, inputs, vResults, vDescription, 'Follower TD Payload');
            end
    end
    %% --------------------------------------------------------------------------------------
    %	Engine properties Volvo AT2612F Gearbox / D13A400 Engine
    %----------------------------------------------------------------------------------------
    changeT = 1773; %RPM where power is max
    
    gears =     [14.94 11.28 9.04 7.09 5.54 4.35 3.44 2.7 2.08 1.63 1.27 1];
    eff_gear =  [0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.97];
    
    eff_diff = 0.97; %differential efficiency
    dif = 3.090; %differential ratio
    
    gearsStart = gears; %Gears for startability - used if crawler gear available
    eff_gearStart = eff_gear; %Gears for startability - used if crawler gear available
    eff_diffStart = eff_diff; %Diff ratio for startability - used if dual differential
    difStart = dif; %Diff ratio for startability - used if dual differential
    
    Torquerpm = [600 698 769 836 903 950 998 1045 1399 1466 1553 1663 1773 1844 1891 1943 1986  2041 2088];
    TorqueNm =  [1268 1402 1504 1601 1708 1805 1901 2003 2003 1901 1805 1703 1601 1499 1402  1300 1199 1097 1000]; 
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
    PostProcessMultiChoice(plotOn, plotSummary, isBus, isDanGoods, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,...
        savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
        Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
        Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
        isSRT, isTASP, isLST, isLSunT ,isSave, isFullPBS, isLog, isRemoveMFiles, runNotes);
end
end

%% PREVIOUS RUNS
