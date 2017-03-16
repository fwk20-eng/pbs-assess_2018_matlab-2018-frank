function [lim] = setLims(isBus, isDanGoods)

lim.STA = [15 12 10 5];
lim.GRAa = [20 15 12 10];
lim.GRAb = [80 70 70 60];
lim.ACC = [20 23 26 29];
lim.YDC = [0.15 0.15 0.15 0.15];
lim.HSTO = [0.6 0.8 1.0 1.2];

if isBus,
    lim.SRT = [0.4 0.4 0.4 0.4];
    lim.FS = [1.5 1.5 1.5 1.5];
elseif isDanGoods,
    lim.SRT = [0.4 0.4 0.4 0.4];
    lim.FS = [0.7 0.7 0.7 0.7];
else
    lim.SRT = [0.35 0.35 0.35 0.35];
    lim.FS = [0.7 0.7 0.7 0.7];
end
    
lim.TASP = [2.9 3.0 3.1 3.3];
lim.LSSP = [7.4 8.7 10.6 13.7];
lim.TS = [0.30 0.35 0.35 0.50];
lim.MoD = [0.55 0.55 0.55 0.55];
lim.DoM = [0.25 0.25 0.25 0.25];
lim.STFD = [80 80 80 80];

end