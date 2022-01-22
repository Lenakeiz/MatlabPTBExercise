%% Initialization
% Clear the workspace and the screen
close all; clear;

% Showing a quick dialog box to register a participant ID
% The function here is plain matlab and do not require PTB
prompt = {'Enter participant ID:'};
dlgtitle = 'Participant info';
% Size of the dialog
dims = [1 40]; 
definput = {'1'};
pID = inputdlg(prompt,dlgtitle,dims,definput);
% for debugging reasons
%pID = '1';
%% PTB initialization
% Default settings for Psychtoolbox 
% 1 = Executes AssertOpenGL to initialize the API for writing on the graphics
% card. Executes KbName('UnifyKeyNames') to ensure the names of special
% keys (e.g. function keys) between operating systems will be consistent
% 2 = Same as before but also normalize the range of colors for 8-bit and
% 16-bit display
PsychDefaultSetup(2);
% Perform basic initialization of the sound driver
InitializePsychSound;

% Get the number of screen available in the current system. That is useful
% when we have more than one screen attached 
screens = Screen('Screens');
screenNumber = max(screens);

Screen('Preference', 'SkipSyncTests', 1);

%% Preparing experiment variables

% Manually adding expriment folders. Assets from where we are going to load
% images, sounds. Results where we are going to save the 
addpath('./Assets');
addpath('./Results');

% It is good practice to have a struct or your preferred data holder to
% keep track of the current variables used in the experiment
% Saving information from the dialog box
expInfo.pID = pID;
% Dictates how many times to display each set of stimuli 
expInfo.nImagesRepeat = 2;
expInfo.trialDuration = 2; % in seconds

% Preapring information about stimuli
expInfo.imagesName       = ["Goomba" "Lakitu" "Bill" "Super Hammer"];
expInfo.images           = ["./Assets/Goomba.png" "./Assets/Lakitu.png" "./Assets/Bill.png" "./Assets/SuperHammer.png"];
expInfo.imagesScale      = [0.3 0.9 0.2 0.5];
expInfo.imagesFlip       = [1 1 0 1];
expInfo.imagesKeyPresses = [KbName('UpArrow') KbName('RightArrow') KbName('DownArrow') KbName('LeftArrow')];

%Saving some information about sounds
expInfo.sounds = ["./Assets/neg_feedback.wav" "./Assets/pos_feedback.wav"];

% Preparing a color palette. You can eventually look at any packages that does that for you (e.g. cbrewer)
expInfo.paletteGrey     = [194/255 194/255 235/255];
expInfo.paletteRed      = [255/255 68/255 59/255];
expInfo.paletteDarkGrey = [109/255 93/255 95/255];
expInfo.paletteWhite = [1 1 1];
expInfo.paletteBlack = [0 0 0];
expInfo.screenGrey   = [0.5 0.5 0.5];

% Setting information for drawing the the fixation cross
expInfo.fixCrossDimPix   = 50;
expInfo.fixLineWidthPix  = 10;
expInfo.fixCrossDuration = 1;

%% Initializing PTB window
% Open a double-buffered on screen window with following parameters
% (1) 2 = which screen where to open the window
% (2) [0,0,0] = default color for the back ground
% (3) [] = specify a rect for the window, if empty draw full screen
% Returns:
% (1) the handle of the window
% (2) the inferred size of the window in pixels
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, expInfo.paletteBlack);

% Get the size of the on screen window
%[expInfo.screenXpixels, expInfo.screenYpixels] = Screen('WindowSize', window);
expInfo.screenXpixels = windowRect(3);
expInfo.screenYpixels = windowRect(4);

% Get the centre coordinate of the window
[expInfo.Xcenter, expInfo.Ycenter] = RectCenter(windowRect);

%ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines, and to allow color blending if
% the alpha channel is used
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%% Training
doTraining(window, expInfo);
%% Test
results = doTest(window, expInfo);
results = cell2table(results,'VariableNames',{'Trial' 'Stimulus' 'Key' 'KeyPress' 'RT' 'Correct'});

% Saving the information to a mat file
save("./Results/" + expInfo.pID{1} + ".mat",'results');
%% Feedback
%% Closing
sca; %aka Screen('CloseAll')
%%
function doTraining(w, expInfo)

    % It is important to enclose our code into try...catch statements. This
    % will help us for when building the experiment to avoid the created
    % window will freeze the matlab execution and will avoid us brute
    % killing the window with ctrl+alt+del on windows or command + period;
    % command + 0 on Mac
    try

        % Remember, everytime we interact with Screen we always draw to the back
        % buffer
        % We always draw things on top of each other, that means we start
        % from the background

        % We want to color the background differently for when displaying
        % instructions (this is just a preference). For doing so we are
        % going to draw a rectangle on the screen with following parameters
        % (1) the handle of the window
        % (2) the color of the rectangle
        % (3) the coordinates where to draw it, if missing default is entire window 
        Screen('FillRect', w, expInfo.paletteDarkGrey, []);

        % [We just want to change the font size ]
        Screen('TextFont',w, 'Helvetica',3);
        Screen('TextSize',w, 80);

        mTextT = ' __Super Mario Matlab__';

        % Draw the text on the screen using formatting options. In this
        % case I want the text to be on the center of the screen and
        % towards the top. Using relative coordinates to the window size
        % gives me the advantage to be independent from the resolution of
        % the screen. Function parameters are
        % 1 text to be displayed as a char array
        % 2/3 coordinate of the center of the text
        % 4 color
        % 5 number of characters after which a new line is formed
        % Returns
        % 1/2 coordinate of text drawing cursor at the last character draw
        % 3 rect containing the bounding box enclosing the text
        [~, ~, bbox] = DrawFormattedText(w, mTextT, 'center', expInfo.screenYpixels * 0.2,  expInfo.paletteRed);
        % For the title we are adding a new drawing using the bounding box
        % information. FrameRect draws only the outline of a rectangle with
        % a specified thickness.
        Screen('FrameRect', w, [expInfo.paletteRed, 1], [bbox(1:2)-15,bbox(3:4)+15],4); 
        
        mTextI = ['Help Mario to survive against different enemies! Each enemy can be avoid by using a particular arrow key.\n' ...
            '\n In the next part you will learn the what arrow key to use for each different enemy.'];
        Screen('TextSize',w, 50);
        % Displaying the instruction text and cut the text every 40
        % characters
        DrawFormattedText(w, mTextI, 'center', 'center', [expInfo.paletteGrey, 1], 40);
        
        mTextC = 'Press any key to continue';
        DrawFormattedText(w, mTextC, 'center', expInfo.screenYpixels * 0.8, [expInfo.paletteGrey, 1]);

        % This function switch the back buffer to the front buffer. This is
        % when effectively our drawing will compare on the screen.
        % Everytime we flip the buffers the backbuffer gets cleared
        Screen('Flip',w);
        % Waiting for any key press
        KbWait;
        % Waiting for anu key to be released
        KbReleaseWait;

        clear bbox mTextT mTextI mTextC
        
        % This time I want the background to be black, so I am drawing a
        % black rectangle to the backbuffer
        Screen('FillRect', w, [0 0 0]);

        % Loading all the stimuli
        for i = 1:size(expInfo.imagesName,2)
            
            % Preparing instruction for each stimuli
            mText = char( "When " + expInfo.imagesName(i) + " " + "appears you press " + KbName(expInfo.imagesKeyPresses(i)) );
            disp(mText);
            
            Screen('TextSize',w, 50);
            
            % Drawing  instruction for each stimuli
            DrawFormattedText(w, mText, 'center', expInfo.screenYpixels * 0.2,  [expInfo.paletteGrey, 1]);            
            
            % Reading the image from the assets folder
            currImage = imread(expInfo.images(i));
            % Manually scaling the images so to have the same size. When
            % preparing the experiment you should do this separately and
            % once (i.e. transform the images and overwirte the same file) 
            currImage = imresize(currImage, expInfo.imagesScale(i));
            % Flip some of them vertically
            if expInfo.imagesFlip(i); currImage = flip(currImage,2); end

            % Make the image into a texture    
            imageTexture = Screen('MakeTexture', w, currImage);
            % Draw the image to the screen, unless otherwise specified PTB will draw
            % the texture full size in the center of the screen. Parameters
            % are as follow
            % 1 backbuffer where to draw the texture
            % 2 texture to draw 
            % 3 rect portion of texture to draw, defualt is full texture
            % For other optional parameters see Screen DrawTexture?
            Screen('DrawTexture', w, imageTexture, [], [], 0);
            Screen('Flip',w);
            
            isCorrectKey = 0;

            % Waiting for a correct key press as indicated in the
            % instructions
            while ~isCorrectKey
                % Stop execution of the script waiting for any keyboard
                % press
                KbWait;
                % Checking which keycode has been pressed
                [keyIsDown, ~, keyCode] = KbCheck;
                % keyCode is a 256-element array.
                keyCode = find(keyCode, 1);
                if keyIsDown
                    disp("Pressed key " + KbName(keyCode));
                    if(keyCode == expInfo.imagesKeyPresses(i))
                        isCorrectKey = 1;                    
                    end
                    % Stoppping execution until current key is released
                    KbReleaseWait;
                end
            end

        end

        clear currImage isCorrectKey keyIsDown keyCode i

        mText = char("Good job! Now you will go through " + expInfo.nImagesRepeat * size(expInfo.imagesName,2) + " to help Mario.\n \n Good luck!\n \n Press any key to continue");
        DrawFormattedText(w, mText, 'center', 'center',  [expInfo.paletteGrey, 1]);        
        
        Screen('Flip',w);
        
        KbWait;
        KbReleaseWait;

        Screen('FillRect', w, [0 0 0]);
        Screen('Flip',w);

        WaitSecs(0.5);

    catch ME

        % Catching any error will securely close the window and then
        % rethrow the error
        sca; Screen('CloseAll');
        ShowCursor; 
        rethrow(ME);

    end

end
%%
function results = doTest(w, expInfo)

    % Creating trial structure
    trialStructure = repmat(1:size(expInfo.imagesName,2),1,expInfo.nImagesRepeat);
    % This is an handy function that comes with PTB
    trialStructure = Shuffle(trialStructure);
    % This is better that just randomizing trials as we still have control
    % on how many times each stimuli is presented.
    % totalTrials = 8; randi([1 size(expInfo.imagesName,2)],1,totalTrials);
    
    results = cell(size(trialStructure,2),6);
        
    for nTrial = 1:size(trialStructure,2)
        
        results(nTrial,:) = {nTrial expInfo.imagesName(trialStructure(nTrial)) KbName(expInfo.imagesKeyPresses(trialStructure(nTrial))) "" 0 0};

        % We perform useful operation for the current trial before working
        % on the window

        %Loading current image
        currImage = imread(expInfo.images(trialStructure(nTrial)));
        currImage = imresize(currImage, expInfo.imagesScale(trialStructure(nTrial)));
        if expInfo.imagesFlip(trialStructure(nTrial)); currImage = flip(currImage,2); end

        % Make the image into a texture to be able to draw into the screen.
        imageTexture = Screen('MakeTexture', w, currImage);

        % We diplay a fixation cross
        doFixationCross(w,expInfo);

        try
    
            reactTime = 0;
            respKeyCode = 0;
            readResponse = 0;

            FlushEvents;
            while KbCheck; end % Wait until all keys are released.            

            % Draw the image to the screen, unless otherwise specified PTB will draw
            % the texture full size in the center of the screen. 
            Screen('DrawTexture', w, imageTexture, [], [], 0);
    
            % Flip to back buffer and getting a timestamp for the operation. It is interestingly to see how timestamps can be different 
            % from the screen
            startT = Screen('Flip', w);
            currT = startT;

            while(currT - startT < expInfo.trialDuration)
                
                % Polling the input devices to check for any key event
                % (press or release). 
                [keyIsDown, secs, keyCode, ~] = KbCheck;
                keyCode = find(keyCode, 1); %in most cases this is redundant
                
                % Registering only a press event and save it as a response
                if(keyIsDown && ~readResponse)
                    reactTime = secs - startT;
                    respKeyCode = keyCode;
                    readResponse = 1; %avoiding to get 
                end
                
                % Updating the current time
                currT = GetSecs;

            end
            
            % Alternative method is using KbWait. For high performance this
            % is not ideal as the method polls every 5ms.
            % [respT, respKeyCode, ~] = KbWait([],2,expInfo.trialDuration); %this checks every 5ms. If higher resolution is required you can loop through each frames.
            % reactTime = restT - startT;
            % if(reactTime < expInfo.trialDuration); WaitSecs(expInfo.trialDuration - reactTime); end
            
            %clean the screen
            Screen('FillRect', w, [0 0 0]);
            Screen('Flip',w);

            %Saving trial resutls
            if (respKeyCode ~= 0); results{nTrial,4} = KbName(respKeyCode); else; results{nTrial,4} = ""; end
            results{nTrial,5} = reactTime;
            if(respKeyCode == expInfo.imagesKeyPresses(trialStructure(nTrial))); results{nTrial,6} = 1; end
    
            % PLaying a feedback soudn
            playFeedback(expInfo.sounds(results{nTrial,6} + 1));

        catch ME
    
            sca;
            ShowCursor;
            rethrow(ME);
    
        end
    
    end

end
%%
function doFixationCross(w,expInfo)
    
    try
        % Now we set the coordinates (these are all relative to zero we will let
        % the drawing routine center the cross in the center of our monitor for us)
        xCoords = [-expInfo.fixCrossDimPix expInfo.fixCrossDimPix 0 0];
        yCoords = [0 0 -expInfo.fixCrossDimPix expInfo.fixCrossDimPix];
        allCoords = [xCoords; yCoords];
    
        Screen('DrawLines', w, allCoords,expInfo.fixLineWidthPix, expInfo.paletteWhite, [expInfo.Xcenter expInfo.Ycenter], 2);
        Screen('Flip',w);

        WaitSecs(expInfo.fixCrossDuration);

    catch ME
        sca;
        ShowCursor;
        rethrow(ME);
    end
end
%%
function playFeedback(soundFile)

    try
        %Loading the current audio file
        [sWave, freq] = psychwavread(soundFile);
        waveL = length(sWave)/freq;
        sWave = sWave';
        nrChannels = size(sWave,1);
        
        % If it is a mono channel we duplicate the wave to simulate stereo
        % output
        if(nrChannels < 2)
            sWave = [sWave;sWave];
            nrChannels = 2;
        end

        % As for the screen we prepare our items into a buffer
        % Open Psych-Audio port, with the follow arguments
        % (1) [] = default sound device
        % (2) 1 = sound playback only
        % (3) 1 = default level of latency
        % (4) Requested frequency in samples per second
        % (5) 2 = stereo putput
        audioBuff = PsychPortAudio('Open',[],1,0,freq,nrChannels);
        % Placing the audio into the buffer
        PsychPortAudio('FillBuffer',audioBuff,sWave);
        % Play the audio
        PsychPortAudio('Start',audioBuff);
        WaitSecs(waveL);
        PsychPortAudio('Stop',audioBuff);
        PsychPortAudio('Close',audioBuff);

    catch ME
        PsychPortAudio('Close');
        rethrow(ME);
    end
end