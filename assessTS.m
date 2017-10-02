function [TS_max] = assessTS(Sprung, Combination, Axle, Project, Is, X_StOut, Y_StOut, X_RP6, Y_RP6, X_RP7, Y_RP7,...
    X_RP8, Y_RP8, X_RP9, Y_RP9, ladentext)

for i = 1:Sprung.numberOffUnits
    if sum(i == Combination.dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
        [minY6(i), indTS6(i)] = min(Y_RP6{i});             % find minimums        
        [minY7(i), indTS7(i)] = min(Y_RP7{i});             % find minimums
        [minY8(i), indTS8(i)] = min(Y_RP8{i});             % find minimums
        [minY9(i), indTS9(i)] = min(Y_RP9{i});             % find minimums        
        
        % Take into account vehicle width. Note that the reference point outputs are in m, hence divided by 2000
        TS(i) = abs(min( [minY6(i), minY7(i), minY8(i), minY9(i)])) - ...
            (max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000;                
    end
end

TS_max = max(TS);

if Is.plotOn
    figure('name', 'TS')

    hold on
    legTitles = {};
    XDimensions.MaxWidthLaden = [floor(X_RP6{Sprung.numberOffUnits}(1)*5)/5-5 25];

    plot(X_StOut, Y_StOut+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'Color', getColour(1))
    legTitles = [legTitles; 'steer'];

    plot(XDimensions.MaxWidthLaden, [0 0], '--b')
    legTitles = [legTitles; 'vehicle width'];
    
    ind=1;
    for i = 1:Sprung.numberOffUnits                                             % plot: X_RP6789, Y_RP6789
        if sum(i == Combination.dollys(:)) == 0                                 % only evaluated if veh unit number not in dollys vector
            ind=ind+1;
            plot(X_RP6{i}, Y_RP6{i}+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'Color', getColour(ind));      % plot next line
            ind=ind+1;
            plot(X_RP7{i}, Y_RP7{i}+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'Color', getColour(ind));      % plot next line
            ind=ind+1;            
            plot(X_RP8{i}, Y_RP8{i}+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'Color', getColour(ind));      % plot next line
            ind=ind+1;            
            plot(X_RP9{i}, Y_RP9{i}+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'Color', getColour(ind));      % plot next line            
            legTitles = [legTitles; ['unit ' int2str(i) ' p1']; ['unit ' int2str(i) ' p2']; ['unit ' int2str(i) ' p3']; ['unit ' int2str(i) ' p4'] ];
        end
    end
    
    for i = 1:Sprung.numberOffUnits                                             % plot: X_RP6789, Y_RP6789
        if sum(i == Combination.dollys(:)) == 0                                 % only evaluated if veh unit number not in dollys vector
            plot(X_RP6{i}(indTS6(i)), Y_RP6{i}(indTS6(i))+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'or'); % plot peaks            
            plot(X_RP7{i}(indTS7(i)), Y_RP7{i}(indTS7(i))+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'or'); % plot peaks            
            plot(X_RP8{i}(indTS8(i)), Y_RP8{i}(indTS8(i))+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'or'); % plot peaks
            plot(X_RP9{i}(indTS9(i)), Y_RP9{i}(indTS9(i))+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, 'or'); % plot peaks
        end
    end

    XentryTan = [floor(X_RP6{Sprung.numberOffUnits}(1)*5)/5-5 30];
    YentryTan = [Y_StOut(1) Y_StOut(1)]; 
    plot(XentryTan, YentryTan+(max(Combination.maxWidth)-Axle.SteerAxleOverallWidth)/2000, '--r')
           
    axis 'auto x'
    lims=axis;
    axis([lims(1)+10 15 -1 1])
    
    iPlot = 1;
    for i = 1:Sprung.numberOffUnits
        if sum(i == Combination.dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
            [Yloc j] = min([Y_RP6{i}(indTS6(i)) Y_RP7{i}(indTS7(i)) Y_RP8{i}(indTS8(i)) Y_RP9{i}(indTS9(i))]);
            vecr=[X_RP6{i}(indTS6(i)); X_RP7{i}(indTS7(i)); X_RP8{i}(indTS8(i)); X_RP9{i}(indTS9(i))];
            Xloc=vecr(j);
            text(Xloc, Yloc-0.1*i,['TS_' int2str(i) ' = ' num2str(ceil(TS(i)*100)/100) ' m'])
            iPlot = iPlot + 1;
        end
    end
    
    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('X [m]')
    ylabel('Y [m]')
    legend(legTitles, 'Location', 'northeastoutside'); legend('boxoff');
    
    if Is.save
        savePlot(Project.savePath, Project.runKey, ['TS' ladentext])
    end
    
    title(['Tail Swing' ladentext])
    hold off
end