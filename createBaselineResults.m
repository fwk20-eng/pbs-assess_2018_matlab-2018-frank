function results = createBaselineResults(r, Lim, nLevels, Is)

results = {}; %Allows for a non-square matrix

if r.STA ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STA), computePBSLevel('>', r.STA, Lim.STA, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.GRAa ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.GRAa), computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.GRAb ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.GRAb), computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.ACC ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.ACC), computePBSLevel('<', r.ACC, Lim.ACC, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.SRTt ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.SRTt), computePBSLevel('>', r.SRTt, Lim.SRT, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.SRTtrrcu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.SRTtrrcu), computePBSLevel('>', r.SRTtrrcu, Lim.SRT, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.YDC ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.YDC), computePBSLevel('>', r.YDC, Lim.YDC, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.RA), computePBSLevel('<', r.RA, Lim.RA, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.HSTO ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.HSTO), computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TASP ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TASP), computePBSLevel('<', r.TASP, Lim.TASP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.LSSP ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.LSSP), computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TS ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TS), computePBSLevel('<', r.TS, Lim.TS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.FS ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.FS), computePBSLevel('<', r.FS, Lim.FS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    if r.MoD ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.MoD), computePBSLevel('<', r.MoD, Lim.MoD, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
    
    if r.DoM ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.DoM), computePBSLevel('<', r.DoM, Lim.DoM, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
end

if r.STFD ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STFD), computePBSLevel('<', r.STFD, Lim.STFD, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.LSSPu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.LSSPu), computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.TSu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.TSu), computePBSLevel('<', r.TSu, Lim.TS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.FSu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.FSu), computePBSLevel('<', r.FSu, Lim.FS, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    if r.TSu ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.MoDu), computePBSLevel('<', r.MoDu, Lim.MoD, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
    
    if r.TSu ~= '-'
        results = addResultsRow_ForBaseline(results, num2str(r.DoMu), computePBSLevel('<', r.DoMu, Lim.DoM, nLevels));
    else
        results = addResultsRow_ForBaseline(results, '-', '-');
    end
end

if r.TSu ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(r.STFDu), computePBSLevel('<', r.STFDu, Lim.STFD, nLevels));
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = addResultsRow_ForBaseline(results, num2str(5.7*r.SRTt, '%0.1f'), '-');
else
    results = addResultsRow_ForBaseline(results, '-', '-');
end

end