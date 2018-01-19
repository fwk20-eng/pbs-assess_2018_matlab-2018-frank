%% Function Description
%
% Compiles all of the data for the hitch details table in the PBS assessment report
%
%% Inputs
%
% * Hitch
%
%% Outputs
%
% * PBSreportTable: cell array structured correctly to be used with latexTable function
%
%% Change Log
%
% [0.1.0] - 2017-05-09
%
% *Added*
%
% * First code

function [PBSreportTable, logTable] = createTableLatexHitchDetails(Hitch)
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double
%% Table 7:  Hitch Details
% Extracting table contents

nHitches = length(Hitch.DatasetArray);
Table.data = {};
% Loop through the hitches and format the table
for iHitch = 1 : nHitches
    sUnit = int2str(iHitch);
    temp = strsplit(Hitch.DatasetArray{iHitch}{:}, ' (');
    sType = temp{1};
    % Negate TruckSim to get coordinate for X hitch position according to SAE coordinate system
    sLongitudinalPosition = num2str(-Hitch.XPositionArray(iHitch)*1000);
    sHeight = num2str(Hitch.ZPositionArray(iHitch)*1000);
    % Roll moment dataset must be named to suit the PBS assessment report
    temp = strsplit(Hitch.RollMomentArray{iHitch}{:}, ' (');
    sRollStiffness = temp{1};
    
    rowOfDataForTable = {sUnit, sType, sLongitudinalPosition, sHeight, sRollStiffness};
    
    Table.data = [Table.data; rowOfDataForTable];
end

Table.Headings = {'\textbf{Unit}' '\textbf{Hitch type}' '\textbf{Longitudinal position (mm)}\tnote{1}' '\textbf{Height (mm)}\tnote{2}' '\textbf{Roll stiffness (Nm/\degree{})}'};

markdownHeadings = {'Unit' 'Hitch type' 'Longitudinal position (mm)' 'Height (mm)' 'Roll stiffness (Nm/degree)'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.footNotes = {'\item[1] SAE up co-ordinate system and origin taken from centre of steer axle or hitch point at ground level';
                   '\item[2] This hitch height is at the unladen condition and may differ from the hitch height indicated on the GA drawing'};
Table.tableCaption = 'Hitch Details';
Table.tableLabel = 'HitchDetails';
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
