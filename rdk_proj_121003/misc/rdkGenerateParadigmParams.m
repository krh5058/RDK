function params = rdkGenerateParadigmParams( trial )

switch trial.paradigm
    case 'Constant'       
        % REGION: Does shape or size of dot region change over time?        
        region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
        region.space_cycle_fr = [];
        region.space_cycle_hz = 0;
        
        % MOTION: Do motion parameters change over time?
        
        motion.speed_mod_mode = 'none'; %{'none', 'motion/static'}
        motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}        
    case 'MOFO'
        % REGION: Does shape or size of dot region change over time?
        % Two regions at least...
        
        region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
        
        % MOTION: Do motion parameters change over time?
        % Whether speed or direction vary depends on motion form subtype
        
        % If varying direction, then direction modulates, if speed...,
        % coherence, etc.
        
        motion.speed_mod_mode = 'none'; %{'none'}
        motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}
        
        % Have to reconcile space constraints of both regions...
                
    case 'MOCO'
        
        % Region of stimulation constant
        % Motion directions vary, speeds constant
        
        % motion.direction_mod_mode   = 'coh/incoh'; %{'none', 'coh/incoh'}       
        % motion.direction_duty_cycle = .5; % [0,1]
        % motion.direction_cycle_fr   = 60; % 1 Hz @ 60 fps or compute
        % motion.direction_cycle_hz   = display.fps/motion.cycle_fr;
        
    case 'Retinotopy'
        % Region of stimulation varies over time
        % Motion params may vary also
    case 'Optic Flow'
    otherwise
end

region.time_mode = 'fixed'; % {'fixed', 'variable'}
region.time_mod_mode = 'none'; % {'on_off', 'coh_incoh', 'dir_reverse'}
region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
region.space_duty_cycle = .5;  % Compute size of region based on this -- FIX

%--------   NOT USER SPECIFIED

if ~strcmp( region.space_mod_mode, 'none' )
    region.space_mod_period_s = trial.duration_secs*region.space_duty_cycle;% DEFAULT
    region.space_mod_period_fr = round( region.space_mod_period_s * display.update_hz );
    region.space_mod_rad_per_fr = 2*pi/(region.space_mod_period_s * display.update_hz );
else
    region.space_duty_cycle = 1;
    region.space_mod_period_s = trial.duration_secs;% DEFAULT
    region.space_mod_period_fr = round( region.space_mod_period_s * display.update_hz );
    region.space_mod_rad_per_fr = 2*pi/(region.space_mod_period_s * display.update_hz );
end 

region.time_mod_freq_hz = 0;
if region.time_mod_freq_hz ~= 0;
    region.time_mod_fr_period = round( display.fps * region.time_mod_freq_hz/display.update_hz );
end


%--------   USER SPECIFIED

%---    Generic region params for both stims
dotstim(1).region = region;

if trial.ndotstim == 2
    dotstim(2).region = region;
end

%----   Regions 
dotstim(1).region.shape = 'annulus'; %{'annulus', 'wedge', 'circle', 'rectangle','none'}
dotstim(1).region.rminmax_deg = [ 5 10 ]; % Outer circle
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
    dotstim(2).region.shape = 'wedge';
    dotstim(2).region.space_mod_mode = 'rot_wedge';
    dotstim(2).region.rminmax_deg = [ 0 5 ];  % inner circle
    dotstim(2).region.tminmax     = [ pi 2*pi ];
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

motion.mode = 'radial_constant'; %{'radial_constant', 'radial_accel', 'random', 'linear_constant', 'rotate_const_angle' }
motion.rot_rads_per_fr = pi/360;
motion.speed_distrib = 'uniform'; %{'constant', 'random_uniform'};

%----   Computed/dependent motion params

% redundant, remove one of the following two
motion.pix_per_fr  = motion.deg_per_sec * display.ppd / display.fps;  % compute pfs
motion.pfs = motion.deg_per_sec * display.ppd / display.fps;

%---    Assign defaults to dotstim
dotstim(1).motion = motion;

if trial.ndotstim == 2
    dotstim(2).motion = motion;
    dotstim(2).motion.direction_rads = pi;
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

