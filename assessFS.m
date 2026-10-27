%% Function Description
%
% Calculates the frontal swing of a vehicle combination
%% Change Log
%% [0.1.1] - 2020-11-03
% Corrected X-axis of MoD
%% [0.1.0] - 2018-08-08
% *Added*
% * Change log added

function [FS, MoDmax, DoMmax] = assessFS(Sprung, Combination, Is, Project, X_StOut, Y_StOut,...
    X_RP3, Y_RP3, X_RP4, Y_RP4, X_RP5, Y_RP5, ladentext)

%% --------------------------------------------
%      ** Frontal Swing **
%----------------------------------------------

FS = assessSPW(Project, Is, X_StOut, Y_StOut, ...
    X_RP3{1}, Y_RP3{1}, ...
    X_RP4{1}, Y_RP4{1}, ...
    X_RP5{1}, Y_RP5{1}, ...
    'FS', ladentext);

XexitTan = [X_StOut(end) X_StOut(end)];
YexitTan = [0 max(Y_StOut)];

% Determine maximum X of three RPs and combine to X345 Y345
%----------------------------------------------

iCurr = 1;

while iCurr <= Sprung.numberOffUnits
    
    if sum(iCurr == Combination.dollys_trailerFrontAxles(:)) == 0
        
        % Only start evaluating once X is greater than X_StOut
        j3start = find(X_RP3{iCurr} >= X_StOut(end), 1, 'first');
        if isempty(j3start)
            j3start = 1;
        end
        
        j4start = find(X_RP4{iCurr} >= X_StOut(end), 1, 'first');
        if isempty(j4start)
            j4start = 1;
        end
        
        j5start = find(X_RP5{iCurr} >= X_StOut(end), 1, 'first');
        if isempty(j5start)
            j5start = 1;
        end
        
        switch min([ ...
                Y_RP3{iCurr}(j3start) ...
                Y_RP4{iCurr}(j4start) ...
                Y_RP5{iCurr}(j5start)])
            
            case Y_RP3{iCurr}(j3start)
                
                X1{iCurr} = X_RP3{iCurr}(j3start:end);
                Y1{iCurr} = Y_RP3{iCurr}(j3start:end);
                
                X2{iCurr} = X_RP4{iCurr}(1:end);
                Y2{iCurr} = Y_RP4{iCurr}(1:end);
                
                X3{iCurr} = X_RP5{iCurr}(1:end);
                Y3{iCurr} = Y_RP5{iCurr}(1:end);
                
            case Y_RP4{iCurr}(j4start)
                
                X1{iCurr} = X_RP4{iCurr}(j4start:end);
                Y1{iCurr} = Y_RP4{iCurr}(j4start:end);
                
                X2{iCurr} = X_RP3{iCurr}(1:end);
                Y2{iCurr} = Y_RP3{iCurr}(1:end);
                
                X3{iCurr} = X_RP5{iCurr}(1:end);
                Y3{iCurr} = Y_RP5{iCurr}(1:end);
                
            case Y_RP5{iCurr}(j5start)
                
                X1{iCurr} = X_RP5{iCurr}(j5start:end);
                Y1{iCurr} = Y_RP5{iCurr}(j5start:end);
                
                X2{iCurr} = X_RP4{iCurr}(1:end);
                Y2{iCurr} = Y_RP4{iCurr}(1:end);
                
                X3{iCurr} = X_RP3{iCurr}(1:end);
                Y3{iCurr} = Y_RP3{iCurr}(1:end);
                
        end
        
        j = 1;
        
        while (j <= length(X1{iCurr})) && ...
                (Y1{iCurr}(j) < Y2{iCurr}(end-1)) && ...
                (Y1{iCurr}(j) < Y3{iCurr}(end-1))
            
            i2 = find(Y1{iCurr}(j) >= Y2{iCurr}, 1, 'last');
            
            if isempty(i2)
                X2new = 0;
            else
                X2new = interp1( ...
                    Y2{iCurr}(i2:i2+1), ...
                    X2{iCurr}(i2:i2+1), ...
                    Y1{iCurr}(j));
            end
            
            i3 = find(Y1{iCurr}(j) >= Y3{iCurr}, 1, 'last');
            
            if isempty(i3)
                X3new = 0;
            else
                X3new = interp1( ...
                    Y3{iCurr}(i3:i3+1), ...
                    X3{iCurr}(i3:i3+1), ...
                    Y1{iCurr}(j));
            end
            
            [X345{iCurr}(j), pt{iCurr}(j)] = max([ ...
                X1{iCurr}(j) ...
                X2new ...
                X3new]);
            
            Y345{iCurr}(j) = Y1{iCurr}(j);
            
            j = j + 1;
        end
        
        iCurr = iCurr + 1;
        
    else
        
        iCurr = iCurr + 1;
        
    end
end


%% --------------------------------------------
%      ** MoD **
%----------------------------------------------

iPrev = 1;
iCurr = 2;

while iCurr <= Sprung.numberOffUnits
    
    if sum(iCurr == Combination.dollys_trailerFrontAxles(:)) == 0
        
        % We expect Y to be lowest for iCurr when starting j=0,
        % and Y to be lowest for iPrev when finished j=end
        
        j = 1;
        
        while (j <= length(X1{iCurr})) && ...
                (Y1{iCurr}(j) < Y2{iCurr}(end-1)) && ...
                (Y1{iCurr}(j) < Y3{iCurr}(end-1))
            
            if Y345{iCurr}(j) < Y345{iPrev}(1)
                
                i = 1;
                
            else
                
                i = find(Y345{iCurr}(j) >= Y345{iPrev}, ...
                    1, 'last');
                
                if isempty(i)
                    i = 1;
                end
                
            end
            
            if Y345{iCurr}(j) > 17
                
                X345new = interp1( ...
                    Y345{iPrev}(i:i+1), ...
                    X345{iPrev}(i:i+1), ...
                    Y345{iCurr}(j));
                
                MoDdiff{iPrev}(j) = ...
                    X345{iCurr}(j) - X345new;
                
            else
                
                % Effectively make difference zero below 17 m
                MoDdiff{iPrev}(j) = -0.001;
                
            end
            
            j = j + 1;
            
        end
        
        [MoD(iPrev), indMoD(iPrev)] = ...
            max(MoDdiff{iPrev});
        
        MoDx(iPrev) = {[ ...
            X345{iCurr}(indMoD(iPrev)) ...
            X345{iCurr}(indMoD(iPrev)) - MoD(iPrev)]};
        
        MoDy(iPrev) = {[ ...
            Y345{iCurr}(indMoD(iPrev)) ...
            Y345{iCurr}(indMoD(iPrev))]};
        
        MoDtext(iPrev) = {[
            'MoD_' int2str(iPrev) '_' int2str(iCurr) ...
            ' = ' ...
            num2str(ceil(MoD(iPrev)*100)/100) ...
            ' m']};
        
        iPrev = iCurr;
        iCurr = iCurr + 1;
        
    else
        
        iCurr = iCurr + 1;
        
    end
    
end


if Sprung.numberOffUnits > 1
    
    if (ceil(MoD*100)/100) < 0
        
        MoDmax = NaN;
        
    else
        
        MoDmax = max(MoD);
        
    end
    
else
    
    MoDmax = NaN;
    
end


%% --------------------------------------------
%      Plot MoD
%----------------------------------------------

if Is.plotOn
    
    if (isfield(Is,'plotBackground') & Is.plotBackground)
        
        figure('name', 'MoD', 'visible', 'off');
        
    else
        
        figure('name', 'MoD');
        
    end
    
    hold on
    
    legTitles = {};
    
    plot(X_StOut, Y_StOut, ...
        'Color', getColour(1));
    
    legTitles = [legTitles; ...
        'front steer path'];
    
    
    % Plot widest path for every applicable vehicle unit
    for i = 1:Sprung.numberOffUnits
        
        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0
            
            plot(X345{i}, Y345{i}, ...
                'Color', getColour(i+1));
            
            legTitles = [legTitles; ...
                ['widest of pts 3-5 on unit ' int2str(i)]];
            
        end
        
    end
    
    
    % Plot MoD measurement lines and labels
    for i = 1:Sprung.numberOffUnits-1
        
        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0
            
            plot(MoDx{i}, MoDy{i}, '-or')
            
            % Light change:
            % Position label to the RIGHT of the complete
            % MoD measurement line rather than on the curve.
            text(max(MoDx{i}) + 0.1, ...
                MoDy{i}(1) + 1.0, ...
                MoDtext{i});
            
        end
        
    end
    
    
    plot(XexitTan, YexitTan, '--r')
    
    
    % Keep original axis behaviour.
    % Do NOT freeze the Y limits.
    axis([ ...
        floor(XexitTan(1)*2-1)/2 ...
        ceil(max(max(cell2mat(X_RP3)))*2)/2+1 ...
        -5 25])
    
    axis 'auto y'
    
    
    % Overall MoD result in clear lower-left area. Best remove this.
    %text( ...
    %    floor(XexitTan(1)*2-1)/2 + 0.07, ...
    %    85, ...
    %    ['MoD = ' ...
    %    num2str(ceil(MoDmax*100)/100) ...
    %    ' m']);
    
    
    set(gcf, 'PaperPosition', [0 0 16 11])
    
    set(gca, 'Xgrid', 'on');
    set(gca, 'Ygrid', 'on');
    
    xlabel('X [m]')
    ylabel('Y [m]')
    
    
    % Light change:
    % lower-right is clear in the MoD figures
    legend(legTitles, 'Location', 'northeast');
    
    
    if Is.save
        
        savePlot( ...
            Project.savePath, ...
            Project.runKey, ...
            ['MoD' ladentext])
        
    end
    
    title(['Maximum of Difference' ladentext])
    
    hold off
    
end


%% --------------------------------------------
%      ** DoM **
%----------------------------------------------

[maxPx(1), indMaxPx(1)] = max(X345{1});

pt{1}(indMaxPx(1));

iPrev = 1;
iCurr = 2;

while iCurr <= Sprung.numberOffUnits
    
    if sum(iCurr == Combination.dollys_trailerFrontAxles(:)) == 0
        
        [maxPx(iCurr), indMaxPx(iCurr)] = ...
            max(X345{iCurr});
        
        DoM(iPrev) = ...
            maxPx(iCurr) - maxPx(iPrev);
        
        DoMx(iPrev) = {[ ...
            maxPx(iPrev) ...
            maxPx(iPrev) ...
            maxPx(iCurr)]};
        
        DoMy(iPrev) = {[ ...
            Y345{iPrev}(indMaxPx(iPrev)) ...
            Y345{iCurr}(indMaxPx(iCurr)) ...
            Y345{iCurr}(indMaxPx(iCurr))]};
        
        DoMtext(iPrev) = {[
            'DoM_' int2str(iPrev) '_' int2str(iCurr) ...
            ' = ' ...
            num2str(ceil(DoM(iPrev)*100)/100) ...
            ' m ']};
        
        iPrev = iCurr;
        iCurr = iCurr + 1;
        
    else
        
        iCurr = iCurr + 1;
        
    end
    
end


if Sprung.numberOffUnits > 1
    
    if (ceil(MoD*100)/100) < 0
        
        DoMmax = NaN;
        
    else
        
        DoMmax = max(DoM);
        
    end
    
else
    
    DoMmax = NaN;
    
end


%% --------------------------------------------
%      Plot DoM
%----------------------------------------------

if Is.plotOn
    
    if (isfield(Is,'plotBackground') & Is.plotBackground)
        
        figure('name', 'DoM', 'visible', 'off');
        
    else
        
        figure('name', 'DoM');
        
    end
    
    hold on
    
    legTitles = {};
    
    
    plot(X_StOut, Y_StOut, ...
        'Color', getColour(1));
    
    legTitles = [legTitles; ...
        'front steer path'];
    
    
    % Plot widest path for every applicable vehicle unit
    for i = 1:Sprung.numberOffUnits
        
        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0
            
            plot(X345{i}, Y345{i}, ...
                'Color', getColour((i-1)+2));
            
            legTitles = [legTitles; ...
                ['widest of pts 3-5 on unit ' int2str(i)]];
            
        end
        
    end
    
    
    % Plot DoM measurement lines and labels
    for i = 1:Sprung.numberOffUnits-1
        
        if sum(i == Combination.dollys_trailerFrontAxles(:)) == 0
            
            plot(DoMx{i}, DoMy{i}, '-or')
            
            % Light change:
            % Position label to the RIGHT of the complete
            % DoM measurement geometry and slightly above
            % its horizontal measurement line.
            text(max(DoMx{i}) + 0.1, ...
                DoMy{i}(3) + 0.5, ...
                DoMtext{i});
            
        end
        
    end
    
    
    plot(XexitTan, YexitTan, '--r')
    
    
    % Keep original axis behaviour.
    % Do NOT freeze the Y limits.
    axis([ ...
        floor(XexitTan(1)*2-1)/2 ...
        ceil(max(max(cell2mat(X_RP3)))*2)/2+1 ...
        -5 25])
    
    axis 'auto y'
    
    
    % Overall DoM result in clear lower-left area. Best remove this.
    %text( ...
    %    floor(XexitTan(1)*2-1)/2 + 0.1, ...
    %    85, ...
    %    ['DoM = ' ...
    %    num2str(ceil(DoMmax*100)/100) ...
    %    ' m']);
    
    
    set(gcf, 'PaperPosition', [0 0 16 11])
    
    set(gca, 'Xgrid', 'on');
    set(gca, 'Ygrid', 'on');
    
    xlabel('X [m]')
    ylabel('Y [m]')
    
    
    % Light change:
    % lower-right is clear in the supplied DoM figures
    legend(legTitles, 'Location', 'northeast');
    
    
    if Is.save
        
        savePlot( ...
            Project.savePath, ...
            Project.runKey, ...
            ['DoM' ladentext])
        
    end
    
    title(['Difference of Maxima' ladentext])
    
    hold off
    
end

end