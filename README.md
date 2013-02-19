RDK
===

Random Dot Kinetogram Project - PSU, SLEIC, Gilmore Lab

Author: Ken Hwang

2/19/13

Re-coded (due to lost 2/12/13 changes):
- Single/dual display both tested as of current build
- Added exp.coh_mod_fr (default 1.2 Hz)
- Used to calculate exp.fpc (1/coh_mod_fr *fps) -- frames per cycle (Default is 50 frames)
- exp.fpc is used during modulation check
- Coherency mod check at duty cycle.
- Direction reversal mod check at 2x duty cycle.
- Using floor() for coh (50*.25) is not a full integer
- Must use floor() for both, or will be offphase.
- Added obj.exp.cohflag, which will bypass coherency dot parsing if 0.  Constructs empty cohdot array and passes the entirety of dot to dotparsed.
- Adjusted the calculation of trial_n to accurately account of reversal flag.
- exp.reverse is automatically set to 0 if not dual.
- Fixed an issue with single display.  Issue was due to improper variable reference (pers_fix).
- Modified presmat and out cell to not include an extra column if single display.
- Accounted for extra frames, adds required frames to exp.fr (lines 500-502), Needs testing
- Removed all button press logging during single display.
- Changed trial iterating into a while loop to accommodate for trial restarts.
- Added ‘p’ for trial restart key.  If ‘p’ is pressed no logging takes place.

ToDo:
- Running into some memory issues when issuing multiple runs during one matlab session
- Need to scale according to screen resolution.  How much?
- Movie capture.
- Accounted for extra frames, adds required frames to exp.fr (lines 500-502), Needs testing

2/18/13

Added inter-annulus distance calculations within exp.mask, adjusts dot.field(1:2,:)
dot.field is 2x4 now.
dot.field_area adjusted accordingly
Fixed bug in lin2 function, changed length() to size().
Randomization and cohort selection within ‘i’ iteration of DotGen.

2/13/13

- Updated BiRi laptop with current version (not final).
- FrameRate function for screen does not work for laptop, using 60 Hz default instead.
- Adjusted annulus scale to [1 3.5] for now.

2/12/13

- Single/dual display both tested as of current build
- Added exp.coh_mod_fr (default 1.2 Hz)
- Used to calculate exp.fpc (1/coh_mod_fr *fps) -- frames per cycle (Default is 50 frames)
- exp.fpc is used during modulation check
- Coherency mod check at duty cycle.
- Direction reversal mod check at 2x duty cycle.
- Using floor() for coh (50*.25) is not a full integer
- Must use floor() for both, or will be offphase.
- Added obj.exp.cohflag, which will bypass coherency dot parsing if 0.  Constructs empty cohdot array and passes the entirety of dot to dotparsed.
- Adjusted the calculation of trial_n to accurately account of reversal flag.
- exp.reverse is automatically set to 0 if not dual.
- Fixed an issue with single display.  Issue was due to improper variable reference (pers_fix).
- Modified presmat and out cell to not include an extra column if single display.
- Accounted for extra frames, adds required frames to exp.fr (lines 500-502), Needs testing
- Removed all button press logging during single display.
- Changed trial iterating into a while loop to accommodate for trial restarts.
- Added ‘p’ for trial restart key.  If ‘p’ is pressed no logging takes place.

ToDo:
- Running into some memory issues when issuing multiple runs during one matlab session
- Need to scale according to screen resolution.  How much?
- Movie capture.
- Accounted for extra frames, adds required frames to exp.fr (lines 500-502), Needs testing

2/5/13

New RDK assessment:
- Restart trial option
- Need 1.2 Hz coherency modulation
	- Needs to complete last cycle even if total frames is reached
- Needs single display compatibility.
	- pers.fix
	- coherence matrix.
	- annulus scaling
	- output
- Needs movie capture.
	- Needs development on PC for capture
	- Capture movies

2/5/13

Old RDK accounts for 1.2 Hz global frequency.
	- time_mod_period_fr = 50, this is the calculation of (1/1.2Hz)  * (60 frames/s)
	- Two mod tests: 
- First one is for direction reversal: rdkShowStimuli, lines 157-168
	- Tests only if 4-phase.
	- Tests against time_mod_period_fr*2 (50*2 = 100).
	- Multiplied by 2 becaulsse 100 frames constitutes two cycles. (Coherent + incoherent, first direction; Coherent + incoherent, second direction.).  
- switchFlag tests if the modulo of frame against time_mod_period*2 is greater than time_mod_period_fr.  Switches if it is.  So, frames 1-50 are one direction and frames 51-100 are another.  
- Second test is for coherence/incoherence modulation: rdkComputeGradient, lines 25-52.
-First, arrive at modulo of frame against time_mod_period_fr
-Then, determine if greater than time_mod_period_fr * time_mod_duty_cycle.
- Duty cycle, in this case is .5, which refers to on/off coherency phase.
- Direction reversals is one order higher than duty cycle.
- So, in this example, coherency changes every 25 frames and direction changes every 50 frames.  This is correct.


=======
>>>>>>> parent of 015531f... 2/12/13 Build -- See ReadMe.md
1/17/13

Time/date verification seems okay.
Documented ObjSet.m and rdkMain.m.
Rearranged contents of while loop in rdkMain.m for processing purposes, but it seems like the delay in press is primarily due to the while loopÕs interaction with the timer object.  This may be unavoidable and a firm, prolonged press until black screen may be necessary for advancement of trial.

1/16/13

Verify time checking.
Fixed typo line 26 (rdkMain.m): ÔdateÕ > ÔtimeÕ
Keys changed to Z and /?.
Expect 2nd testing keyboard.

1/11/13

-Script is ready for field testing.
-Uncommented ListenChar(2).
-Moved to function.

ToDo:
Separate query function (Ask prior to run if want to log): Birthdate (convert to weeks), Testdate, Sex, Acuity (Report?), Stereo Acuity, Binocular

1/10/13

-Added persistent fixation to timer_fcn and exp.fix property.
-Added user input for testdate and testtime for cases prepare and newrun.  Also added error displays for when these values are input incorrectly.
-Added headers to out.csv.
-Allowed for escape during start_fcn.
-Added begin_fcn which executes pres.txt_size_fcn and pres.txt_fcn.  Also, added pres.txt_val property.  Ôbegin_fcnÕ method is used to display text on an introductory screen (separate from testing) using the txt* function handles.  The txt* function handles set up DrawText parameters and draws introductory text to screen.  To be used prior to presentation execution.
-Modified script due to performance issues when pressing button responses.  Now, program appropriately advances screen draw upon key press.

ToDo:
	Move script to function.
	Uncomment ListenChar(2).
Separate query function (Ask prior to run if want to log): Birthdate (convert to weeks), Testdate, Sex, Acuity (Report?), Stereo Acuity, Binocular

1/9/13

Added dot lifetime to dot creation.  Default 10 frames.
Fixed response output to correctly include no response trials.

ToDo:
Query function (Ask prior to run if want to log): Birthdate (convert to weeks), Testdate, Sex, Acuity (Report?), Stereo Acuity, Binocular
Option: Persistent fixation
Format: YYYYMMDD_HHMM
Ask for input for session time.
Add headers.
Allow for escape during start_fcn.
Issue after 10s run, loss of control? (Has not reoccured.  Must have been due to ctrl-c)

1/7/13

Query function (Ask prior to run if want to log): Birthdate (convert to weeks), Testdate, Sex, Acuity (Report?), Stereo Acuity, Binocular
Option: Persistent fixation
Format: YYYYMMDD_HHMM
Ask for input for session time.
Add headers.
Allow for escape during start_fcn.
Issue after 10s run, loss of control?

Dot Lifetime:
- Birthdate, death date
- For example. 

1/4/13

Format: YYYYMMDD_HHMM
Ask for input for session time.
Add headers.
Allow for escape during start_fcn.

1/3/13

-Working on wrapper script: rdkMain
	- ÔprepareÕ: AllowÕs for multiple batchDot runs.  Must specify number of iterations.  No presentation will occur
	- ÔnewrunÕ: Perform batchDot and begin trial run.
	- ÔoldloadÕ: Run a pre-existing set of dots.  New object definition is required and property specification.  Must pick from file directory.
- Space key has been restricted for start_fcn.
- Esc key, Left Arrow key, and Right Arrow key have been restricted for timer function.
- Fixed a bug where block and trial indexing from dotStore was reversed.
- Move timer object generation as itÕs own method -- tGen.  Can be used to create timer object property in obj at any point, so that window pointer can vary and not produce errors in old timer object callback functions.
- Fixed escaping.  Does not use error(), but rather an esc_flag to exit both sets of for loops (block + trial).
-Óout.csvÓ now goes to the appropriate exp directory.

ToDo:
-Noticed an issue with delayed keyboard response at times.  Should not be a large issue, but will look into it.
-Add ListenChar(2) when ready.

12/21/12

Implemented timer object.
	- start_fcn: Blank Screen > Key press > Fixation > Key press
	- timer_fcn: Cycles through dot display.  Still need to advance trials.
	- stop_fcn: Screen Close all.  Need to move this to error_fcn for response abort.
Added pres property structure.
Saving entire obj structure to file (method: saveToStruct).  Added display to wait.

ToDo:
- Add object properties to advance through trials.
- Enable response while loop and key press abort (current stop_fcn).
- Data logging and output.

12/19/12

Added temporary solution to radial dot recycling.  Need to talk to Rick for better algorithm.
Ditched parallel dot generation and shell scripting.
Changed batchDot to trialDot.
Added new batchDot method to run dot generation through every block.
Expanded obj.dotStore and obj.out to accommodate for every block.
Added time estimate (calculated from average of new property obj.gen_times)
Saving obj to ./exp/trial-date.

ToDo:
Need new methods for:
- Dot display
	- Timer object
	- Record presentation and appropriately draw to stereo
- Response Recording
- Output

12/14/12

Google Docs now documented under ReadMe.md

ToDo:
-Keep quit function.
-Migrate screen display related function handles to new object.  
-Within obj.batchDot: Save to mat file after each dot generation
-Within UNIX shell script use: /Applications/MATLAB_R2011b.app/bin/matlab < rdkMain.m to intialize sys, exp, obj, and obj.batchDot.  Then, have another script check for new dot generation, and display when ready.  (Or communicate between matlab scripts if possible.)

Need new methods for:
- Dot display
	- Timer object
	- Record presentation and appropriately draw to stereo
- UI Recording
	- Combine dot display with keyboard pressing using spmd

-Need to fix radial dot recycling.

12/12/12

Added obj.dotStore, but will remove.
Added method obj.batchDot.  This is a recursive call function that will continuously run obj.DotGen

ToDo:
-Keep quit function.
-Migrate screen display related function handles to new object.  
-Within obj.batchDot: Save to mat file after each dot generation
-Within UNIX shell script use: /Applications/MATLAB_R2011b.app/bin/matlab < rdkMain.m to intialize sys, exp, obj, and obj.batchDot.  Then, have another script check for new dot generation, and display when ready.  (Or communicate between matlab scripts if possible.)

Need new methods for:
- Dot display
	- Timer object
	- Record presentation and appropriately draw to stereo
- UI Recording
	- Combine dot display with keyboard pressing using spmd

11/28/12

Fixed fixation coordinates.
Timing for 1 trial DotGen: 9.219843s
One 4-D dot array: 23.4375 Mb
Tested selectstereo_fun, draw_fun, fix_fun, and flip_fun.
Added direction reversals.  Changed variable from dir to drctn.
Added out object property for data logging.

Need new methods for:
- Dot display
	- Timer object
	- Record presentation and appropriately draw to stereo
- UI Recording
	- Combine dot display with keyboard pressing using spmd
- Use Client to generate dots or worker?
	- How to access new created dots?

11/27/12

Added bounds check, masking, and output ÔdotoutÕ to DotGen.
Fixed exp.dot.n to equal # of dots in dot field.exp.dot.n_masked is # of dots after mask.

11-15-12

ToDo:
DotGen.m
- Bounds Check and Dot Recycle
- Apply Mask (CanÕt sparse with singles -- will use NaN)
- Save Final Array (3-d array) -- each frame will contain a 2 column array -- 2560x2x600
- Fix fixation draw -- coordinates
- Add direction reversals
Need new methods for:
- Dot display
	- Timer object
	- Record presentation and appropriately draw to stereo
- UI Recording
	- Combine dot display with keyboard pressing using spmd
- Use Client to generate dots or worker?
	- How to access new created dots?

- New method: DotGen.  Output is dot.  It first creates a randomized dot vector, then it randomly draws a pattern type.  If the pattern typeÕs count has exceeded the count limit, then it will redraw until it finds another.  DotGet has a set of for loops to generate dot motion for each stereo display, at each frame, and for each pattern.  After parsing a dot index based on coherence value, it evaluates coherent dots then incoherent.  For each set, it will run through the list of function handles outlined in ExpSet.  For each function, an argument list is generated and by using exp.nomen, converts the shorthand argument list into actual variable calls.  The expected function output, function handle, and argument list are fed into eval() for every function call.  Afterwards, cohdot and incohdot matrices are combined and rewrites the ÔdotÕ variable.
- Removed dot.init.  Relocated randomized initial dot vector to DotGen
- Organized experimental coherence conditions to separate pattern structures.
- Added exp.nomen to convert string values of function handles into variable string calls
- Added organized matrix of experimental parameters.
- Added expected output names in pattern function handle cells (column 2).  Function handles themselves are in column 1.
- Added function handles for DrawDots and Flip.  Tested.
- Added function handles for StereoDraw select and fixation draw.

11-14-12

- Added function handles for linear, radial, and random.
	- Tested all function handles
- Added initial dot array, converted to single = 13104 bytes
	- Need to double-check.  It seems that ÔDrawDotsÕ does not accept single class values.
- According to Mathworks, the largest workspace for a 32-bit MatLab is ~3GB.  However, we are running 64-bit OSX with 64-bit MatLab (8 GB RAM).  According to these calculations:
- 3 GB / 13104 Bytes = 2.4582*10^5 dot arrays
- 2.4582*10^5 / (60 Hz * 10s) = 409.7 entire 10 second run
- 409.7 Runs / 16 Trials = 25.6062 blocks.
- Need to verify these numbers.

ToDo:
1) Parallel object processing & Testing
2) Experimental design set-up
3) Dot generator object (feeding in values to function handles)
4) Dot display object
5) Response set-up
6) Output formatting
7) Memory allocation

10-18-12

Update old rdk or modify dmdt?

Update rdk: 
	- CanÕt run multiple motion types in single block
	- No break screens implemented
	- Front-end undeveloped

Modify dmdt:
	- No dual screen
	- No radial motion
	- 10s trial duration results in 1.2s DotGen delay.  Will need to generate dots parallel to presentation (Not timer StartFcn).
	- Block/Condition structure made for DMDT, will need to reorganize
	- No response implementation yet
	- No reversals implemented

10-11-12

-Method of limits
-Radial, Linear (Horizontal) -- 2 trial types
-2AFC
-Control side (0-0)
-Experimental side (0-X)
	- 5 10 15 20 (4 conditions)
	- 1 speed (2deg/s)
-Randomize side

-Blocks -- 16 trials
	- Rest between blocks -- Press to continue

-Blank between trials
-Timing (Infant)
	- Experiment parameters
	- Run
	- Blank screen (press) -- Spacebar to continue (for adults)
	- Fixation (press) -- Spacebar to continue (for adults)
	- Trial (10s or until button press) -- L/R to continue (for adults)
	- Blank screen (press)
	- Fixation (press)
-Output
	- L/R
	- RT
	- ACC