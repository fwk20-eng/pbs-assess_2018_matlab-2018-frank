function results = generateBaselineResults(r, Lim, nLevels, Is)

results = {}; %Allows for a non-square matrix

if r.STA ~= '-'
    results = AppenderBaseline(results, num2str(r.STA), checkLevel('>', r.STA, Lim.STA, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.GRAa ~= '-'
    results = AppenderBaseline(results, num2str(r.GRAa), checkLevel('>', r.GRAa, Lim.GRAa, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.GRAb ~= '-'
    results = AppenderBaseline(results, num2str(r.GRAb), checkLevel('>', r.GRAb, Lim.GRAb, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.ACC ~= '-'
    results = AppenderBaseline(results, num2str(r.ACC), checkLevel('<', r.ACC, Lim.ACC, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.SRTt ~= '-'
    results = AppenderBaseline(results, num2str(r.SRTt), checkLevel('>', r.SRTt, Lim.SRT, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.SRTtrrcu ~= '-'
    results = AppenderBaseline(results, num2str(r.SRTtrrcu), checkLevel('>', r.SRTtrrcu, Lim.SRT, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.YDC ~= '-'
    results = AppenderBaseline(results, num2str(r.YDC), checkLevel('>', r.YDC, Lim.YDC, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = AppenderBaseline(results, num2str(r.RA), checkLevel('<', r.RA, Lim.RA, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.HSTO ~= '-'
    results = AppenderBaseline(results, num2str(r.HSTO), checkLevel('<', r.HSTO, Lim.HSTO, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TASP ~= '-'
    results = AppenderBaseline(results, num2str(r.TASP), checkLevel('<', r.TASP, Lim.TASP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.LSSP ~= '-'
    results = AppenderBaseline(results, num2str(r.LSSP), checkLevel('<', r.LSSP, Lim.LSSP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TS ~= '-'
    results = AppenderBaseline(results, num2str(r.TS), checkLevel('<', r.TS, Lim.TS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.FS ~= '-'
    results = AppenderBaseline(results, num2str(r.FS), checkLevel('<', r.FS, Lim.FS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
    if r.MoD ~= '-'
        results = AppenderBaseline(results, num2str(r.MoD), checkLevel('<', r.MoD, Lim.MoD, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
    
    if r.DoM ~= '-'
        results = AppenderBaseline(results, num2str(r.DoM), checkLevel('<', r.DoM, Lim.DoM, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
end

if r.STFD ~= '-'
    results = AppenderBaseline(results, num2str(r.STFD), checkLevel('<', r.STFD, Lim.STFD, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.LSSPu ~= '-'
    results = AppenderBaseline(results, num2str(r.LSSPu), checkLevel('<', r.LSSPu, Lim.LSSP, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.TSu ~= '-'
    results = AppenderBaseline(results, num2str(r.TSu), checkLevel('<', r.TSu, Lim.TS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.FSu ~= '-'
    results = AppenderBaseline(results, num2str(r.FSu), checkLevel('<', r.FSu, Lim.FS, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
    if r.TSu ~= '-'
        results = AppenderBaseline(results, num2str(r.MoDu), checkLevel('<', r.MoDu, Lim.MoD, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
    
    if r.TSu ~= '-'
        results = AppenderBaseline(results, num2str(r.DoMu), checkLevel('<', r.DoMu, Lim.DoM, nLevels));
    else
        results = AppenderBaseline(results, '-', '-');
    end
end

if r.TSu ~= '-'
    results = AppenderBaseline(results, num2str(r.STFDu), checkLevel('<', r.STFDu, Lim.STFD, nLevels));
else
    results = AppenderBaseline(results, '-', '-');
end

if r.RA ~= '-'
    results = AppenderBaseline(results, num2str(5.7*r.SRTt, '%0.1f'), '-');
else
    results = AppenderBaseline(results, '-', '-');
end

end