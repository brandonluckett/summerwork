% Calculate mean of each series
m2=[];
s2=[];
m2(1,:) = mean(num(1:45,:));
s2(1,:) = std(num(1:45,:));
avgerr=sqrt(m2(1,1).^2 + m2(1,2).^2 + (m2(1,3)+3).^2);
k=1;
while k<46
    Mavg(k,1)=sqrt(num(k,1).^2 + num(k,2).^2 + (num(k,3)+3).^2);
    k=k+1;
end


%max=(m2(1,1).^2 + m2(1,2).^2 + (m2(1,3)+3).^2)
        