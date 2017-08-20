function [Lim, LimReport] = setLims(Is)

Lim.STA = [15 12 10 5];
Lim.GRAa = [20 15 12 10];
Lim.GRAb = [80 70 70 60];
Lim.ACC = [20 23 26 29];

if Is.bus
    Lim.SRT = [0.4 0.4 0.4 0.4];
    Lim.FS = [1.5 1.5 1.5 1.5];
elseif Is.danGoods
    Lim.SRT = [0.4 0.4 0.4 0.4];
    Lim.FS = [0.7 0.7 0.7 0.7];
else
    Lim.SRT = [0.35 0.35 0.35 0.35];
    Lim.FS = [0.7 0.7 0.7 0.7];
end

Lim.YDC = [0.15 0.15 0.15 0.15];
Lim.HSTO = [0.6 0.8 1.0 1.2];
Lim.TASP = [2.95 3.05 3.15 3.35];
Lim.LSSP = [7.4 8.7 10.6 13.7];
Lim.TS = [0.30 0.35 0.35 0.50];
Lim.MoD = [0.55 0.55 0.55 0.55];
Lim.DoM = [0.25 0.25 0.25 0.25];
Lim.STFD = [80 80 80 80];

% % PBS Levels for PBS Report
LimReport.STA =     {'$\geq$15' '$\geq$12' '$\geq$10' '$\geq$5'};
LimReport.GRAa =    {'$\geq$20'	'$\geq$15' '$\geq$12' '$\geq$10'};
LimReport.GRAb =    {'$\geq$80'	'$\geq$70' '$\geq$70' '$\geq$60'};
LimReport.ACC =     {'$\leq$20'	'$\leq$23' '$\leq$26' '$\leq$29'};

if Is.bus
    LimReport.SRT = {'$\geq$0.4' '$\geq$0.4' '$\geq$0.4' '$\geq$0.4'};
    LimReport.FS =  {'$\leq$1.5' '$\leq$1.5' '$\leq$1.5' '$\leq$1.5'};
elseif Is.danGoods
    LimReport.SRT = {'$\geq$0.4' '$\geq$0.4' '$\geq$0.4' '$\geq$0.4'};
    LimReport.FS =  {'$\leq$0.7' '$\leq$0.7' '$\leq$0.7' '$\leq$0.7'};
else
    LimReport.SRT = {'$\geq$0.35' '$\geq$0.35' '$\geq$0.35'	'$\geq$0.35'};
    LimReport.FS =  {'$\leq$0.7' '$\leq$0.7' '$\leq$0.7' '$\leq$0.7'};
end

LimReport.YDC =     {'$\geq$0.15' '$\geq$0.15' '$\geq$0.15' '$\geq$0.15'};
LimReport.RA = {'$\leq\dagger$' '$\leq\dagger$' '$\leq\dagger$' '$\leq\dagger$'};
LimReport.HSTO =    {'$\leq$0.6' '$\leq$0.8' '$\leq$1.0' '$\leq$1.2'};
LimReport.TASP =    {'$\leq$2.95' '$\leq$3.05' '$\leq$3.15' '$\leq$3.35'};
LimReport.LSSP =    {'$\leq$7.4' '$\leq$8.7' '$\leq$10.6' '$\leq$13.7'};
LimReport.TS =      {'$\leq$0.3' '$\leq$0.35' '$\leq$0.35' '$\leq$0.50'};
LimReport.MoD =     {'$\leq$0.55' '$\leq$0.55' '$\leq$0.55' '$\leq$0.55'};
LimReport.DoM =     {'$\leq$0.25' '$\leq$0.25' '$\leq$0.25' '$\leq$0.25'};
LimReport.STFD =    {'$\leq$80' '$\leq$80' '$\leq$80' '$\leq$80'};

LimReport.RA =    {'-' '-' '-' '-'};

% LimReport.STA =     [{'$\geq$15'} {'$\geq$12'} {'$\geq$10'} {'$\geq$5'}];
% LimReport.GRAa =    [{'$\geq$20'}	{'$\geq$15'} {'$\geq$12'} {'$\geq$10'}];
% LimReport.GRAb =    [{'$\geq$80'}	{'$\geq$70'} {'$\geq$70'} {'$\geq$60}'}];
% LimReport.ACC =     [{'$\leq$20'}	{'$\leq$23'} {'$\leq$26'} {'$\leq$29'}];
% 
% if Is.bus
%     LimReport.SRT = [{'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'}];
%     LimReport.FS =  [{'$\leq$1.5'} {'$\leq$1.5'} {'$\leq$1.5'} {'$\leq$1.5'}];
% elseif Is.danGoods
%     LimReport.SRT = [{'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'}];
%     LimReport.FS =  [{'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'}];
% else
%     LimReport.SRT = [{'$\geq$0.35'} {'$\geq$0.35'} {'$\geq$0.35'}	{'$\geq$0.35'}];
%     LimReport.FS =  [{'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'}];
% end
% 
% LimReport.YDC =     [{'$\geq$0.15'} {'$\geq$0.15'} {'$\geq$0.15'} {'$\geq$0.15'}];
% LimReport.RA = [{'$\leq\dagger$'} {'$\leq\dagger$'} {'$\leq\dagger$'} {'$\leq\dagger$'}];
% LimReport.HSTO =    [{'$\leq$0.6'} {'$\leq$0.8'} {'$\leq$1.0'} {'$\leq$1.2'}];
% LimReport.TASP =    [{'$\leq$2.9'} {'$\leq$3.0'} {'$\leq$3.1'} {'$\leq$3.3'}];
% LimReport.LSSP =    [{'$\leq$7.4'} {'$\leq$8.7'} {'$\leq$10.6'} {'$\leq$13.7'}];
% LimReport.TS =      [{'$\leq$0.3'} {'$\leq$0.35'} {'$\leq$0.35'} {'$\leq$0.50'}];
% LimReport.MoD =     [{'$\leq$0.55'} {'$\leq$0.55'} {'$\leq$0.55'} {'$\leq$0.55'}];
% LimReport.DoM =     [{'$\leq$0.25'} {'$\leq$0.25'} {'$\leq$0.25'} {'$\leq$0.25'}];
% LimReport.STFD =    [{'$\leq$80'} {'$\leq$80'} {'$\leq$80'} {'$\leq$80'}];
% % 
% PBS Levels for PBS Report
% LimReport = [{'Level 1'} {'Level 2'} {'Level 3'} {'Level 4'}];
% LimReport = [LimReport; [{'$\geq$15'} {'$\geq$12'} {'$\geq$10'} {'$\geq$5'}]];
% LimReport = [LimReport; [{'$\geq$20'}	{'$\geq$15'} {'$\geq$12'} {'$\geq$10'}]];
% LimReport = [LimReport;[{'$\geq$80'}	{'$\geq$70'} {'$\geq$70'} {'$\geq$60}'}]];
% LimReport = [LimReport;[{'$\leq$20'}	{'$\leq$23'} {'$\leq$26'} {'$\leq$29'}]];
% 
% if Is.bus
%     LimReport = [LimReport;[{'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'}]];
%     LimReport = [LimReport;[{'$\leq$1.5'} {'$\leq$1.5'} {'$\leq$1.5'} {'$\leq$1.5'}]];
% elseif Is.danGoods
%     LimReport = [LimReport;[{'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'} {'$\geq$0.4'}]];
%     LimReport = [LimReport;[{'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'}]];
% else
%     LimReport = [LimReport;[{'$\geq$0.35'} {'$\geq$0.35'} {'$\geq$0.35'}	{'$\geq$0.35'}]];
%     LimReport = [LimReport;[{'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'} {'$\leq$0.7'}]];
% end
% 
% LimReport = [LimReport;[{'$\geq$0.15'} {'$\geq$0.15'} {'$\geq$0.15'} {'$\geq$0.15'}]];
% LimReport = [LimReport;[{'$\leq$0.6'} {'$\leq$0.8'} {'$\leq$1.0'} {'$\leq$1.2'}]];
% LimReport = [LimReport;[{'$\leq$2.9'} {'$\leq$3.0'} {'$\leq$3.1'} {'$\leq$3.3'}]];
% LimReport = [LimReport;[{'$\leq$7.4'} {'$\leq$8.7'} {'$\leq$10.6'} {'$\leq$13.7'}]];
% LimReport = [LimReport;[{'$\leq$0.3'} {'$\leq$0.35'} {'$\leq$0.35'} {'$\leq$0.50'}]];
% LimReport = [LimReport;[{'$\leq$0.55'} {'$\leq$0.55'} {'$\leq$0.55'} {'$\leq$0.55'}]];
% LimReport = [LimReport;[{'$\leq$0.25'} {'$\leq$0.25'} {'$\leq$0.25'} {'$\leq$0.25'}]];
% LimReport = [LimReport;[{'$\leq$80'} {'$\leq$80'} {'$\leq$80'} {'$\leq$80'}]];
end