function [Data, error] = readSimulationVariables_WithDummyAxles(MatKey, varNames, varLengths, spacer, skip, savePath, runsPath, runKey,...
    specialNumbering)

[filename, error] = copySimulationFiles(MatKey{1}, MatKey{2}, savePath, runsPath, runKey, 0); % You do not need to copy files in this step

if error == 1
    load(filename);
else
    return          % problem with files in directory
end

Data(1) = {Time};

for iVar = 1:length(varNames)       % copy all variables in varNames into Data
    
    if length(varLengths{iVar}) == 1
        % If a single number is passed through, the readSimulationVariables can execute as per normal
        for iUnit = 1:varLengths{iVar}
            if iUnit == 1 && specialNumbering(iVar) == 3
                Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
                % Unit 2 and above reference points with 2017.1 sensors
            elseif specialNumbering(iVar) == 3
                splitVariableName = strsplit(varNames{iVar}, '_S');
                Data(iVar+1, iUnit) = {eval([splitVariableName{1} '_S' int2str(iUnit - 1) splitVariableName{2}])};
                % Situation where a variable has a zero suffix relative to the unit such as for additional accel. sensors
            elseif specialNumbering(iVar) == 2
                Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(iUnit) '0'])};
                % since numbering is e.g. Ay, Ay_2, Ay_3
            elseif iUnit == 1 && ~specialNumbering(iVar)
                Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
                % only process if iUnit does not appear in skip or 1st entry does include a 1 (e.g. tyre forces)
            elseif sum(iUnit == skip(:)) == 0
                Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(iUnit)])};
            end
        end
    else
        % If instead a vector array has been passed through, the readSimulationVariables can read specific variables, skipping dummy variables
        for iUnit = 1:length(varLengths{iVar})
            if iUnit == 1 && specialNumbering(iVar) == 3
                Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
                % Unit 2 and above reference points with 2017.1 sensors
            elseif specialNumbering(iVar) == 3
                splitVariableName = strsplit(varNames{iVar}, '_S');
                Data(iVar+1, iUnit) = {eval([splitVariableName{1} '_S' int2str(varLengths{iVar}(iUnit) - 1) splitVariableName{2}])};
                % Situation where a variable has a zero suffix relative to the unit such as for additional accel. sensors
            elseif specialNumbering(iVar) == 2
                Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(varLengths{iVar}(iUnit)) '0'])};
                % since numbering is e.g. Ay, Ay_2, Ay_3
            elseif iUnit == 1 && ~specialNumbering(iVar)
                Data(iVar+1, iUnit) = {eval([varNames{iVar}])};
                % only process if iUnit does not appear in skip or 1st entry does include a 1 (e.g. tyre forces)
            elseif sum(iUnit == skip(:)) == 0
                Data(iVar+1, iUnit) = {eval([varNames{iVar} spacer{iVar} int2str(varLengths{iVar}(iUnit))])};
            end
        end
    end
end
end