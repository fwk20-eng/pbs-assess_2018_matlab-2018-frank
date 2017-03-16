%Changelogs
%Ver 1.0
%   -> First iteration
%Ver 2.0
%   -> Added excel com server ability to improve speed
%Ver 3.0
%   -> Added functionality to do rounded and raw axle loads in the same
%   book
function [] = printResultsAxleLoads(fileName, savePath, loadMat, loadHeadings, Acomb, groupingHeadings)
warning off MATLAB:xlswrite:AddSheet %Not sure what this does - copied from postProcess
savePath = strcat(savePath, '\', fileName); %Generating the savePath
%----Inputs------------------------------------
try
    Excel = actxGetRunningServer('Excel.application');
catch
    Excel = actxserver('Excel.Application');
end

if exist(savePath,'file') == 0 %If file doesnt exist, add workbook
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

writeExcel(savePath, 'axleLoads', loadMat, loadHeadings, Acomb, groupingHeadings, 0);
writeExcel(savePath, 'axleLoadsRounded', loadMat, loadHeadings, Acomb, groupingHeadings, 1);

Excel.Sheets.Item(1).Delete; %Might be problematic if running multiple times
Excel.Visible = 1;
invoke(Excel.ActiveWorkbook,'Save');
Excel.delete
clear Excel
end

%Function that writes the data to excel
function [] = writeExcel(savePath, sheetName, loadMat, loadHeadings, Acomb, groupingHeadings, isRounded)
Excel = actxGetRunningServer('Excel.application');
switch isRounded
    case 0 %output not to be rounded
        xlswrite1(savePath, groupingHeadings(1,:),  sheetName, 'A1');
        %xlswrite1(savePath, Acomb,  sheetName, 'A2');
        xlswrite1(savePath, Acomb(1:2,:),  sheetName, 'A2');
        xlswrite1(savePath,{'GCM'; sum(Acomb(1,:))}, sheetName, sprintf('%s%s',xlscol(length(groupingHeadings)+1),'1'));
        xlswrite1(savePath,{'Calculated using axleLoadCalc and individual masses'; 'Calculated using AxleLoade and combined masses'}, sheetName, sprintf('%s%s',xlscol(length(groupingHeadings)+2),'2'));
        xlswrite1(savePath, loadHeadings(1,:),  sheetName, 'A4');
        iCol = 1;
        
        for i = 1:length(loadMat) %Loop through the number of units
            if i > 1 %Add spaces if not the first unit
                iCol = iCol + 1;
            end
            for ii = 1:length(loadMat{1,i}) %Loop through the load matrix for each unit
                xlswrite1(savePath, loadMat{1,i}{1,ii}(:,1),  sheetName, sprintf('%s%s',xlscol(iCol),'5'));
                iCol = iCol + 1;
            end
        end
    case 1 %output to be rounded
        xlswrite1(savePath, groupingHeadings(1,:),  sheetName, 'A1');
        xlswrite1(savePath, round(Acomb(1:2,:),0),  sheetName, 'A2');
        %xlswrite1(savePath, round(Acomb,0),  sheetName, 'A2');
        xlswrite1(savePath,{'GCM'; round(sum(Acomb(1,:)),0)}, sheetName, sprintf('%s%s',xlscol(length(groupingHeadings)+1),'1'));
        xlswrite1(savePath,{'Calculated using axleLoadCalc and individual masses'; 'Calculated using AxleLoade and combined masses'}, sheetName, sprintf('%s%s',xlscol(length(groupingHeadings)+2),'2'));
        xlswrite1(savePath, loadHeadings(1,:),  sheetName, 'A4');
        iCol = 1;
        
        for i = 1:length(loadMat) %Loop through the number of units
            if i > 1 %Add spaces if not the first unit
                iCol = iCol + 1;
            end
            for ii = 1:length(loadMat{1,i}) %Loop through the load matrix for each unit
                switch ii
                    case 1
                        xlswrite1(savePath,loadMat{1,i}{1,ii}(:,1),  sheetName, sprintf('%s%s',xlscol(iCol),'5')); %Do not round when it is the heading column
                    otherwise
                        xlswrite1(savePath, round(loadMat{1,i}{1,ii}(:,1),0), sheetName, sprintf('%s%s',xlscol(iCol),'5')); %Round when it is not a heading column
                end
                
                iCol = iCol + 1;
            end
        end
end
end