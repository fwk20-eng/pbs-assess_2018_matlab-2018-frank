%ver 2.0
%	-> Completely removed PBS functions from the input file
%	-> Each project will now get its own PostProcess file of the format a000_PostProcess - the a to move it to the top of the folder
%ver 2.1
%   -> Changes made in PostProcessMultiChoice - see that .m file for
%   updates
%   -> Added isSave as 1 into the inputs for the manouevres, hence there is
% no need to pass through the isSave parameter.
%   -> Added isDanGoods to alter the SRT limit for dangerous goods vehicles

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
function [] = PostProcess(plotOn, plotSummary, isBus, isDanGoods, isSemi, isPBS, isAxleLoads, runsPath, Ldesired, groupingHeadings, grouping, loadshare1, loadshare2,...
    savePath, runKey, fileName, mAxle, xAxle, zAxle, Ndrive, nSteer, rollCoupled, loadCoupled, dollys, l, h, mChas, xChas, zChas, dLoad, mLoad, xLoad, zLoad,...
    Area, gears, eff_gear, gearsStart, eff_gearStart, eff_diff, dif, eff_diffStart, difStart, Torquerpm, TorqueNm, engageTrpm, engageTNm, changeT, rr, Ie, It, gearshiftregime,...
    Ltot, VehWidthLoad, VehWidthUnload, SteerWidth, matKeyYawD, matKeyRA, matKeyHSTO, matKeySRTt, matKeyTASP, matKeyLSTurn, matKeyLSTurnu);
disp('____________next run')
warning off
g = 9.81;
nLevels = 4;    % PBS levels - should correspond to size of cell arrays in setLims function
%% Combination configuration
nAxles = length(mAxle);
%% Sprung Mass and CoG for Lead and Trailer units
radial = 1; %radial = 1 for radial tyres else = 0 if bias ply
%% Conditional properties **Input for blizzard atego complete
Ch=1; %Ch = 1 for a good road, 1.2 for a fair road and 1.5 for a poor road
Cd=1.0; %Coefficient of drag Cd = 0.9 with no aerodynamic shields and 0.7 with shields Lohr EC16303 Results
Ce=1; %Ce =1 at sea level, 0.86 at 5000 ft and 0.74 at 10000 ft
%% Constants
muPeakSteer = 1;       % not sure why but TS also uses 1.0 for their STFD calcs
RAinputAy = 0.15;      % [g] normally 0.15 for RA test completed at 88km/h
SRTrollThresh = 30;    % PBS rules
%% Execute PBS manoeuvres
if isPBS
    nVehUnits = length(mChas);      % includes dollys
    A = what;
    currdir = A.path;   %get current directory
    fullName = setFullNames();
    lim = setLims(isBus, isDanGoods);
    [mSprung, XcgSprung, HcgSprung]=detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
    [mSprungU, XcgSprungU, HcgSprungU]=detSprung(mChas, xChas, zChas, cellfun(@(x) x*0,mLoad,'un',0), cellfun(@(x) x*0,xLoad,'un',0), cellfun(@(x) x*0,zLoad,'un',0)); % Determine sprung mass properties of each vehicle unit in unloaded configuration
    [mTotal x z] = determineCOG(mChas, xChas, zChas, mAxle, xAxle, zAxle, grouping, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
    Axle1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled); %Check
    Axle2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled); %Check
    AxleU1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare1,loadCoupled); %Unloaded axle loads
    AxleU2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare2,loadCoupled); %Unloaded axle loads
    AxleLoading = [[1:nAxles]; loadshare1; Axle1; AxleU1; loadshare2; Axle2; AxleU2];%Raw axle loading values
    roundAxleLoading = [[1:nAxles]; loadshare1; round(Axle1,0); round(AxleU1,0); loadshare2; round(Axle2,0); round(AxleU2,0)];%Rounded axle loadings
    [r.STA, r.GRAa, r.GRAb, r.ACC] = LONG_solve(mTotal,Axle1,Axle2,Area,radial,Ch,Cd,Ce,gears,eff_gear,gearsStart,eff_gearStart,eff_diff,dif,eff_diffStart,difStart,Torquerpm,TorqueNm,engageTrpm,engageTNm,changeT,rr,Ie,It,Ndrive,gearshiftregime,savePath, runKey, plotOn, 1);
    r.YDC = YawD_solve(nVehUnits, savePath, runsPath, runKey, matKeyYawD, plotOn, 1);
    r.RA = RA_solve(mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKeyRA, plotOn, 1); %must add check to ensure path is tracked to within 30mm/150mm
    r.HSTO = HSTO_solve(nAxles, Ltot, savePath, runsPath, runKey, matKeyHSTO, plotOn, 1);
    [r.SRTt, r.SRTtrrcu] = SRTt_solve(nAxles,nSteer,lim.SRT(Ldesired),SRTrollThresh, mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, matKeySRTt, plotOn, 1, 1);
    r.TASP = TASP_solve(nVehUnits, dollys, savePath, runsPath, runKey, matKeyTASP, plotOn, 1);
    [r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = LSTurn_solve(nVehUnits, dollys, VehWidthLoad, SteerWidth, nSteer, muPeakSteer, true, savePath, runsPath, runKey, matKeyLSTurn, plotOn, 1);
    [r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = LSTurn_solve(nVehUnits, dollys, VehWidthUnload, SteerWidth, nSteer, muPeakSteer, false, savePath, runsPath, runKey, matKeyLSTurnu, plotOn, 1);
    %% post process the post processed results
    results_round = rounder(r);
    results = r;
    lim.RA = setLimsRA(r);  % is captured as hard code in function below (should read in from stored file) % calculated here before SRTrrcu is rounded off
    disp('Analysis complete')
    if plotSummary
        runSummaryChart(fullName, r, lim, Ldesired, savePath, runKey, isSemi)
    end
%% Save results to excel
    printResultsPBS(results, lim, fullName, nLevels, savePath, 'results', 'postAxleLoad',  AxleLoading, isSemi, fileName)
    printResultsPBS(results_round, lim, fullName, nLevels, savePath, 'resultsRounded', 'postAxleLoadRounded', roundAxleLoading, isSemi, fileName) 
    %% Adding functionality to remove the .mat files from the runs directory
    RemoveMfiles = questdlg('Would you like to delete the .mat files in the run folder?', 'Delete .m files?', 'Yes', 'No', 'No');
    if strcmp(RemoveMfiles, 'Yes')
        f = fullfile(runsPath, '*.mat');
        delete(f);
    else if strcmp(RemoveMfiles, 'No')
        msgbox('Files not deleted');
        end
    end
    warning on
end
%% Excel Axle Loads
if isAxleLoads
    processAxleLoads(fileName, savePath, grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad, dLoad, 1);
end

end