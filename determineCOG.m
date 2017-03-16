function [mTotal x z] = determineCOG(mChas, xChas, zChas, mAxle, xAxle, zAxle, grouping, mLoad, xLoad, zLoad);

for  ii=1:length(mChas)
    if (ii==1)
        mTotal(ii)=mChas(ii)+sum(mAxle(grouping{ii}))+sum(mAxle(grouping{ii+1}))+sum(mLoad{:,ii});       
        x(ii)=(xChas(ii)*mChas(ii) + sum(xAxle(grouping{ii}).*mAxle(grouping{ii})) + sum(xAxle(grouping{ii+1}).*mAxle(grouping{ii+1})) + sum(xLoad{:,ii}.*mLoad{:,ii}) )/mTotal(ii);        
        z(ii)=(zChas(ii)*mChas(ii) +sum(zAxle(grouping{ii}).*mAxle(grouping{ii})) +sum(zAxle(grouping{ii+1}).*mAxle(grouping{ii+1})) +sum(zLoad{:,ii}.*mLoad{:,ii}) )/mTotal(ii);
    else
        mTotal(ii)=mChas(ii)+sum(mAxle(grouping{ii+1}))+sum(mLoad{:,ii});       
        x(ii)=(xChas(ii)*mChas(ii) + sum(xAxle(grouping{ii+1}).*mAxle(grouping{ii+1})) + sum(xLoad{:,ii}.*mLoad{:,ii}) )/mTotal(ii);        
        z(ii)=(zChas(ii)*mChas(ii) +sum(zAxle(grouping{ii+1}).*mAxle(grouping{ii+1})) +sum(zLoad{:,ii}.*mLoad{:,ii}) )/mTotal(ii);
    end
end
end