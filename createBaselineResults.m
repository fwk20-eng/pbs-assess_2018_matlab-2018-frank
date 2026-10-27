function results = createBaselineResults(r, Lim, nLevels, Is)
%% Change Log
%
% [0.1.0] - 2020-09-08 Improved the significant figures process
%
results = {}; %Allows for a non-square matrix

if r.STA ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STA,'%.0f'), computePBSLevel('>', r.STA, Lim.STA, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.GRAa ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.GRAa,'%.0f'), computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.GRAb ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.GRAb,'%.0f'), computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.ACC ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.ACC,'%.1f'), computePBSLevel('<', r.ACC, Lim.ACC, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.SRTt ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.SRTt,'%.2f'), computePBSLevel('>', r.SRTt, Lim.SRT, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.SRTtrrcu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.SRTtrrcu,'%.2f'), computePBSLevel('>', r.SRTtrrcu, Lim.SRT, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.YDC ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.YDC,'%.2f'), computePBSLevel('>', r.YDC, Lim.YDC, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.RA,'%.2f'), computePBSLevel('<', r.RA, Lim.RA, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.HSTO ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.HSTO,'%.1f'), computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TASP ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TASP,'%.2f'), computePBSLevel('<', r.TASP, Lim.TASP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.LSSP ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.LSSP,'%.1f'), computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TS ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TS,'%.2f'), computePBSLevel('<', r.TS, Lim.TS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.FS ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.FS,'%.2f'), computePBSLevel('<', r.FS, Lim.FS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    if r.MoD ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.MoD,'%.2f'), computePBSLevel('<', r.MoD, Lim.MoD, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
    
    if r.DoM ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.DoM,'%.2f'), computePBSLevel('<', r.DoM, Lim.DoM, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
end

if r.STFD ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STFD,'%.0f'), computePBSLevel('<', r.STFD, Lim.STFD, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.LSSPu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.LSSPu,'%.1f'), computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TSu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TSu,'%.2f'), computePBSLevel('<', r.TSu, Lim.TS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.FSu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.FSu,'%.2f'), computePBSLevel('<', r.FSu, Lim.FS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    if r.MoDu ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.MoDu,'%.2f'), computePBSLevel('<', r.MoDu, Lim.MoD, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
    
    if r.DoMu ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.DoMu,'%.2f'), computePBSLevel('<', r.DoMu, Lim.DoM, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
end

if r.STFDu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STFDu,'%.0f'), computePBSLevel('<', r.STFDu, Lim.STFD, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

%% Rearward Amplification limit

if isnumeric(r.RA)

    if isnumeric(r.SRTtrrcu)

        % Use rearmost roll-coupled unit SRT
        % Round upwards to nearest 0.01
        raLimit = ceil(5.7*r.SRTtrrcu*100)/100;
        raLimitText = num2str(raLimit, '%.2f');

    elseif isnumeric(r.SRTt)

        % Fallback for historical baseline results
        % without a separate SRTrrcu
        raLimitText = num2str(5.7*r.SRTt, '%.1f');

    else
        raLimitText = '-';
    end

    results = addResultsRow_ForBaseline( ...
        results, raLimitText, '-');

else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

end