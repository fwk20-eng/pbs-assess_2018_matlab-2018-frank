%% Function Description
%
% Compiles all of the data for the unsprung mass details table in the PBS assessment report
%
%% Inputs
%
% * Sprung
%
%% Outputs
%
% * Table: a structure containing all the details in table three for a PBS report including the latex settings
%
%% Change Log
%
% [0.1.0] - 2017-05-08
%
% *Added*
%
% * First code

function [PBSreportTable, logTable] = createTableLatexUnloadedSprungMassDetails(Sprung)
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double
%% Extracting table contents
Table.data = {};

for iUnit = 1 : Sprung.numberOffUnits
    
    sUnit = int2str(iUnit);
    sMass = int2str(Sprung.MassArray(iUnit));
    
    sMOIx = num2str(Sprung.MOIx(iUnit), '%0.0f');
    sMOIy = num2str(Sprung.MOIy(iUnit), '%0.0f');
    sMOIz = num2str(Sprung.MOIz(iUnit), '%0.0f');
    
    sMOI = sprintf('%s%s%s%s%s', sMOIx, '; ', sMOIy, '; ', sMOIz);
    
    % *Note:* 
    % *1. Due to the unit coversions for the post processor, the CoG positions must be converted back to mm, hence
    % the x 1000 in the expressions below. If the post processor gets unified to mm in all cases, this will need to be
    % updated. Since CoGy is not used in the Post Processor, it is not converted to m and does not need to be converted
    % back to mm.
    % *2. Since the coordinate system within the report is according to the SAE system, and the way that the CoGx is
    % entered into TruckSim is opposite, the value for CoGx for the report must be negated.
    sCoGx = num2str(-Sprung.MassCoGxPosition(iUnit)*1000, '%0.0f');
    sCoGy = num2str(Sprung.MassCoGyPosition(iUnit), '%0.0f');
    sCoGz = num2str(Sprung.MassCoGzPosition(iUnit)*1000, '%0.0f');
    
    sCoG = sprintf('%s%s%s%s%s%s%s', '(',sCoGx, '; ', sCoGy, '; ', sCoGz, ')');
    
    rowOfDataForTable = {sUnit, sMass, sMOI, sCoG};
    Table.data = [Table.data; rowOfDataForTable];
    
end
%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
Table.Headings = {'\textbf{Unit}' '\textbf{Mass (kg)}' '\textbf{Moments of inertia (kg.m\sstw{}) Ixx; Iyy; Izz}' '\textbf{CoG position (mm) (x;y;z)}\tnote{1}'};

markdownHeadings = {'Unit' 'Mass (kg)' 'Moments of inertia (kg.m2) Ixx; Iyy; Izz' 'CoG position (mm) (x;y;z)'};
MdTable.data = [markdownHeadings; Table.data];

%% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.footNotes = {'\item[1] SAE up co-ordinate system and origin taken from centre of steer axle or hitch point at ground level'};
Table.tableCaption = 'Unloaded Sprung Mass Values, Moments of Inertia and CoG Positions';
Table.tableLabel = 'UnloadedSprungMassValuesMomentsOfInertiaAndCoGPositions';
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
