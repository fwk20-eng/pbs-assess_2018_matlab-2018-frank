%% Function Description
%
% Takes a table, assumes the first row is a header row and creates a markdowntable
%
%% Inputs
%
% * table: a cell array of strings containing the data for the
%
%% Outputs
%
% * markdownTable: cell array of strings with each row containing a row of the table. This can be written to a .md file
% and then be viewed in any markdown editor
%
%% Change Log
%
% [0.2.0] - 2017-10-04
%
% * Added ability to print a heading with the table
%
% [0.1.0] - 2017-06-24
%
% *Added*
%
% * First code

function markdownTable = markdownTable(RawTable)

%% Create results header row
nRows = size(RawTable.data,1);
nColumns = size(RawTable.data,2);
header = '|';
headerDivider = '|';

tableStructure = class(RawTable.data);

for iCol = 1 : nColumns
    
    switch tableStructure
        case 'double'
            entry = RawTable.data(1,iCol);
        case 'cell'
            entry = RawTable.data{1,iCol};
    end
    
    if isa(entry,'double')
        entry = num2str(entry);
    end
    
    header = [header, entry, '|'];
    headerDivider = [headerDivider, '---|'];
end

markdownTable = {header; headerDivider};

%% Generating the remaining rows
for iRow = 2 : nRows
    row = '|';
    for iCol = 1 : nColumns
        
        switch tableStructure
            case 'double'
                entry = RawTable.data(iRow,iCol);
            case 'cell'
                entry = RawTable.data{iRow,iCol};
        end
        
        if isa(entry,'double')
            entry = num2str(entry);
        end
        
        row = [row, entry, '|'];
    end
    markdownTable = [markdownTable; row];
end

%% Add a heading to the table if a label field exists

if isfield(RawTable, 'label')
    tableLabel = ['#### ', RawTable.label];
    markdownTable = [tableLabel; ''; markdownTable];
end

end