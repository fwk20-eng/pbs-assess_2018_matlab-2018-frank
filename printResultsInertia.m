function [] = printResultsInertia(fileName, savePath, inputHeadings, resultsHeadings, inputs, results, sheetName)
warning off MATLAB:xlswrite:AddSheet %Not sure what this does - copied from postProcess

savePath = strcat(savePath, '\', fileName); %Generating the savePath
try
    Excel = actxGetRunningServer('Excel.application');
catch
    Excel = actxserver('Excel.Application');
end

if exist(savePath,'file') == 0 %If file doesnt exist, add workbook
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(savePath);
    %ExcelWorkbook.Close(false);
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

numInputs = length(inputs);
numResults = length(results);

startResultsHeadings = sprintf('%s%i', 'A', numInputs + 2);
startResults = sprintf('%s%i', 'B', numInputs + 2);

%----Inputs------------------------------------
xlswrite1(savePath, inputHeadings',  sheetName, 'A1');
xlswrite1(savePath, inputs',  sheetName, 'B1');
%----Results------------------------------------
xlswrite1(savePath, resultsHeadings',  sheetName, startResultsHeadings);
xlswrite1(savePath, results',  sheetName, startResults);
    
invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end