function params = setRDKparams

%---    Show master RDK menu
params = rdkMenu;
drawnow;

%---
params = setParamDefaults( params );

%---    Display defaults *** Change to get user input
disp( sprintf('[%s]: Setting display params.', mfilename ) );
if ~params.display.useDisplayDefaults
    params = displayParamsMenu;
    drawnow;
else
    display.screens = Screen('Screens');
    display.screenNumber = max( display.screens );
    display.doublebuffer = 1;

    [width_pix, height_pix]=Screen('WindowSize', display.screenNumber);
    display.width_pix = width_pix;
    display.height_pix = height_pix;

    display.rect = [0  0 width_pix height_pix];shit

    display.black = 1;
    display.white = 256;
    display.width_cm = 39;
    [display.center(1), display.center(2)] = RectCenter( display.rect );

    display.view_dist_cm = 60;
    display.fps = 60;
    display.ifi = 1/display.fps;

    display.update_hz    = 60; % Redundant
    display.waitframes   = 1;
    display.ppd = pi * (width_pix) / atan(display.width_cm/display.view_dist_cm/2) / 360;

    params.display = display;
end

%---    Dot parameters
if ~params.dots.useDotDefaults
    disp( sprintf('[%s]: Launching dotParamsMenu GUI.', mfilename ) );
    params.dots = dotParamsMenu;
    drawnow;
end
params = setDotParams( params );

%---    Motion parameters menu
if ~params.motion.useMotionDefaults
    disp( sprintf('[%s]: Launching motionParamsMenu GUI.', mfilename ) );
    params.motion = motionParamsMenu;
    drawnow;
end
params = setMotionParams( params );

%----   Patch params
disp( sprintf('[%s]: Setting patch params.', mfilename ) );
patch.mode      = 'sine_radius';  % {'fixed', 'sine_radius', 'radar_theta'}
patch.n_patches = 1;
patch.rminmax_deg   = [ 5 10 ];
patch.tminmax       = [ 0 2*pi ];
patch.hminmax_deg   = [ -10 10 ];
patch.vminmax_deg   = [ -10 10 ];
patch.fr_per_cyc    = 180;
patch.wedge_rads    = pi/4;

%----   Bounds params
disp( sprintf('[%s]: Setting bounds params.', mfilename ) );
% bounds.mode     = 'polar';  %{'polar', 'rectangular'}
% bounds.rminmax_deg  = [ 5 10 ];
% bounds.tminmax  = [ 0 2*pi ];
% bounds.hminmax_deg  = [ -10 10 ];
% bounds.vminmax_deg  = [ -10 10 ];

switch params.bounds.mode
    case 'polar'
        params.bounds.rminmax_pix = params.bounds.rminmax_deg * display.ppd;

%         tmin        = 0;
%         tmax        = 2*pi;
%         bounds.tminmax = [ 0 2*pi ];
% 
        params.bounds.hminmax_pix = params.bounds.hminmax_deg * display.ppd;
        params.bounds.vminmax_pix = params.bounds.vminmax_deg * display.ppd;
% 
%         hmin = 0;
%         hmax = 0;
%         vmin = 0;
%         vmax = 0;
    case 'rectangular'
        params.bounds.rminmax_pix = [ 0 0 ];
        params.bounds.tminmax = [ 0 0 ];
        params.bounds.hminmax_pix = params.bounds.hminmax_deg * display.ppd;
        params.bounds.vminmax_pix = params.bounds.vminmax_deg * display.ppd;

%         hmin = -display.ppd*.10;
%         hmax = abs( hmin );
%         vmin = -max_d/2 * display.ppd;
%         vmax = abs( vmin );
    otherwise
        error('bounds_mode misspecified.');
end

%----   Fixation params
disp( sprintf('[%s]: Setting fixation params.', mfilename ) );
fix.mode    = 'on';
fix.deg     = .15;
fix.center  = [ 0 0 ];
fix.pix     = fix.deg * display.ppd;
fix.coord   = [ display.center - fix.pix  display.center + fix.pix ];
fix.color   = uint8( display.white );

params.fix = fix;
params.patch = patch;

return;