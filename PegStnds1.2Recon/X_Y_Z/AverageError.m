% Calculate mean of each series
m2=[];
s2=[];
m2(1,:) = mean(m(1:8,:));
s2(1,:) = std(m(1:8,:));
avgerr=sqrt(m2(1,1).^2 + m2(1,2).^2 + (m2(1,3)+2.8).^2);


%max=(m2(1,1).^2 + m2(1,2).^2 + (m2(1,3)+3).^2)
        