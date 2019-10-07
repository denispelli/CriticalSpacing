function oo=SortFields(oo)
[~,newOrder]=sort(lower(fieldnames(oo)));
oo=orderfields(oo,newOrder);
end
