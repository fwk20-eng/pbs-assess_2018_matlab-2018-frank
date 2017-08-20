%% Function Description
%
% Generate the commissioning table to assist the commissioning party
%
%% Inputs
%
% * Table: The structure of tables that have been created so far
% * Axle: Extracted axle details
% * Sprung: Extracted sprung mass details
%
%% Outputs
%
% * CommissioningTable: a structure of structures. Each structure within CommissioningTable will include the structure
% requirements for a latexTable function to generate the table
%
%% Change Log
%
% [0.1.0] - 2017-07-27
%
% *Added*
%
% * First code

function [ComTable] = generateTableCommissioning(Axle, Sprung, Tyre, Hitch, Combination)

%% Required structures
% Modifiers - should actually extract the prime mover model. Getting it from the modifiers is actually going to be a
% pain

nUnits = Sprung.numberOffUnits;

%% Tweaking variables
modelNames = editCombinationCellSplitText(Sprung.DescriptionArray,...
    {' (',' ['}, 1);

%% Creating combination tables
for iUnit = 1:nUnits
    commissioningParameters{iUnit} = {};
    commissioningParameterHeadings{iUnit} = {...
        '\textbf{Parameter}'  '\textbf{Units}' '\textbf{Required Value}' '\textbf{Measured Value}'};
    commissioningAxleFormat = {};
    %% Calculated variables
    %% Number of axles in each unit and split into groups
    indicesOfAxlesInUnit = find(Axle.UnitAndGroup(:,2) == iUnit);
    
    for iAxle = 1:length(indicesOfAxlesInUnit)
        axleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
        % Calculate the number of axles in the first axle group
        if iAxle == 1
            % Number of axles in group 1 on the current unit
            nAxles = sum(Axle.UnitAndGroup(:,3) == axleGroup);
            commissioningAxleFormat{1,3} = int2str(nAxles);
            currentAxleGroup = axleGroup;
            % If moved on to a new axle group, then calculate number of axles in the new axle group
        else if iAxle > 1 && axleGroup ~= currentAxleGroup
                nAxles = sum(Axle.UnitAndGroup(:,3) == axleGroup);
                commissioningAxleFormat{1,3} = [commissioningAxleFormat{1,3} '.' int2str(nAxles)];
                currentAxleGroup = axleGroup;
            end
        end
    end
    
    commissioningAxleFormat{1,1} = 'No. Axles';
    commissioningAxleFormat{1,2} = '-';
    commissioningAxleFormat{1,4} = ' ';
    %% Generating lists where the need arises
    clear axleTyreSize;
    for iAxle = 1:length(Axle.DescriptionCell{iUnit})
        parameterDescription = ['Tyre size - ' Axle.DescriptionCell{iUnit}{iAxle}];
        parameterValue = Tyre.sizes{iUnit}{iAxle};
        if iAxle == 1
            tyreSize = strsplit(parameterValue, ' ');
            % Extracting tyre size
            tyreSize = tyreSize{1};
            
            axleTyreSize{iAxle, 1} = parameterDescription;
            axleTyreSize{iAxle, 2} = '-';
            axleTyreSize{iAxle, 3} = tyreSize;
            axleTyreSize{iAxle, 4} = ' ';
            
            % Check to see if the result is identical to the previous result (no point in duplicate information)
        elseif ~(strcmp(parameterDescription,axleTyreSize{iAxle-1,1})) && ~(strcmp(parameterValue,...
                axleTyreSize{iAxle-1,2}))
            axleTyreSize{iAxle, 1} = parameterDescription;
            axleTyreSize{iAxle, 2} = '-';
            axleTyreSize{iAxle, 3} = tyreSize;
            axleTyreSize{iAxle, 4} = ' ';
            
        end
    end
    
    % For stabiliser, you need them all
    clear axleStabiliser;
    for iAxle = 1:length(Axle.DescriptionCell{iUnit})
        parameterDescription = [Axle.DescriptionCell{iUnit}{iAxle} ' axle stabiliser'];
        parameterValue = Axle.stabiliserModel{iUnit}{iAxle};
        axleStabiliser{iAxle, 1} = parameterDescription;
        axleStabiliser{iAxle, 2} = '-';
        axleStabiliser{iAxle, 3} = parameterValue;
        axleStabiliser{iAxle, 4} = ' ';
    end
    
    %% Calculating the hitch offsets
    if iUnit == 1
        indicesOfAxlesInUnit = find(Axle.UnitAndGroup(:,2) == iUnit);
        indicesOfAxlesInDriveGroup = find(Axle.UnitAndGroup(indicesOfAxlesInUnit(indicesOfAxlesInUnit),3) == 2);
        firstDriveAxleIndex = indicesOfAxlesInDriveGroup(1);
        hitchOffset = (Hitch.XPositionArray(iUnit) - Axle.XPositionArray(firstDriveAxleIndex))*1000; % mm
    elseif iUnit < nUnits
         indicesOfAxlesInUnit = find(Axle.UnitAndGroup(:,2) == iUnit);
         indiceOfFirstAxle = indicesOfAxlesInUnit(1);
         hitchOffset = (Hitch.XPositionArray(iUnit) - Axle.XPositionArray(indiceOfFirstAxle))*1000; % mm
    end
        
    
    %% Generating the table contents for each vehicle unit
    %% First vehicle unit
    if iUnit == 1 % First vehicle unit
        %% Determining the axle positions
        axlePositions = {};
        % First axle is skipped for unit 1
        for iAxle = 2:length(Axle.DescriptionCell{iUnit})
            parameterDescription = ['Distance to axle ' num2words(iAxle) ' rear of steer axle'];
            parameterValue = Axle.XPositionArray(iAxle);
            
            axlePositions{iAxle-1, 1} = parameterDescription;
            axlePositions{iAxle-1, 2} = 'mm';
            axlePositions{iAxle-1, 3} = num2str(parameterValue*1000);
            axlePositions{iAxle-1, 4} = ' ';
        end
        
        commissioningParameters{iUnit} = [
            'Model', '-', modelNames{iUnit}, ' ';
            {'Registration Plate'}, {'-'}, {'\textcolor{gray}{Determine on Site}'}, {' '};
            commissioningAxleFormat;
            axleTyreSize;
            {'Tyre Arrangement'}, {'-'}, Combination.vehicleStringCell{iUnit}, {' '};
            axleStabiliser;
            axlePositions;
            {'Load cell / measurement system'}, {'-'}, {'\textcolor{gray}{On-Board or Other}'}, {' '};
            {'Front overhang of cab'}, {'mm'}, {num2str(Combination.frontalOverhangsRelativeToDatum(iUnit))}, {' '};
            {'Hitch offset (+ behind first drive axle)'}, {'mm'}, num2str(hitchOffset), {' '};
            {'Max trailer projection (incl. payload)'}, {'mm'}, ...
            num2str(Combination.frontalOverhangsRelativeToDatum(iUnit+1)), {' '};
            {'Max height'}, {'mm'}, num2str(Combination.maxHeight(iUnit)), {' '};
            {'Max width'}, {'mm'}, num2str(Combination.maxWidth(iUnit)), {' '};
            {'Overall vehicle length'}, {'mm'}, num2str(Combination.totalLength), {' '};
            {'Abnormal vehicle signage'}, {'-'}, {'Yes'}, {' '};
            {'Amber lights'}, {'-'}, {'Yes'}, {' '};
            {'Marker lights and reflectors'}, {'-'}, {'Yes'}, {' '};
            ];
        %% Second to second last unit
    elseif iUnit < nUnits % Trailing unit that is not the last unit
        axlePositions = {};
        % Determine axle number index based on previous unit axle numbers
        nPreviousAxles = 0;
        for iPrevUnit = (iUnit - 1) : -1 :  1
            nPreviousAxles = nPreviousAxles + length(Axle.DescriptionCell{iPrevUnit});
        end
        
        for iAxle = 1:length(Axle.DescriptionCell{iUnit})
            parameterDescription = ['Distance to axle ' num2words(iAxle) ' rear of hitch position'];
            parameterValue = Axle.XPositionArray(iAxle + nPreviousAxles);
            
            axlePositions{iAxle, 1} = parameterDescription;
            axlePositions{iAxle, 2} = 'mm';
            axlePositions{iAxle, 3} = num2str(parameterValue*1000);
            axlePositions{iAxle, 4} = ' ';
        end
        
        commissioningParameters{iUnit} = [commissioningParameters{iUnit};
            'Model', '-', modelNames{iUnit}, ' ';...
            {'Registration Plate'}, {'-'}, {'\textcolor{gray}{Determine on Site}'}, {' '};
            commissioningAxleFormat;
            axleTyreSize;
            {'Tyre Arrangement'}, {'-'}, Combination.vehicleStringCell{iUnit}, {' '};
            axleStabiliser;
            axlePositions;
            {'Front overhang of payload forward of trailer structure'}, {'mm'},...
            {num2str(Combination.frontalOverhangs(iUnit))}, {' '};
            {'Rear overhang of payload rear of trailer structure'}, {'mm'},...
            {num2str(Combination.rearOverhangs(iUnit))}, {' '};
            {'Hitch offset (+ behind first axle in trailer axle group)'}, {'mm'}, num2str(hitchOffset), {' '};
            {'Max trailer projection (incl. payload)'}, {'mm'}, ...
            num2str(Combination.frontalOverhangsRelativeToDatum(iUnit+1)), {' '};
            {'Max height'}, {'mm'}, num2str(Combination.maxHeight(iUnit)), {' '};
            {'Max width'}, {'mm'}, num2str(Combination.maxWidth(iUnit)), {' '};
            {'Abnormal vehicle signage'}, {'-'}, {'Yes'}, {' '};
            {'Amber lights'}, {'-'}, {'Yes'}, {' '};
            {'Marker lights and reflectors'}, {'-'}, {'Yes'}, {' '};
            ];
        %% Last unit
    elseif iUnit == nUnits % Last vehicle unit
        axlePositions = {};
        % Determine axle number index based on previous unit axle numbers
        nPreviousAxles = 0;
        for iPrevUnit = (iUnit - 1) : -1 : 1
            nPreviousAxles = nPreviousAxles + length(Axle.DescriptionCell{iPrevUnit});
        end
        
        for iAxle = 1:length(Axle.DescriptionCell{iUnit})
            parameterDescription = ['Distance to axle ' num2words(iAxle) ' rear of hitch position'];
            parameterValue = Axle.XPositionArray(iAxle + nPreviousAxles);
            
            axlePositions{iAxle, 1} = parameterDescription;
            axlePositions{iAxle, 2} = 'mm';
            axlePositions{iAxle, 3} = num2str(parameterValue*1000);
            axlePositions{iAxle, 4} = ' ';
        end
        
        commissioningParameters{iUnit} = [commissioningParameters{iUnit};
            'Model', '-', modelNames{iUnit}, ' ';
            {'Registration Plate'}, {'-'}, {'\textcolor{gray}{Determine on Site}'}, {' '};
            commissioningAxleFormat;
            axleTyreSize;
            {'Tyre Arrangement'}, {'-'}, Combination.vehicleStringCell{iUnit}, {' '};
            axleStabiliser;
            axlePositions;
            {'Front overhang of payload forward of trailer structure'}, {'mm'},...
            {num2str(Combination.frontalOverhangs(iUnit))}, {' '};
            {'Rear overhang of payload rear of trailer structure'}, {'mm'},...
            {num2str(Combination.rearOverhangs(iUnit))}, {' '};
            {'Max height'}, {'mm'}, num2str(Combination.maxHeight(iUnit)), {' '};
            {'Max width'}, {'mm'}, num2str(Combination.maxWidth(iUnit)), {' '};
            {'Abnormal vehicle signage'}, {'-'}, {'Yes'}, {' '};
            {'Amber lights'}, {'-'}, {'Yes'}, {' '};
            {'Marker lights and reflectors'}, {'-'}, {'Yes'}, {' '};
            ];
    end
    
    tableName = ['commissioning', num2words(iUnit, 'case', 'sentence')];
    
    Table.tablePlacement = 'H';
    Table.userAlignment = 'R|C|L|m{50mm}|';
    Table.data = [commissioningParameterHeadings{iUnit}; commissioningParameters{iUnit}];
    Table.tableCaption = ['Commissioning Table for Vehicle Unit ', num2words(iUnit, 'case', 'sentence')];
    Table.tableLabel = ['tblCommissioning', num2words(iUnit, 'case', 'sentence')];
    Table.booktabs = 0;
    Table.tableBorders = 1;
    
    ComTable.(tableName) = latexTable(Table);
    
    ComTable.(tableName) = [...
        '\newpage';
        ' ';
        ['\section{Commissioning for Unit ' num2str(iUnit) ' of ' num2str(nUnits) ': \reportTitle{}}'];
        ' ';
        '\underline{Commissioning Details:}';
        ' ';
        'Date: \hfill \line(1,0){400}';
        ' ';
        'Operator: \hfill \line(1,0){400}';
        ' ';
        'CGM: \underline{\combGCM{}}';
        ' ';
        '\underline{Assessor Details:}';
        ' ';
        'Name: \hfill \line(1,0){400}';
        ' ';
        'Affiliation: \hfill \line(1,0){400}';
        ' ';
        '\vfill';
        ' ';       
        ComTable.(tableName)
        ];
end

end