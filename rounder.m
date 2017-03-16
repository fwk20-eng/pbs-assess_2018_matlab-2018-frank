function [res] = rounder(raw)

res.STA     = floor(raw.STA);                   % round down to nearest 1%
res.GRAa    = floor(raw.GRAa);                  % round down to nearest 1%
res.GRAb    = floor(raw.GRAb);                  % round down to nearest 1
res.ACC     = round([raw.ACC*10])/10;           % round      to nearest 0.1
res.YDC     = floor(raw.YDC*100)/100;           % round down to nearest 0.01
res.RA      =  ceil(raw.RA*100)/100;            % round up   to nearest 0.01
res.HSTO    =  ceil(raw.HSTO*10)/10;            % round up   to nearest 0.01
res.SRTt    = floor(raw.SRTt*100)/100;          % round down to nearest 0.01
res.SRTtrrcu= floor(raw.SRTtrrcu*100)/100;      % round down to nearest 0.01
res.TASP    =  ceil(raw.TASP*10)/10;            % round up   to nearest 0.1
res.LSSP    =  ceil(raw.LSSP*10)/10;            % round up   to nearest 0.1
res.TS      =  ceil(raw.TS*100)/100;            % round up   to nearest 0.01
res.FS      =  ceil(raw.FS*10)/10;              % round up   to nearest 0.1
res.MoD     =  ceil(raw.MoD*100)/100;           % round up   to nearest 0.01
res.DoM     =  ceil(raw.DoM*100)/100;           % round up   to nearest 0.01
res.STFD    =  ceil(raw.STFD);                  % round up   to nearest 1%
res.LSSPu   =  ceil(raw.LSSPu*10)/10;           % round up   to nearest 0.1
res.TSu     =  ceil(raw.TSu*100)/100;           % round up   to nearest 0.01
res.FSu     =  ceil(raw.FSu*10)/10;             % round up   to nearest 0.1
res.MoDu    =  ceil(raw.MoDu*100)/100;          % round up   to nearest 0.01
res.DoMu    =  ceil(raw.DoMu*100)/100;          % round up   to nearest 0.01
res.STFDu   =  ceil(raw.STFDu);                 % round up   to nearest 1%

end