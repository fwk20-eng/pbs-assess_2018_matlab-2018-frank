%% Function Description
%
% Computes the Tailswing
%% Change Log
%% [0.1.0] - 2020-02-09
% * First code

function [TS_max] = assessTS(Sprung, Combination, Axle, Project, Is, ...
    X_StOut, Y_StOut, X_RP6, Y_RP6, X_RP7, Y_RP7, ...
    X_RP8, Y_RP8, X_RP9, Y_RP9, ladentext)


%% --------------------------------------------
%      Calculate Tail Swing
%----------------------------------------------

for i = 1:Sprung.numberOffUnits

    if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0

        % Find minimums
        [minY6(i), indTS6(i)] = min(Y_RP6{i});
        [minY7(i), indTS7(i)] = min(Y_RP7{i});
        [minY8(i), indTS8(i)] = min(Y_RP8{i});
        [minY9(i), indTS9(i)] = min(Y_RP9{i});

        % Take into account vehicle width.
        % Note that the reference point outputs are in m,
        % hence divided by 2000.
        TS(i) = abs(min([ ...
            minY6(i), ...
            minY7(i), ...
            minY8(i), ...
            minY9(i)])) - ...
            (max(Combination.maxWidth) - ...
            Axle.SteerAxleOverallWidth) / 2000;

    end

end


TS_max = max(TS);


%% --------------------------------------------
%      Plot Tail Swing
%----------------------------------------------

if Is.plotOn

    if isfield(Is,'plotBackground') && Is.plotBackground

        figure('name', 'TS', 'visible', 'off');

    else

        figure('name', 'TS');

    end


    hold on

    legTitles = {};


    % Vertical offset applied to plotted paths
    yPlotOffset = ...
        (max(Combination.maxWidth) - ...
        Axle.SteerAxleOverallWidth) / 2000;


    XDimensions.MaxWidthLaden = [ ...
        floor(X_RP6{Sprung.numberOffUnits}(1)*5)/5-5 ...
        25];


    % Plot steer width
    plot(X_StOut, ...
        Y_StOut + yPlotOffset, ...
        'Color', getColour(1))

    legTitles = [legTitles; 'steer width'];


    % Plot vehicle width
    plot(XDimensions.MaxWidthLaden, ...
        [0 0], ...
        '--b')

    legTitles = [legTitles; 'vehicle width'];


    %% --------------------------------------------
    %      Plot RP6 - RP9 paths
    %----------------------------------------------

    ind = 1;

    for i = 1:Sprung.numberOffUnits

        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0

            ind = ind + 1;

            plot(X_RP6{i}, ...
                Y_RP6{i} + yPlotOffset, ...
                'Color', getColour(ind));


            ind = ind + 1;

            plot(X_RP7{i}, ...
                Y_RP7{i} + yPlotOffset, ...
                'Color', getColour(ind));


            ind = ind + 1;

            plot(X_RP8{i}, ...
                Y_RP8{i} + yPlotOffset, ...
                'Color', getColour(ind));


            ind = ind + 1;

            plot(X_RP9{i}, ...
                Y_RP9{i} + yPlotOffset, ...
                'Color', getColour(ind));


            legTitles = [legTitles; ...
                ['unit ' int2str(i) ' pt. 6']; ...
                ['unit ' int2str(i) ' pt. 7']; ...
                ['unit ' int2str(i) ' pt. 8']; ...
                ['unit ' int2str(i) ' pt. 9']];

        end

    end


    %% --------------------------------------------
    %      Plot minimum points
    %----------------------------------------------

    for i = 1:Sprung.numberOffUnits

        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0

            plot( ...
                X_RP6{i}(indTS6(i)), ...
                Y_RP6{i}(indTS6(i)) + yPlotOffset, ...
                'or');

            plot( ...
                X_RP7{i}(indTS7(i)), ...
                Y_RP7{i}(indTS7(i)) + yPlotOffset, ...
                'or');

            plot( ...
                X_RP8{i}(indTS8(i)), ...
                Y_RP8{i}(indTS8(i)) + yPlotOffset, ...
                'or');

            plot( ...
                X_RP9{i}(indTS9(i)), ...
                Y_RP9{i}(indTS9(i)) + yPlotOffset, ...
                'or');


            legTitles = [legTitles; '', '', '', ''];

        end

    end


    %% --------------------------------------------
    %      Plot entry tangent
    %----------------------------------------------

    XentryTan = [ ...
        floor(X_RP6{Sprung.numberOffUnits}(1)*5)/5-5 ...
        30];

    YentryTan = [Y_StOut(1) Y_StOut(1)];


    plot(XentryTan, ...
        YentryTan + yPlotOffset, ...
        '--r')


    %% --------------------------------------------
    %      Set plot axes
    %----------------------------------------------

    axis 'auto x'

    lims = axis;

    axis_x_min = lims(1) + 10;
    axis_x_max = 15;

    axis_y_min = -1;
    axis_y_max = 1;

    axis([ ...
        axis_x_min ...
        axis_x_max ...
        axis_y_min ...
        axis_y_max])


    %----------------------------------------------
    %      Plotting the level 1 PBS limit
    %----------------------------------------------
    %
    % PBSlevel1Limit = 0.3;
    %
    % PBSlimX = [-15 axis_x_max];
    % PBSlimY_level1 = [-PBSlevel1Limit -PBSlevel1Limit];
    %
    % plot(PBSlimX, PBSlimY_level1, '--k');
    % text(axis_x_min+0.5, -0.3, ['PBS Level 1 limit']);


    %% ---------------------------------------------------------
    %      Tail Swing labels
    %
    % Place labels BELOW the plotted curves.
    %
    % Labels are sorted from left to right and moved downward
    % if required to prevent labels overlapping one another.
    %
    % The text X-coordinate is kept equal to the actual Tail
    % Swing point X-coordinate. Therefore all dotted leader
    % lines are VERTICAL.
    %-----------------------------------------------------------

    ax = gca;

    yLimits = ylim(ax);
    yRange = diff(yLimits);


    %% ---------------------------------------------------------
    % Find the lowest Y value of anything already plotted.
    %
    % This includes vehicle paths, horizontal lines, etc.
    %-----------------------------------------------------------

    lineHandles = findobj(ax, 'Type', 'line');

    curveYmin = inf;


    for k = 1:numel(lineHandles)

        yData = get(lineHandles(k), 'YData');

        yData = yData(isfinite(yData));


        if ~isempty(yData)

            curveYmin = min(curveYmin, min(yData));

        end

    end


    % Clearance between graph and first text label
    yClearance = 0.035 * yRange;


    % Amount to move a label down if another label is in the way
    yStep = 0.060 * yRange;



    %% ---------------------------------------------------------
    %      Collect all Tail Swing locations
    %-----------------------------------------------------------

    TSx      = [];
    TSy      = [];
    TSstring = {};


    for i = 1:Sprung.numberOffUnits

        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0


            [Yloc, j] = min([ ...
                Y_RP6{i}(indTS6(i)), ...
                Y_RP7{i}(indTS7(i)), ...
                Y_RP8{i}(indTS8(i)), ...
                Y_RP9{i}(indTS9(i)) ]);


            Xvec = [ ...
                X_RP6{i}(indTS6(i)), ...
                X_RP7{i}(indTS7(i)), ...
                X_RP8{i}(indTS8(i)), ...
                X_RP9{i}(indTS9(i)) ];


            Xloc = Xvec(j);

            TSx(end+1) = Xloc;

            % Use the same vertical offset as the displayed paths
            TSy(end+1) = Yloc + yPlotOffset;


            TSstring{end+1} = [ ...
                'TS_' int2str(i) ...
                ' = ' ...
                num2str(ceil(TS(i)*100)/100) ...
                ' m'];

        end

    end


    %% ---------------------------------------------------------
    %      Sort labels from LEFT to RIGHT
    %-----------------------------------------------------------

    [TSx, order] = sort(TSx);

    TSy      = TSy(order);
    TSstring = TSstring(order);


%% ---------------------------------------------------------
%      Place labels below the curves
%
% Labels are already sorted from left to right.
% Assume consecutive labels would overlap and move each
% subsequent label one step downward.
%
% The X-coordinate stays equal to the actual Tail Swing
% location, so all leader lines remain vertical.
%-----------------------------------------------------------

for k = 1:length(TSx)

    xText = TSx(k);

    % First label starts below all plotted curves.
    % Each following label is moved one step further down.
    yText = curveYmin - yClearance - (k-1)*yStep;

    text( ...
        xText, ...
        yText, ...
        TSstring{k}, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', 'w', ...
        'Margin', 1, ...
        'Clipping', 'on');

    % Vertical dotted leader line
    plot( ...
        [TSx(k) TSx(k)], ...
        [TSy(k) yText], ...
        ':k', ...
        'HandleVisibility', 'off');

end

    %% --------------------------------------------
    %      Finish plot
    %----------------------------------------------

    set(gcf, 'PaperPosition', [0 0 16 11])

    set(gca, 'Xgrid', 'on');
    set(gca, 'Ygrid', 'on');

    xlabel('X [m]')
    ylabel('Y [m]')


    legend(legTitles, 'Location', 'southwest')


    if Is.save

        savePlot( ...
            Project.savePath, ...
            Project.runKey, ...
            ['TS' ladentext])

    end


    title(['Tail Swing' ladentext])

    hold off

end