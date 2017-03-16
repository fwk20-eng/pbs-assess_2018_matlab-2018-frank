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
lim = setLims(isBus);
[mSprung XcgSprung HcgSprung]=detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit
[mSprungU XcgSprungU HcgSprungU]=detSprung(mChas, xChas, zChas, cellfun(@(x) x*0,mLoad,'un',0), cellfun(@(x) x*0,xLoad,'un',0), cellfun(@(x) x*0,zLoad,'un',0)); % Determine sprung mass properties of each vehicle unit in unloaded configuration
[mTotal x z] = determineCOG(mChas, xChas, zChas, mAxle, xAxle, zAxle, grouping, mLoad, xLoad, zLoad); % Determine sprung mass properties of each vehicle unit

Axle1=AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare1,loadCoupled); %Check
Axle2=AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprung,XcgSprung,HcgSprung,grouping,loadshare2,loadCoupled); %Check
AxleU1 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare1,loadCoupled); %Unloaded axle loads
AxleU2 = AxleLoade(0,mAxle,xAxle,zAxle,l,h,mSprungU,XcgSprungU,HcgSprungU,grouping,loadshare2,loadCoupled); %Unloaded axle loads

AxleLoading = [[1:nAxles]; loadshare1; Axle1; AxleU1; loadshare2; Axle2; AxleU2];%Raw axle loading values
roundAxleLoading = [[1:nAxles]; loadshare1; round(Axle1,0); round(AxleU1,0); loadshare2; round(Axle2,0); round(AxleU2,0)];%Rounded axle loadings

[r.STA, r.GRAa, r.GRAb, r.ACC] = LONG_solve(mTotal,Axle1,Axle2,Area,radial,Ch,Cd,Ce,gears,eff_gear,eff_diff,dif,Torquerpm,TorqueNm,engageTrpm,engageTNm,changeT,rr,Ie,It,Ndrive,gearshiftregime,savePath, runKey, plotOn);
r.YDC = YawD_solve(nVehUnits, savePath, runsPath, runKey, plotOn);
r.RA = RA_solve(mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, plotOn); %must add check to ensure path is tracked to within 30mm/150mm
r.HSTO = HSTO_solve(nAxles, Ltot, savePath, runsPath, runKey, plotOn);
[r.SRTt r.SRTtrrcu] = SRTt_solve(nAxles,nSteer,lim.SRT(Ldesired),SRTrollThresh, mSprung, HcgSprung, rollCoupled, dollys, savePath, runsPath, runKey, plotOn);
r.TASP = TASP_solve(nVehUnits, dollys, savePath, runsPath, runKey, plotOn);
[r.LSSP, r.TS, r.FS, r.MoD, r.DoM, r.STFD] = LSTurn_solve(nVehUnits, dollys, VehWidthLoad, SteerWidth, nSteer, muPeakSteer, true, savePath, runsPath, runKey, plotOn);
[r.LSSPu,r.TSu,r.FSu,r.MoDu,r.DoMu,r.STFDu] = LSTurn_solve(nVehUnits, dollys, VehWidthUnload, SteerWidth, nSteer, muPeakSteer, false, savePath, runsPath, runKey, plotOn);
%% post process the post processed results
results_round = rounder(r);
results = r;

lim.RA = setLimsRA(r);  % is captured as hard code in function below (should read in from stored file)
                        % calculated here before SRTrrcu is rounded off

disp('Analysis complete')

if plotSummary
    runSummaryChart(fullName, r, lim, Ldesired, savePath, runKey, isSemi)
end

r

printResults(results, lim, fullName, nLevels, savePath, runKey, 'results', 'postAxleLoad',  AxleLoading, isSemi)
printResults(results_round, lim, fullName, nLevels, savePath, runKey, 'resultsRounded', 'postAxleLoadRounded', roundAxleLoading, isSemi)

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
function [lim] = setLims(isBus)

lim.STA = [15 12 10 5];
lim.GRAa = [20 15 12 10];
lim.GRAb = [80 70 70 60];
lim.ACC = [20 23 26 29];
lim.YDC = [0.15 0.15 0.15 0.15];
lim.HSTO = [0.6 0.8 1.0 1.2];
if isBus,
    lim.SRT = [0.4 0.4 0.4 0.4];
    lim.FS = [1.5 1.5 1.5 1.5];
else
    lim.SRT = [0.35 0.35 0.35 0.35];
    lim.FS = [0.7 0.7 0.7 0.7];
end
lim.TASP = [2.9 3.0 3.1 3.3];
lim.LSSP = [7.4 8.7 10.6 13.7];
lim.TS = [0.30 0.35 0.35 0.50];
lim.MoD = [0.4 0.4 0.4 0.4];
lim.DoM = [0.2 0.2 0.2 0.2];
lim.STFD = [80 80 80 80];

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
function [] = printResults(r, lim, fullName, nLevels, savePath, runKey, xlsSheet, axleXlsSheet, AxleLoading, isSemi)
warning off MATLAB:xlswrite:AddSheet

savePath = strcat(savePath, '\', runKey, '_summary.xlsx');

results = {}; %Allows for a non-square matrix

results = Appender(results, 'Standard'      , 'units', 'Value', 'NTC Level met', [1:nLevels]);

results = Appender(results, fullName.STA    , '%', r.STA , checkLevel('>', r.STA, lim.STA, nLevels), lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
results = Appender(results, fullName.GRAa   , '%', r.GRAa, checkLevel('>', r.GRAa, lim.GRAa, nLevels), lim.GRAa);
results = Appender(results, fullName.GRAb   , 'km/h', r.GRAb, checkLevel('>', r.GRAb, lim.GRAb, nLevels), lim.GRAb);
results = Appender(results, fullName.ACC    , 's', r.ACC , checkLevel('<', r.ACC, lim.ACC, nLevels), lim.ACC);
results = Appender(results, fullName.SRTt   , 'g', r.SRTt   , checkLevel('>', r.SRTt, lim.SRT, nLevels), lim.SRT);
results = Appender(results, fullName.YDC    , '-', r.YDC    , checkLevel('>', r.YDC, lim.YDC, nLevels), lim.YDC);
results = Appender(results, fullName.RA     , '-', r.RA     , checkLevel('<', r.RA, lim.RA, nLevels), lim.RA);
results = Appender(results, fullName.HSTO   , 'm', r.HSTO   , checkLevel('<', r.HSTO, lim.HSTO, nLevels), lim.HSTO);
results = Appender(results, fullName.TASP   , 'm', r.TASP   , checkLevel('<', r.TASP, lim.TASP, nLevels), lim.TASP);
results = Appender(results, fullName.LSSP   , 'm', r.LSSP   , checkLevel('<', r.LSSP, lim.LSSP, nLevels), lim.LSSP);
results = Appender(results, fullName.TS     , 'm', r.TS     , checkLevel('<', r.TS, lim.TS, nLevels), lim.TS);
results = Appender(results, fullName.FS     , 'm', r.FS     , checkLevel('<', r.FS, lim.FS, nLevels), lim.FS);
if isSemi,%doesnt add MoD, DoM if it is not a SemiTrailer
    results = Appender(results, fullName.MoD    , 'm', r.MoD    , checkLevel('<', r.MoD, lim.MoD, nLevels), lim.MoD);
    results = Appender(results, fullName.DoM    , 'm', r.DoM    , checkLevel('<', r.DoM, lim.DoM, nLevels), lim.DoM);
end
results = Appender(results, fullName.STFD   , '%', r.STFD   , checkLevel('<', r.STFD, lim.STFD, nLevels), lim.STFD);
results = Appender(results, fullName.LSSPu  , 'm', r.LSSPu  , checkLevel('<', r.LSSPu, lim.LSSP, nLevels), lim.LSSP);
results = Appender(results, fullName.TSu    , 'm', r.TSu    , checkLevel('<', r.TSu, lim.TS, nLevels), lim.TS);
results = Appender(results, fullName.FSu    , 'm', r.FSu    , checkLevel('<', r.FSu, lim.FS, nLevels), lim.FS);
if isSemi, %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    results = Appender(results, fullName.MoDu   , 'm', r.MoDu   , checkLevel('<', r.MoDu, lim.MoD, nLevels), lim.MoD);
    results = Appender(results, fullName.DoMu   , 'm', r.DoMu   , checkLevel('<', r.DoMu, lim.DoM, nLevels), lim.DoM);
end
results = Appender(results, fullName.STFDu  , '%', r.STFDu  , checkLevel('<', r.STFDu, lim.STFD, nLevels), lim.STFD);

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
function runSummaryChart(name, r, lim, L, savePath, runKey, isSemi)
if isSemi,
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.MoD name.DoM name.STFD name.LSSPu name.TSu name.FSu name.MoDu name.DoMu name.STFDu};
    res = [r.STA/lim.STA(L) r.GRAa/lim.GRAa(L) r.GRAb/lim.GRAb(L) r.SRTt/lim.SRT(L) r.YDC/lim.YDC(L) r.ACC/lim.ACC(L) r.RA/lim.RA(L) r.HSTO/lim.HSTO(L) r.TASP/lim.TASP(L) r.LSSP/lim.LSSP(L) r.TS/lim.TS(L) r.FS/lim.FS(L) r.MoD/lim.MoD(L) r.DoM/lim.DoM(L) r.STFD/lim.STFD(L) r.LSSPu/lim.LSSP(L) r.TSu/lim.TS(L) r.FSu/lim.FS(L) r.MoDu/lim.MoD(L) r.DoMu/lim.DoM(L) r.STFDu/lim.STFD(L)]*100;
else
    Ylabs = {name.STA name.GRAa name.GRAb name.SRTt name.YDC name.ACC name.RA name.HSTO name.TASP name.LSSP name.TS name.FS name.STFD name.LSSPu name.TSu name.FSu name.STFDu};
    res = [r.STA/lim.STA(L) r.GRAa/lim.GRAa(L) r.GRAb/lim.GRAb(L) r.SRTt/lim.SRT(L) r.YDC/lim.YDC(L) r.ACC/lim.ACC(L) r.RA/lim.RA(L) r.HSTO/lim.HSTO(L) r.TASP/lim.TASP(L) r.LSSP/lim.LSSP(L) r.TS/lim.TS(L) r.FS/lim.FS(L) r.STFD/lim.STFD(L) r.LSSPu/lim.LSSP(L) r.TSu/lim.TS(L) r.FSu/lim.FS(L) r.STFDu/lim.STFD(L)]*100;
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