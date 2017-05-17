function results = generateBaselineResults(r, Lim, nLevels, Is)

results = {}; %Allows for a non-square matrix

if r.STA ~= '-'
    results = AppenderBaseline(results, num2str(r.STA, '%0.2f'), checkLevel('>', r.STA, Lim.STA, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.GRAa ~= '-'
    results = AppenderBaseline(results, num2str(r.GRAa, '%0.2f'), checkLevel('>', r.GRAa, Lim.GRAa, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.GRAb ~= '-'
    results = AppenderBaseline(results, num2str(r.GRAb, '%0.2f'), checkLevel('>', r.GRAb, Lim.GRAb, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.ACC ~= '-'
    results = AppenderBaseline(results, num2str(r.ACC, '%0.2f'), checkLevel('<', r.ACC, Lim.ACC, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.SRTt ~= '-'
    results = AppenderBaseline(results, num2str(r.SRTt, '%0.2f'), checkLevel('>', r.SRTt, Lim.SRT, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.SRTtrrcu ~= '-'
    results = AppenderBaseline(results, num2str(r.SRTtrrcu, '%0.2f'), '-');
else
    results = AppenderBaseline(results, '-', '-');
end

if r.YDC ~= '-'
    results = AppenderBaseline(results, num2str(r.YDC, '%0.2f'), checkLevel('>', r.YDC, Lim.YDC, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = AppenderBaseline(results, num2str(r.RA, '%0.2f'), checkLevel('<', r.RA, Lim.RA, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.HSTO ~= '-'
    results = AppenderBaseline(results, num2str(r.HSTO, '%0.2f'), checkLevel('<', r.HSTO, Lim.HSTO, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TASP ~= '-'
    results = AppenderBaseline(results, num2str(r.TASP, '%0.2f'), checkLevel('<', r.TASP, Lim.TASP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.LSSP ~= '-'
    results = AppenderBaseline(results, num2str(r.LSSP, '%0.2f'), checkLevel('<', r.LSSP, Lim.LSSP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TS ~= '-'
    results = AppenderBaseline(results, num2str(r.TS, '%0.2f'), checkLevel('<', r.TS, Lim.TS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.FS ~= '-'
    results = AppenderBaseline(results, num2str(r.FS, '%0.2f'), checkLevel('<', r.FS, Lim.FS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    if r.MoD ~= '-'
        results = AppenderBaseline(results, num2str(r.MoD, '%0.2f'), checkLevel('<', r.MoD, Lim.MoD, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
    
    if r.DoM ~= '-'
        results = AppenderBaseline(results, num2str(r.DoM, '%0.2f'), checkLevel('<', r.DoM, Lim.DoM, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
end

if r.STFD ~= '-'
    results = AppenderBaseline(results, num2str(r.STFD, '%0.2f'), checkLevel('<', r.STFD, Lim.STFD, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.LSSPu ~= '-'
    results = AppenderBaseline(results, num2str(r.LSSPu, '%0.2f'), checkLevel('<', r.LSSPu, Lim.LSSP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TSu ~= '-'
    results = AppenderBaseline(results, num2str(r.TSu, '%0.2f'), checkLevel('<', r.TSu, Lim.TS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.FSu ~= '-'
    results = AppenderBaseline(results, num2str(r.FSu, '%0.2f'), checkLevel('<', r.FSu, Lim.FS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    if r.TSu ~= '-'
        results = AppenderBaseline(results, num2str(r.MoDu, '%0.2f'), checkLevel('<', r.MoDu, Lim.MoD, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
    
    if r.TSu ~= '-'
        results = AppenderBaseline(results, num2str(r.DoMu, '%0.2f'), checkLevel('<', r.DoMu, Lim.DoM, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
end

if r.TSu ~= '-'
    results = AppenderBaseline(results, num2str(r.STFDu, '%0.2f'), checkLevel('<', r.STFDu, Lim.STFD, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

end