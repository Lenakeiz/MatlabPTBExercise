%% This script accompanies the "Psychophysics toolbox (PTB) - a gentle 
%  introduction" lectures from the UCL Institute of Cognitive Neuroscience
%  Matlab Course. All course details and content - including pre-recorded
%  lectures, slides, practical exercises and solutions - can be found on
%  the course website: https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) uceeaca@ucl.ac.uk
%
%  In the second lecture, we are going to demonstrate use cases of PTB.
%  Every example is contained in a different code section (differentiated
%  by the double comment symbol at the beginning of each section). Each
%  section is therefore completely standalone and can be executed by
%  clicking 'Run section' or using the relevant keyboard shortcut (control
%  and enter on a Windows machine)

%% Example 1: Reading keyboard input with timings (1)

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Let s create a variable for indicating how long we are going to wait for
    % a key press
    trialDuration = 4;

    % Let s measure the time of script execution by reading the clock time
    % using the matlab function clock
    t1 = clock;

    % Getting the realtime clock in seconds using PTB
    startT = GetSecs;

    % We are displaying the start on the command window
    disp(['Showing keyboard timings using example 1. Start time ' num2str(startT)]);

    % Let's use the kBWait 
    [respT, respKeyCode, ~] = KbWait(0,3, startT + trialDuration);
    % Let's find the pressed key index (if any)
    keyCode = find(respKeyCode, 1);

    % We set a trial duration, but kbWait could have returned at a earlier
    % time, so we are going to wait for the remaining trial durataion
    reactTime = respT - startT;
    if(reactTime < trialDuration)
        WaitSecs(trialDuration - reactTime);
    end

    % We have finished our trial, let s measure the clock time
    t2 = clock;

    % Let's print the total real time of execution of the trial, by
    % calculatng the difference between the final clocktime and starting
    % clocktime using the matlab function etime
    disp(['Time elapsed for for script exection: ' num2str(etime(t2,t1))]);

    % Let s print what has been pressed and the reaction time
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode) ' after ' num2str(reactTime) ' seconds']);

    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end

%% Example 2: Reading keyboard with timings (2)

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see examples from lecture 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Let s create a variable for indicating how long we are going to wait for
    % a key press
    trialDuration = 4;

    % We are going also to track whether we have received an input for this
    % trial or not
    inputReceived = 0;

    % Let's prepare also a variable to save teh reaction time in seconds
    reactTime = 0;

    % The following two lines are an extra security before starting the
    % trial. We want to make sure that all the keys are being released
    % and at the same time that all of the previously recorded key
    % events are cleared from the memory. For clearing the key events
    % from memory we can use the PTB function 'FlushEvents'. After that
    % we can wait for all the keys being released by using the PTB
    % function kbReleaseWait. This kind of precautions are more
    % indicated when showing stimuli in a rapid succession (like a
    % Go/noGO task)
    FlushEvents;
    KbReleaseWait;

    % Let s measure the time of script execution by reading the clock time
    % using the matlab function clock
    t1 = clock;

    % Getting the realtime clock in seconds
    startT = GetSecs;
    currT = startT;

    disp(['Showing keyboard timings using example 2. Start time ' num2str(startT)]);

    while(currT - startT < trialDuration)
                
        % To query the keyboard we are going to use the PTB
        % function KbCheck
        [keyIsDown, currSecs, keyCode, ~] = KbCheck;
        % Let s find if there any one (indicating a key with an
        % event) in the array.
        keyCode = find(keyCode, 1);
        
        % We can now check if kbCheck detected any press event by
        % checking if keyIsDown is equal to one. At the same time
        % we are going to ask if we already registered a key press
        % for this trial by reading readResponse variable
        if(keyIsDown && ~inputReceived)

            % Reaction time will then be the difference between the
            % time returned from kbCheck and the time when we
            % flipped our screen
            reactTime = currSecs - startT;

            % Let's save the keycode we just obtained from kbcheck
            respKeyCode = keyCode;

            % Let s set readResponse to 1 to prevent any other key
            % presses to override the information we just saved
            readResponse = 1;

        end
            
            % Before starting the next iteration of the loop we are
            % going to update the variable counting the time by using
            % PTB function GetSecs which returns the time since the
            % start of script execution
            currT = GetSecs;

    end

    % We have finished our trial, let s measure the clock time
    t2 = clock;

    % Let's print the total real time of execution of the trial, by
    % calculatng the difference between the final clocktime and starting
    % clocktime using the matlab function e
    disp(['Time elapsed for for script exection: ' num2str(etime(t2,t1))]);

    % Let s print what has been pressed and the reaction time
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode) ' after ' num2str(reactTime) ' seconds']);

    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end

%% Example 3: Calculating stimulus presentation using the frame rate

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

    % We can measure the minimum time between two screen refreshes to
    % happen
    flipInterval = Screen('GetFlipInterval', window);

    % When dealing with timing we can instruct PTB to allocate the maximum
    % pc resources to the PTB window. That means the PTB window will have a
    % privileged status for your machine and will reduce the chances that
    % background or system processes will affect the execution timing of
    % your script 
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);

    % We are going to use the refresh rate of the monitor to calculate when
    % the nearest flip should happen provided the amount of time we would
    % like to wait
    requiredSeconds = 3;
    totalWaitFromFrames = round(requiredSeconds / flipInterval);

    % Screen can return a timestamp in seconds (similar to GetSecs). We can
    % then flip an empty back-buffer to get the current time when the
    % screen has been changed. This will be our starting time. 
    currentTime = Screen('Flip', window);

    % Wait of any keyboard press
    while ~KbCheck
    
        % Measuring the time of execution
        t1 = clock;
        % Color the screen a random color 
        Screen('FillRect', window, rand(1, 3));
    
        % Flip to the screens only at a specific time using an optional
        % parameter. 
        currentTime = Screen('Flip', window, currentTime + (totalWaitFromFrames - 0.5) * flipInterval);
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

    % Waiting 2 seconds
    WaitSecs(2);

    % Hiding the cursor
    HideCursor;

    % Now, let' change color of the drawn rectangle
    Screen('FillRect', window, [1 0 0.5], [windowCenterX-150 windowCenterY-150 windowCenterX+150 windowCenterY+150])
    
    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Let's hide teh cursor for two seconds
    WaitSecs(2);

    % Let's set the mouse position before unhiding it. We can use the
    % SetMouse function providing the coordinates in pixels of the PTB
    % window where we want to set our mouse cursor. Let's set it a the top
    % left corner of the drawn rectangle
    SetMouse(windowCenterX-150, windowCenterY-150, window);

    % Let s how it again
    ShowCursor;

    % Let's hide wait for two seconds and close PTB
    WaitSecs(2);
    % Close all PTB windows
    sca;

catch ME

    % Close all PTB windows
    sca;

    % When hiding the cursor in the try block remember to add a Showcursor
    % in the catch block
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
    
    % Showing an alternative way to get the dimension of the opened
    % PTBWindow. WindowSize return the size of information contained in
    % sourceRect when opening thePTB window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Let's define a standard way of blending pixels in the screen
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Let's hide the cursor
    HideCursor;

    % We are going to let 
    leftButtonClicked = 0;    

    % Let's loop until we detect a left mouse click
    while ~leftButtonClicked
    
        % GetMouse can be used to query the status of the mouse
        [mouseX, mouseY, buttons] = GetMouse(window);

        % We are going to restrain the read values between (0,0) and the
        % maximum values of the screen in X and Y. This is useful when incase people have two
        % monitors connected. 
        mouseX = min(mouseX, sourceRect(3));
        mouseY = min(mouseY, sourceRect(4));
        mouseX = max(0,mouseX);
        mouseY = max(0,mouseY);
    
        % We could avoid this problem by adding a constraint to the mouse
        % so it does not exit the PTB window. We can do that by using the
        % Screen subfunction ConstrainCursor providing the PTB window
        % pointer, a number indicating whether we want to restrain the
        % cursor (1) or not (0) and a rectangle indicating the portion of
        % the PTB window we want the cursor to restrain. Try to uncomment
        % this call
        %Screen('ConstrainCursor', window, 1, []);

        % We are going to display some text indicating the mouse position so
        % let's change the size here
        Screen('TextSize', window, 40);

        % Let's prepare a text for indicating the mouse coordinate on the
        % screen
        textString = ['Mouse X pixel coordinate ' num2str(round(mouseX)) ' and Y pixel coordinate ' num2str(round(mouseY))];
    
        % Text output of mouse position draw in the centre of the screen
        DrawFormattedText(window, textString, 'center', 'center', [1 1 1]);
    
        % Let's use a new draw function to indicate where the mouse is. We
        % can use DrawDots providing the x,y ptb window coordinate where we
        % want to draw the dot, a color (in this case random), a center
        % where to offset our indicating position (if empty take the
        % position as absolute values) and a number indicating the type of
        % dot we are going to draw
        Screen('DrawDots', window, [mouseX mouseY], 20, rand(1,3), [], 2);
    
        % Flip to the screen at this point
        Screen('Flip', window);
        
        % Let's save the status of the left-click mouse
        leftButtonClicked = buttons(1);

    end
    
    ShowCursor;
    % Close all PTB windows
    sca;


catch ME

    % Close all PTB windows
    sca;
    
    % Return details of the error
    rethrow(ME);
    
end

%% Example 6: Let's play an audio source

%  Let's start by clearing the workspace
clear all;

try

    % Using audios in your experiment requires a separate initialization. The
    % PTB 'InitializePsychSound' perform this. This step is necessary only if
    % you are planning to play any sound throughout your exeperimen otherwise
    % you can skip it
    InitializePsychSound;

    % Like with the images, audio files need to be imported into the
    % matlab workspace. PTB has an fucntion called 'psychwavread' that
    % reads wav files providing the full path to the file. The function
    % returns the sound information as an array and a frequency
    % indicating the sampling rate of the wave file
    [sWave, freq] = psychwavread('./Assets/pos_feedback.wav');

    % We are going to calculate the total duration of the audio by
    % dividing the length of the audio information with the sampling
    % rate
    waveL = length(sWave)/freq;

    % For ptb audio to work we want a row vector rather than a column
    % vector
    sWave = sWave';

    % Sometimes audios have a mono channels, but experimental setup may
    % have two speakers. We can duplicate the wave to simulate a stereo
    % output if we detect the audio wave has only one channel or one
    % raw of data. We are going to do that here by first checking the
    % wave information is only one row
    nrChannels = size(sWave,1);        
    if(nrChannels < 2)
        sWave = [sWave;sWave];
        nrChannels = 2;
    end

    % We are now ready to use open our audio device in order to be
    % able to play sounds through it. The function PsychPortAudio has
    % an open function 'Open' that can be initialize an audio device.
    % It takes as an input the iD of the audio device we want to open
    % (empty brakets for default), a number indicating wheteher the
    % device will be used for audio playback (1) or recording (2),
    % anumber indicating the how PTB should minimize deal with the
    % latency of loading an audio to the device and actually playing
    % it (for most of the application 0 is enough so don't worry too
    % much about this, a number indicating the requested rate in
    % samples per seconds (Hz) for the audio to be played and a number
    % indicating the number of default audio channels to use. The
    % function returns a pointer to our device handle
    audioHandle = PsychPortAudio('Open',[],1,0,freq,nrChannels);

    % In similar way to images, PTB needs a special holder for the
    % audio in order to be played. The special holder is a buffer that
    % we can fill by using the PsychPortAudio subfunction FillBuffer
    % requiring the pointer to the audio device to which we want fill
    % the buffer and the sound wave we are going to write in it
    PsychPortAudio('FillBuffer',audioHandle,sWave);

    % Once the audio has been loaded we are now able to play it by
    % simply using calling the PsychPortAudio sub-function Start
    PsychPortAudio('Start',audioHandle);

    % After playing the audio we should wait some time before stopping
    % it and the closing the audio handle. To wait the correct amout of
    % time we are going to wait for the total duration of the audio we
    % calculated previously
    WaitSecs(waveL);

    % We can finally stop the audio
    PsychPortAudio('Stop',audioHandle);

    % At last we can close the audio device
    PsychPortAudio('Close',audioHandle);

catch ME
    PsychPortAudio('Close');
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

    % We are going to create a new image texture by setting manually the
    % RGB values of the image
    % Let' s define a dimension for the texture we want to draw in pixels
    width = 250;
    height = 250;
	
    % Let's set the colors. 
    % We want red to be an horizontal gradient starting from zero on the
    % left side
	arrayR   =  repmat([1:width]/width , [height,1]);
    % We want green to be a vertical gradient starting from zero on the
    % upper side
	arrayG   =  repmat([1:width]/width , [height,1])';
    % Let's set blue to be always present so let s fill it with ones
	arrayB   =  ones(width,height) * 0.5 ;

    % Let's create multidimensional array for having PTB reading this as an
    % image
	imageArray(:,:,1)   =  arrayR; 	
	imageArray(:,:,2)   =  arrayG; 
	imageArray(:,:,3)   =  arrayB;

    % Let's create a new stimuli by adding our image array to a texture
    imageTexture = Screen('MakeTexture', window, imageArray);

    % Now, finally, we can draw the texture into the back buffer by using
    % the DrawTexture sub-function and providing, as input, the texture we
    % have just created
    Screen('DrawTexture', window, imageTexture, [],[windowCenterX-250 windowCenterY-250 windowCenterX+250 windowCenterY+250]);

    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Now, let's wait for a key press (see Example 10 for PTB basic
    % keyboard functions)
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

%% Example 8: Looping through randomised images

%  Let's start by clearing the workspace
clear all;
clc;

%  Let's create a variable with the path to each image file in a cell array
expInfo.images         = {'./Assets/Goomba.png','./Assets/Lakitu.png','./Assets/Bill.png','./Assets/SuperHammer.png'};
%  Let's set how many times the images will be placed 
expInfo.nPresentations = 3;

% We have four images we want to show a number of times to the participant
% Let's then create an array containing the indices of the images repeated
% for a number of times equal to the number of repetitions for that image
% We can use the matlab function 'repmat' that receives as an input the
% array we want to duplicate and two numbers specifying the number of array
% copies in the row and column
trialStructure = repmat(1:size(expInfo.images,2),1,expInfo.nPresentations);

% Now that we have our indices let's shuffle them so
% the participants will not be able to predict the next trial.
% PTB APIs contains a shuffle function that we can use for this
% purpose.
trialStructure = Shuffle(trialStructure);

% Alternatively using Matlab available functions
% Let s set a seed for our random generator
% Then create a random permutations of integers [1..nTotalTrials]
% Then use the random permutations to shuffle our array

% rng('shuffle');
% trialStructure = repmat(1:size(expInfo.images,2),1,expInfo.nPresentations);
% randPermutations = randperm(size(trialStructure,2));
% trialStructure = trialStructure(randPermutations);

for nTrial = 1:size(trialStructure,2)
    disp(['Trial: ' num2str(nTrial) ' Showing: ' expInfo.images{trialStructure(nTrial)}])
end
%% Example 9: Creating an input dialog for collecting participant information

%  Let's start by clearing the workspace
clear all;
clc;

%  Before starging our experiment sometimes we would like to  get some
%  information from the participant. We can do this by opening a dialog box
%  using Matlab 'inputdlg' function. This function requires the
%  following inputs: an array indicating the prompts to be displayed into
%  the dialog box, a text that will be put onto the window bar of the
%  dialog box, a matrix of n rows and 2 columns indicating the width and
%  height of the space where answer will be inserted, a cell array
%  indicating default answers to be diplayed in the dialog box upon
%  presentation. The function returns a cell array with the information the
%  participant insert.

%  Before calling the function let' s prepare the variables for the
%  function.
prompts      = {'Enter participant ID:', 'Name', 'Age:', 'Years of Education:', 'Right/Left Handness:'};
dlgtitle   	= 'Participant info';

%  This variable defines the dimension of the input dialog. The first
%  number is the hight of the input field and the second one is the length
%  of the input field.
dims        = [1 25; 1 50; 1 15; 1 15; 1 10];

%  Let's insert some default values for the prompts
definput    = {'1', 'Mario', '18', '15', 'R'};

%  Let's open the dialog box here. The execution of the matlab script will
%  stopped until the dialog box is closed. All the information set on the
%  prompts will be saved into the cell array pInfo
pInfo        = inputdlg(prompts,dlgtitle,dims,definput);

clear prompts dlgtitle dims definput