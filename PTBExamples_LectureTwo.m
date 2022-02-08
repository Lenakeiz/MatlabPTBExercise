%% This script accompanies the "Psychophysics toolbox (PTB) - a gentle 
%  introduction" lectures from the UCL Institute of Cognitive Neuroscience
%  Matlab Course. All course details and content - including pre-recorded
%  lectures, slides, practical exercises and solutions - can be found on
%  the course website: https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) uceeaca@ucl.ac.uk
%
%  In the second lecture, we are going to demonstrate some further
%  functions available within PTB. Every example is contained in a
%  different code section (differentiated by the double comment symbol at
%  the beginning of each section). Each section is therefore completely
%  standalone and can be executed by clicking 'Run section' or using the
%  relevant keyboard shortcut (control and enter on a Windows machine)


%% Example 1: Reading keyboard input with timings (part 1)

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Let's create a variable that indicates how long we are going to wait 
    % for a key press
    trialDuration = 4;

    % Let's measure the time of script execution by reading the clock time
    % using the Matlab function 'clock'
    t1 = clock;

    % Next, let's use a PTB function to find the time (in seconds)
    % according to the task clock
    startT = GetSecs;

    % We can now display that start time in the command window
    disp(['Showing keyboard timings using example 1. Start time: ' num2str(startT) 's']);

    % Next, let's use the 'kBWait' function to wait a specific duration for
    % a key press (remembering that the first input indicates which
    % keyboard we are waiting for a key press on, and the second input
    % indicates what kind of key press we are waiting for - in this case,
    % any key that is released, pressed, and released again)
    [respT, respKeyCode, ~] = KbWait(0,3, startT + trialDuration);
    
    % Next, let's find which key has been pressed, and compute the reaction
    % time
    keyCode = find(respKeyCode, 1);
    reactTime = respT - startT;
    
    % We set a trial duration, but 'kbWait' could have returned a key press
    % at an earlier time, so we are now going to wait for the remaining
    % trial duration
    if(reactTime < trialDuration)
        WaitSecs(trialDuration - reactTime);
    end

    % We have finished this trial, so let's measure the clock time again
    t2 = clock;

    % Let's now display the total real time of trial execution of the
    % trial, by calculatng the difference between the start and end clock
    % time using the Matlab function 'etime'
    disp(['Time elapsed for for script execution: ' num2str(etime(t2,t1))]);

    % Let's also display what has been pressed and the reaction time
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode) ' after ' num2str(reactTime) ' seconds']);

    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 2: Reading keyboard input with timings (part 2)

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Let's create a variable that indicates how long we are going to wait 
    % for a key press
    trialDuration = 4;

    % We are also going to track whether we have received an input on this
    % trial or not
    inputReceived = 0;

    % Let's also prepare an empty variable in which we can later store the
    % reaction time in seconds
    reactTime = 0;

    % The following two lines are useful steps for additional security
    % before starting a trial. Specifically, we want to make sure that all
    % the keys have been released and that all previously recorded key
    % press and release events are cleared from the memory. To clear
    % previous key events from memory we can use the PTB function
    % 'FlushEvents'. After that we can wait for all keys to be released
    % using the PTB function 'kbReleaseWait'. These kind of precautions are
    % more often used when showing stimuli in rapid succession (like in a
    % Go / no GO task)
    FlushEvents;
    KbReleaseWait;

    % Let's measure the time of script execution by reading the clock time
    % using the Matlab function 'clock'
    t1 = clock;

    % Next, let's use the PTB 'GetSecs' function to find the time (in
    % seconds) according to the task clock, and also store that as the
    % current time
    startT = GetSecs;
    currT = startT;
    
    % We can now display that start time in the command window
    disp(['Showing keyboard timings using example 2. Start time: ' num2str(startT) 's']);

    while(currT - startT < trialDuration)
                
        % To query keyboard inputs we are going to use the PTB function
        % 'KbCheck'
        [keyIsDown, currSecs, keyCode, ~] = KbCheck;
        
        % Let's find if any key events have occurred (i.e. whether there
        % are any ones in the keyCode array)
        keyCode = find(keyCode, 1);
        
        % We can now determine whether 'kbCheck' detected any key press
        % events by checking if keyIsDown is equal to one. At the same time
        % we are going to ask if we have already registered a key press
        % during this trial by checking the readResponse variable
        if(keyIsDown && ~readResponse)

            % Let's compute the reaction time, which will be the difference
            % between the time returned by kbCheck and the trial start time
            reactTime = currSecs - startT;

            % Let's save the keycode we just obtained from 'kbCheck'
            respKeyCode = keyCode;

            % Let's set readResponse to 1 to prevent any other key presses
            % being recorded and overwriting the information we just saved
            readResponse = 1;

        end
            
        % Before starting the next iteration of the loop we are going to
        % update the currT variable we are using to record the current time
        % using the PTB function 'GetSecs', which returns the time since
        % the start of script execution
        currT = GetSecs;

    end

    % We have finished this trial, so let's measure the clock time again
    t2 = clock;

    % Let's now display the total real time of trial execution of the
    % trial, by calculatng the difference between the start and end clock
    % time using the Matlab function 'etime'
    disp(['Time elapsed for for script exection: ' num2str(etime(t2,t1))]);

    % Let's also display what has been pressed and the reaction time
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode) ' after ' num2str(reactTime) ' seconds']);

    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 3: Calculating the duration of stimulus presentation using the display frame rate

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
PsychDefaultSetup(2);

try
    
    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);

    % We can now measure the time interval between screen refreshes
    flipInterval = Screen('GetFlipInterval', window);

    % If we are concerned with accurate timing, we can instruct PTB to
    % allocate the maximum possible resources to the PTB window. That means
    % the PTB window will have a privileged status on your machine and
    % reduces the chances that background or system processes will affect
    % execution timing in your script
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);

    % We are going to use the time interval between screen refreshes to
    % calculate when the nearest flip to our desired display duration will
    % happen
    requiredSeconds = 3;
    totalWaitFrames = round(requiredSeconds / flipInterval);

    % The 'Screen' function can return a timestamp in seconds (similar to
    % GetSecs). We can then flip an empty back-buffer to get the current
    % time when the screen has changed - this will be our start time
    currentTime = Screen('Flip', window);

    % Now, we can wait for any keyboard press
    while ~KbCheck
    
        % We can then measure the current time
        t1 = clock;
        
        % Color the screen a random RGB color 
        Screen('FillRect', window, rand(1, 3));
    
        % Then we can flip that screen at a specific time by using the 
        % additional input that we computed earlier
        currentTime = Screen('Flip', window, currentTime + (totalWaitFrames - 0.5) * flipInterval);
        
        % We can then meaure the current time again, and display the total
        % real time of trial execution
        t2 = clock;
        disp(etime(t2,t1));
    end
    
    % Clear the screen.
    sca;
    
catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 4: Hiding and Showing mouse cursor

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Get the center coordinates of the PTB window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % Now, let's draw a rectangle
    Screen('FillRect', window, [0.8 0 1], [windowCenterX-150 windowCenterY-150 windowCenterX+150 windowCenterY+150])

    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Wait 2 seconds
    WaitSecs(2);

    % Hide the cursor
    HideCursor;

    % Now, let's change the color of the rectangle
    Screen('FillRect', window, [1 0 0.5], [windowCenterX-150 windowCenterY-150 windowCenterX+150 windowCenterY+150])
    
    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Let's hide the cursor for two seconds
    WaitSecs(2);

    % Let's set the mouse position before showing the cursor again. We can
    % use the 'SetMouse' function to do this, using inputs that dictate the
    % pixel coordinates within the PTB window where we want to set our
    % mouse cursor, and the ID of the window in which we wish to display
    % the cursor. Let's set it to be the top left corner of the drawn
    % rectangle
    SetMouse(windowCenterX-150, windowCenterY-150, window);

    % Let's show the cursor again
    ShowCursor;

    % Let's wait for two further seconds before we close PTB
    WaitSecs(2);
    
    % Close all PTB windows
    sca;

catch ME

    % Close all PTB windows
    sca;

    % When hiding the cursor in the try block, remember to call the
    % 'ShowCursor' function in the catch block, so that the mouse cursor
    % reappears if the script crashes during the try block
    ShowCursor;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 5: Querying the mouse

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Get the center coordinates of the PTB window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);
    
    % There is an alternative way to get the pixel dimensions of an open
    % PTBWindow - using the sub-function 'WindowSize'. This returns the
    % information contained in the sourceRect variable that is created when
    % we open the PTB window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Let's define a standard way of blending pixels in the screen
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Let's hide the cursor
    HideCursor;

    % Now let's set a variable that tracks whether the left mouse button
    % has been pressed during the trial
    leftButtonClicked = 0;    

    % Let's loop until we detect a left mouse click
    while ~leftButtonClicked
    
        % 'GetMouse' can be used to query the status of the mouse
        [mouseX, mouseY, buttons] = GetMouse(window);

        % We are going to restrain the mouse cursor location values to lie
        % between (0,0) and the maximum x and y pixel coordinates of the
        % screen. This is useful in case people have two monitors connected
        mouseX = min(mouseX, sourceRect(3));
        mouseY = min(mouseY, sourceRect(4));
        mouseX = max(0,mouseX);
        mouseY = max(0,mouseY);
    
        % Alternatively, we could avoid this problem by constraining the
        % mouse cursor to remain within the PTB window. We can do that by
        % using the Screen subfunction 'ConstrainCursor' providing, as
        % inputs, the PTB window pointer, a number indicating whether we
        % want to restrain the cursor (1) or not (0) and a rectangle
        % indicating the portion of the PTB window we want the cursor to
        % restrain (or leave this empty to indicate the whole window). You
        % can try this by removing the comment from the line below and
        % re-running this code section 
        % Screen('ConstrainCursor', window, 1, []);

        % We are going to display some text indicating the mouse position,
        % so let's change the font size here
        Screen('TextSize', window, 40);

        % Let's prepare some text for indicating the mouse coordinate on
        % the screen
        textString = ['Mouse X pixel coordinate ' num2str(round(mouseX)) ' and Y pixel coordinate ' num2str(round(mouseY))];
    
        % We can now display that text in the centre of the screen
        DrawFormattedText(window, textString, 'center', 'center', [1 1 1]);
    
        % Let's use a new sub-function, 'DrawDots', to indicate where the
        % mouse is. This requires, as inputs, a pointer to the relevant PTB
        % window, the x and y pixel coordinates in the PTB window where we
        % want to draw a dot, an RGB color (in this case random), a center
        % coordinate which our draw position is set relative to (if empty,
        % as in this case, then the pixel coordinates will be interpreted
        % as absolute values) and a number indicating the type of dot we
        % are going to draw (don't worry too much about this input - for
        % most cases, any value between 1 and 3 will draw round dots that
        % look much the same, and a value of 4 will draw a square dot)
        Screen('DrawDots', window, [mouseX mouseY], 20, rand(1,3), [], 2);
    
        % Flip to the screen at this point
        Screen('Flip', window);
        
        % Let's save the status of the left-click mouse
        leftButtonClicked = buttons(1);

    end
    
    % Let's show the cursor again
    ShowCursor;
    
    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Show the cursor again
    ShowCursor;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 6: Audio output

%  Let's start by clearing the workspace
clear all;

try

    % Using audio in your experiment requires an additional initialization
    % step, performed by the PTB function 'InitializePsychSound'. This step
    % is necessary only if you are planning to play any sound during your
    % experiment, otherwise you can skip it
    InitializePsychSound;

    % Like with images, audio files need to be imported into the Matlab
    % workspace before they can be played by PTB. PTB has a function called
    % 'psychwavread' that reads wav files into the workspace, given the
    % full path to the corresponding file. The function returns the sound
    % wave as an array (sWavw) as well as a numerical output indicating the
    % sampling rate of the wave file (freq)
    [sWave, freq] = psychwavread('./Assets/pos_feedback.wav');

    % We can now calculate the total duration of the audio clip by dividing
    % the length of the audio signal by the sampling rate
    waveL = length(sWave)/freq;

    % For ease of use, it is preferable to have the audio signal as a row
    % vector rather than a column vector - so we can use the ' shortcut to
    % transpose that matrix
    sWave = sWave';

    % Sometimes audio clips are mono rather than stereo - i.e. only have
    % one component, rather than two - but most experimental setups will
    % have two speakers. To deal with this, we can simply duplicate the
    % audio signal to simulate a stereo output, if the signal only has one
    % channel (i.e. one row)
    nrChannels = size(sWave,1);        
    if(nrChannels < 2)
        sWave = [sWave;sWave];
        nrChannels = 2;
    end

    % We are now ready to use open our audio device in order to play sound.
    % The function PsychPortAudio has a sub-function 'Open' that can be
    % used to initialize the audio device. It takes, as inputs, the ID of
    % the audio device we want to open (empty brackets for default), a
    % number indicating whether the device will be used for audio playback
    % (1) or recording (2), a number indicating the how PTB should minimize
    % the latency between sending an audio signal to that device and
    % actually playing it (don't worry too much about this, for most
    % purposes, and particularly if you don't care too much about very
    % precise timing, a value of 0 is sufficient), the audio sample rate in
    % samples per seconds (Hz), and a value indicating the number of audio
    % channels to use. The function returns a pointer to our audio device
    % that can be used by subsequent audio functions
    audioHandle = PsychPortAudio('Open',[],1,0,freq,nrChannels);

    % As with images, PTB uses a special buffer to organise the audio
    % output before it is played. We can add audio signals to this buffer
    % using the PsychPortAudio subfunction 'FillBuffer' which requires, as
    % inputs, a pointer to the relevant audio device and the audio signal
    % we wish to write to it
    PsychPortAudio('FillBuffer',audioHandle,sWave);

    % Once the audio has been loaded into the buffer, we are now able to
    % play it by simply calling the PsychPortAudio sub-function 'Start'
    PsychPortAudio('Start',audioHandle);

    % After starting the audio we should wait some time before stopping
    % it and closing the audio device. To wait the correct amout of
    % time we are going to wait for the total duration of the audio we
    % calculated previously
    WaitSecs(waveL);

    % We can then stop the audio
    PsychPortAudio('Stop',audioHandle);

    % Then we can close the audio device
    PsychPortAudio('Close',audioHandle);

catch ME
    
    % Close the audio device
    PsychPortAudio('Close');
    
    % Return details of the error
    rethrow(ME);
end


%% Example 7: Displaying a created stimuli

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Hide the mouse cursor
    HideCursor;

    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Get the center coordinates of the PTB window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % Let's define a standard way of blending pixels in the screen
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % We are going to create a new image texture by manually setting the
    % RGB values of the image. First, let's define a dimension for the
    % texture we want to draw in pixels
    width = 250;
    height = 250;
	
    % Next,let's set the colors. We want red to be a horizontal gradient
    % starting from zero on the left side
	arrayR   =  repmat([1:width]/width , [height,1]);
    
    % We want green to be a vertical gradient starting from zero on the
    % upper side
	arrayG   =  repmat([1:height]'/height, [1,width]);
    
    % We want blue to be present throughout, so let's fill it with ones
	arrayB   =  ones(width,height) * 0.5 ;

    % We can then combine these values in a single, multidimensional array
    % which PTB can read in a single step
	imageArray(:,:,1)   =  arrayR; 	
	imageArray(:,:,2)   =  arrayG; 
	imageArray(:,:,3)   =  arrayB;

    % Let's create a new stimulus by adding our image array to a texture
    imageTexture = Screen('MakeTexture', window, imageArray);

    % Now, finally, we can draw the texture into the back buffer by using
    % the DrawTexture sub-function and providing, as input, the texture we
    % have just created
    Screen('DrawTexture', window, imageTexture, [],[windowCenterX-250 windowCenterY-250 windowCenterX+250 windowCenterY+250]);

    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Now, let's wait for a key press
    KbWait;

    % Show the mouse cursor
    ShowCursor;

    % Close all PTB windows
    sca;

catch ME
    
    % Close all PTB windows
    sca;

    % Show the mouse cursor
    ShowCursor;
    
    % Return details of the error
    rethrow(ME);
    
end


%% Example 8: Randomising the order of stimulus presentation

%  Let's start by clearing the workspace
clear all;

%  Let's create a variable with the path to each image file in a cell array
expInfo.images         = {'./Assets/Goomba.png','./Assets/Lakitu.png','./Assets/Bill.png','./Assets/SuperHammer.png'};

%  Let's set how many times the images will be placed 
expInfo.nPresentations = 3;

%  We have four images we want to show a number of times to the
%  participant. Let's create an array containing the indices of the images
%  repeated a number of times equal to the number of presentations. To do
%  this, we can use the Matlab function 'repmat' that takes, as inputs, the
%  array we want to duplicate and two numbers specifying the number of
%  times we wish to copy that array in separate rows and columns
trialStructure = repmat(1:size(expInfo.images,2),1,expInfo.nPresentations);

%  Now that we have our indices, let's shuffle them so that the order in
%  which stimuli are presented is random. PTB has a 'Shuffle' function that
%  we can use for this purpose
trialStructure = Shuffle(trialStructure);

%  Alternatively, we can achieve the same thing using built-in Matlab
%  functions. First, let's seed our random number generator. Then, we can
%  use the random permutation function 'randperm' to shuffle our array

%  rng('shuffle');
%  trialStructure = repmat(1:size(expInfo.images,2),1,expInfo.nPresentations);
%  randPermutations = randperm(size(trialStructure,2));
%  trialStructure = trialStructure(randPermutations); clear randPermutations

%  Finally, let's display our random presentation order in the command
%  window
for nTrial = 1:size(trialStructure,2)
    disp(['Trial: ' num2str(nTrial) ' Showing: ' expInfo.images{trialStructure(nTrial)}])
end


%% Example 9: Creating an input dialog box to collect participant information

%  Let's start by clearing the workspace
clear all;

%  Before starting our experiment, we might like to get some information
%  from the participant. We can do so by opening a dialog box using the
%  Matlab 'inputdlg' function. This requires, as inputs, an array
%  indicating the prompts to be displayed into the dialog box, the text
%  that will be displayed in the title bar of the dialog box, a matrix (of
%  n rows and 2 columns) indicating the width and height of the space into
%  which each response will be inserted, and a cell array indicating
%  default answers to be diplayed in the dialog box upon presentation. The
%  function returns a single cell array containing all the information the
%  participant entered

%  Before we demonstrate this by calling the 'inputdlg' function, let's
%  prepare some input variables for that function
prompts     = {'Participant ID', 'Name', 'Age', 'Years of Education', 'Right/Left Handed'};
dlgtitle   	= 'Participant Information';

%  This next variable defines the dimensions of the input dialog boxes. The
%  first number is the hight of the input field and the second one is the
%  length of the input field (in characters)
dims        = [1 25; 1 50; 1 15; 1 15; 1 10];

%  Let's insert some default values for the prompts
definput    = {'1', 'Mario', '18', '15', 'R'};

%  Finally, let's open the dialog box. The execution of this Matlab script
%  will pause until the dialog box is closed. At that point, all of the
%  information entered into the dialog box will be returned in the cell
%  array pInfo
pInfo        = inputdlg(prompts,dlgtitle,dims,definput);

%  Clear all unnecessary variables before the script ends
clear prompts dlgtitle dims definput