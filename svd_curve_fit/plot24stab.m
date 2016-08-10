%% long term stability
if 0
 make_mat_from_study('/tmp/pegsstudy24h.mat','1.2.826.0.1.3680043.8.498.522279114561898119543756',[1 1 1 1 1 1 1])
 load /tmp/pegsstudy24h.mat
end

close all

study=2;
ch=3;

center_stage=find(sum(stage_positions{study}.^2,2)==0);
X=signal{study}(:,center_stage,ch);

XA = mean(X(50:150,:),1);

figure(1);
clf
hold on
c = colormap(jet(size(X,2)));
for ii = size(X,2):-1:1
%%for ii = 1:size(X,2) 
    plot(time{2},X(:,ii),'color',c(ii,:)')
end
xlabel('time');
ylabel('V')
title(sprintf('Channel %i center stage over 24 hours',ch))

figure(2)
clf
hold on
c = colormap(jet(size(X,2)));
%%for ii = size(X,2):-1:1
for ii = 1:size(X,2)
    plot(time{2},X(:,ii),'color',c(ii,:)')
end
xlabel('time');
ylabel('V')
title(sprintf('Channel %i center stage over 24 hours',ch))

%%
figure(3)
clf
hold on
studies=[2 4];
for i=studies
    center_stage=find(sum(stage_positions{i}.^2,2)==0);
    X=signal{i}(:,center_stage,ch);
    XA = mean(X(50:150,:),1);
    plot(XA)
end
title(sprintf('Channel %i, center stage, mean for small t',ch))
xlabel('Trace number')
legend('singe source','Both Sources','Background')

%%
figure(4)
clf
hold on
studies=[2 4 5];
for i=studies
    center_stage=find(sum(stage_positions{i}.^2,2)==0);
    X=signal{i}(:,center_stage,ch);
    XA = mean(X(50:150,:),1);
    plot(movingstd(XA,10))
end
title(sprintf('Channel %i, center stage, moving standard deviation',ch))
xlabel('Trace number')
legend('singe source','Both Sources','Background')


%% offset hist
figure(5)
clf
hold on
b = linspace(-3,1,512);
for i=1:6
    [c, b1] = hist(shift{2}(1,:,i),b);
    plot(b,c)
end
legend('1','2','3','4','5','6','7')
title(sprintf('Constant offset histogram'))
xlabel('offset')
ylabel('count')
