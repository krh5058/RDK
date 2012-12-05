function [dot,obj] = batchDot(obj)

    p = pathdef;
    matlabpath(p);
    dot = obj.DotGen;

end



