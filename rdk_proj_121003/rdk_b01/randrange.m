function x = randrange(minx, maxx, n)
%   x = randrange(minx, maxx, n)

rangeX = maxx - minx;
if isscalar ( n )
    x = rand(n,1)*rangeX + ones(n,1)*minx;
else
    
    x = rand(n)*rangeX + ones(n)*minx;
end

return