function [] = printResultsPBS(r, lim, fullName, nLevels, savePath, xlsSheet, axleXlsSheet, AxleLoading, isSemi, fileName)
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

results = Appender(results, fullName.STA        , '%'       , r.STA , checkLevel('>', r.STA, lim.STA, nLevels), lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
results = Appender(results, fullName.GRAa       , '%'       , r.GRAa, checkLevel('>', r.GRAa, lim.GRAa, nLevels), lim.GRAa);
results = Appender(results, fullName.GRAb       , 'km/h'    , r.GRAb, checkLevel('>', r.GRAb, lim.GRAb, nLevels), lim.GRAb);
results = Appender(results, fullName.ACC        , 's'       , r.ACC , checkLevel('<', r.ACC, lim.ACC, nLevels), lim.ACC);
results = Appender(results, fullName.SRTt       , 'g'       , r.SRTt   , checkLevel('>', r.SRTt, lim.SRT, nLevels), lim.SRT);
results = Appender(results, fullName.SRTtrrcu   , 'g'       , r.SRTtrrcu   , '-', []);
results = Appender(results, fullName.YDC        , '-'       , r.YDC    , checkLevel('>', r.YDC, lim.YDC, nLevels), lim.YDC);
results = Appender(results, fullName.RA         , '-'       , r.RA     , checkLevel('<', r.RA, lim.RA, nLevels), lim.RA);
results = Appender(results, fullName.HSTO       , 'm'       , r.HSTO   , checkLevel('<', r.HSTO, lim.HSTO, nLevels), lim.HSTO);
results = Appender(results, fullName.TASP       , 'm'       , r.TASP   , checkLevel('<', r.TASP, lim.TASP, nLevels), lim.TASP);
results = Appender(results, fullName.LSSP       , 'm'       , r.LSSP   , checkLevel('<', r.LSSP, lim.LSSP, nLevels), lim.LSSP);
results = Appender(results, fullName.TS         , 'm'       , r.TS     , checkLevel('<', r.TS, lim.TS, nLevels), lim.TS);
results = Appender(results, fullName.FS         , 'm'       , r.FS     , checkLevel('<', r.FS, lim.FS, nLevels), lim.FS);
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

xlswrite1(savePath, results,  xlsSheet, 'A1');
%% Writes the axle loading to a seperate sheet 
AxleHeadings = {'Axle #';'Load Distribution 1';'Axle Loading 1';'Unloaded Loading 1';'Load Distribution 2';'Axle Loading 2'; 'Unloaded Loading 2'};
xlswrite1(savePath, AxleHeadings, axleXlsSheet,'A1');
xlswrite1(savePath, AxleLoading, axleXlsSheet,'B1');

invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end