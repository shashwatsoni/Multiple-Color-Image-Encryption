function[x]=piecewiselinearchaoticmap(p,len,initial)
x=zeros(1,len);
x(1)=initial;
for i=1:len-1
    if(x(i)>=0&&x(i)<p)
      x(i+1)=x(i)/p;
    elseif(x(i)>=p&&x(i)<0.5)
      x(i+1)=((x(i)-p)/(0.5-p));
    elseif(x(i)>=0.5&&x(i)<1)
        if((1-x(i))>=0&&(1-x(i))<p)
        x(i+1)=(1-x(i))/p;
        elseif((1-x(i))>=p&&(1-x(i))<0.5)
        x(i+1)=((1-x(i))-p)/(0.5-p);
        end
    end
end
end