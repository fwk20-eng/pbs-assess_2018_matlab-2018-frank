%% Function Description
%
% Compiles all of the data for the payload details table in the PBS assessment report
%
%% Inputs
%
% * Sprung
% * Payload
% * caption
% * label
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

function [PBSreportTable, logTable] = createTableLatexPayloadDetails(Sprung, Payload, caption, label)
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double

%% Removing trucksim modifiers from payload

try
    payloadDetailsForReport = editCombinationCellSplitText(Payload.DescriptionCell, {' (',' ['}, 1);
catch
    disp('No valid payloads found');
end

%% Extracting table contents

Table.data = {};

for iUnit = 1 : Sprung.numberOffUnits
    
    nPayloads = length(Payload.MassCell{iUnit});
    if nPayloads == 0
        sUnit = int2str(iUnit);
        sPayloadDescription = 'Payloads if any are taken into account in the sprung mass';
        sMass = '-';
        sCoG = '-';
        sMOI = '-';
        rowOfDataForTable = {sUnit, sPayloadDescription, sMass, sCoG, sMOI};
        Table.data = [Table.data; rowOfDataForTable];
    else
        for iPayload = 1 : nPayloads
            sUnit = int2str(iUnit);
            sMass = int2str(Payload.MassCell{iUnit}(iPayload));
            sPayloadDescription = payloadDetailsForReport{iUnit}{iPayload};
            sMOIx = num2str(Payload.MOIxCell{iUnit}(iPayload), '%0.0f');
            sMOIy = num2str(Payload.MOIyCell{iUnit}(iPayload), '%0.0f');
            sMOIz = num2str(Payload.MOIzCell{iUnit}(iPayload), '%0.0f');
            
            sMOI = sprintf('%s%s%s%s%s', sMOIx, '; ', sMOIy, '; ', sMOIz);
            
            % *Note:*
            % *1. Due to the unit coversions for the post processor, the CoG positions must be converted back to mm, hence
            % the x 1000 in the expressions below. If the post processor gets unified to mm in all cases, this will need to be
            % updated. Since CoGy is not used in the Post Processor, it is not converted to m and does not need to be converted
            % back to mm.
            % *2. Since the coordinate system within the report is according to the SAE system, and the way that the CoGx is
            % entered into TruckSim is opposite, the value for CoGx for the report must be negated.
            sCoGx = num2str(-Payload.CoGxPositionCell{iUnit}(iPayload)*1000, '%0.0f');
            sCoGy = num2str(Payload.CoGyPositionCell{iUnit}(iPayload), '%0.0f');
            sCoGz = num2str(Payload.CoGzPositionCell{iUnit}(iPayload)*1000, '%0.0f');
            
            sCoG = sprintf('%s%s%s%s%s%s%s', '(',sCoGx, '; ', sCoGy, '; ', sCoGz, ')');
            
            rowOfDataForTable = {sUnit, sPayloadDescription, sMass, sCoG, sMOI};
            Table.data = [Table.data; rowOfDataForTable];
        end
    end
    
end

%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
Table.Headings = {'\textbf{Unit}' '\textbf{Payload description}' '\textbf{Mass (kg)}' '\textbf{Moments of inertia (kg.m\sstw{}) Ixx; Iyy; Izz}' '\textbf{CoG position (mm) (x;y;z)}\tnote{1}'};

markdownHeadings = {'Unit' 'Payload description' 'Mass (kg)' 'Moments of inertia (kg.m2) Ixx; Iyy; Izz' 'CoG position (mm) (x;y;z)'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.footNotes = {'\item[1] SAE up co-ordinate system and origin taken from centre of steer axle or hitch point at ground level'};
Table.userAlignment = 'c|C|C|C|C|';
Table.tableCaption = caption;
Table.tableLabel = label;
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
