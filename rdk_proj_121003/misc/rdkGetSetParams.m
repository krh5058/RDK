function params = rdkGetSetParams( param_fn, control )
% rdkGetSetParams -- Get user params, set contingent ones
%
% params = rdkGetSetParams

%----   Feature adds/bugs
% 081214 Set display params via separate routine.
% 081214 Set control params via GUI menu.
% 081214 Mechanism for efficient condition setting like PowerDiva
% 081214 Get user specified params, separate routine to calculate
%        dependencies

%----   History
% 081214    rog wrote as hack to get data stucture oriented program up and
%           running. Added 'wedge' region.shape.

% %----   Control
% control.debug = 1;
% if control.debug == 1
%     control.verbose = 1;
% end

params = [];

%----   Experiment

if ~strcmp( param_fn, '') % param_fn not blank
    if ~strcmp( param_fn, 'new') % file name specified or default
        load( param_fn );
        if exist( 'rdkparams' )
            params = rdkparams;
            if control.verbose
                disp( sprintf('[%s]: Loaded parameter file.', mfilename ) );
            end
            return;
        else
            if control.verbose
                disp( sprintf('[%s]: Generating new parameters.', mfilename ) );
            end
        end % if exist
    end % if strcmp
else % Error in param_fn.
    if control.verbose
        disp( sprintf('[%s]: No param filename specified.', mfilename ) );
        return;
    end
end% if ~strcmp

%----   Control
params.control = control;

%----   Display
display = rdkGetDisplayParams( params );

if params.control.verbose
    disp( sprintf('[%s]: Setting experiment params.', mfilename ) );
end

exp.generate_mode = 'generate_online'; %{'generate_online', 'generate_frame_arrays'}
exp.type = 'demo'; %{'psychophysics', 'fmri', 'vep', 'demo'}
exp.nblocks = 1;

%----   Block
% for b=1:exp.nblocks...
block.ntrials = 1;
block.length_type = 'fixed'; %{'fixed', 'user_resp', 'threshold'}

%----   Trials
trial.fig_bg_mode = 'fig+bgnd'; % {'fig', 'bgnd', 'fig+bgnd'}
switch trial.fig_bg_mode
    case {'fig', 'bgnd'}
        trial.ndotstim = 1;
    case 'fig+bgnd'
        trial.ndotstim = 2;
    otherwise
        trial.ndotstim = 1;
end % switch trial.fig_bg_mode

trial.duration_secs = 5;
trial.duration_fr = round( trial.duration_secs * display.fps );

%----   Fixation
fix.mode    = 'on';
fix.deg     = .15;
fix.center  = [ 0 0 ];
fix.pix     = fix.deg * display.ppd;
fix.coord   = [ display.center - fix.pix  display.center + fix.pix ];
fix.color   = uint8( display.white );

%----   Region params, specifying time and space components of each region

%----   Patch areas + density determine dot numbers so compute first...

disp( sprintf('[%s]: Setting region params.', mfilename ) );

%----   Names
if trial.ndotstim == 2
    dotstim(2).region.name = 'fig';
    dotstim(1).region.name = 'bgnd';
else
    dotstim.region.name = trial.fig_bg_mode;
end % if

%----   Space modulation mode
region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
region.space_duty_cycle = 1;  % Compute size of region based on this -- FIX

%--------   NOT USER SPECIFIED

if ~strcmp( region.space_mod_mode, 'none' )
    region.space_mod_period_s = trial.duration_secs*region.space_duty_cycle;% DEFAULT
    region.space_mod_period_fr = round( region.space_mod_period_s * display.update_hz );
    region.space_mod_rad_per_fr = 2*pi/(region.space_mod_period_s * display.update_hz );
else
    region.space_mod_period_s = trial.duration_secs;% DEFAULT
    region.space_mod_period_fr = round( region.space_mod_period_s * display.update_hz );
    region.space_mod_rad_per_fr = 2*pi/(region.space_mod_period_s * display.update_hz );
end 
    
% region.time_mod_freq_hz = 0;
% if region.time_mod_freq_hz ~= 0;
%     region.time_mod_fr_period = round( display.fps * region.time_mod_freq_hz/display.update_hz );
% end


%--------   USER SPECIFIED

%---    Generic region params for both stims
dotstim(1).region = region;

if trial.ndotstim == 2
    dotstim(2).region = region;
end

%----   Regions 
dotstim(1).region.shape = 'annulus'; %{'annulus', 'wedge', 'circle', 'rectangle','none'}

dotstim(1).region.rminmax_deg = [ 7.5 10 ]; % Outer circle
dotstim(1).region.tminmax     = [ 0 2*pi ];
dotstim(1).region.hminmax_deg   = [ -10 10 ];
dotstim(1).region.vminmax_deg   = [ -10 10 ];

%---    Convert to pix
dotstim(1).region.rminmax_pix = floor( dotstim(1).region.rminmax_deg * display.ppd ); 

dotstim(1).region.rminmax_static_pix = dotstim(1).region.rminmax_pix;

%---    ring width useful in expanding/contracting paradigms
dotstim(1).region.ring_width_pix = dotstim(1).region.rminmax_pix(2)-dotstim(1).region.rminmax_pix(1);
dotstim(1).region.hminmax_pix = floor( dotstim(1).region.hminmax_deg * display.ppd ); 
dotstim(1).region.vminmax_pix = floor( dotstim(1).region.vminmax_deg * display.ppd ); 

if trial.ndotstim == 2
    dotstim(2).region.shape = 'annulus';
    dotstim(2).region.space_mod_mode = 'none';
    dotstim(2).region.rminmax_deg = [ 5 7.5 ];  % inner circle
    dotstim(2).region.tminmax     = [ 0 2*pi ];
    dotstim(2).region.hminmax_deg   = [ -5 5 ];
    dotstim(2).region.vminmax_deg   = [ -5 5 ];

    dotstim(2).region.rminmax_pix = floor( dotstim(2).region.rminmax_deg * display.ppd );
    dotstim(2).region.rminmax_static_pix = dotstim(2).region.rminmax_pix;
    dotstim(2).region.ring_width_pix = dotstim(2).region.rminmax_pix(2)-dotstim(2).region.rminmax_pix(1);
    dotstim(2).region.hminmax_pix = floor( dotstim(2).region.hminmax_deg * display.ppd );
    dotstim(2).region.vminmax_pix = floor( dotstim(2).region.vminmax_deg * display.ppd );
end

%---    Size shape params differ, however


%---------  NOT USER SPECIFIED



%----   Compute outer bounds for stimuli based on patches
max_r = zeros( trial.ndotstim, 1);
max_v = zeros( trial.ndotstim, 1);
max_h = zeros( trial.ndotstim, 1);
min_v = zeros( trial.ndotstim, 1);
min_h = zeros( trial.ndotstim, 1);
for s = 1:trial.ndotstim
    max_r(s) = max( dotstim(s).region.rminmax_pix );
    max_v(s) = max( dotstim(s).region.vminmax_pix );
    max_h(s) = max( dotstim(s).region.hminmax_pix );
    
    min_v(s) = min( dotstim(s).region.vminmax_pix );
    min_h(s) = min( dotstim(s).region.hminmax_pix );
end
trial.bounds.rminmax_pix = max( max_r );
trial.bounds.hminmax_pix = [ min( min_h ) max( max_h ) ];
trial.bounds.vminmax_pix = [ min( min_v ) max( max_v ) ];

%----   To compute region areas, it's a bit tricky
for s = 1:trial.ndotstim
    switch dotstim(s).region.shape
        case 'circle'
            dotstim(s).region.area_pix2 = pi*dotstim(s).region.rminmax_pix(2)^2;
        case 'annulus'
            outerA = pi*dotstim(s).region.rminmax_pix(2)^2;
            innerA = pi*dotstim(s).region.rminmax_pix(1)^2;
            dotstim(s).region.area_pix2 = outerA - innerA;
        case 'wedge'
            outerA = pi*dotstim(s).region.rminmax_pix(2)^2;
            innerA = pi*dotstim(s).region.rminmax_pix(1)^2;
            annulusArea = outerA - innerA;
            % Calculate area of annulus first, then scale by fraction of
            % theta range
            thetaFraction = (dotstim(s).region.tminmax(2)-dotstim(s).region.tminmax(1))/(2*pi);
            dotstim(s).region.area_pix2 = annulusArea * thetaFraction;
        case 'rect'
            hside = dotstim(s).region.hminmax(2) - dotstim(s).region.hminmax_pix(1);
            vside = dotstim(s).region.vminmax(2) - dotstim(s).region.minmax_pix(1);
            dotstim(s).region.area_pix2 = hside * vside;
        case 'rect_annulus' %* FIX
            hsideOut = dotstim(s).region.hminmax(2) - dotstim(s).region.hminmax_pix(1);
            vsideOut = dotstim(s).region.vminmax(2) - dotstim(s).region.minmax_pix(1);
            dotstim(s).region.area_pix2 = hsideOut * vsideOut;
        otherwise
            dotstim(s).region.area_pix2 = 0;
    end
end

%----   Dot stim
disp( sprintf('[%s]: Setting dot params.', mfilename ) );

%---- Generic dot params
dots.density    = .1; % not valid, just a placeholder
dots.distrib    = 'polar'; %{'polar', 'rect'}
dots.f_kill     = 0.01;
dots.differentcolors = 0;
dots.differentsizes  = 0;
dots.deg             = 0.1;
dots.dimensionality  = 2;
dots.shape           = 1;  %{ 0, 1, 2 }

%----   Both dotstim have identical dot distributions in default mode   
dotstim(1).dots = dots;

if trial.ndotstim == 2
    dotstim(2).dots = dots;
end

%----   Compute ndots
for s = 1:trial.ndotstim
    dots = dotstim(s).dots;
    
    dots.pix  = round( dots.deg * display.ppd );   
    dots.ndots = round( dots.density/(dots.pix^2) * dotstim(s).region.area_pix2 );
    if dots.differentsizes > 0
        dots.pix   = (1+rand(1, dots.ndots)*(dots.differentsizes-1))*dots.pix;
    end
    dots.xy              = zeros( dots.ndots, dots.dimensionality );
    dots.rt              = zeros( dots.ndots, dots.dimensionality );
    dots.nout            = dots.ndots;
    dots.out_index       = (1:dots.ndots)';

    if dots.differentcolors == 1
        dots.colors = uint8( round( rand( 3, dots.ndots )*display.white ) );
    else
        dots.colors = display.white;
    end;
    dotstim(s).dots = dots;
end

%--------   Motion
disp( sprintf('[%s]: Setting motion params.', mfilename ) );

%----   Generic params
motion.deg_per_sec = 2.5;
motion.direction_mode  = 'uniform'; %{'opposing', 'uniform'}
motion.direction_rads = 0;  % horizontal
motion.direction_distrib = 'uniform';

motion.mode = 'rotate_const_angle'; %{'radial_constant', 'radial_accel', 'random', 'linear_constant', 'rotate_const_angle' }
motion.rot_rads_per_fr = pi/360;
motion.speed_distrib = 'uniform'; %{'constant', 'random_uniform'};

%----   Computed/dependent motion params

% redundant, remove one of the following two
motion.pix_per_fr  = motion.deg_per_sec * display.ppd / display.fps;  % compute pfs
% motion.pfs = motion.deg_per_sec * display.ppd / display.fps;

%---    Assign defaults to dotstim
dotstim(1).motion = motion;

if trial.ndotstim == 2
    dotstim(2).motion = motion;
    dotstim(2).motion.rot_rads_per_fr = -pi/360;
    dotstim(2).motion.deg_per_sec = 3;
    dotstim(2).motion.pix_per_fr  = dotstim(2).motion.deg_per_sec * display.ppd / display.fps;  % compute pfs
end

%---    Assign motion direction vectors to each dotstim & initialize dxdy's
for s = 1:trial.ndotstim
    %---   Motion direction vector
    switch dotstim(s).motion.direction_mode
        case 'opposing'
            dotstim(s).motion.mdir = 2 * floor(rand(dotstim(s).dots.ndots,1)+0.5) - 1;    % motion direction (in or out) for each dot
        case 'uniform'
            dotstim(s).motion.mdir = ones( dotstim(s).dots.ndots, 1);
        otherwise
            error('direction_mode specified improperly.');
    end
    dotstim(s).motion.drdt   = zeros( dotstim(s).dots.ndots, dotstim(s).dots.dimensionality); % initialize
    dotstim(s).motion.dxdy   = zeros( dotstim(s).dots.ndots, dotstim(s).dots.dimensionality); % initialize    
end

%----   Assemble data structure

trial.dotstim = dotstim;
trial.fix = fix;
block.trial = trial;
exp.block = block;

params.exp = exp;
params.display = display;
params.control = control;

if control.verbose
    disp(sprintf('[%s]: Saving parameter file as %s.', mfilename, param_fn ) );
end
save( param_fn, 'params' );

return;

