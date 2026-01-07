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
% [0.5.0] - 2018-02-08
%
% *Changed*
%
% Added a single referencepointnames variable into this section,all reference points will be labelled according to front/rear as a generic to avoid complexity in reporting
%
% [0.4.0]
%
% * Dolly unit support (no reference points printed for dolly)
%
% [0.3.0]
%
% *Fixed*
%
% * Hitch height compensation removed due to bug fix in TruckSim 2017.1
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

function [PBSreportTable, logTable] = createTableLatexReferencePoints(refPointsLadenCell,...
    Sprung, Combination, tableCaption, tableLabel)

Table.data = {};

referencePointNames = {...
    'Front';...% 1
    'Front';...% 2
    'Front';...% 3
    'Front';...% 4
    'Front';...% 5
    'Rear';...% 6
    'Rear';...% 7
    'Rear';...% 8
    'Rear'};% 9

nDollys = length(Combination.dollys_trailerFrontAxles);
nUnitsWithReferencePoints = Sprung.numberOffUnits - nDollys;

for iUnit = 1 : Sprung.numberOffUnits
    % Do not print reference points if a dolly unit
    if ~any(iUnit == Combination.dollys_trailerFrontAxles)
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
        sRefPointDescription = referencePointNames;
        
        referencePointsForUnit = [sReferencePointsUnit, sReferencePointNumber, sManoeuvre, sLeftRight, sRefPointDescription, sXref, sYref, sZref];
        
        Table.data = [Table.data; referencePointsForUnit];
    end

end

Table.Headings = {'\textbf{Sprung unit}'  '\textbf{Pt.}' '\textbf{PM}' '\textbf{L/R}' '\textbf{Description}' '\textbf{X (mm)\tnote{1}}' '\textbf{Y (mm)\tnote{1}}' '\textbf{Z (mm)\tnote{1}}'};

markdownHeadings = {'Sprung unit' 'Pt.' 'PM' 'L/R' 'Description' 'X (mm)' 'Y (mm)' 'Z (mm)'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.footNotes = {'\item[1] SAE up co-ordinate system and origin taken from centre of steer axle or hitch point at ground level'};
Table.data = [Table.Headings; Table.data];
Table.tableCaption = tableCaption;
Table.tableLabel = tableLabel;
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
