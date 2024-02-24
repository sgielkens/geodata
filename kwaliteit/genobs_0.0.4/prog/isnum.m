function r = isnum(a)
    if ( isnumeric(a) )
        r = 1;
    else
        o = str2num(a);
        r = ~isempty(o);
    end
end 