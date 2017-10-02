%% Function Description
%
% This function will write the generated latex tables for the PBS report into a tex file
%
%% Inputs
%
% * Table: structure containing each of the latex tables generated using latexTable.
%
%% Outputs
%
% * variable: description
%
%% Change Log
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function createLatexTables(Table, filename, PBSassessmentPath)

savePath = strcat(PBSassessmentPath, '\tex');
filepath = strcat(savePath, '\', filename);

fieldNames = fieldnames(Table);
nTables = length(fieldNames);

% save LaTex code as file
fid=fopen(filepath,'w');

for iTable = 1 : nTables
    % save LaTex code as file
    
    [nrows,ncols] = size(Table.(fieldNames{iTable}));
    
    for row = 1:nrows
        fprintf(fid,'%s\n',Table.(fieldNames{iTable}){row,:});
    end
    
    fprintf(fid,'\n');
end

fclose(fid);
fprintf('\n... your LaTex code has been saved as ''filename'' in your working directory\n');

end

