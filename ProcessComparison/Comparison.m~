clear all; 
close all;
%Wolfgang data
load('1.2.826.0.1.3680043.8.498.52227911456195992948037_filtered.mat');
[beta res]=est_field(time,signal,BG_Series);
    m = [];
    s = [];
%for ii = 2:10
%    ser = ii;
%    j = 1;
%    for i=1:5:25
%        m(j,:,ii-1) = mean(beta{ser}(i:4+i,:),1);
%        s(j,:,ii-1) = std(beta{ser}(i:4+i,:),[],1);
%        j = j + 1;
%    end
%end
for i=1:7
    for ii=2:10
        load (['Series',num2str(ii)]);
        data(ii-1,i)=m(1,i);
        StdDev(ii-1,i)=s(1,i);
    end
end
%MSA data
load('Line Source Data CSV.csv');
    j = 1;
    m1 = [];
    s1 = [];
    for i=1:5:540
        m1(j,:) = mean(Line_Source_Data_CSV(i:4+i,:),1);
        s1(j,:) = std(Line_Source_Data_CSV(i:4+i,:),[],1);
        j = j + 1;
    end
    iter=1;
    for i=1:6:54
        data1(iter,:)=m1(i,:);
        %data3(iter,:)=s1(i,:);
        iter=iter+1;
    end
%plot(data);
%figure
%plot(data1);

%Find the constant relating MSA to Wolfgang
n=1;
while n<10
    num(n,:)=data1(n,:)./data(n,:);
    n=n+1;
end
AverageConst=mean(num);
AverageConst=mean(AverageConst);

%Normalize the graphs
dataMDA=transpose(data);
dataMSA=transpose(data1);
MaxMDA=max(dataMDA);
MaxMSA=max(dataMSA);

for k=1:9
    normalMDA(k,:)=abs(data(k,:)./MaxMDA(1,k));
    normalMSA(k,:)=abs(data1(k,:)./MaxMSA(1,k));
end

%Plot of the norm
plot(normalMDA,'--')
hold on;
plot(normalMSA)
ylim([-2 2]);
legend('MSA')
title('Normal of MSA v.s. MDA')
xlabel('Detector')
ylabel('Normalized Sensor Signal')


%Plot of the difference of norms
figure
plot(normalMDA-normalMSA)
ylim([-1 1]);

for a=1:7
    normalDiff(:,a)=norm(normalMSA(:,a)-normalMDA(:,a));
end

%Average of the norm of the StdDev of s and s1 using 1:6:54 of s1
    iter=1;
for i=1:6:54
    s1_1(iter,:)=s1(i,:);
    iter=iter+1;
end

sMDA=transpose(StdDev);
sMSA=transpose(s1_1);
Max_s_MDA=max(sMDA);
Max_s_MSA=max(sMSA);

k=1;
for k=1:9
    normal_s_MDA(k,:)=abs(StdDev(k,:)./Max_s_MDA(1,k));
    normal_s_MSA(k,:)=abs(s1_1(k,:)./Max_s_MSA(1,k));
end
    

    AvgNormMDA=mean(normal_s_MDA);
    AvgNormMSA=mean(normal_s_MSA);


 
