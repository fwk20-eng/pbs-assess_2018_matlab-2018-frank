function [RA] = computePBSLimitsRA(r)

RAtemp = floor(5.7*r.SRTtrrcu*100)/100;        %round up to nearest 0.01
RA = [RAtemp RAtemp RAtemp RAtemp];

end