function display = rdkGetDisplayParams( params )
% rdkGetDisplay : Gets SCREEN params for rdk experiment displays
%   and returns result as data structure.

%----   History
%   081230  rog wrote

if params.control.verbose
    fprintf('[%s]: Setting display params. \n', mfilename);
end

display.screens = Screen('Screens');
display.screenNumber = max( display.screens );
display.doublebuffer = 1;

[width_pix, height_pix]=Screen('WindowSize', display.screenNumber);

display.width_pix_full = width_pix;

if params.exp.dual % If dual screen
    width_pix = width_pix/2; % Halve width
end

display.height_pix = height_pix;
display.width_pix = width_pix;

display.rect = [0  0 width_pix height_pix];

display.black = 1;
display.white = 255;
display.width_cm = 39;
[display.center(1), display.center(2)] = RectCenter( display.rect );

display.view_dist_cm = 60;
display.fps = 60;
display.ifi = 1/display.fps;

display.waitframes   = 1;
display.update_hz    = display.fps/display.waitframes;
display.update_ifi   = 1/display.update_hz;
display.ppd = pi * (width_pix) / atan(display.width_cm/display.view_dist_cm/2) / 360;

return
