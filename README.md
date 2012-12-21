RDK
===

Random Dot Kinetogram Project - PSU, SLEIC, Gilmore Lab

Author: Ken Hwang

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