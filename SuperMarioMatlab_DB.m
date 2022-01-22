%% This script accompanies the "Psychtoolbox - a gentle introduction" 
%  lectures from the UCL Institute of Cognitive Neuroscience Matlab Course.
%  All course details and content - including pre-recorded lectures, 
%  slides, practical exercises and solutions - can be found on the course 
%  website: https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) a.castegnaro@ucl.ac.uk

% [In this example we are going to create a simple game which will show all
% the basic functionalities of Psychophysics tool box (PTB) Matlab package.
% In the game, like in Mario Bros, we need to help Mario avoid different kind of enemies 
% (presented as images on the screen). The game is divided in two parts, a tutorial and testing phase.
% During tutorial part we will show which key needs to be pressed upon an image presentation.
% During the testing phase enemies will be presented in a random order and the user 
% will have a fixed amount of time to press the correct key. In this game we are interested to 
% collect the information of which key the user has pressed and how long
% did it take to give a response.

%% Initialization
%  [First, before we start running our PTB
%  script, we want to make sure the workspace is empty and that all previous figure
%  windows have been closed, to prevent anything interfering with our task]

% Clear the workspace and the openened windows
close all; clear;

%  [Then we want to obtain a participant ID, which we will use to save the
%  data for this session. We can create a dialog box to do this, using the
%  built in matlab 'inputdlg' function. This function requires the
%  following inputs: a prompt to be displayed into the dialog box, a text that will be put onto the window bar of the dialog
% box, a number specifying how many lines are required for the answer, a default answer to be diplayed in the dialog box upon
% presentation. The function returns the information the user input.
% Before calling the function let' s prepare the variables for the
% function. You could put the variables directly into the function but in
% this case we are doing it to make the execution clearer to the reader
% reader)]

prompt      = {'Enter participant ID:'}; %text displayed inside the dialog to help the user understand which information is needed
dlgtitle   	= 'Participant info'; % text presented on the top bar of the dialog box
dims        = 1; % indicates how many lines we need the input field to be. 1 is enough for a single number.
definput    = {'1'}; % indicate a default input filed text
pID         = inputdlg(prompt,dlgtitle,1,definput); % opens the dialog box

%% PTB initialization
%
%  [Next, we need to initialise Psychtoolbox. This
%  means starting the toolbox, initialising the sound, detecting how many
%  screens are available, and deciding which screen we will use to display
%  our task. First, let's initialise PTB. To do this, we use the
%  'PsychDefaultSetup' function. This function only takes one input - a
%  number 0, 1 or 2. Each value specifies a different type of setup. Don't
%  worry about the details for now - you will almost always use a value of
%  2 so let's do that here:]
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

% [Next, we nede to initialize the sound. This step is necessary only if
% you are planning to play any sound throughout your exeperimen otherwise
% you can skip it. The PTB 'InitializePsychSound' perform this]
InitializePsychSound;

% [Then similar explanation for the other things - what each function does,
% does it need any inputs, why else might you use it, would you ever not
% use it etc. Don't include any information they don't NEED to know]

% [In most experimental setups you will have more than one screen. In this
% case we want to output the PTB window to the external screen presented in
% the system. We can use the sub-function 'Screens' of the 'Screen' PTB function
% to detect how many screen are present in the current system. The function returns 
% an number array where each number represent a monitor in the system.
% Usually the numbers should follow the numbering you find in Windows
% Display Settings (and equivalent for Mac).]
screens         = Screen('Screens');

% [If having a two screen setup I usually set the external one, presenting the task to the user,
% as 2 (if the monitors are more than two I always set the external it as the highest number 
% in the Windows display settings. In this way no matter the experimental setup the script will always get
% the external desktop by getting the highest number in the array retunred by the previous function. 
% Let s get that number by using the matlab function 'max' returning the
% maximum value inside an array. The number array will be the one obtained
% as a result from the previous function call]
screenNumber    = max(screens);

%% Preparing experiment variables

%  [It's always good practice to assign all constant values at the top of your script, 
%  so they can be changed easily without having to go through all of the
%  code. It s also useful to pack these variable into a struct (or your
%  preferred data structure) in order to keep the workspace as clean as possible, 
%  but also to easily pass these variables to other functions.
%  Let's create a structure to hold these variables in this section.]

% [Sometimes you will have to load external files to present stimuli into your experiment. 
% In this game we are going to use a set of images and audios. It is a good practice to keep the
% experimental files in a separate folder, but in doing so, we have to make sure the folders 
% where experimental files are kept are added to the matlab search path
% otherwise we will not able to load them. 
% Let's add folders to the Matlab search path using the function
% 'addpath' which requires as an input the path to the folder we would like
% to add. We use the speacial character './' to indicate start from the
% current folder.]
addpath('./Assets');

% [It is a good practice to save results from the task in different folders, therefore 
% we are also going to add another folder called results]
addpath('./Results');

% [We are now ready to prepare the experimental variables. How
% many information we need to save will depend on the kind of
% stimuli we are using in our task and the kind of variables we want to
% make flexible for the experiment (e.g. number of trials, trial duration, etc.)
% Let's use a struct called expInfo containing all of this information]

% [Let's save in the expINfo the participant ID we get from the dialog box]
expInfo.pID                 = pID;

% [In this task there will be a fixed number of different stimuli. We want to let the experimenter decide how many times
% those stimuli will be presented. For this reason let's create an experimental variable to keep the number of time we want 
% to present the set of stimuli]
expInfo.nImagesRepeat       = 2;
% [The user will have a certain amount of time to react an enemy image when presenting on the screen.
% Let's make this information variable. Let's save the duration (in seconds) of each stimuli]
expInfo.trialDuration       = 2;

% [In this part we are going to prepare the information about the images. 
% The images will be a fixed set of stimuli. In the tutorial we are going
% to present each image with the corresponding key press to the user.
% For this reason we are going to create a variable holding the path to the files, the name of the enemies and the arrow keys that
% should be pressed when reacting to the enemy.
% Notice how the indices of these variables relate to the each other (e.g.
% index 1 represent an enemy called Goomba, which is presented as an
% image in the assets folder called Gommba.png and that can avoided by Mario with using the
% up arrow. In this way it will be easier later to check when presenting Goomba which correct key we are expecting.]

% [Let s create a vraible with the names of the images in a char array]
expInfo.imagesName          = {'Goomba','Lakitu','Bill','Super Hammer'};

% [Let s create a variable with the path to the files]
expInfo.images              = {'./Assets/Goomba.png','./Assets/Lakitu.png','./Assets/Bill.png','./Assets/SuperHammer.png'};

% [Let s create a variable containg an array of integers which represent a specific key in the keyboard. Each key is identified by a unique integer.
% We are going to use the PTB function 'KbName' that holds a mapping
% between the integers and the keyboard names. Tip: Keyboard names are unique in
% PTB. Run KbName('KeyNames') in the command window to print out the mapping PTB uses between names and code for keys]

% [We want the user to just use arrow keys to react to the images. We have four different images and four different arrow keys]
expInfo.imagesKeyPresses    = [KbName('UpArrow') KbName('RightArrow') KbName('DownArrow') KbName('LeftArrow')];

% [Sometimes stimuli will have different pixel resolutions. Since we want them to occupy the same portion of 
% screen we are going to scale them manually before presenting them. Let's save this information here as a number representing how much
% an image should be scaled in proportion to its real size e.g. 0.5 means halving the size of the image]
expInfo.imagesScale         = [0.3 0.9 0.2 0.5];

% [Sometimes you would like to present stimuli as a flipped/mirrored image. 
% In this example I would like Goomba to face leftward, 
% so I am going to prepare a simple array that tells me whenever I need to flip an 
% image using 1 or not using 0. This information is used later on to flip the images]
expInfo.imagesFlip          = [1 1 0 1];

% [After the end of a trial, we are going to provide a feedback depending
% on the user pressing the correct arrow key or not.
% We are going to prepare this feedback as an audio so we need a negative
% and a positive audio feedback.
% Let's create a variable holding the paths to these files.]
expInfo.sounds              = {'./Assets/neg_feedback.wav','./Assets/pos_feedback.wav'};

% [During the game some of the elements that are going to be drawn on the
% screen may have a specific color.
% PTB gives us the possibility to draw texts colored in different way, so
% let's create some colours (or a palette of) that we will use later on. 
% Each color is represented as an Red Green Blue (RGB) value. Each of
% these value has usually a range [0..255] but PTB normalizes these values
% from [0..1] range. For these reason we need to divide by 255.
% Sometimes you can also specify an RGBA color where A stands for alpha and
% represent the transparency of that color. 
% Let's prepare a set of colours that can be used later by creating arrays
% of three numbers.]

% [During the tutorial the text will be displayed in grey]
expInfo.paletteGrey         = [194/255 194/255 235/255];

% [The title of the task will be displayed in red]
expInfo.paletteRed          = [255/255 68/255 59/255];

% [Dark grey will be the colour chosen as a background for the text in the
% tutorial].
expInfo.paletteDarkGrey     = [109/255 93/255 95/255];

% [Black will be the background color of the PTB window]
expInfo.paletteBlack        = [0 0 0];

% [Before each of the stimuli we are going to propmt the attention of the
% user by using a fixation cross placed at the centre of the screen.
% In this example the fixation cross will be 'hand-drawn' as to line
% segments placed at the center of the screen. 
% In order to make the drawing more flexible we want to be able to easily
% change the lenght of the segments, thickness and color. Let's then create
% some variables to save this information.].

% [Let s create a variable that will tell us how long the segment of the
% fixation cross will be in pixels size]
expInfo.fixCrossDimPix      = 50;
% [Let s define a thickness for the line]
expInfo.fixLineWidthPix     = 10;
% [Let s define a color for the fixation]
expInfo.paletteWhite        = [1 1 1];

% [We would like to modify the duration for which the fixation cross will
% be on the screen. For this purpose let's create a variable that gives us
% the duration in seconds]
expInfo.fixCrossDuration    = 1;

%% Initializing PTB window
% [We have now set all the experimental variables that we are going to use
% in the game. It is now time to start using PTB to open a window where we
% can present our game to the user.
% In this section we are going to open a full window into the second screen. 
% We are going to use the function PsychImaging with the subfunction 'OpenWindow' 
% providing as an input the index of the screen where to open the window,
% a color that will be the background color for our window, and an optional
% parameter that will represent the start and end position (x and y pixel
% coordinates) of the window within the screen. 
% Since we want to draw the window at full screen mode that parameter will
% be empty. The PsychImaging function returns a pointer to the window we
% just opened and the dimension in pixels of the openend window.
% The window pointer will be used later on to instruct any drawing function
% to the correct window.]
[window, windowRect]        = PsychImaging('OpenWindow', screenNumber, expInfo.paletteBlack, []); % WHAT IS THIS FUNCTION? WHAT DOES IT DO?

% [Now, from windowRect let's calculate the lenght of the window in pixels
% size in the x and y coordinate. This will be used later to draw
% shapes/texts offset according to the window dimension.]
expInfo.screenXstart        = windowRect(1);
expInfo.screenYstart        = windowRect(2); 
expInfo.screenXpixels       = windowRect(3)-windowRect(1); 
expInfo.screenYpixels       = windowRect(4)-windowRect(2);

% [We want also to calculate the center of the window in pixel coordinate.
% This will be helpful when drawing the fixation cross for example.
% We can use the PTB function RectCenter to extract the center pixel
% coordinates of the windows by providing the rectangular dimension of the
% window.]
[expInfo.Xcenter, expInfo.Ycenter] = RectCenter(windowRect); 

% [When drawing shapes into a PTB window we need to specify how the screen
% color needs to behave when we color the same pixel on the screen by using
% the . Don't worry too much about this and let's just set a standard 
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Training
% [Now that our window is opened we can start developing the actual game. 
% We are going to start with the tutorial. Organinizing the code on an high
% level can be susceptible to preferences. In this case I opted to create
% an in-script function to divide the execution of the game. Let's then
% create a function for handling the tutorial. This function will receive
% as input the window pointer we want to interact with and the experimental
% variables.]
doTraining(window, expInfo);


%% Test
%  TESTING WHAT? WHY? HOW? WHAT IS THIS FUNCTION? WHERE DID IT COME FROM?
%  WHAT INPUTS DOES IT NEED? 
%results = doTest(window, expInfo);

%  WHAT DOES THIS DO? WHY? WHAT IS A TABLE? WHY SHOULD I USE ONE? ISN'T IT
%  EASIER JUST TO KEEP SEPARATE VARIABLES FOR EACH OUTPUT THAT I CAN EASILY
%  ACCESS AND MANIPULATE?
%results = cell2table(results,'VariableNames',{'Trial' 'Stimulus' 'Key' 'KeyPress' 'RT' 'Correct'});

% Saving the information to a mat file
% save(['./Results/' expInfo.pID{1} '.mat'],'results');

%% Closing
sca; %aka Screen('CloseAll') % WHAT DOES THIS DO? WHAT IS 'SCREEN'?


function doTraining(window, expInfo)
%  This function handles the training section of the game. It receives as
%  inputs the pointer to the PTB window where we want to make the tutorial
%  and the experimental variables we created at the beginnign of the
%  script.

%  [The tutorial works as follows: first we to present a welcome screen
%  explaining what is the purpose of the game an how to score higher. Afetr
%  thant we are going to show each of the different stimuli images and
%  indicate which arrow key needs to be pressed when presented with the
%  image. We are going to allow users to press only the correct key on the
%  tutorial to make sure they understood which key needs to be pressed. We
%  are going to finish the tutorial by presenting a final screen where we
%  are going to display some text telling the user the game is finished and
%  that they can go to the testing part.]

    % [It is good practice to enclose our code into a 'try/catch'
    % statement. When in a try/catch statement code gets executed only
    % inside the try block. If an error arise then instead of quitting the
    % execution of the script we can 'catch' the error and execute the code
    % to handle the error in the catch block.
    % try/catch is helpful when building experiments with PTB because when
    % an error arises and we haven't closed the PTB window, we then have
    % the possibility to close the PTB window within the catch statement.
    % Without this possibily the script will terminate its execution and
    % depending on the cases it will block your system on the PTB window.
    % In those extreme case we will have to brute kill the PTB window with 
    % ctrl+alt+del on windows or command + period;% command + 0 on Mac]
    try

        % [Now let's start drawning into the screen. As explained in the
        % lectures we never actually draw directly into the screen, but
        % rather we prepare our screen by drawing into the back-buffer.
        % Only when calling the 'Flip' Screen sub-function we make present
        % images on the real screen.] 

        % [Drawing starts from the background to the foreground so the
        % first thing we are going to do is drawing the backgground. 
        % For the tutorial we want to put text on a dark grey background. We can
        % use the sub-function 'FillRect' to draw a rectangle on the
        % screen. The function takes as an input the pointer to the PTB window
        % we want to use for the drawing, takes an RGB color and a optional
        % parameter representing the portion of the window in pixels where
        % to draw the rectancle. Since we are interestd in drawing the
        % rectangle in the entire window this parameter will be empty.]
        Screen('FillRect', window, expInfo.paletteDarkGrey, []);
        
        % [Next, we want to set the font type to be used in the text. We can
        % use the sub-function 'TextFont' which requires the name of the
        % font to be used, the pointer to the window we want to set the 
        % text preferences, a  number indicating the style 
        % (1 for italic, 2 for bold and 3 for italic+bold). 
        % Let's set an Helvetica text with italic and bold enabled for our
        % PTB window.
        Screen('TextFont',window, 'Helvetica',1+2);

        % [Next, we want to set the set the size of the text. We can
        % use the sub-function 'TextSize' which requires the pointer 
        % to the PTB window we want to set the text preferences, a number 
        % indicating the size of the font.]
        Screen('TextSize',window, 80);

        % [Let's create a variable for our title]
        mTextT = ' __Super Mario Matlab__';

        % [Let's start to draw the title. For doing so we can use the
        % PTB function DrawFormattedText or simply DrawText. We prefer the
        % former so to have some more controls on how to di display the
        % text on the window. DrawformattedText requires as in input the
        % the pointer to the PTB window, the text we want to display, the
        % position on the x axis of the screen where we want to draw the
        % text, the position on the y axis where we want to draw the text,
        % the color of the text. It returns the x coordinate on the screen
        % where last character was draw, the y coordinate on the screen 
        % where last character was draw, the rectangular in
        % pixels that enclose the entire text.]

        % [Let's draw the title on the upper center part of the PTB window. 
        % For centering in the x dimension we can use the special word
        % 'center'.
        % For displaying in the upper side of the screen 
        % we are going to use the calculated size of the PTB window and
        % display the text at 20% from the top (remember that in the screen
        % coordinate (0,0) is always top left corner.
        % This has the advantage to be resolution independent. From the
        % function we are going to save the rectangular that encloses the
        % entire text.
        [~, ~, bbox] = DrawFormattedText(window, mTextT, 'center', expInfo.screenYstart + expInfo.screenYpixels * 0.2, expInfo.paletteRed);

        % [As a nice touch we are going to add is a frame for the title. We can
        % use the Screen sub-function 'FrameRect' to draw a frame providing
        % the pointer to the PTB window, a color, the rectangular
        % coordinate of the frame we want to draw, the thickness of the
        % frame border.]
        
        % [Let's draw a red frame around the title text. We are going to use the
        % rectangle enclosing the text we get from the previous function
        % adding some padding to make it slightly bigger.]
        Screen('FrameRect', window, expInfo.paletteRed, [bbox(1:2)-15,bbox(3:4)+15],4); 
        
        % [Next, we are going to write the body of the screen. A message to 
        % welcome the user and the instructions explaining what the game is
        % about. Let's prepare the body text]
        mTextI = ['Help Mario to survive against different enemies! Each enemy can be avoid by using a particular arrow key.\n' ...
            '\n In the next part you will learn the what arrow key to use for each different enemy.'];

        % [We want the body text to be smaller than the title,so we are going to change the text size again]
        Screen('TextSize',window, 50);

        % [Let's write the text at the center of the screen. This time we are going to use an additional parameter
        % indicating the maximum number of characters allowed for each
        % line. Let's set it to 40.
        DrawFormattedText(window, mTextI, 'center', 'center', expInfo.paletteGrey, 40);
        
        % [Finally we are going to ask the participant to press any button to continue]
        mTextC = 'Press any key to continue';
        DrawFormattedText(window, mTextC, 'center', expInfo.screenYpixels * 0.8, [expInfo.paletteGrey, 1]);

        % [As explained in the lectures everytime we are drawing any item
        % using the Screen function what we are actually doing is writing
        % to a back-buffer which is not the actual PTB window. Once we have
        % prepared the back-buffer in order to display it on the PTB window
        % we have to call the Screen sub-function 'Flip' to literally flip
        % the back-buffer into the window (and clear the current
        % back-buffer). Since we have all the elements in the current
        % screen we can call it now. 
        Screen('Flip',window);

        % [We want the user to take any time he needs to read the text, so
        % we are going to wait for him to press any key on the keyboard. We
        % can simply do that by calling the PTB function KbWait. The
        % execution of the code will be stopped at this point until a key
        % press is detected.]
        KbWait;
        % [Once a key is pressed the code will continue its execution to
        % the next instruction. We want to make sure before goint into the
        % next section of the tutorial that the participant has releaset
        % the key he previously pressed. We are going to do that using the
        % PTB function KbReleaseWait. This function will stop the execution
        % after it detects that all the keyboard keys have been released.]
        KbReleaseWait;

        % [Next we are going to clear some of the workspace variables we don t need anymore]
        clear bbox mTextT mTextI mTextC
        
        % [Next, in this tutorial section we are going to show users which
        % arrow key corresponds to each of the enemy. We are going to draw
        % each enemy on the screen using their images and we are going to
        % wait for the user to press the correct key.] 

        % [First we want to set the background with a black color]
        Screen('FillRect', window, expInfo.paletteBlack);

        % [We are going to loop through each of the stimuli we have in our.
        % Let's create a four loop that goes through the images]
        for i = 1:size(expInfo.imagesName,2)
            
            % [Let's prepare a text to be displayed in the upper part of the screen.
            % Previously we have save all the information about the enemies
            % name in the expInfo struct so we are going to use it here.
            % Also we are going to use the KbName function we previously
            % used to get back the name of the key from its code which is
            % stored in the imageKeyPresses array in expInfo.
            mText = ['When ' expInfo.imagesName{i} ' appears you press ' KbName(expInfo.imagesKeyPresses(i))];
            
            % [Setting the text size]
            Screen('TextSize',window, 50);
            
            % [As previously for the title we are going to draw the text in
            % the upper center part of the screen. As before we are going
            % to use relative coordinates by taking a portion of the
            % current height of the window to find a suitable upper position.
            DrawFormattedText(window, mText, 'center', expInfo.screenYstart + expInfo.screenYpixels * 0.2,  expInfo.paletteGrey);            
            
            % [NExt,we are going to draw the images. Before doing that we
            % need to load them as a file. We previously saved the lcoation
            % of each picture into our expINfo struct. Let's get a single
            % element of that array and let's use the matlab function
            % 'imread' to load the image into the workspace.]
            currImage = imread(expInfo.images{i});

            % [Pictures comes with different sizes and resolutions. However
            % we want to present them in a similar portion of the screen,
            % so we are going to scale the images manually. We can use it
            % by calling the matlab function 'imresize' which takes as an
            % input the information of an image loaded into the workspace
            % and a number indicating the scaling factor. Let's do that by
            % using the scaling values we saved previously in expInfo.] 
            currImage = imresize(currImage, expInfo.imagesScale(i));

            % [We want also to flip some of the images horizontally. We can
            % do it by using the matlab 'flip' command. We are going to do
            % that according to the variable we previously saved in
            % expInfo.
            if expInfo.imagesFlip(i); currImage = flip(currImage,2); end

            % [Next we want to prepare the images into the PTB window keeping
            % in mind everytime we draw something on the screen we are actually
            % drawing to the back-buffer. In PTB before drawing to the
            % screen an image we need an holder for that image. In this
            % case the holder is a texture. To create a texture we can use
            % the Sreen sub-function MakeTexture that receive as input the
            % pointer to the PTB window and the image we want to use for
            % the texure.]
            imageTexture = Screen('MakeTexture', window, currImage);

            % [We can now finally draw the texture into the back buffer by
            % using the DrawTexture sub-function.
            % For other optional parameters type Screen DrawTexture? in the
            % command window
            Screen('DrawTexture', window, imageTexture);

            % [We are now ready to present the screen to the user. This
            % requires a flip of the PTB windoww.]
            Screen('Flip',window);
            
            % [In the next section we are going to wait for the correct key
            % press from the user. The key to be pressed is the one that
            % has been prompted in the previous section.]

            % [Let's create a variable that will help usunderstand when to
            % exit the loop.]
            isCorrectKey = 0;

            while ~isCorrectKey

                % [We are going to stop the exectuon of the script until
                % the user presses a key on the keyboard. For this we can
                % use the PTB function KbWait that waits for any key
                % press.]
                KbWait;

                % [After a key is being pressed we can now ask what kind of
                % key was that and what kind of the movement was detected
                % e.g. a release or a press. The PTB function kbCheck can
                % be used for checking this information. The function
                % returns 1 if any key, including modifiers is down, 0 otherwise, 
                % retturn the time in seconds since the beginning of the script and 
                % an array with all of the key detected at this
                % point.]
                [keyIsDown, ~, keyCode] = KbCheck;
                
                % [At this point we are expecting only one key press. Since
                % keyCode is a 256-element array we are going to find the
                % only 1 in the array. That index is the keycode pressed at
                % this time. So if kbCheck returned a key press and that
                % key presses is the actual key prompted to the user we are
                % going to present instructions for the next enemy.]
                keyCode = find(keyCode, 1);
                if keyIsDown
                    if(keyCode == expInfo.imagesKeyPresses(i))
                        isCorrectKey = 1;                    
                    end
                    % [Stopping the executuon until all of the keys are
                    % released.]
                    KbReleaseWait;
                end
            end

        end

        clear currImage isCorrectKey keyIsDown keyCode i

        % [We have now presented all of the stimuli once with the
        % corresponding key presses. We can now tell the user that the
        % tutorial is finished and now we are going to test the user on the
        % knowledge they just acquired. The following screen use all the
        % functions that have already been presented so at this point you
        % should be familiar with those.]

        mText = ['Good job! Now you will go through ' expInfo.nImagesRepeat * size(expInfo.imagesName,2) ' to help Mario.\n \n Good luck!\n \n Press any key to continue'];
        DrawFormattedText(window, mText, 'center', 'center',  expInfo.paletteGrey);        
        
        Screen('Flip',window);
        
        % [Let's wait for any key press]
        KbWait;
        KbReleaseWait;
        
        % [Let's just clear the end tutorial screen]
        Screen('FillRect', window, expInfo.paletteBlack);
        Screen('Flip',window);

        WaitSecs(0.5);

    catch ME

        % [The catch block is exectued only when an error is raised in the
        % try block. This is a good opportunity to clear the PTB window
        % that otherwise would be stucked on our monitors (unless closed
        % forcefully).
        % We are going to call the Screen sub-function ('CloseAll') with
        % the PTB shorthand sca to clear the window.]
        sca;

        % [If we disable the cursor for this game, we can enable it again.]
        ShowCursor;
        % [We are interested in looking at the problem that happened at
        % this point so we are literally going to rethrow the error so that
        % it will appear in the Matlab command window and stop the
        % execution of the script
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
        
        results(nTrial,:) = {nTrial expInfo.imagesName(trialStructure(nTrial)) KbName(expInfo.imagesKeyPresses(trialStructure(nTrial))) '' 0 0};

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
            if (respKeyCode ~= 0); results{nTrial,4} = KbName(respKeyCode); else; results{nTrial,4} = ''; end
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