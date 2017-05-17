function [Data, error] = readData(keyword, varNames, varLengths, spacer, skip, savePath, runsPath, runKey, specialNumbering)

[filename, error] = getRun(keyword, savePath, runsPath, runKey, 0); % Do not need to copy files in this step

if error == 1
    load(filename);
else
    return          % problem with files in directory
end


Data(1) = {Time};

for iVar = 1:length(varNames)       % copy all variables in varNames into Data
    for iUnit = 1:varLengths(iVar)    
        if iUnit == 1 && ~specialNumbering(iVar) % since numbering is e.g. Ay, Ay_2, Ay_3
            Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
        elseif sum(iUnit == skip(:)) == 0        % only process if iUnit does not appear in skip or 1st entry does include a 1 (e.g. tyre forces) 
            Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(iUnit)])};
        end       
    end
end

end