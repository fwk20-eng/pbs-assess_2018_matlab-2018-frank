function writeExcelPBSResults(r, Lim, fullName, nLevels, savePath, xlsSheet, axleXlsSheet, AxleLoading, isSemi, fileName)
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

results = addResultsRow(results, 'Standard'      , 'units', 'Value', 'NTC Level met', [1:nLevels]);

results = addResultsRow(results, fullName.STA        , '%'       , r.STA , computePBSLevel('>', r.STA, Lim.STA, nLevels), Lim.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
results = addResultsRow(results, fullName.GRAa       , '%'       , r.GRAa, computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels), Lim.GRAa);
results = addResultsRow(results, fullName.GRAb       , 'km/h'    , r.GRAb, computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels), Lim.GRAb);
results = addResultsRow(results, fullName.ACC        , 's'       , r.ACC , computePBSLevel('<', r.ACC, Lim.ACC, nLevels), Lim.ACC);
results = addResultsRow(results, fullName.SRTt       , 'g'       , r.SRTt   , computePBSLevel('>', r.SRTt, Lim.SRT, nLevels), Lim.SRT);
results = addResultsRow(results, fullName.SRTtrrcu   , 'g'       , r.SRTtrrcu   , '-', []);
results = addResultsRow(results, fullName.YDC        , '-'       , r.YDC    , computePBSLevel('>', r.YDC, Lim.YDC, nLevels), Lim.YDC);
results = addResultsRow(results, fullName.RA         , '-'       , r.RA     , computePBSLevel('<', r.RA, Lim.RA, nLevels), Lim.RA);
results = addResultsRow(results, fullName.HSTO       , 'm'       , r.HSTO   , computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels), Lim.HSTO);
results = addResultsRow(results, fullName.TASP       , 'm'       , r.TASP   , computePBSLevel('<', r.TASP, Lim.TASP, nLevels), Lim.TASP);
results = addResultsRow(results, fullName.LSSP       , 'm'       , r.LSSP   , computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels), Lim.LSSP);
results = addResultsRow(results, fullName.TS         , 'm'       , r.TS     , computePBSLevel('<', r.TS, Lim.TS, nLevels), Lim.TS);
results = addResultsRow(results, fullName.FS         , 'm'       , r.FS     , computePBSLevel('<', r.FS, Lim.FS, nLevels), Lim.FS);
if isSemi %doesnt add MoD, DoM if it is not a SemiTrailer
    results = addResultsRow(results, fullName.MoD    , 'm', r.MoD    , computePBSLevel('<', r.MoD, Lim.MoD, nLevels), Lim.MoD);
    results = addResultsRow(results, fullName.DoM    , 'm', r.DoM    , computePBSLevel('<', r.DoM, Lim.DoM, nLevels), Lim.DoM);
end
results = addResultsRow(results, fullName.STFD   , '%', r.STFD   , computePBSLevel('<', r.STFD, Lim.STFD, nLevels), Lim.STFD);
results = addResultsRow(results, fullName.LSSPu  , 'm', r.LSSPu  , computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels), Lim.LSSP);
results = addResultsRow(results, fullName.TSu    , 'm', r.TSu    , computePBSLevel('<', r.TSu, Lim.TS, nLevels), Lim.TS);
results = addResultsRow(results, fullName.FSu    , 'm', r.FSu    , computePBSLevel('<', r.FSu, Lim.FS, nLevels), Lim.FS);
if isSemi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    results = addResultsRow(results, fullName.MoDu   , 'm', r.MoDu   , computePBSLevel('<', r.MoDu, Lim.MoD, nLevels), Lim.MoD);
    results = addResultsRow(results, fullName.DoMu   , 'm', r.DoMu   , computePBSLevel('<', r.DoMu, Lim.DoM, nLevels), Lim.DoM);
end
results = addResultsRow(results, fullName.STFDu  , '%', r.STFDu  , computePBSLevel('<', r.STFDu, Lim.STFD, nLevels), Lim.STFD);

xlswrite1(savePath, results,  xlsSheet, 'A1');
%% Writes the axle loading to a seperate sheet 
AxleHeadings = {'Axle #';'Load Distribution 1';'Axle Loading 1';'Unloaded Loading 1';'Load Distribution 2';'Axle Loading 2'; 'Unloaded Loading 2'};
xlswrite1(savePath, AxleHeadings, axleXlsSheet,'A1');
xlswrite1(savePath, AxleLoading, axleXlsSheet,'B1');

invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end