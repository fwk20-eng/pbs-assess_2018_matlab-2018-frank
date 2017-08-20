%% Function Description
%
% Compiles all of the data for the reference point details table in the PBS assessment report
%
%% Inputs
%
% * referencePointNames
% * refPointsLadenCell
% * Sprung
% * tableCaption
% * tableLabel
%
%% Outputs
%
% * PBSreportTable: cell array structured correctly to be used with latexTable function
%
%% Change Log
%
% [0.3.0]
%
% *Fixed*
%
% * 
%
% [0.2.0]
%
% *Fixed*
%
% * Added "TASP" to manoeuvre for last 4 reference points
%
% [0.1.0] - 2017-05-09
%
% *Added*
%
% * First code

function PBSreportTable = generateTableReferencePoints(referencePointNames, refPointsLadenCell, Sprung, tableCaption,...
    tableLabel)
%% Table 11:  ReferencePoints (Laden)
% Extracting table contents

% Table.data = [Table.VehicleParameterHeadings columnDataForTable];
Table.data = {};

for iUnit = 1 : Sprung.numberOffUnits
    
    iReferencePointsUnit = iUnit * ones(9,1);
    
    % Only the first 9 reference points are used in the current post processor
    iXref = refPointsLadenCell{iUnit,1}(1:9);
    iYref = refPointsLadenCell{iUnit,2}(1:9);
    iZref = refPointsLadenCell{iUnit,3}(1:9);
    
    sLeftRight = {'Left'; 'Left'; 'Right'; 'Right'; 'Right'; 'Right'; 'Right'; 'Right'; 'Right'};
    sManoeuvre = {'TASP'; 'TASP'; 'FS'; 'FS'; 'FS'; 'TASP \& TS'; 'TASP \& TS'; 'TASP \& TS'; 'TASP \& TS'};
    sReferencePointNumber = {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'};
    sReferencePointsUnit = arrayfun(@(x) num2str(x, '%0.0f'), iReferencePointsUnit, 'UniformOutput', false);
    sXref = arrayfun(@(x) num2str(x, '%0.0f'), iXref, 'UniformOutput', false);
    sYref = arrayfun(@(x) num2str(x, '%0.0f'), iYref, 'UniformOutput', false);
    sZref = arrayfun(@(x) num2str(x, '%0.0f'), iZref, 'UniformOutput', false);
    sRefPointDescription = referencePointNames{iUnit};
    
    referencePointsForUnit = [sReferencePointsUnit, sReferencePointNumber, sManoeuvre, sLeftRight, sRefPointDescription, sXref, sYref, sZref];
    
    Table.data = [Table.data; referencePointsForUnit];
end

Table.Headings = {'\textbf{Unit}'  '\textbf{Pt.}' '\textbf{PM}' '\textbf{L/R}' '\textbf{Description}' '\textbf{X (mm)\tnote{1}}' '\textbf{Y (mm)\tnote{1}}' '\textbf{Z (mm)\tnote{1}}'};
% Compiling the structure fields required by latexTable
Table.footNotes = {'\item[1] SAE up co-ordinate system and origin taken from centre of steer axle or hitch point at ground level'};
Table.data = [Table.Headings; Table.data];
Table.tableCaption = tableCaption;
Table.tableLabel = tableLabel;
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
