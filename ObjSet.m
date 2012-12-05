classdef ObjSet < handle
    %
    properties (SetObservable) 
        sys % System settings
        exp % Experimental parameter settings
        out % Output recording
        trial_n = 1; % Trial counter
        t % Timer object
    end
    
    methods
        
        function obj = ObjSet(sys,exp)
            obj.sys = sys;
            obj.exp = exp;
        end
        
        function dotout = DotGen(obj) % DotGen method
            if obj.trial_n <= obj.exp.trial_n % Fail-safe
                dot = zeros([obj.exp.dot.n 2]); % Pre-allocate dot array for new generation
                dot(:,1) = rand([obj.exp.dot.n 1])*(obj.exp.dot.field(3)-obj.exp.dot.field(1)) + ones([obj.exp.dot.n 1])*obj.exp.dot.field(1); % X coordinates (pix)
                dot(:,2) = rand([obj.exp.dot.n 1])*(obj.exp.dot.field(4)-obj.exp.dot.field(2)) + ones([obj.exp.dot.n 1])*obj.exp.dot.field(2); % Y coordinates (pix)
                dot = single(dot); % Convert to single precision
                
                pattern = obj.exp.pattern{randi([1 length(obj.exp.pattern)])}; % Randomly generate pattern type
                while obj.exp.(pattern).count > length(obj.exp.(pattern).coh) % Check if count has been reached for this pattern
                    pattern = obj.exp.pattern{randi([1 length(obj.exp.pattern)])}; % Randomly generate pattern type
                end % End while
                
                obj.out{obj.trial_n,1} = obj.trial_n; % Trial count
                obj.out{obj.trial_n,2} = pattern; % Pattern type
                obj.out{obj.trial_n,3} = obj.exp.(pattern).coh(obj.exp.(pattern).count,1); % Left Coherence
                obj.out{obj.trial_n,4} = obj.exp.(pattern).coh(obj.exp.(pattern).count,2); % Right Coherence
                
                dotout = single(zeros([obj.exp.dot.n_masked 2 obj.exp.fr 2])); % Estimate of number dots for preallocation [x y frame stereo]
                
                for i = 1:1+obj.sys.display.dual % For each stereo display
                    for ii = 1:obj.exp.fr % For each frame 
                        % Direction reversals
                        fr_in_cycle = mod( ii, obj.sys.display.fps*obj.exp.dutycycle ); % Current frame within duty cycle
                        if fr_in_cycle == 1 % If current frame is first in the duty cycle
                           obj.exp.drctn = -1*obj.exp.drctn; % Change direction
                        end
                        drctn = obj.exp.drctn; % Set drctn variable
                        dotindex = obj.exp.dot.parse(dot,obj.exp.(pattern).coh(obj.exp.(pattern).count,i)); % Use dot.parse to obtain an index of coherently-selected dots
                        dot_parsed = dot(dotindex,:); % Dot array using index
                        for iii = 1:length(obj.exp.(pattern).([pattern '_fun'])) 
                            f = functions(obj.exp.(pattern).([pattern '_fun']){iii,1}); % Obtain function handle
                            arglist = regexp(f.function,'[@]{1,1}[(]{1,1}(.*)[)]{1,1}[(]{1,1}','tokens'); 
                            arglist = regexp(arglist{1}{1},'[,]','split'); % Obtain arglist
                            argstr = []; % Preallocate argument string
                            for iiii = 1:length(arglist) % For each argument
                                arglist{iiii} = obj.exp.nomen{strcmp(arglist{iiii},obj.exp.nomen(:,1)),2}; % Rename arglist
                                argstr = [argstr ',' arglist{iiii}]; % Construct argstr
                            end
                            eval([obj.exp.(pattern).([pattern '_fun']){iii,2} ' = obj.exp.(pattern).([pattern ''_fun'']){iii,1}(' argstr(2:end) ');']); % Evaluate function handle with argstr
                        end
                        cohdot = newdot; % Coherent dot array
                        dot_parsed = dot(~dotindex,:); % Dot array of previously unselected dots
                        for jjj = 1:length(obj.exp.random_fun) % For each function handle
                            f = functions(obj.exp.random_fun{jjj,1}); % Obtain function handle
                            arglist = regexp(f.function,'[@]{1,1}[(]{1,1}(.*)[)]{1,1}[(]{1,1}','tokens');
                            arglist = regexp(arglist{1}{1},'[,]','split'); % Obtain arglist
                            argstr = []; % Preallocate argument string
                            for jjjj = 1:length(arglist) % For each argument
                                arglist{jjjj} = obj.exp.nomen{strcmp(arglist{jjjj},obj.exp.nomen(:,1)),2}; % Rename arglist
                                argstr = [argstr ',' arglist{jjjj}]; % Construct argstr
                            end
                            eval([obj.exp.random_fun{jjj,2} ' = obj.exp.random_fun{jjj,1}(' argstr(2:end) ');']); % Evaluate function handle with argstr
                        end
                        incohdot = newdot; % Incoherent (random) dot array
                        dot = [cohdot;incohdot]; % Combine arrays & rewrite dot
                        
                        % Bounds Check
                        xlo = find(dot(:,1) <= obj.exp.dot.field(1)); % X < XMin
                        xhi = find(dot(:,1) >= obj.exp.dot.field(3)); % X > XMax
                        ylo = find(dot(:,2) <= obj.exp.dot.field(2)); % Y < YMin
                        yhi = find(dot(:,2) >= obj.exp.dot.field(4)); % Y > YMax
                        
                        if any(xlo)
                            dot(xlo,1) = obj.exp.dot.field(3) - (obj.exp.dot.field(1) - dot(xlo,1)); % Shifting X coordinates from left of dot field to left of right side of dot field
                        end
                        if any(xhi)
                            dot(xhi,1) = obj.exp.dot.field(1) + (dot(xhi,1) - obj.exp.dot.field(3)); % Shifting X coordinates from right of dot field to right of left side of dot field
                        end
                        if any(ylo)
                            dot(ylo,2) = obj.exp.dot.field(4) - (obj.exp.dot.field(2) - dot(ylo,2)); % Shifting Y coordinates from below dot field to below top of dot field
                        end
                        if any(yhi)
                            dot(yhi,2) = obj.exp.dot.field(2) + (dot(yhi,2) - obj.exp.dot.field(4)); % Shifting Y coordinates from above dot field to above bottom of dot field
                        end
                        
                        % Mask
                        r = sqrt((dot(:,1) - obj.sys.display.center(1)).^2 + (dot(:,2) - obj.sys.display.center(2)).^2); % Determine radii in polar space
                        r_ind = (r >= obj.exp.mask.annulus_pix(1)) & (r <= obj.exp.mask.annulus_pix(2)); % Index of dots after mask
                        
                        % Output
                        dotout(1:size(dot(r_ind,:),1),1:size(dot(r_ind,:),2),ii,i) = dot(r_ind,:); % Place 2-D array within frame and stereo index
                    end
                end
                
                obj.exp.(pattern).count = obj.exp.(pattern).count + 1; % Add to pattern count
                obj.trial_n = obj.trial_n + 1; % Add to trial count
            end
            
        end
    end
    
    methods (Static)
        function sys = SysCheck
            
            % Set PTB path dependencies
            p = pathdef;
            matlabpath(p);
            
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
            sys.buffer = 3*1024*1024*1024; % Buffer size (bytes): 3GB -- Guideline from MathWorks for 32-bit
            
            % Opening multiple labs (default is equal to number of cores
%             matlabpool;
            
%             % Display Settings
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
            
            % Set PTB path dependencies
            p = pathdef;
            matlabpath(p);
            
            % General Experimental Parameters
            exp.block = 5; % Number of blocks
            exp.trial_t = 10; % Trial duration (sec)
            exp.fr = sys.display.fps*exp.trial_t; % Frames total
            exp.reverse = 1; % Reverse sides
            exp.pattern = {'radial','linear'}; % Pattern conditions
            exp.coherence = [.05 .1 .15 .2]; % Coherence conditions
            exp.v = 2; % Dot speed (deg/sec)
            exp.dutycycle = .25; % Phase (default is 4-phase==.25) 
            exp.drctn = 1; % 1/-1 for direction reversal
            exp.ppf  = exp.v * sys.display.ppd / sys.display.fps; % Dot speed (pix/frame)
            exp.trial_n = length(exp.pattern) * length(exp.coherence) * (2*exp.reverse); % Number of trials per block
            pres = [zeros([length(exp.coherence) 1]) exp.coherence']; % Constructing presentation matrix
            if exp.reverse
                pres = [pres; [pres(:,2) pres(:,1)]];  % Include reversed eyes
            end

            % Mask Constraint Parameters
            exp.mask.annulus_deg = [5 10]; % Annulus radius minimum and maximum (deg)
            exp.mask.annulus_pix = exp.mask.annulus_deg * sys.display.ppd; % Annulus radius minimum and maximum (pix)
            outerA = pi*exp.mask.annulus_pix(2)^2;
            innerA = pi*exp.mask.annulus_pix(1)^2;
            exp.mask.area = outerA - innerA; % Total area (pixels)
                
            % Fixation Parameters
            exp.fix = 1; % Fixation on or off (0/1)
            exp.fix.size_deg = .15; % Fixation size in degrees
            exp.fix.size_pix = exp.fix.size_deg*sys.display.ppd; % Fixation size in pixels
            exp.fix.color = sys.display.white; % Fixation color (default white)
            exp.fix.coord = [sys.display.center(1)-exp.fix.size_pix/2 sys.display.center(2)-exp.fix.size_pix/2 sys.display.center(1)+exp.fix.size_pix/2 sys.display.center(2)+exp.fix.size_pix/2]; % Fixation coordinates
            
            % Dot Parameters
            exp.dot.dens = .1; % Dot density fraction
            exp.dot.size_deg = .1; % Dot size (deg)
            exp.dot.size_pix = round(exp.dot.size_deg * sys.display.ppd); % Dot size (pix)
            exp.dot.field = [(sys.display.center(1) - exp.mask.annulus_pix(2)) (sys.display.center(2) - exp.mask.annulus_pix(2)) (sys.display.center(1) + exp.mask.annulus_pix(2)) (sys.display.center(2) + exp.mask.annulus_pix(2)) ]; % Dot field (pix)
            exp.dot.field_area = (exp.dot.field(3) - exp.dot.field(1))*(exp.dot.field(4) - exp.dot.field(2));
            exp.dot.n = round( exp.dot.dens/(exp.dot.size_pix^2) * exp.dot.field_area ); % Number of dots for field
            exp.dot.prop = exp.mask.area/exp.dot.field_area; % Proportion of mask area relative to dot field
            exp.dot.n_masked = round(exp.dot.n*exp.dot.prop); % Number of estimated dots in masked area
            
            % Pattern Parameters
            for p = 1:length(exp.pattern);
                [pres_shuffle1,shufflesort] = Shuffle(pres(:,1)); % Shuffle first column of pres
                exp.(exp.pattern{p}).coh = [pres_shuffle1 pres(shufflesort,2)]; % Reconstruct with sorted second column -- apply to pattern structure
                exp.(exp.pattern{p}).count = 1; % Initialize count
                switch exp.pattern{p} 
                    case 'linear' % Linear function handles
                        exp.(exp.pattern{p}).dir_rads = pi/2; % Horizontal
                        lin1 = @(rad,ppf)([cos(rad) sin(rad)]*ppf); % Motion vector (exp.linear.dir_rads,exp.ppf)
                        lin2 = @(mot,dot,drctn)(dot + (repmat(mot, [length(dot) 1]) .* [repmat(drctn, [length(dot) 1]) repmat(drctn, [length(dot) 1])])); % New dot vector (output from lin1, dot vector, 1/-1)
                        exp.(exp.pattern{p}).linear_fun = {lin1, 'mot'; lin2, 'newdot'}; % Function handles and expected output
                    case 'radial' % Radial function handles
                        rad1 = @(dot)(atan2(dot(:,2),dot(:,1))); % Calculate theta (Dot array)
                        rad2 = @(theta,ppf,drctn)([cos(theta) sin(theta)] .* repmat(ppf*drctn,[length(theta) 2])); % Cos-Sin vector of theta values times motion matrix (output from rad1, exp.ppf, 1/-1)
                        rad3 = @(mot,dot)(dot + mot); % New dot vector (motion vector, dot array)
                        exp.(exp.pattern{p}).radial_fun = {rad1, 'theta'; rad2, 'mot'; rad3, 'newdot'}; % Function handles and expected output
                end
            end
            
            % Random function handles
            rand1 = @(dot)(rand(length(dot), 1)*2*pi); % Random direction (Dot array)
            rand2 = @(dot,ppf,mot)(dot + (repmat(ppf,[length(dot) 2]) .* [cos(mot) sin(mot)])); % New dots created by adding random direction vector (Dot array, exp.ppf, output from rand1)
            exp.random_fun = {rand1, 'mot'; rand2, 'newdot'}; % Function handles and expected output
            
            % Variable nomenclature
            exp.nomen = {'drctn', 'drctn'; 'dot', 'dot_parsed'; ...
                'mot', 'mot'; 'ppf', 'obj.exp.ppf'; ...
                'rad', 'obj.exp.(pattern).dir_rads'; ...
                'theta','theta'};
            
            % Dot parse function handle
            exp.dot.parse = @(dot,coh)(rand(size(dot(:,1))) < coh); % Variable each call
            
            % Presentation function handles
            exp.selectstereo_fun = @(w,stereo)(Screen('SelectStereoDrawBuffer', w, stereo)); % Select stereo buffer to draw
            exp.fix_fun = @(w,fix)(Screen('FillOval',w,fix.color,fix.coord)); % Draw fixation
            exp.draw_fun = @(dot,w)(Screen('DrawDots',w,double(dot))); % Draw dots 
            exp.flip_fun = @(w)(Screen('Flip',w)); % Flip buffer
        end
        
    end
    
end