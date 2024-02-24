function msg = AddMessage(msg, mesg_g);
    if ~isempty(mesg_g)
        if isempty(msg)
            msg = mesg_g;
        else
            msg = [msg; mesg_g];
        end
    end
end