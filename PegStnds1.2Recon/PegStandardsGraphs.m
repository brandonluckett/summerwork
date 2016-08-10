close all;
hold on;
clear all;
filename = '1.2 Recon.csv';
num=csvread(filename);
filename1 = 'Fig1.2Expected.csv';
num1=csvread(filename1);
    for ii=1:5
        x(ii,1)=num(ii,1);
        y(ii,1)=num(ii,2);
        z(ii,1)=num(ii,3);
        m(ii,1)=num(ii,4)./100;
    end
scatter(x,y,m,'filled')
text1='\leftarrow 1';
text2='\leftarrow 2';
text3='\leftarrow 3';
text4='\leftarrow 4';
text5='\leftarrow 5';
    text(x(1,1),y(1,1),text1)
    text(x(2,1),y(2,1),text2)
    text(x(3,1),y(3,1),text3)
    text(x(4,1),y(4,1),text4)
    text(x(5,1),y(5,1),text5)
    for i=1:5
        x1(i,1)=num1(i,1);
        y1(i,1)=num1(i,2);
    end
scatter(x1,y1,100,'filled');
text1='\leftarrow 1';
text2='\leftarrow 2';
text3='\leftarrow 3';
text4='\leftarrow 4';
text5='\leftarrow 5';
    text(x1(1,1),y1(1,1),text1)
    text(x1(2,1),y1(2,1),text2)
    text(x1(3,1),y1(3,1),text3)
    text(x1(4,1),y1(4,1),text4)
    text(x1(5,1),y1(5,1),text5)
xlim([-3 3]);
ylim([-3 3]);
xlabel('X-Position(cm)');
ylabel('Y-Position(cm)');
title('Figure 1.2 Recon');
legend('Reconstructed','Expected');
for i=1:5
    error(i,1)=abs(z(i,1)+2.8);
end
avg_err=(error(1,1)+error(2,1)+error(3,1)+error(4,1)+error(5,1))/5;
    


    