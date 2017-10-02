nUnits = Sprung.numberOffUnits;

%% Tweaking variables
modelNames = editCombinationCellSplitText(Sprung.DescriptionArray,...
    {' (',' ['}, 1);

%% Creating combination tables
for iUnit = 1:nUnits
    commissioningParameters{iUnit} = {};
    commissioningParameters{iUnit} = {'\textbf{Parameter}' '\textbf{Units}'  '\textbf{Required Value}'};
    
    %% Calculated variables
    nAxlesInGroup = sum(Axle.UnitAndGroup(:,2)==iUnit); % Parameter 1
    
    %% Generating lists where the need arises
    clear axleTyreSize;
    for iAxle = 1:length(Axle.DescriptionCell{iUnit})
        parameterDescription = [Axle.DescriptionCell{iUnit}{iAxle} ' tyre size'];
        parameterValue = Tyre.sizes{iUnit}{iAxle};
        if iAxle == 1
            axleTyreSize{iAxle, 1} = parameterDescription;
            axleTyreSize{iAxle, 2} = parameterValue;
            % Check to see if the result is identical to the previous result (no point in duplicate information)
        elseif ~(strcmp(parameterDescription,axleTyreSize{iAxle-1,1})) && ~(strcmp(parameterValue,axleTyreSize{iAxle-1,2}))
            axleTyreSize{iAxle, 1} = parameterDescription;
            axleTyreSize{iAxle, 2} = parameterValue;
        end
    end
    
    % For stabiliser, you need them all
    clear axleStabiliser;
    for iAxle = 1:length(Axle.DescriptionCell{iUnit})
        parameterDescription = [Axle.DescriptionCell{iUnit}{iAxle} ' axle stabiliser'];
        parameterValue = Axle.stabiliserModel{iUnit}{iAxle};
        %         if iAxle == 1
        axleStabiliser{iAxle, 1} = parameterDescription;
        axleStabiliser{iAxle, 2} = parameterValue;
        % Check to see if the result is identical to the previous result (no point in duplicate information)
        %         elseif ~(strcmp(parameterDescription,axleStabiliser{iAxle-1,1})) && ~(strcmp(parameterValue,axleStabiliser{iAxle-1,2}))
        %             axleStabiliser{iAxle, 1} = parameterDescription;
        %             axleStabiliser{iAxle, 2} = parameterValue;
        %         end
    end
    
    %% parameter cell
    if iUnit == 1
        commissioningParameters{iUnit} = [commissioningParameters{iUnit};...
            'Model', modelNames{iUnit};...
            {'Registration Plate'}, {'\textcolor{gray}{Enter on Site}'};...
            {'# Axles'}, {num2str(nAxlesInGroup)};...
            axleTyreSize;
            axleStabiliser;
            {'Load cell / measurement system'}, {'\textcolor{gray}{Enter on Site}'};
            {'Front overhang'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to first drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to second drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Hitch offset (+ in front of first drive axle)'}, {'\textcolor{gray}{Enter on Site}'};
            {'Trailer projection'}, {'\textcolor{gray}{Enter on Site}'};
            {'Height'}, {'\textcolor{gray}{Enter on Site}'};
            {'Width (bumper)'}, {'\textcolor{gray}{Enter on Site}'};
            {'Overall vehicle length'}, {'\textcolor{gray}{Enter on Site}'};
            {'Abnormal vehicle signage'}, {'\textcolor{gray}{Enter on Site}'};
            {'Amber lights'}, {'\textcolor{gray}{Enter on Site}'};
            {'Marker lights and reflectors'}, {'\textcolor{gray}{Enter on Site}'};
            ];
    elseif iUnit < nUnits
        commissioningParameters{iUnit} = [commissioningParameters{iUnit};...
            'Model', modelNames{iUnit};...
            {'Registration Plate'}, {'\textcolor{gray}{Enter on Site}'};...
            {'# Axles'}, {num2str(nAxlesInGroup)};...
            axleTyreSize;
            axleStabiliser;
            {'Load cell / measurement system'}, {'\textcolor{gray}{Enter on Site}'};
            {'Front overhang'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to first drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to second drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Hitch offsed (in front of the axle group)'}, {'\textcolor{gray}{Enter on Site}'};
            {'Trailer projection'}, {'\textcolor{gray}{Enter on Site}'};
            {'Height'}, {'\textcolor{gray}{Enter on Site}'};
            {'Width (bumper)'}, {'\textcolor{gray}{Enter on Site}'};
            {'Overall vehicle length'}, {'\textcolor{gray}{Enter on Site}'};
            {'Abnormal vehicle signage'}, {'\textcolor{gray}{Enter on Site}'};
            {'Amber lights'}, {'\textcolor{gray}{Enter on Site}'};
            {'Marker lights and reflectors'}, {'\textcolor{gray}{Enter on Site}'};
            ];
    elseif iUnit == nUnits
        commissioningParameters{iUnit} = [commissioningParameters{iUnit};...
            'Model', modelNames{iUnit};...
            {'Registration Plate'}, {'\textcolor{gray}{Enter on Site}'};...
            {'# Axles'}, {num2str(nAxlesInGroup)};...
            axleTyreSize;
            axleStabiliser;
            {'Load cell / measurement system'}, {'\textcolor{gray}{Enter on Site}'};
            {'Front overhang'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to first drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Distance to second drive axle from steer axle'}, {'\textcolor{gray}{Enter on Site}'};
            {'Height'}, {'\textcolor{gray}{Enter on Site}'};
            {'Width (bumper)'}, {'\textcolor{gray}{Enter on Site}'};
            {'Overall vehicle length'}, {'\textcolor{gray}{Enter on Site}'};
            {'Abnormal vehicle signage'}, {'\textcolor{gray}{Enter on Site}'};
            {'Amber lights'}, {'\textcolor{gray}{Enter on Site}'};
            {'Marker lights and reflectors'}, {'\textcolor{gray}{Enter on Site}'};
            ];
    end
end
