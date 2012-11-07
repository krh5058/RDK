classdef ObjSet < handle
    %
    properties (SetObservable) 
        % SysCheck
        core
        io_device
        mem
        javmem
        buffersize
        display
        
        % ExpSet
        block
        trial
        trial_dur
        reverse_flag
        cond_n
        cond_v
        dot_speed
        subjID
        outFormat
        dot
        fix
    end
    
    methods
        
        function obj = ObjSet
            
        end
        
    end
    
    methods (Static)
        function sys = SysCheck
            % Core size
            [~, core_out ] = system('sysctl -n hw.ncpu');
            sys.core = uint8(str2double(strtrim(core_out)));
            
            % Devices (picked up by PTB)
            sys.io_device = PsychHID('Devices');
            
            % Get the parent process ID
            [s,ppid] = unix('ps -p $PPID -l | awk ''{ if(NR==1) for(i=1;i<=NF;i++) { if($i~/PPID/) { colnum=i;break} } else print $colnum }'' ' );
            % Get memory used by the parent process (resident set size)
            [s,thisused] = unix(['ps -O rss -p ' strtrim(ppid) ' | awk ''NR>1 {print$2}'' ']);
            % RSS is in kB, convert to bytes
            sys.mem.thisused = str2double(thisused)*1024;
            % Total memory (bytes)
            [~,total] = unix('sysctl hw.memsize | cut -d: -f2');
            sys.mem.total = str2double(strtrim(total));
            sys.mem.free = sys.mem.total - sys.mem.thisused;
            
            % Java memory
            java.lang.Runtime.getRuntime.gc; % Free/Reallocate? Memory
            sys.javmem.max = java.lang.Runtime.getRuntime.maxMemory;
            sys.javmem.free = java.lang.Runtime.getRuntime.freeMemory;
            sys.javmem.total = java.lang.Runtime.getRuntime.totalMemory;
            
            % Buffer size
            sys.buffer = 10E6; % Buffer remained free (bytes)
            
            % Display Settings
            sys.display.screens = Screen('Screens'); % Screens available
            sys.display.screenNumber = max( sys.display.screens ); % Screen to use
            
            [sys.display.width_pix, sys.display.height_pix]=Screen('WindowSize', sys.display.screenNumber); % Screen dimensions in pixels
            
            sys.display.dual = 1; % Dual screen (0/1)
            sys.display.width_pix_full = sys.display.width_pix; % Full width (pix)
            sys.display.width_pix_half = sys.display.width_pix_full/2; % Halve width (pix)
            
            if sys.display.dual
                sys.display.rw_pix = sys.display.width_pix_half;
            else
                sys.display.rw_pix = sys.display.width_pix_full;
            end
            
            sys.display.rect = [0  0 sys.display.rw_pix sys.display.height_pix]; % Rectangle to use (pix)
            [sys.display.center(1), sys.display.center(2)] = RectCenter( sys.display.rect ); % Rectangle center (pix)
            
            sys.display.black = intmin('uint8'); % Black value
            sys.display.white = intmax('uint8'); % White value
            [sys.display.width_mm,sys.display.height_mm] = Screen('DisplaySize',sys.display.screenNumber); % Display size (mm)
            sys.display.width_cm = sys.display.width_mm/10; % Display width (cm)
            sys.display.height_cm = sys.display.height_mm/10; % Display height (cm)
            
            sys.display.view_dist_cm = 60; % View distance (variable)
            sys.display.fps = Screen('FrameRate', sys.display.screenNumber); % Frame rate (hz)
            sys.display.ifi = 1/sys.display.fps; % Inverse frame rate
            
            sys.display.ppd = pi * (sys.display.width_pix) / atan(sys.display.width_cm/sys.display.view_dist_cm/2) / 360; % Pixels per degree
            
        end
        
        function exp = ExpSet(sys)
            % General Experimental Parameters
            exp.block = 5; % Number of blocks
            exp.trial_t = 10; % Trial duration (sec)
            exp.reverse = 1; % Reverse sides
            exp.pattern = {'radial','linear'}; % Pattern conditions
            exp.coherence = [.05 .1 .15 .2]; % Coherence conditions
            exp.v = 2; % Dot speed (deg/sec)
            exp.ppf  = exp.v * sys.display.ppd / sys.display.fps; % Dot speed (pix/frame)
            exp.trial_n = length(exp.pattern) * length(exp.coherence) * (2*exp.reverse); % Number of trials per block
            
            % Mask Constraint Parameters
            exp.mask.annulus_deg = [5 10]; % Annulus radius minimum and maximum (deg)
            exp.mask.annulus_pix = exp.mask.annulus_deg * sys.display.ppd; % Annulus radius minimum and maximum (pix)
            
            % Fixation Parameters
            exp.fix = 1; % Fixation on or off (0/1)
            exp.fix.size = .15; % Fixation size in degrees
            exp.fix.color = sys.display.white; % Fixation color (default white)
            
            % Dot Parameters
            exp.dot.dens = .1; % Dot density fraction
            exp.dot.size = .1167; % Dot size
            exp.dot.field = [(sys.display.center(1) - exp.mask.annulus_pix(2)) (sys.display.center(2) + exp.mask.annulus_pix(2)) (sys.display.center(1) + exp.mask.annulus_pix(2)) (sys.display.center(2) - exp.mask.annulus_pix(2)) ]; % Dot field (pix)
                        
            % Pattern Parameters
            for p = 1:length(exp.pattern);
                
                switch exp.pattern{p}
                    
                    case 'linear'
                        exp.(exp.pattern{p}).dir_rads = pi/2; % Horizontal
%                         function motion(obj,dotarray)
%                             v = [cos(exp.(exp.pattern{p}).dir_rads) sin(exp.(exp.pattern{p}).dir_rads)] * exp.ppf;
%                             
%                         end
                    case 'radial'
                        
                end
                     
            end
            
        end
    end
    
end