%% ----Some robustness to help prevent overwritting a run----
if exist(savePath,'dir')
    warnRunExists = questdlg('The run already exists, are you sure you want to overwrite?', 'Run exists warning', 'Yes', 'Cancel', 'Change', 'Cancel');
    switch warnRunExists
        case 'Yes'
            uiwait(msgbox('Run will be overwritten', 'Run chosen to be overwritten'));
            delete(strcat(savePath, '\', runKey, '_summary.xlsx'));%Deleting results file to prevent leftover information clash
        case 'Change'
            savePath = uigetdir(savePath,'Please select directory to store results');
        case 'Cancel'
            return;
    end
end
%% ----Some robustness to help prevent overwritting a run----
    
%savePath = uigetdir(currdir,'Please select directory to store results');
%runsPath = uigetdir(currdir,'Please select directory containing Trucksim data files [usually \TruckSim_Data\Runs]');
%% Code Implimentation
nVehUnits = length(mChas);      % includes dollys
A = what;
currdir = A.path;   %get current directory
fullName = setFullNames();
Lim = setLims(isBus);
[mSprung XcgSprung HcgSprung]=detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
[mSprungU XcgSprungU HcgSprungU]=detSprung(mChas, xChas, zChas, cellfun(@(x) x*0,mLoad,'un',0), cellfun(@(x) x*0,xLoad,'un',0), cellfun(@(x) x*0,zLoad,'un',0)); % Determine sprung mass properties of each vehicle unit in unloaded configuration
[mTotal x z] = determineCOG(mChas, xChas, zChas, mAxle, xAxle, zAxle, grouping, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit

Axle1=AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled); %Check
Axle2=AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled); %Check
AxleU1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare1,loadCoupled); %Unloaded axle loads
AxleU2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare2,loadCoupled); %Unloaded axle loads

AxleLoading = [[1:nAxles]; loadshare1; Axle1; AxleU1; loadshare2; Axle2; AxleU2];%Raw axle loading values
roundAxleLoading = [[1:nAxles]; loadshare1; round(Axle1,0); round(AxleU1,0); loadshare2; round(Axle2,0); round(AxleU2,0)];%Rounded axle loadings

[r.STA, r.GRAa, r.GRAb, r.ACC] = LONG_solve(mTotal,Axle1,Axle2,Area,radial,Combination.ch,Combination.cd,Combination.ce,gears,eff_gear,eff_diff,dif,Torquerpm,TorqueNm,engageTrpm,engageTNm,changeT,rr,Ie,It,Ndrive,gearshiftregime,savePath, runKey, plotOn);
r.YDC = YawD_solve(nVehUnits, savePath, runsPath, runKey, plotOn);
r.RA = RA_solve(mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, plotOn); %must add check to ensure path is tracked to within 30mm/150mm
r.HSTO = HSTO_solve(nAxles, Ltot, savePath, runsPath, runKey, plotOn);
[r.SRTt r.SRTtrrcu] = SRTt_solve(nAxles,nSteer,Lim.SRT(Ldesired),SRTrollThresh, mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, plotOn);
r.TASP = TASP_solve(nVehUnits, dollys, savePath, runsPath, runKey, plotOn);
[r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = LSTurn_solve(nVehUnits, dollys, VehWidthLoad, SteerWidth, nSteer, muPeakSteer, true, savePath, runsPath, runKey, plotOn);
[r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = LSTurn_solve(nVehUnits, dollys, VehWidthUnload, SteerWidth, nSteer, muPeakSteer, false, savePath, runsPath, runKey, plotOn);
%% post process the post processed results
results_round = rounder(r);
results = r;

Lim.RA = setLimsRA(r);  % is captured as hard code in function below (should read in from stored file)
                        % calculated here before SRTrrcu is rounded off

disp('Analysis complete')

if plotSummary
    runSummaryChart(fullName, r, Lim, Ldesired, savePath, runKey, isSemi)
end

r

printResults(results, Lim, fullName, nLevels, savePath, runKey, 'results', 'postAxleLoad',  AxleLoading, isSemi)
printResults(results_round, Lim, fullName, nLevels, savePath, runKey, 'resultsRounded', 'postAxleLoadRounded', roundAxleLoading, isSemi)

fileName = strcat(runKey, '_summary');
processAxleLoads(fileName, savePath, grouping, groupingHeadings, loadshare1, loadCoupled, l, mAxle, xAxle, mChas, xChas, mLoad, xLoad, dLoad);
disp(['Results saved to ' runKey '_summary.xls'])

RemoveMfiles = questdlg('Would you like to delete the .m files in the run folder?', 'Delete .m files?', 'Yes', 'No', 'No');
%Adding functionality to remove the .m files from the runs directory
if strcmp(RemoveMfiles, 'Yes')
    f = fullfile(runsPath, '*.mat');
    delete(f);
else if strcmp(RemoveMfiles, 'No')
    msgbox('Files not deleted');
    end
end

warning on

%%
function [fullName] = setFullNames()

fullName.STA        = 'Startability';
fullName.GRAa       = 'Gradeability A';
fullName.GRAb       = 'Gradeability B';
fullName.ACC        = 'Acceleration Capability';
fullName.SRTt       = 'Static Rollover Threshold - Tilt Table';
fullName.YDC        = 'Yaw Damping Coefficient - 100 km/h';
fullName.RA         = 'Rearward Amplification';
fullName.HSTO       = 'High-speed Transient Offtracking';
fullName.TASP       = 'Tracking Ability on a Straight Path';
fullName.LSSP       = 'Low-speed Swept Path';
fullName.TS         = 'Tail Swing';
fullName.FS         = 'Frontal Swing';
fullName.MoD        = 'Maximum of Difference';
fullName.DoM        = 'Difference of Maxima';
fullName.STFD       = 'Steer-tyre Friction Demand';
fullName.LSSPu      = 'Low-speed Swept Path - Unladen';
fullName.TSu        = 'Tail Swing - Unladen';
fullName.FSu        = 'Frontal Swing - Unladen';
fullName.MoDu       = 'Maximum of Difference - Unladen';
fullName.DoMu       = 'Difference of Maxima - Unladen';
fullName.STFDu      = 'Steer-tyre Friction Demand - Unladen';


%%
function [Lim] = setLims(isBus)

Lim.STA = [15 12 10 5];
Lim.GRAa = [20 15 12 10];
Lim.GRAb = [80 70 70 60];
Lim.ACC = [20 23 26 29];
Lim.YDC = [0.15 0.15 0.15 0.15];
Lim.HSTO = [0.6 0.8 1.0 1.2];
if isBus,
    Lim.SRT = [0.4 0.4 0.4 0.4];
    Lim.FS = [1.5 1.5 1.5 1.5];
else
    Lim.SRT = [0.35 0.35 0.35 0.35];
    Lim.FS = [0.7 0.7 0.7 0.7];
end
Lim.TASP = [2.9 3.0 3.1 3.3];
Lim.LSSP = [7.4 8.7 10.6 13.7];
Lim.TS = [0.30 0.35 0.35 0.50];
Lim.MoD = [0.4 0.4 0.4 0.4];
Lim.DoM = [0.2 0.2 0.2 0.2];
Lim.STFD = [80 80 80 80];

%%
function [RA] = setLimsRA(r)

RAtemp = ceil(5.7*r.SRTtrrcu*1000)/1000;        %round up   to nearest 0.001
RA = [RAtemp RAtemp RAtemp RAtemp];

%%
function [res] = rounder(raw)

res.STA     = floor(raw.STA);                   % round down to nearest 1%
res.GRAa    = floor(raw.GRAa);                  % round down to nearest 1%
res.GRAb    = floor(raw.GRAb);                  % round down to nearest 1
res.ACC     = round([raw.ACC*10])/10;           % round      to nearest 0.1
res.YDC     = floor(raw.YDC*100)/100;           % round down to nearest 0.01
res.RA      =  ceil(raw.RA*100)/100;            % round up   to nearest 0.01
res.HSTO    =  ceil(raw.HSTO*10)/10;            % round up   to nearest 0.01
res.SRTt    = floor(raw.SRTt*100)/100;          % round down to nearest 0.01
res.SRTtrrcu= floor(raw.SRTtrrcu*100)/100;      % round down to nearest 0.01
res.TASP    =  ceil(raw.TASP*10)/10;            % round up   to nearest 0.1
res.LSSP    =  ceil(raw.LSSP*10)/10;            % round up   to nearest 0.1
res.TS      =  ceil(raw.TS*100)/100;            % round up   to nearest 0.01
res.FS      =  ceil(raw.FS*10)/10;              % round up   to nearest 0.1
res.MoD     =  ceil(raw.MoD*100)/100;           % round up   to nearest 0.01
res.DoM     =  ceil(raw.DoM*100)/100;           % round up   to nearest 0.01
res.STFD    =  ceil(raw.STFD);                  % round up   to nearest 1%
res.LSSPu   =  ceil(raw.LSSPu*10)/10;           % round up   to nearest 0.1
res.TSu     =  ceil(raw.TSu*100)/100;           % round up   to nearest 0.01
res.FSu     =  ceil(raw.FSu*10)/10;             % round up   to nearest 0.1
res.MoDu    =  ceil(raw.MoDu*100)/100;          % round up   to nearest 0.01
res.DoMu    =  ceil(raw.DoMu*100)/100;          % round up   to nearest 0.01
res.STFDu   =  ceil(raw.STFDu);                 % round up   to nearest 1%


%%
function [L] = checkLevel(type, X, limits, nLevels)
i = nLevels+1;
check = true;
while (i > 1) && check
    if type == '>'
        check = (X >= limits(i-1));
    elseif type == '<'
        check = (X <= limits(i-1));
    else
        disp('invalid input to checkLevel')
    end
    
    if check
        i = i-1;
    end
end

if i > nLevels
    L = 'FAIL';
elseif (limits(1)==limits) %all the limits are the same
    L = 'ALL';
else
    L = strcat('L', num2str(i));
end

%%
function [] = printResults(r, Lim, fullName, nLevels, savePath, runKey, xlsSheet, axleXlsSheet, AxleLoading, isSemi)
warning off MATLAB:xlswrite:AddSheet

savePath = strcat(savePath, '\', runKey, '_summary.xlsx');

results = {}; %Allows for a non-square matrix

results = Appender(results, 'Standard'      , 'units', 'Value', 'NTC Level met', [1:nLevels]);

results = Appender(results, fullName.STA    , '%', r.STA , checkLevel('>', r.STA, Lim.STA, nLevels), Lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
results = Appender(results, fullName.GRAa   , '%', r.GRAa, checkLevel('>', r.GRAa, Lim.GRAa, nLevels), Lim.GRAa);
results = Appender(results, fullName.GRAb   , 'km/h', r.GRAb, checkLevel('>', r.GRAb, Lim.GRAb, nLevels), Lim.GRAb);
results = Appender(results, fullName.ACC    , 's', r.ACC , checkLevel('<', r.ACC, Lim.ACC, nLevels), Lim.ACC);
results = Appender(results, fullName.SRTt   , 'g', r.SRTt   , checkLevel('>', r.SRTt, Lim.SRT, nLevels), Lim.SRT);
results = Appender(results, fullName.YDC    , '-', r.YDC    , checkLevel('>', r.YDC, Lim.YDC, nLevels), Lim.YDC);
results = Appender(results, fullName.RA     , '-', r.RA     , checkLevel('<', r.RA, Lim.RA, nLevels), Lim.RA);
results = Appender(results, fullName.HSTO   , 'm', r.HSTO   , checkLevel('<', r.HSTO, Lim.HSTO, nLevels), Lim.HSTO);
results = Appender(results, fullName.TASP   , 'm', r.TASP   , checkLevel('<', r.TASP, Lim.TASP, nLevels), Lim.TASP);
results = Appender(results, fullName.LSSP   , 'm', r.LSSP   , checkLevel('<', r.LSSP, Lim.LSSP, nLevels), Lim.LSSP);
results = Appender(results, fullName.TS     , 'm', r.TS     , checkLevel('<', r.TS, Lim.TS, nLevels), Lim.TS);
results = Appender(results, fullName.FS     , 'm', r.FS     , checkLevel('<', r.FS, Lim.FS, nLevels), Lim.FS);
if isSemi,%doesnt add MoD, DoM if it is not a SemiTrailer
    results = Appender(results, fullName.MoD    , 'm', r.MoD    , checkLevel('<', r.MoD, Lim.MoD, nLevels), Lim.MoD);
    results = Appender(results, fullName.DoM    , 'm', r.DoM    , checkLevel('<', r.DoM, Lim.DoM, nLevels), Lim.DoM);
end
results = Appender(results, fullName.STFD   , '%', r.STFD   , checkLevel('<', r.STFD, Lim.STFD, nLevels), Lim.STFD);
results = Appender(results, fullName.LSSPu  , 'm', r.LSSPu  , checkLevel('<', r.LSSPu, Lim.LSSP, nLevels), Lim.LSSP);
results = Appender(results, fullName.TSu    , 'm', r.TSu    , checkLevel('<', r.TSu, Lim.TS, nLevels), Lim.TS);
results = Appender(results, fullName.FSu    , 'm', r.FSu    , checkLevel('<', r.FSu, Lim.FS, nLevels), Lim.FS);
if isSemi, %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    results = Appender(results, fullName.MoDu   , 'm', r.MoDu   , checkLevel('<', r.MoDu, Lim.MoD, nLevels), Lim.MoD);
    results = Appender(results, fullName.DoMu   , 'm', r.DoMu   , checkLevel('<', r.DoMu, Lim.DoM, nLevels), Lim.DoM);
end
results = Appender(results, fullName.STFDu  , '%', r.STFDu  , checkLevel('<', r.STFDu, Lim.STFD, nLevels), Lim.STFD);

xlswrite(savePath, results,  xlsSheet, 'A1');
%% Writes the axle loading to a seperate sheet 
AxleHeadings = {'Axle #';'Load Distribution 1';'Axle Loading 1';'Unloaded Loading 1';'Load Distribution 2';'Axle Loading 2'; 'Unloaded Loading 2'};
xlswrite(savePath, AxleHeadings, axleXlsSheet,'A1');
xlswrite(savePath, AxleLoading, axleXlsSheet,'B1');

%%
function [C] = Appender(C, title, units, value, level, lims)

lenC = size(C,1);
C(lenC+1,1:4) = {title, units, value, level};

for i = 1:size(lims,1)             % size returns num of rows for dim 1
    for j = 1:size(lims,2)         % size returns num of cols for dim 2
        C(lenC+i,4+j) = {lims(i,j)};
    end
end

%%
function runSummaryChart(name, r, Lim, L, savePath, runKey, isSemi)
if isSemi,
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.MoD name.DoM name.STFD name.LSSPu name.TSu name.FSu name.MoDu name.DoMu name.STFDu};
    res = [r.STA/Lim.STA(L) r.GRAa/Lim.GRAa(L) r.GRAb/Lim.GRAb(L) r.SRTt/Lim.SRT(L) r.YDC/Lim.YDC(L) r.ACC/Lim.ACC(L) r.RA/Lim.RA(L) r.HSTO/Lim.HSTO(L) r.TASP/Lim.TASP(L) r.LSSP/Lim.LSSP(L) r.TS/Lim.TS(L) r.FS/Lim.FS(L) r.MoD/Lim.MoD(L) r.DoM/Lim.DoM(L) r.STFD/Lim.STFD(L) r.LSSPu/Lim.LSSP(L) r.TSu/Lim.TS(L) r.FSu/Lim.FS(L) r.MoDu/Lim.MoD(L) r.DoMu/Lim.DoM(L) r.STFDu/Lim.STFD(L)]*100;
else
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.STFD name.LSSPu name.TSu name.FSu name.STFDu};
    res = [r.STA/Lim.STA(L) r.GRAa/Lim.GRAa(L) r.GRAb/Lim.GRAb(L) r.SRTt/Lim.SRT(L) r.YDC/Lim.YDC(L) r.ACC/Lim.ACC(L) r.RA/Lim.RA(L) r.HSTO/Lim.HSTO(L) r.TASP/Lim.TASP(L) r.LSSP/Lim.LSSP(L) r.TS/Lim.TS(L) r.FS/Lim.FS(L) r.STFD/Lim.STFD(L) r.LSSPu/Lim.LSSP(L) r.TSu/Lim.TS(L) r.FSu/Lim.FS(L) r.STFDu/Lim.STFD(L)]*100;
end

maxX = ceil(max(res)/5)*5+5;
figure()
hold on

% blocks indicating failure region
h1 = barh([100 100 100 100 100 maxX*ones(1,16)], 'r');
set(h1,'EdgeColor','r')
set(h1,'BarWidth',1)
h2 = barh([0 0 0 0 0 100*ones(1,16)], 'w');
set(h2,'EdgeColor','w')
set(h2,'BarWidth',1)

h = barh(res);
set(h, 'FaceColor', [0.15 0.15 0.58])
set(h, 'EdgeColor', [0.15 0.15 0.58])
if isSemi,
    set(gca,'Ytick',[1:1:21])
else
    set(gca,'Ytick',[1:1:17])
end
set(gca,'YTickLabel',Ylabs)

axis ([-0.02 maxX+0.02 0.48 length(res)+.52])
xlabel('Performance in relation to limit [%]')
set(gca,'YDir','reverse')
set(gca,'box','on')
set(gca,'Linewidth',2)

set(gcf,'PaperPosition',[0 0 16 11])
savePlot(savePath, runKey, 'summary')

hold off