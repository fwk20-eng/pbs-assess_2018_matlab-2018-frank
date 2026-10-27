%% Function Description
%
% Removes NaN from excel data extractions. It looks at the first row and column and eliminates any NaN's after the first
% NaN
%
%% Inputs
%
% * dataset: A matrix/array/cell with values where rows/columns may include NAN values
%
%% Outputs
%
% * trimmedDataset: The dataset is trimmed such that all data is removed after the first NAN value found in the first
% column and row
%
%% Change Log
%
% [0.1.0] - 2017-10-26
%
% *Added*
%
% * First code

function trimmedDataset = removeNAN(dataset)

switch class(dataset)
    
    case 'cell'
        disp('Cell not supported yet, to be added in the future');
        
    case 'double'
        firstRow = dataset(1,:);
        firstColumn = dataset(:,1);
        
        nanIndicesRow = find(isnan(firstRow));
        nanIndicesColumn = find(isnan(firstColumn));
        
        % Find last valid row if there are NaN values
        if ~isempty(nanIndicesRow)
            nValidColumns = nanIndicesRow(1) - 1;
        else
            nValidColumns = size(dataset,2);
        end
        
        % Find last valid column if there are NaN values
        if ~isempty(nanIndicesColumn)
            nValidRows = nanIndicesColumn(1) - 1;
        else
            nValidRows = size(dataset,1);
        end
        
        trimmedDataset = dataset(1:nValidRows, 1:nValidColumns);
        
    otherwise
        disp('Invalid datatype - only works with cells or arrays (double)');
        
end
end