function ret=get_opt(st,name,default)

if isfield(st,name)
    
    ret = st.(name);
else
    ret = default;
end