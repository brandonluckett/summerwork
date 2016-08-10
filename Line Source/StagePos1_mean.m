close all;
hold on;
for i=1:7
    for ii=2:10
        load (['Series',num2str(ii)]);
        data(ii,i)=m(6,i);
        data2(ii,i)=s(6,i);
    end
end
plot(data);
plot(data+data2,'--');
plot(data-data2,'--');
legend('Detector 1','Detector 2','Detector 3','Detector 4', 'Detector 5', 'Detector 6', 'Detector 7');
