function params = rdkComputeDependentParams( params )

for b=1:params.exp.nblocks
    thisblock = params.exp.block(b);

    for t=params.exp.block(b).ntrials
        thistrial = thisblock.trial(t);

        %----   Paradigm-specific parameter settings
        switch thistrial.paradigm 
            case 'constant'
                % Motion speed, direction do not vary during trial
                
                for s=1:thistrial.ndotstim
                    thistrial.dotstim(s).motion.speed_mod_mode = 'none'; %{'none', 'motion/static'}
                    thistrial.dotstim(s).motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}
                end
                
            case 'mofo'
                % Motion Form: A region changes its motion parameters at
                % some defined temporal frequency
                
                % Two regions (for now)
                thistrial.ndotstim = 2;
                
                % Loop on nstim
                for s = 1:thistrial.ndotstim

                    % Dot regions remain fixed (for now)
                    thistrial.dotstim(s).region.space_mod_mode = 'none'; %{'none', 'exp_ring', 'rot_wedge', 'trans'}
                    thistrial.dotstim(s).motion.speed_mod_mode = 'none'; %{'none'}
                    thistrial.dotstim(s).motion.direction_mod_mode   = 'none'; %{'none', 'coh/incoh'}
                end
                % Have to reconcile space constraints of both regions...

            case 'moco'
                % Motion coherence: Whole screen changes from coherent to
                % incoherent motion at defined temporal frequency
                
                % Region of stimulation constant
                % Motion directions vary, speeds constant

                thistrial.ndotstim = 1;
                          
                thistrial.dotstim.motion.direction_mod_mode   = 'coh/incoh'; %{'none', 'coh/incoh'}
                
                thistrial.dotstim.motion.direction_duty_cycle = .5; % [0,1]
                thistrial.dotstim.motion.direction_cycle_fr   = 60; % 1 Hz @ 60 fps or compute
                thistrial.dotstim.motion.direction_cycle_hz   = display.fps/motion.cycle_fr;

            case 'retinotopy'
                % Region of stimulation varies over time
                % Motion params may vary also
            case 'optic_flow'
            otherwise
        end % switch thistrial.paradigm
        
        
    end % for t
    
end % for b

