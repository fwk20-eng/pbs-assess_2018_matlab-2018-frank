function [FS, MoDmax, DoMmax] = FS_solve(nVehUnits, dollys, X_StOut, Y_StOut, X_RP3, Y_RP3, X_RP4, Y_RP4, X_RP5, Y_RP5, ladentext, savePath, runKey, plotOn, isSave);

FS = SPW_solve(X_StOut, Y_StOut, X_RP3{1}, Y_RP3{1}, X_RP4{1}, Y_RP4{1}, X_RP5{1}, Y_RP5{1}, 'FS', ladentext, savePath, runKey, plotOn, isSave);

XexitTan = [X_StOut(end) X_StOut(end)];
YexitTan = [0 max(Y_StOut)];

% Determine maximum X of three RPs and combine to X345 Y345
iCurr = 1;
while iCurr <= nVehUnits
    if sum(iCurr == dollys(:)) == 0       % Only evaluated if veh unit number not in dollys vector
        j3start=find(X_RP3{iCurr}>=X_StOut(end),1,'first'); % Only start evaluating once X is greater then X_StOut
        if isempty(j3start), j3start = 1;,end;
        j4start=find(X_RP4{iCurr}>=X_StOut(end),1,'first'); % Only start evaluating once X is greater then X_StOut
        if isempty(j4start), j4start = 1;,end;        
        j5start=find(X_RP5{iCurr}>=X_StOut(end),1,'first'); % Only start evaluating once X is greater then X_StOut
        if isempty(j5start), j5start = 1;,end;        
            switch min( [ Y_RP3{iCurr}(j3start) Y_RP4{iCurr}(j4start) Y_RP5{iCurr}(j5start)])
            case Y_RP3{iCurr}(j3start) % RP3 has lowest Y when hitting X_StOut
                X1{iCurr}=X_RP3{iCurr}(j3start:end);
                Y1{iCurr}=Y_RP3{iCurr}(j3start:end);
                X2{iCurr}=X_RP4{iCurr}(1:end);
                Y2{iCurr}=Y_RP4{iCurr}(1:end);
                X3{iCurr}=X_RP5{iCurr}(1:end);
                Y3{iCurr}=Y_RP5{iCurr}(1:end);
            case Y_RP4{iCurr}(j4start) % RP4 has lowest Y when hitting X_StOut
                X1{iCurr}=X_RP4{iCurr}(j4start:end);
                Y1{iCurr}=Y_RP4{iCurr}(j4start:end);
                X2{iCurr}=X_RP3{iCurr}(1:end);
                Y2{iCurr}=Y_RP3{iCurr}(1:end);
                X3{iCurr}=X_RP5{iCurr}(1:end);
                Y3{iCurr}=Y_RP5{iCurr}(1:end);
            case Y_RP5{iCurr}(j5start) % RP5 has lowest Y when hitting X_StOut
                X1{iCurr}=X_RP5{iCurr}(j5start:end);
                Y1{iCurr}=Y_RP5{iCurr}(j5start:end);
                X2{iCurr}=X_RP4{iCurr}(1:end);
                Y2{iCurr}=Y_RP4{iCurr}(1:end);
                X3{iCurr}=X_RP3{iCurr}(1:end);
                Y3{iCurr}=Y_RP3{iCurr}(1:end);
        end
        j=1;
        while (j<=(length(X1{iCurr}))&(Y1{iCurr}(j)<Y2{iCurr}(end-1))&(Y1{iCurr}(j)<Y3{iCurr}(end-1)))
            i2=find(Y1{iCurr}(j)>=Y2{iCurr},1,'last'); % The index when Y2 reaches the same Y as Y1
            X2new=interp1(Y2{iCurr}(i2:i2+1),X2{iCurr}(i2:i2+1),Y1{iCurr}(j));
            i3=find(Y1{iCurr}(j)>=Y3{iCurr},1,'last'); % The index when Y3 reaches the same Y as Y1
            X3new=interp1(Y3{iCurr}(i3:i3+1),X3{iCurr}(i3:i3+1),Y1{iCurr}(j));          
            [X345{iCurr}(j) pt{iCurr}(j)]=max([X1{iCurr}(j) X2new X3new]); %Choose the largest 'swing out' or X for the given Y
            Y345{iCurr}(j)=Y1{iCurr}(j);
            j=j+1;
        end
        iCurr = iCurr + 1;   % Move to next veh unit
    else
        iCurr = iCurr + 1;   % Try next veh unit
    end
end

%MoD
iPrev = 1;
iCurr = 2;

while iCurr <= nVehUnits
    if sum(iCurr == dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
        % We expect Y to be lowest for iCurr when starting j=0, and Y to be lowest for iPrev when finished j=end 
        j=1;
        while (j<=(length(X1{iCurr}))&(Y1{iCurr}(j)<Y2{iCurr}(end-1))&(Y1{iCurr}(j)<Y3{iCurr}(end-1)))
            if Y345{iCurr}(j)<Y345{iPrev}(1)
                i=1;
            else
                i=find(Y345{iCurr}(j)>=Y345{iPrev},1,'last'); % The index when Y{iPrev} reaches the same Y as Y{iCurr}(j)
            end
            X345new=interp1(Y345{iPrev}(i:i+1),X345{iPrev}(i:i+1),Y345{iCurr}(j));  % X345new is the iPrev X at the same Y345 iCurr
            diff{iPrev}(j)=[X345{iCurr}(j) - X345new];                      
            %diffpts{iPrev}(j,1:2)=[pt{iPrev}(i) pt{iCurr}(j)]; %Vehicle unit in front then the one following
            j=j+1;
        end
        
        [MoD(iPrev), indMoD(iPrev)] = max(diff{iPrev});        
        %MoDpt(iPrev,1:2)=[diffpts{iPrev}(indMoD(iPrev),1) diffpts{iPrev}(indMoD(iPrev),1)];                
        MoDx(iPrev) = {[X345{iCurr}(indMoD(iPrev)) X345{iCurr}(indMoD(iPrev))-MoD(iPrev)]};
        MoDy(iPrev) = {[Y345{iCurr}(indMoD(iPrev)) Y345{iCurr}(indMoD(iPrev))]};
        %MoDtext(iPrev) = {['MoD_' int2str(iPrev) '_' int2str(iCurr) ' = ' num2str(ceil(MoD(iPrev)*100)/100) ' m - Pt' num2str(MoDpt(iPrev,1)+2) ' to pt' num2str(MoDpt(iPrev,2)+2) ]};        
        MoDtext(iPrev) = {['MoD_' int2str(iPrev) '_' int2str(iCurr) ' = ' num2str(ceil(MoD(iPrev)*100)/100) ' m']};
        iPrev = iCurr;       % progress iPrev to current veh unit
        iCurr = iCurr + 1;   % try next veh unit
    else
        iCurr = iCurr + 1;   % try next veh unit, iPrev not updated since this veh unit is a dolly
    end
    
end

MoDmax = max(MoD);
if MoDmax<0
    MoDmax=NaN;
end

if plotOn
    figure('name', 'MoD')

    hold on
    legTitles = {};

    plot(X_StOut, Y_StOut, 'Color', getColour(1))    
    legTitles = [legTitles; 'steer'];
    
    for i = 1:nVehUnits                          
        if sum(i == dollys(:)) == 0       % only plotted if veh unit number not in dollys vector
            plot(X345{i}, Y345{i},'Color', getColour((i+1)));
            legTitles = [legTitles; ['unit ' int2str(i)]];                        
        end
    end
    
    for i = 1:nVehUnits-1                                      
        if sum(i == dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
            plot(MoDx{i}, MoDy{i}, '-or')
            text(MoDx{i}(2)+0.1, MoDy{i}(1)+1, MoDtext(i))
        end
    end
    
    plot(XexitTan, YexitTan, '--r')
    
    axis([floor(XexitTan(1)*2-1)/2 ceil(max(max(cell2mat(X345)))*2)/2 -5 25])
    axis 'auto y'
    set(gca,'XTick',[floor(XexitTan(1)*2-1)/2:0.1:ceil(max(max(cell2mat(X345)))*2)/2]);
    text(floor(XexitTan(1)*2-1)/2 + (XexitTan(1)- floor(XexitTan(1)*2-1)/2)/6, max(Y_StOut)*2/3, ['MoD = ' num2str(ceil(MoDmax*100)/100) ' m'])
    legend(legTitles, 'Location', 'Best');
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('X [m]')
    ylabel('Y [m]')
    legend(legTitles, 'Location', 'best');
    
    if isSave
        savePlot(savePath, runKey, ['MoD' ladentext])
    end
    
    title(['Maximum of Difference' ladentext])
    hold off
end

%DoM
[maxPx(1), indMaxPx(1)] = max(X345{1});             %find first maximum
pt{1}(indMaxPx(1));
iPrev = 1;
iCurr = 2;
while iCurr <= nVehUnits
    if sum(iCurr == dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
        [maxPx(iCurr), indMaxPx(iCurr)] = max(X345{iCurr});        
        
        DoM(iPrev) = maxPx(iCurr) - maxPx(iPrev);
        %DoMpt(iPrev,1:2) = [pt{iPrev}(indMaxPx(iPrev)) pt{iCurr}(indMaxPx(iCurr))]; %Vehicle unit in front then the one following
        DoMx(iPrev) = {[maxPx(iPrev) maxPx(iPrev) maxPx(iCurr)]};
        DoMy(iPrev) = {[Y345{iPrev}(indMaxPx(iPrev)) Y345{iCurr}(indMaxPx(iCurr)) Y345{iCurr}(indMaxPx(iCurr))]};
        %DoMtext(iPrev) = {['DoM_' int2str(iPrev) '_' int2str(iCurr) ' = ' num2str(ceil(DoM(iPrev)*100)/100) ' m - Pt' num2str(DoMpt(iPrev,1)+2) ' to pt' num2str(DoMpt(iPrev,2)+2)]};
        DoMtext(iPrev) = {['DoM_' int2str(iPrev) '_' int2str(iCurr) ' = ' num2str(ceil(DoM(iPrev)*100)/100) ' m ']};
            
        iPrev = iCurr;       % progress iPrev to current veh unit
        iCurr = iCurr + 1;   % try next veh unit
    else
        iCurr = iCurr + 1;   % try next veh unit, iPrev not updated since this veh unit is a dolly
    end
    
end

DoMmax = max(DoM);
if MoDmax<0
    DoMmax=NaN;
end

if plotOn
    figure('name', 'DoM')

    hold on
    legTitles = {};
    
    plot(X_StOut, Y_StOut,'Color', getColour(1))    
    legTitles = [legTitles; 'steer'];
    
    for i = 1:nVehUnits
        if sum(i == dollys(:)) == 0       % only plotted if veh unit number not in dollys vector
            plot(X345{i}, Y345{i},'Color', getColour((i-1)+2));
            legTitles = [legTitles; ['unit ' int2str(i)]];
        end
    end
    
    for i = 1:nVehUnits-1
        if sum(i == dollys(:)) == 0       % only plotted if veh unit number not in dollys vector
            plot(DoMx{i}, DoMy{i}, '-or')
            text(max(DoMx{i}(2), DoMx{i}(3))+0.1, Y345{i}(indMaxPx(i)), DoMtext(i))
        end
    end
    
    plot(XexitTan, YexitTan, '--r')
    
    axis([floor(XexitTan(1)*2-1)/2 ceil(max(max(cell2mat(X_RP3)))*2)/2+1 -5 25])
    axis 'auto y'
    text(floor(XexitTan(1)*2-1)/2 + (XexitTan(1)- floor(XexitTan(1)*2-1)/2)/6, max(Y_StOut)*2/3, ['DoM = ' num2str(ceil(DoMmax*100)/100) ' m'])
    legend(legTitles, 'Location', 'Best');
    
    set(gcf,'PaperPosition',[0 0 16 11])
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    xlabel('X [m]')
    ylabel('Y [m]')
    legend(legTitles, 'Location', 'best');
    
    if isSave
        savePlot(savePath, runKey, ['DoM' ladentext])
    end
    
    title(['Difference of Maxima' ladentext])
    
    hold off
end

