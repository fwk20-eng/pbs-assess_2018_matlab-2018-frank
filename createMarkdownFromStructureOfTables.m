%% Function Description
%
% This function takes a stucture containing markdown formatted tables and writes them in sequence into a markdown file
%
%% Inputs
%
% * variable: description
%
%% Outputs
%
% * variable: description
%
%% Change Log
%
% [0.1.1] - 2018-06-03
%
% *Fixed*
%
% * Updated fopen to append to account for writing of the maxLatError and maxAy
%
%
% [0.1.0] - 2017-10-04
%
% *Added*
%
% * First code


function createMarkdownFromStructureOfTables(Table, savePath, fileName)

filePath = strcat(savePath, '\', fileName);

fieldNames = fieldnames(Table);
nTables = length(fieldNames);

% save LaTex code as file
fid=fopen(filePath,'a');

for iTable = 1 : nTables
    % save LaTex code as file
    
    [nrows,~] = size(Table.(fieldNames{iTable}));
    
    for row = 1:nrows
        fprintf(fid,'%s\n',Table.(fieldNames{iTable}){row,:});
    end
    
    fprintf(fid,'\n');
end

fclose(fid);
fprintf(['\n... your log file named ', fileName, ' has been modified\n']);

end
