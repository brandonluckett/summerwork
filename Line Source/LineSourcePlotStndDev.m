hold on;
for ii=2:10
    for i=1:6
        load (['Series',num2str(ii)]);
        scatter(1:(numel(s(i,:))),s(i,:));
    end
end