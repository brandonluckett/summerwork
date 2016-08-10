hold on;
for ii=1:10
    for i=1:5
        scatter(1:(numel(s(i,:,ii))),s(i,:,ii));
    end
end