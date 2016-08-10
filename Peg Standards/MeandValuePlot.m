close all;
hold on;
for i=1:7
    for ii=1:5
         data(ii,i)=m(ii,i,5);
         data2(ii,i)=s(ii,i,5);
    end
end
plot(data);
plot(data+data2,'--');
plot(data-data2,'--');
%semilogy(data); hold on;
%semilogy(data+data2,'--')
%semilogy(data-data2,'--')
legend('Detector 1','Detector 2','Detector 3','Detector 4', 'Detector 5', 'Detector 6', 'Detector 7');
