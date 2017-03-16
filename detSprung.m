function [m x z] =  detSprung(mChas, xChas, zChas, mLoad, xLoad, zLoad)

for ii=1:length(mChas)
    if ii==1,
        m(ii)=mChas(ii)+sum(mLoad{:,ii});
        x(ii)=(xChas(ii)*mChas(ii) + sum(xLoad{:,ii}.*mLoad{:,ii}) )/m(ii);
        z(ii)=(zChas(ii)*mChas(ii) + sum(zLoad{:,ii}.*mLoad{:,ii}) )/m(ii);
    else
        m(ii)=mChas(ii)+sum(mLoad{:,ii});
        x(ii)=(xChas(ii)*mChas(ii) + sum(xLoad{:,ii}.*mLoad{:,ii}) )/m(ii);
        z(ii)=(zChas(ii)*mChas(ii) + sum(zLoad{:,ii}.*mLoad{:,ii}) )/m(ii);
    end
end
end