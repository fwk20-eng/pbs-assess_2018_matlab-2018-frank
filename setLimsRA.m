function [RA] = setLimsRA(r)

RAtemp = ceil(5.7*r.SRTtrrcu*1000)/1000;        %round up   to nearest 0.001
RA = [RAtemp RAtemp RAtemp RAtemp];

end