function printResultsPBS(r, Lim, fullName, nLevels, savePath, xlsSheet, axleXlsSheet, AxleLoading, isSemi, fileName)
warning off MATLAB:xlswrite:AddSheet
savePath = strcat(savePath, '\', fileName);

try
    Excel = actxGetRunningServer('Excel.application');
catch
    Excel = actxserver('Excel.Application');
end

doesFileExist = exist(savePath,'file');

if  doesFileExist == 0 %If file doesnt exist, add workbook
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(savePath);
    ExcelWorkbook.Close(false);
end

try
    invoke(Excel.Workbooks,'Open',savePath);
catch
    Excel.Quit;
    Excel.delete;
    clear Excel;
    try
        Excel = actxGetRunningServer('Excel.application');
    catch
        Excel = actxserver('Excel.Application');
    end
    invoke(Excel.Workbooks,'Open',savePath);
end

results = {}; %Allows for a non-square matrix

results = Appender(results, 'Standard'      , 'units', 'Value', 'NTC Level met', [1:nLevels]);

results = Appender(results, fullName.STA        , '%'       , r.STA , checkLevel('>', r.STA, Lim.STA, nLevels), Lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
results = Appender(results, fullName.GRAa       , '%'       , r.GRAa, checkLevel('>', r.GRAa, Lim.GRAa, nLevels), Lim.GRAa);
results = Appender(results, fullName.GRAb       , 'km/h'    , r.GRAb, checkLevel('>', r.GRAb, Lim.GRAb, nLevels), Lim.GRAb);
results = Appender(results, fullName.ACC        , 's'       , r.ACC , checkLevel('<', r.ACC, Lim.ACC, nLevels), Lim.ACC);
results = Appender(results, fullName.SRTt       , 'g'       , r.SRTt   , checkLevel('>', r.SRTt, Lim.SRT, nLevels), Lim.SRT);
results = Appender(results, fullName.SRTtrrcu   , 'g'       , r.SRTtrrcu   , '-', []);
results = Appender(results, fullName.YDC        , '-'       , r.YDC    , checkLevel('>', r.YDC, Lim.YDC, nLevels), Lim.YDC);
results = Appender(results, fullName.RA         , '-'       , r.RA     , checkLevel('<', r.RA, Lim.RA, nLevels), Lim.RA);
results = Appender(results, fullName.HSTO       , 'm'       , r.HSTO   , checkLevel('<', r.HSTO, Lim.HSTO, nLevels), Lim.HSTO);
results = Appender(results, fullName.TASP       , 'm'       , r.TASP   , checkLevel('<', r.TASP, Lim.TASP, nLevels), Lim.TASP);
results = Appender(results, fullName.LSSP       , 'm'       , r.LSSP   , checkLevel('<', r.LSSP, Lim.LSSP, nLevels), Lim.LSSP);
results = Appender(results, fullName.TS         , 'm'       , r.TS     , checkLevel('<', r.TS, Lim.TS, nLevels), Lim.TS);
results = Appender(results, fullName.FS         , 'm'       , r.FS     , checkLevel('<', r.FS, Lim.FS, nLevels), Lim.FS);
if isSemi %doesnt add MoD, DoM if it is not a SemiTrailer
    results = Appender(results, fullName.MoD    , 'm', r.MoD    , checkLevel('<', r.MoD, Lim.MoD, nLevels), Lim.MoD);
    results = Appender(results, fullName.DoM    , 'm', r.DoM    , checkLevel('<', r.DoM, Lim.DoM, nLevels), Lim.DoM);
end
results = Appender(results, fullName.STFD   , '%', r.STFD   , checkLevel('<', r.STFD, Lim.STFD, nLevels), Lim.STFD);
results = Appender(results, fullName.LSSPu  , 'm', r.LSSPu  , checkLevel('<', r.LSSPu, Lim.LSSP, nLevels), Lim.LSSP);
results = Appender(results, fullName.TSu    , 'm', r.TSu    , checkLevel('<', r.TSu, Lim.TS, nLevels), Lim.TS);
results = Appender(results, fullName.FSu    , 'm', r.FSu    , checkLevel('<', r.FSu, Lim.FS, nLevels), Lim.FS);
if isSemi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    results = Appender(results, fullName.MoDu   , 'm', r.MoDu   , checkLevel('<', r.MoDu, Lim.MoD, nLevels), Lim.MoD);
    results = Appender(results, fullName.DoMu   , 'm', r.DoMu   , checkLevel('<', r.DoMu, Lim.DoM, nLevels), Lim.DoM);
end
results = Appender(results, fullName.STFDu  , '%', r.STFDu  , checkLevel('<', r.STFDu, Lim.STFD, nLevels), Lim.STFD);

xlswrite1(savePath, results,  xlsSheet, 'A1');
%% Writes the axle loading to a seperate sheet 
AxleHeadings = {'Axle #';'Load Distribution 1';'Axle Loading 1';'Unloaded Loading 1';'Load Distribution 2';'Axle Loading 2'; 'Unloaded Loading 2'};
xlswrite1(savePath, AxleHeadings, axleXlsSheet,'A1');
xlswrite1(savePath, AxleLoading, axleXlsSheet,'B1');

invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end