%% Function Description
% 
% Describe the function here
% 
%% Inputs
% 
% * variable: description
% 
%% Outputs
% 
% * variable: description
% 
%% Change Log
%
% [0.3.0] - 2020-09-08 Separated that Australian PBS doesn't have the
% subscripts and improved the significant figures
%
% [0.2.0] - 2017-06-04
%
% *Fixed*
%
% * Removed the floating precision
% 
% [0.1.0] - 2017-05-02
% 
% *Added*
% 
% * First code

function pbsResultsTable = createTableLatexResults(fullName, Lim, LimReport, r, Report, nLevels, Is)
pbsResultsTable = {};

pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STA        , '\%'       , num2str(r.STA,'%.0f') , computePBSLevel('>', r.STA, Lim.STA, nLevels), LimReport.STA); % C3 = [C1 C2] concatenates contents of cell arrays C1 & C2 into a cell array
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.GRAa       , '\%'       , num2str(r.GRAa,'%.0f') , computePBSLevel('>', r.GRAa, Lim.GRAa, nLevels), LimReport.GRAa);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.GRAb       , 'km/h'    , num2str(r.GRAb,'%.0f') , computePBSLevel('>', r.GRAb, Lim.GRAb, nLevels), LimReport.GRAb);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.ACC        , 's'       , num2str(r.ACC,'%.1f') , computePBSLevel('<', r.ACC, Lim.ACC, nLevels), LimReport.ACC);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.SRTt       , 'g'       , num2str(r.SRTt,'%.2f')   , computePBSLevel('>', r.SRTt, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.SRTtrrcu   , 'g'       , num2str(r.SRTtrrcu,'%.2f')   , computePBSLevel('>', r.SRTtrrcu, Lim.SRT, nLevels), LimReport.SRT);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.YDC        , '-'       , num2str(r.YDC,'%.2f')    , computePBSLevel('>', r.YDC, Lim.YDC, nLevels), LimReport.YDC);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.RA         , '-'       , num2str(r.RA,'%.2f')     , computePBSLevel('<', r.RA, Lim.RA, nLevels), LimReport.RA);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.HSTO       , 'm'       , num2str(r.HSTO,'%.1f')   , computePBSLevel('<', r.HSTO, Lim.HSTO, nLevels), LimReport.HSTO);
if ~Is.australianPBS
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.TASP '\tnote{1}']       , 'm'       , num2str(r.TASP,'%.1f')   , computePBSLevel('<', r.TASP, Lim.TASP, nLevels), LimReport.TASP);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.LSSP       , 'm'       , num2str(r.LSSP,'%.1f')   , computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels), LimReport.LSSP);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TS         , 'm'       , num2str(r.TS,'%.2f')     , computePBSLevel('<', r.TS, Lim.TS, nLevels), LimReport.TS);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.FS '\tnote{3}'], 'm'       , num2str(r.FS,'%.2f')     , computePBSLevel('<', r.FS, Lim.FS, nLevels), LimReport.FS);
    if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.MoD '\tnote{2}']    , 'm', num2str(r.MoD,'%.2f')    , computePBSLevel('<', r.MoD, Lim.MoD, nLevels), LimReport.MoD);
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.DoM '\tnote{2}']    , 'm', num2str(r.DoM,'%.2f')    , computePBSLevel('<', r.DoM, Lim.DoM, nLevels), LimReport.DoM);
    end
else
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TASP       , 'm'       , num2str(r.TASP,'%.1f')   , computePBSLevel('<', r.TASP, Lim.TASP, nLevels), LimReport.TASP);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.LSSP       , 'm'       , num2str(r.LSSP,'%.1f')   , computePBSLevel('<', r.LSSP, Lim.LSSP, nLevels), LimReport.LSSP);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TS         , 'm'       , num2str(r.TS,'%.2f')     , computePBSLevel('<', r.TS, Lim.TS, nLevels), LimReport.TS);
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.FS         , 'm'       , num2str(r.FS,'%.2f')     , computePBSLevel('<', r.FS, Lim.FS, nLevels), LimReport.FS);
    if Is.semi %doesnt add MoD, DoM if it is not a SemiTrailer
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.MoD    , 'm', num2str(r.MoD,'%.2f')    , computePBSLevel('<', r.MoD, Lim.MoD, nLevels), LimReport.MoD);
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.DoM    , 'm', num2str(r.DoM,'%.2f')    , computePBSLevel('<', r.DoM, Lim.DoM, nLevels), LimReport.DoM);
    end
end    
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STFD   , '\%', num2str(r.STFD,'%.0f')   , computePBSLevel('<', r.STFD, Lim.STFD, nLevels), LimReport.STFD);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.LSSPu  , 'm', num2str(r.LSSPu,'%.1f')  , computePBSLevel('<', r.LSSPu, Lim.LSSP, nLevels), LimReport.LSSP);
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.TSu    , 'm', num2str(r.TSu,'%.2f')    , computePBSLevel('<', r.TSu, Lim.TS, nLevels), LimReport.TS);
if ~Is.australianPBS
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.FSu '\tnote{3}'], 'm', num2str(r.FSu,'%.2f')   , computePBSLevel('<', r.FSu, Lim.FS, nLevels), LimReport.FS);
    if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.MoDu '\tnote{1}']   , 'm', num2str(r.MoDu,'%.2f')   , computePBSLevel('<', r.MoDu, Lim.MoD, nLevels), LimReport.MoD);
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, [fullName.DoMu '\tnote{1}']   , 'm', num2str(r.DoMu,'%.2f')   , computePBSLevel('<', r.DoMu, Lim.DoM, nLevels), LimReport.DoM);
    end
else
    pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.FSu, 'm', num2str(r.FSu,'%.2f')   , computePBSLevel('<', r.FSu, Lim.FS, nLevels), LimReport.FS);
    if Is.semi %Doesnt add MoDu, DoMu if it is not a SemiTrailer
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.MoDu  , 'm', num2str(r.MoDu,'%.2f')   , computePBSLevel('<', r.MoDu, Lim.MoD, nLevels), LimReport.MoD);
        pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.DoMu  , 'm', num2str(r.DoMu,'%.2f')   , computePBSLevel('<', r.DoMu, Lim.DoM, nLevels), LimReport.DoM);
    end
end
pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, fullName.STFDu  , '\%', num2str(r.STFDu,'%.0f')  , computePBSLevel('<', r.STFDu, Lim.STFD, nLevels), LimReport.STFD);

pbsResultsTable = addResultsRow_ForReport(pbsResultsTable, '$\dagger$ 5.7*SRTrrcu'  , '-', num2str(Lim.RA(1), '%0.2f')  , '-', {'-' '-' '-' '-'});