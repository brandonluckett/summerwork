clear all
close all
load('1.2.826.0.1.3680043.8.498.52227911456195992948037_filtered.mat');
%load /Users/wstefan/Downloads/2394713_1.2.826.0.1.3680043.8.498.52227911456127175984041_filtered.mat
%serbg = 1;
%ser   = 10;
%load /home/wstefan/Downloads/1.2.826.0.1.3680043.8.498.52227911456127175984041_filtered.mat
%load /tmp/Peg_Standards_06_2016_filterd.mat

%% 
tic
[beta res]=est_field(time,signal,BG_Series);
toc

tic
beta_nobg=est_field_nobg(time,signal);
toc

%% Plot
close all
%sers=[91 132]; %mouse
%sers=[94 134]
sers=[2 4 5 6 7 8 9 10];
%sers=2;
%sers=[19 20]
%sers=[2 3 4 5 6 7 8 9 10]


for i = 1:length(sers)
    ser=sers(i);
    [s,idx]=sort(stage_positions{ser}(:,1)*10000+stage_positions{ser}(:,2)*100+stage_positions{ser}(:,3));
    idx = 1:size(beta{ser},1);
    figure(i)
    subplot(2,2,1)
    n = 1:size(beta{ser},1);
    plot(n,beta{ser}(idx,:))
    
    plot(n,beta{ser}(idx,:))
    old_stage=[1e18  1e18 1e18];
    for i=1:length(stage_positions{ser});
        if not(norm(stage_positions{ser}(idx(i),:)-old_stage)==0)
            old_stage=stage_positions{ser}(idx(i),:);
            h=text(i+10,0,sprintf('%i ',old_stage));
            set(h,'Rotation',90);
        end
    end
    title(Series_description{ser})
    legend('1','2','3','4','5','6','7')
    xlabel('trace');
    ylabel('relative field strength');

    subplot(2,2,3)    
    if BG_Series(ser)>0
        plot(beta_nobg{BG_Series(ser)})
        xlabel('background')
    end
    
    subplot(2,2,2)
    m = mean(beta{ser},1);
    s = std(beta{ser},[],1);
    errorbar(1:7,m,s)
    %plot(beta{ser}')
    xlabel('Sensor')
    ylabel('relative field strength');
    subplot(2,2,4)
    semilogy(n,res{ser}(idx,:))
    xlabel('trace');
    ylabel('residual norm');
end



