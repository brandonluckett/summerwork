close all;
hold on;
for i=1:7
    for ii=31:35
        %Series1(ii,i)=num(ii,i);
        %load (['Series',num2str(ii)]);
        data(ii-30,i)=m(ii,i);
        data2(ii-30,i)=s(ii,i);
    end
end
plot(data);
plot(data+data2,'--');
plot(data-data2,'--');
legend('Detector 1','Detector 2','Detector 3','Detector 4', 'Detector 5', 'Detector 6', 'Detector 7');
