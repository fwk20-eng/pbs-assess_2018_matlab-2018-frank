function printResultsPBSnotes(resultsWithLevel, savePath, xlsSheet, axleXlsSheet, AxleLoading, fileName, runNotes)
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

xlswrite1(savePath, runNotes, 'Run Notes','A1');
xlswrite1(savePath, resultsWithLevel,  xlsSheet, 'A1');
%% Writes the axle loading to a seperate sheet 
AxleHeadings = {'Axle #';'Load Distribution 1';'Axle Loading 1';'Unloaded Loading 1';'Load Distribution 2';'Axle Loading 2'; 'Unloaded Loading 2'};
xlswrite1(savePath, AxleHeadings, axleXlsSheet,'A1');
xlswrite1(savePath, AxleLoading, axleXlsSheet,'B1');

invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end