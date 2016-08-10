close all;
hold on;
iter=1;
for i=1:6:54
    
        
       % load (['Series2']);
        data(iter,:)=m1(i,:);
        data2(iter,:)=s1(i,:);
        iter=iter+1;
    
end
plot(data);
plot(data+data2,'--');
plot(data-data2,'--');
legend('Detector 1','Detector 2','Detector 3','Detector 4', 'Detector 5', 'Detector 6', 'Detector 7');
