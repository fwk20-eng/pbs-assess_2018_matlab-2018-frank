%ver 2.0
%	-> Completely removed PBS functions from the input file
%	-> Each project will now get its own PostProcess file of the format a000_PostProcess - the a to move it to the top of the folder
%   -> Added functionality to choose which PBS manoeuvres to run
%   -> Results will only be saved for a full PBS analysis

%ver 2.1
%   -> Added a check for the lateral acceleration in the YawD manoeuvre
%   (Program will now generate an error if the lateral acceleration is
%   outside of the range 0.19 < LatAccel < 0.21 for the lead unit) -fwk
%   -> Added a check for the lateral error in the RA manoeuvre
%   (Program will now generate an error if the lateral error is above 30 mm)
%   -> Added a new function to generate an auto log file with the runNotes
%   which can be appended even if no data is saved

% Further work
%     Extract axle loadings from MatLab Files to add/compare to MatLab (use a static procedure in TruckSim to get accurate loadings)
%     Have function that checks input parameters are correct
%     Do artic angle and artic angle rate for Yaw Damping
%     Do summary of all elements in r
%     Does the programme work for truck trailer combination with dolleys?
%     Correct STFD
%     Correct SRT for lift of all Fz except steer.
%     Check SRTrrcu

% NOTES:
% List of inputs from TruckSim listed in "Inputs required from TruckSim.xls" file in this folder

%%
function [] = PostProcessMultiChoice(plotOn, plotSummary, isBus, isDanGoods, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,...
    savePath, rootPath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad, uLoad,...
    Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
    Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu, isLong, isYawD, isRA, isHSTO,...
    isSRT, isTASP, isLST, isLSunT, isSave, isFullPBS, isLog, isRemoveMFiles, runNotes)
disp('-------------------------------------------------------------------------------------')
disp('	Next Run')
disp('-------------------------------------------------------------------------------------')
%% --------------------------------------------------------------------------------------
%	Writing the log file if saved
%----------------------------------------------------------------------------------------
if isSave %Write run notes and revision to text file
    runLogName = 'runLog.txt';
    runLogPath = strcat(rootPath, runLogName);
    fRunLog = fopen(runLogPath,'a');
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    fprintf(fRunLog,strcat(datestr(now,'yyyy-mm-dd'), ':\t' ,runKey, '\n'));
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    
    for i = 1:length(runNotes)
        fprintf(fRunLog, runNotes{i,1});
        fprintf(fRunLog,'\n');
    end
    fprintf(fRunLog,'\nComments:\n');
    fclose(fRunLog);
end
%% --------------------------------------------------------------------------------------
%	Constants
%----------------------------------------------------------------------------------------
warning off
g = 9.81;
nLevels = 4;    % PBS levels - should correspond to size of cell arrays in setLims function
nAxles = length(mAxle);
radial = 1; %radial = 1 for radial tyres else = 0 if bias ply

Ch=1; %Ch = 1 for a good road, 1.2 for a fair road and 1.5 for a poor road
Cd=1.0; %Coefficient of drag Cd = 0.9 with no aerodynamic shields and 0.7 with shields Lohr EC16303 Results
Ce=1; %Ce =1 at sea level, 0.86 at 5000 ft and 0.74 at 10000 ft

muPeakSteer = 1;       % not sure why but TS also uses 1.0 for their STFD calcs
RAinputAy = 0.15;      % [g] normally 0.15 for RA test completed at 88km/h
SRTrollThresh = 30;    % PBS rules
%% --------------------------------------------------------------------------------------
%	Execute PBS manoeuvres
%----------------------------------------------------------------------------------------
if isPBS
    nVehUnits = length(mChas);      % includes dollys
    %A = what;
    %currdir = A.path;   %get current directory
    fullName = setFullNames();
    lim = setLims(isBus, isDanGoods);
    
    [mSprung, XcgSprung, HcgSprung]=detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
    [mSprungU, XcgSprungU, HcgSprungU]=detSprung(mChas, xChas, zChas, cellfun(@(m,u) m.*u, mLoad, uLoad, 'UniformOutput',0), cellfun(@(m,u) m.*u, xLoad, uLoad, 'UniformOutput',0), cellfun(@(m,u) m.*u, zLoad, uLoad, 'UniformOutput',0)); % Determine sprung mass properties of each vehicle unit in unloaded configuration
    [mTotal x z] = determineCOG(mChas, xChas, zChas, mAxle, xAxle, zAxle, grouping, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
    
    Axle1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled); %Loaded axles loads for normal operation
    Axle2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled); %Loaded axles loads for Startability
    AxleU1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare1,loadCoupled); %Unoaded axles loads for normal operation
    AxleU2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare2,loadCoupled); %Unoaded axles loads for Startability, which is not required
    AxleLoading = [[1:nAxles]; loadshare1; Axle1; AxleU1; loadshare2; Axle2; AxleU2];%Raw axle loading values
    roundAxleLoading = [[1:nAxles]; loadshare1; round(Axle1,0); round(AxleU1,0); loadshare2; round(Axle2,0); round(AxleU2,0)];%Rounded axle loadings
    
    if isLong
        [r.STA, r.GRAa, r.GRAb, r.ACC] = LONG_solve(mTotal,Area,radial,Ch,Cd,Ce,gears,eff_gear,gearsStart,eff_gearStart,eff_diff,dif,eff_diffStart,difStart,Torquerpm,TorqueNm,engageTrpm,engageTNm,changeT,rr,Ie,It,Ndrive,gearshiftregime,savePath, runKey, plotOn, isSave,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1, loadshare2,loadCoupled);
    end
    
    if isYawD
        r.YDC = YawD_solve(nVehUnits, savePath, runsPath, runKey, matKeyYawD, plotOn, isSave);
    end
    
    if isRA
        r.RA = RA_solve(mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKeyRA, plotOn, isSave); %must add check to ensure path is tracked to within 30mm/150mm
    end
    
    if isHSTO
        r.HSTO = HSTO_solve(nAxles, Ltot, savePath, runsPath, runKey, matKeyHSTO, plotOn, isSave);
    end
    
    if isSRT
        [r.SRTt, r.SRTtrrcu] = SRTt_solve(nAxles,nSteer,lim.SRT(Ldesired),SRTrollThresh, mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKeySRTt, plotOn, isSave);
    end
    
    if isTASP
        r.TASP = TASP_solve(nVehUnits, dollys, savePath, runsPath, runKey, matKeyTASP, plotOn, isSave);
    end
    
    if isLST
        [r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = LSTurn_solve(nVehUnits, dollys, VehWidthLoad, SteerWidth, nSteer, muPeakSteer, true, savePath, runsPath, runKey, matKeyLSTurn, plotOn, isSave);
    end
    
    if isLSunT
        [r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = LSTurn_solve(nVehUnits, dollys, VehWidthUnload, SteerWidth, nSteer, muPeakSteer, false, savePath, runsPath, runKey, matKeyLSTurnu, plotOn, isSave);
    end
    
    disp('-------------------------------------------------------------------------------------')
    disp('	Results')
    disp('-------------------------------------------------------------------------------------')
    display(r);
    %% --------------------------------------------------------------------------------------
    %	post process the post processed results
    %----------------------------------------------------------------------------------------
    
    %% --------------------------------------------------------------------------------------
    %	Save results to excel
    %----------------------------------------------------------------------------------------
    if isFullPBS %SRT required for this to work
        lim.RA = setLimsRA(r);  % is captured as hard code in function below (should read in from stored file) % calculated here before SRTrrcu is rounded off
    end
    
    if isFullPBS && isSave
        results_round = rounder(r);
        results = r;
        printResultsPBSnotes(results, lim, fullName, nLevels, savePath, 'results', 'postAxleLoad',  AxleLoading, isSemi, fileName,runNotes);
        printResultsPBS(results_round, lim, fullName, nLevels, savePath, 'resultsRounded', 'postAxleLoadRounded', roundAxleLoading, isSemi, fileName);
    end
    
    if isFullPBS && plotSummary
        runSummaryChart(fullName, r, lim, Ldesired, savePath, runKey, isSemi)
    end
    
    %% --------------------------------------------------------------------------------------
    %	Adding functionality to remove the .mat files from the runs directory
    %----------------------------------------------------------------------------------------
    if isRemoveMFiles == 1
        RemoveMfiles = questdlg('Would you like to delete the .mat files in the run folder?', 'Delete .m files?', 'Yes', 'No', 'No');
        if strcmp(RemoveMfiles, 'Yes')
            f = fullfile(runsPath, '*.mat');
            delete(f);
        else if strcmp(RemoveMfiles, 'No')
                msgbox('.mat files not deleted in the run folder.');
            end
        end
    end
    warning on
end
%% --------------------------------------------------------------------------------------
%	Excel Axle Loads
%----------------------------------------------------------------------------------------

if isAxleLoads
    disp('-------------------------------------------------------------------------------------')
    disp('	Axle Loads')
    disp('-------------------------------------------------------------------------------------')
    [mSprung, XcgSprung, HcgSprung]=detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
    processAxleLoads(fileName, savePath, grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, zAxle, h, mSprung, XcgSprung, HcgSprung, mChas, xChas, mLoad, xLoad, dLoad, isSave);
end
%% --------------------------------------------------------------------------------------
%	Writing the log file if saved
%----------------------------------------------------------------------------------------
if isLog %Write run notes and revision to text file
    runLogName = 'runLog.txt';
    runLogPath = strcat(rootPath, runLogName);
    fRunLog = fopen(runLogPath,'a');
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    fprintf(fRunLog,strcat(datestr(now,'yyyy-mm-dd'), ':\t' ,runKey, '\n'));
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    
    for i = 1:length(runNotes)
        fprintf(fRunLog, runNotes{i,1});
        fprintf(fRunLog,'\n');
    end
    
    fprintf(fRunLog,'\nResults:\n');
    
    if isPBS
        resultTable = struct2table(r);
        resultLog = [resultTable.Properties.VariableNames; table2cell(resultTable)];
        
        for i = 1:length(resultLog)
            fprintf(fRunLog, strcat(resultLog{1,i},': ', num2str(resultLog{2,i}), '\n'));
        end
        
        fprintf(fRunLog,'\nComments:\n');
    end
    fclose(fRunLog);
end

disp('-------------------------------------------------------------------------------------')
disp('	Analysis complete')
disp('-------------------------------------------------------------------------------------')
end