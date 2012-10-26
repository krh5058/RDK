function [ r, t ] = rect2polar( x, y )
% rect2polar -- converts rectangular coords to polar
% [ r, t ] = rect2polar( x, y )

% if nargin < 2
%     if nargin < 1
%         disp( sprintf('[%s]: x, y coords not specified.', mfilename) );
%         return;
%     end
%     xy = varargin{1};
%     x = xy(:,1); y = xy(:,2);
% end

r = sqrt( x.^2 + y.^2 );
t = atan2( y, x );

return
