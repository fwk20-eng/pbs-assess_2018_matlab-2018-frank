function [Data, error] = readData(keyword, varNames, varLengths, spacer, skip, savePath, runsPath, runKey, ...
    specialNumbering)

% Do not need to copy files in this step, so copy set to 0
[filename, error] = getRun(keyword, savePath, runsPath, runKey, 0); 

if error == 1
    load(filename);
else
    return          % problem with files in directory
end

% Data{1} is always going to be time
Data(1) = {Time};

% copy all variables in varNames into Data
for iVar = 1:length(varNames)       
    for iUnit = 1:varLengths(iVar)
        % since numbering is e.g. Ay, Ay_2, Ay_3
        if iUnit == 1 && ~specialNumbering(iVar) 
            Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
        % only process if iUnit does not appear in skip or 1st entry does include a 1 (e.g. tyre forces) 
        elseif sum(iUnit == skip(:)) == 0        
            Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(iUnit)])};
        end       
    end
end

end