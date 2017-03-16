function [SW99] = TASP_solve(nVehUnits, dollys, savePath, runsPath, runKey, matKey, plotOn, isSave)   % note nVehUnits is a count of the num with RPs recorded

if nargin == 0  % i.e. program run directly from here
    % Example inputs: 
    % -----------------------------------------------------------------
    % Example inputs:
    % -----------------------------------------------------------------
    nVehUnits = 3;
    dollys = [];     % vehicle unit numbers with no reference points (dolly's do not have RPs)
    savePath = 'C:\Users\A0006942\Documents\Delete';
    runsPath = 'C:\Dropbox\trucksimDatabase_JAD\Runs';
    runKey ='Test';
    matKey = 'TASP_FL';
    plotOn = true;
    % -----------------------------------------------------------------
end


[Data, error] = readData(matKey, {'X_RP1' 'X_RP2' 'X_RP6' 'X_RP7' 'X_RP8' 'X_RP9' ...
    'Y_RP1' 'Y_RP2' 'Y_RP6' 'Y_RP7' 'Y_RP8' 'Y_RP9'}, nVehUnits*ones(1,12),...
    {'' '' '' '' '' '' '' '' '' '' '' ''}, dollys, savePath, runsPath, runKey, zeros(1, 12), isSave);

if error == 1
    Time    = Data{1};      % convert to vector
    X_RP1   = Data(2,:);    % These are still cell arrays
    X_RP2   = Data(3,:);
    X_RP6   = Data(4,:);
    X_RP7   = Data(5,:);
    X_RP8   = Data(6,:);
    X_RP9   = Data(7,:);    
    Y_RP1   = Data(8,:);
    Y_RP2   = Data(9,:);
    Y_RP6   = Data(10,:);
    Y_RP7   = Data(11,:);    
    Y_RP8   = Data(12,:);
    Y_RP9   = Data(13,:);    
else
    return                  % data not loaded correctly
end

% RP locations:
% 1 -- 3
% 2 -- 4
%   -- 5
%  |  |
%  |  |
%   -- 6
%   -- 7
%   -- 8
%   -- 9
%Note: dollies have no RP outputs

% only consider points between the lead in and lead out sections
LenStart = 200;    % [m] lead in
LenTsect = 1000;   % [m] test section length

iTsect = 1;
while X_RP1{1}(iTsect) < LenStart           % find i for start of Tsect
    iTsect = iTsect + 1;
end
iStart = iTsect;

while X_RP1{1}(iTsect) < LenStart+LenTsect  % find i for end of Tsect
    iTsect = iTsect + 1;
end
iEnd = iTsect;

% need to create an array of swept path widths for each X position along
% the road
SW = [];
for i = iStart:iEnd
    
    iL = 1;
    for iVU = 1:nVehUnits
        
        if sum(iVU == dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
            iRP1 = indClosestX(i, X_RP1{1}(i), X_RP1{iVU});    % get i for when this RP on this veh unit was at this X position
            iRP2 = indClosestX(i, X_RP1{1}(i), X_RP2{iVU});

            Ltemp(iL) = Y_RP1{iVU}(iRP1);   % excursion of RP1 on this vehicle unit
            LxTemp(iL) = X_RP1{iVU}(iRP1);
            iL = iL + 1;
            
            Ltemp(iL) = Y_RP2{iVU}(iRP2);   % excursion of RP3 on this vehicle unit        
            LxTemp(iL) = X_RP2{iVU}(iRP2);
            iL = iL + 1;
            
        end
               
    end
    
    [L(i-iStart+1), iLmax] = max(Ltemp); % find furthest excursion at this X position along the road
    Lx(i-iStart+1) = LxTemp(iLmax);      % -iStart-1 to start at 1
    
    iR = 1;
    for iVU = 1:nVehUnits
        
        if sum(iVU == dollys(:)) == 0       % only evaluated if veh unit number not in dollys vector
            iRP6 = indClosestX(i, X_RP1{1}(i), X_RP6{iVU});    % get i for when this RP on this veh unit was at this X position
            iRP7 = indClosestX(i, X_RP1{1}(i), X_RP7{iVU});
            iRP8 = indClosestX(i, X_RP1{1}(i), X_RP8{iVU});
            iRP9 = indClosestX(i, X_RP1{1}(i), X_RP9{iVU});            
            
            Rtemp(iR) = Y_RP6{iVU}(iRP6);   % excursion of RP2 on this vehicle unit
            RxTemp(iR) = X_RP6{iVU}(iRP6);
            iR = iR + 1;
            
            Rtemp(iR) = Y_RP7{iVU}(iRP7);   % excursion of RP4 on this vehicle unit        
            RxTemp(iR) = X_RP7{iVU}(iRP7);
            iR = iR + 1;
            
            Rtemp(iR) = Y_RP8{iVU}(iRP8);   % excursion of RP6 on this vehicle unit        
            RxTemp(iR) = X_RP8{iVU}(iRP8);
            iR = iR + 1;

            Rtemp(iR) = Y_RP9{iVU}(iRP9);   % excursion of RP7 on this vehicle unit        
            RxTemp(iR) = X_RP9{iVU}(iRP9);
            iR = iR + 1;
        end
    
    end

    [R(i-iStart+1), iRmax] = min(Rtemp); % find furthest excursion at this X position along the road
    Rx(i-iStart+1) = RxTemp(iRmax);
    
    SW = [SW (L(end) - R(end))];
       
end


TSW = max(SW);
SW = sort(SW);
SW99 = SW(ceil(length(SW)/100*99)); %get 99th percentile

if plotOn
    figure('name', 'TASP')
    
    hold on
    legTitles = {};

    for i = 1:nVehUnits             % plot: X_RP, Y_RP

        if sum(i == dollys(:)) == 0                           % only evaluated if veh unit number not in dollys vector
            plot(X_RP1{i}, Y_RP1{i}, 'Color', getColour(i));
            plot(X_RP2{i}, Y_RP2{i}, 'Color', getColour(i));
            plot(X_RP6{i}, Y_RP6{i}, 'Color', getColour(i));
            plot(X_RP7{i}, Y_RP7{i}, 'Color', getColour(i));
            plot(X_RP8{i}, Y_RP8{i}, 'Color', getColour(i));
            plot(X_RP9{i}, Y_RP9{i}, 'Color', getColour(i));            
            
            legTitles = [legTitles; ['unit' int2str(i) '-1']];
            legTitles = [legTitles; ['unit' int2str(i) '-2']];
            legTitles = [legTitles; ['unit' int2str(i) '-3']];
            legTitles = [legTitles; ['unit' int2str(i) '-4']];
            legTitles = [legTitles; ['unit' int2str(i) '-5']];
            legTitles = [legTitles; ['unit' int2str(i) '-6']];
            legTitles = [legTitles; ['unit' int2str(i) '-7']];
            legTitles = [legTitles; ['unit' int2str(i) '-8']];            
            legTitles = [legTitles; ['unit' int2str(i) '-9']];                        
        end
    end
    
    
    
%     plot([min(X_RP1{1}) max(X_RP1{1})], [max(L) max(L)], '--r', [min(X_RP2{1}) max(X_RP2{1})], [min(R) min(R)], '--r')
    plot(Lx, L, '-r', Rx, R, '-r')

    %axis ([floor(min(X_RP1{1})/20)*20 ceil(max(X_RP1{1})/20)*20 floor(min(R)/0.5)*0.5 ceil(max(L)/0.5)*0.5]) 
    axis([0 1400 -2.0 1.5]);
    xlabel('X [m]')
    ylabel('Y [m]')
    text(50,  0.5, ['Total Swept Width TSW = ' num2str(ceil(TSW*10)/10) ' m'])
    text(50, -0.5, ['99th percentile TSW = ' num2str(ceil(SW99*10)/10) ' m'])

    set(gcf,'PaperPosition',[0 0 16 11])            
    set(gca,'Xgrid','on');
    set(gca,'Ygrid','on');
    
    if isSave
        savePlot(savePath, runKey, 'TASP')
    end
    
    title('Tracking Ability on a Straight Path')
    hold off
end

function [i] = indClosestX(iLead, X_Lead, X_follow)
i = iLead;  % iFollower must be greater than iLead so start at iLead (better than starting from 1)
while (X_follow(i) < X_Lead) && (i < length(X_follow))   % find closest point along the road (could be off by 1 point)
    i = i + 1;            
end
