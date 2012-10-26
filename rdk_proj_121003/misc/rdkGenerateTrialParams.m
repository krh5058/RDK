function trial = rdkGenerateTrialParams( trial )

switch trial.paradigm
    case 'constant'       
        % REGION: Does shape or size of dot region change over time?        
        region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
        
        % MOTION: Do motion parameters change over time?
        
        motion.speed_mod_mode = 'none'; %{'none', 'motion/static'}
        motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}        
    case 'mofo'
        % REGION: Does shape or size of dot region change over time?
        % Two regions at least...
        trial.ndotstim = 2;
                        
        region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
        
        % MOTION: Do motion parameters change over time?
        % Whether speed or direction vary depends on motion form subtype
        
        % If varying direction, then direction modulates, if speed...,
        % coherence, etc.
        
        motion.speed_mod_mode = 'none'; %{'none'}
        motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}
        
        % Have to reconcile space constraints of both regions...
                
    case 'moco'
        
        % Region of stimulation constant
        % Motion directions vary, speeds constant
        
        motion.direction_mod_mode   = 'coh/incoh'; %{'none', 'coh/incoh'}
        
        motion.direction_duty_cycle = .5; % [0,1]
        motion.direction_cycle_fr   = 60; % 1 Hz @ 60 fps or compute
        motion.direction_cycle_hz   = display.fps/motion.cycle_fr;
        
    case 'retinotopy'
        % Region of stimulation varies over time
        % Motion params may vary also
    case 'optic_flow'
    otherwise
end

return
