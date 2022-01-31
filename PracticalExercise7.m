%% This script accompanies the "Psychophysics toolbox (PTB) - a gentle
%  introduction" lectures from the UCL Institute of Cognitive Neuroscience
%  Matlab Course. All course details and content - including pre-recorded
%  lectures, slides, practical exercises and solutions - can be found on
%  the course website: https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) uceeaca@ucl.ac.uk
%
%  In this example we are going to create a simple game which will show all
%  the basic functionality of the Psychophysics (PTB) toolbox for Matlab.
%  In this game, we will help Mario avoid different kind of enemies
%  (presented as images on the screen). The game will be divided into two
%  parts: a tutorial and testing phase. During the tutorial phase, we will
%  show which key needs to be pressed for each image presentation. During
%  the testing phase enemies will be presented in a random order and the
%  participant will have a fixed amount of time to press the correct key.
%  We will record the key pressed and reaction time in each trial

%% Initialization
%  First, before we start running our PTB script, we want to make sure the
%  workspace is empty and that all previous figure windows have been
%  closed, to prevent anything interfering with our task
close all; clear;

%  Then we want to obtain a participant ID, which we will use to save the
%  data for this session. We can create a dialog box to do this, using the
%  built in matlab 'inputdlg' function. This function requires the
%  following inputs: a prompt to be displayed into the dialog box, a text
%  that will be put onto the window bar of the dialog box, a number
%  specifying how many lines are required for the answer, a default answer
%  to be diplayed in the dialog box upon presentation. The function returns
%  the information the participant input.
%  Before calling the function let' s prepare the variables for the
%  function. You could put the variables directly into the function but in
%  this case we are doing it to make the execution clearer to the reader

prompt      = {'Enter participant ID:'};
dlgtitle   	= 'Participant info';
%  This variable defines the dimension of the input dialog. The first
%  number is the hight of the input field and the second one is the length
%  of the input field.
dims        = [1 50]; 
definput    = {'1'};

%  Let's open the dialog box here. The execution of the matlab script will
%  stopped until the dialog box is closed.]
pID         = inputdlg(prompt,dlgtitle,dims,definput);

clear prompt dlgtitle definput dims
%% PTB initialization
%
%  Next, we need to initialise Psychtoolbox. This means starting the
%  toolbox, initialising the sound, detecting how many screens are
%  available, and deciding which screen we will use to display our task.
%  First, let's initialise PTB. To do this, we use the 'PsychDefaultSetup'
%  function. This function only takes one input - a number 0, 1 or 2. Each
%  value specifies a different type of setup. Don't worry about the details
%  for now - you will almost always use a value of 2. Before doing that, we
%  also need to ask PTB to avoid carrying out any sync test of our monitor.
%  This sync test is performed automatically by PTB to make sure the screen
%  'flip' (i.e. display command) is in line with the screen refresh rate
%  (measured in Hz). Nowadays, it is not really necessary as refresh rates
%  are generally very high for modern monitors, so we are going to prevent
%  PTB performing this initial check as it could also generate irrelevant
%  errors.
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

% Using audios in your experiment requires a separate initialization. The
% PTB 'InitializePsychSound' perform this. This step is necessary only if
% you are planning to play any sound throughout your exeperimen otherwise
% you can skip it
InitializePsychSound;

%  In most experimental setups you will have more than one screen. We can
%  use the sub-function 'Screens' of the 'Screen' PTB function to detect
%  how many screens are present in the current system. The function returns
%  a numerical array where each entry represents a different available
%  monitor. Usually those entries should follow the numbering you find in
%  Windows Display Settings (and equivalent for Mac)
screens         = Screen('Screens');

%  If you have a two screen setup I usually set the 'external' one, which
%  presents the task to the participant, as number 2 (with more than two
%  monitors I always set the external screen as the highest number in the
%  Windows display settings). In this way, no matter what the experimental
%  setup is, the script will always select the appropriate external screen
%  by choosing the highest number in the array returned by the previous
%  function. Let's get that number by using the Matlab function 'max',
%  which returns the maximum value inside an array
screenNumber    = max(screens);

%% Preparing experiment variables
%
%  Sometimes you will have to load external files to present stimuli into
%  your experiment, whether these are images or audio. It is good practice
%  to keep these files in a separate folder, but if doing so, we have to
%  make sure that folder has been added to the Matlab path, otherwise we
%  will not able to load them. So, next, let's add the folder called
%  'Assets' within our current folder to the Matlab path using the function
%  'addpath', which requires as an input the path to the folder we would
%  like to add. We use the special character './' to indicate that the file
%  path should start from the current folder
addpath('./Assets');

%  It is also good practice to save results from the task in a different
%  folder, so we are also going to add another folder called 'Results' to
%  the Matlab path. Don't worry about this for now - it will be used in the
%  second part of this practical exercise, following the second PTB lecture
addpath('./Results');

%  Next, it's always good practice to assign all constant values at the top
%  of your script, so they can be changed easily without having to go
%  through all of the code. It's also useful to store these variable in a
%  single structure in order to keep the workspace as neat as possible, but
%  also so that you can easily pass all of these variables to other
%  functions, as a single input. In this section, we will prepare that
%  structure. What information you need to store will depend on the kind of
%  stimuli you are using in a task and the kind of variables you want to be
%  flexible for the specific experiment you are running (e.g. number of
%  trials, trial duration, etc.) In any case, let's use a structure called
%  expInfo to store all of this information
expInfo                     = struct;

%  Let's start by saving the participant information
expInfo.pID                 = pID;
clear pID

%  In this task there will be a fixed number of different stimuli.
%  We also want to let the experimenter decide how many times each stimulus
%  will be presented. For this reason let's create an experimental variable
%  to store this information
expInfo.nImagesRepeat       = 2;

%  The user will have a fixed amount of time for reacting to an enemy
%  image. Let's make this time an experimental variable. The duration of
%  each stimuli is in secods.
expInfo.trialDuration       = 2;

%  Next, we need to prepare some information about the images themselves.
%  Specifically, we are going to create a variable that stores the path to
%  each image file, the name of the corresponding enemy shown in each image
%  file, and the arrow key that should be pressed when reacting to that
%  enemy. Notice how the indices of these variables relate to each other
%  (e.g. the first entry in each corresponds to details of the enemy called
%  Goomba, which is presented as an image in the assets folder called
%  Goomba.png and can avoided by Mario using the up arrow. In this way it
%  will be easier to check, when presenting each image, which key press
%  we are expecting

%  Let's create a variable with the names of the images in a cell array
expInfo.imagesName          = {'Goomba','Lakitu','Bill','Super Hammer'};

%  Let's create a variable with the path to each file in a cell array
expInfo.images              = {'./Assets/Goomba.png','./Assets/Lakitu.png','./Assets/Bill.png','./Assets/SuperHammer.png'};

%  Let's create a variable containg an array of integers that represent
%  specific keys on the keyboard. Each key is identified by a unique
%  integer. To do this, we are going to use the PTB function 'KbName',
%  which stores the mapping between integer identifiers and key names.
%  Tip: enter KbName('KeyNames') into the command window to print out the
%  full mapping between key names and numerical codes in PTB

%  We want the participant to just use arrow keys to react to the images.
%  We have four different images and four different arrow keys
expInfo.imagesKeyPresses    = [KbName('UpArrow') KbName('RightArrow') KbName('DownArrow') KbName('LeftArrow')];

%  Sometimes stimuli will have different pixel resolutions. Since we want
%  them to occupy the same portion of the screen we are going to scale them
%  manually before presenting them. Let's save this information here as a
%  number representing how much an image should be scaled in proportion to
%  its real size (e.g. 0.5 means halving the size of the image)
expInfo.imagesScale         = [0.3 0.9 0.2 0.5];

%  Sometimes we would also like to present stimuli as a flipped / mirrored
%  image. In this example I would like Goomba to face leftward, instead of
%  rightward (as in the raw image file), so I am going to prepare a simple
%  array that tells me whenever I need to flip an image (using 1) or not
%  (using 0)
expInfo.imagesFlip          = [1 1 0 1];

%  After the end of a trial, we are going to provide an auditory feedback
%  to the participant which will depend on the use of the correct arrow key or not. 
% Let's create a variable holding the path to the files.
expInfo.sounds              = {'./Assets/neg_feedback.wav','./Assets/pos_feedback.wav'};

%  During the game some of the elements that are going to be drawn on the
%  screen will have a specific color. For example, PTB gives us the
%  possibility to draw text colored in different way, so let's create a
%  palette of colours that we can use throughout the task later on. Each
%  color is represented as a three digit RGB (e.g. red, green, blue) array.
%  Each of these values usually occupies the range [0 - 255] but PTB
%  normalizes these values into the [0 - 1] range. For this reason we will
%  use values that are fractions of 255. Sometimes you can also specify an
%  RGBA color, where A stands for alpha and represents the transparency of
%  that color, but we won't do that here (although you may see it
%  elsewhere)

%  During the tutorial the main text will be displayed in light grey
expInfo.paletteGrey         = [194/255 194/255 235/255];

%  The title of the task will be displayed in red
expInfo.paletteRed          = [255/255 68/255 59/255];

%  Dark grey will be the background colour chosen for the tutorial text
expInfo.paletteDarkGrey     = [109/255 93/255 95/255];

%  Black will be the background color of the PTB window
expInfo.paletteBlack        = [0 0 0];

%  Before each of the stimuli we are going to propmt the attention of the
%  participant by using a fixation cross placed at the centre of the screen.
%  In this example the fixation cross will be directly draw into the screen
%  as two line segements.
%  In order to make the drawing more flexible we want to be able to easily
%  change the lenght of the segments, thickness and color. Let's create some
%  variables associated to those properties.

expInfo.fixCrossDimPix      = 50;
expInfo.fixLineWidthPix     = 10;
expInfo.paletteWhite        = [1 1 1];

%  We would like to modify the duration for which the fixation cross will
%  be on the screen. For this purpose let's create a variable that gives us
%  the duration in seconds
expInfo.fixCrossDuration    = 1;


%% Initializing PTB window
%  We have now set all the experimental variables that we are going to use
%  in the game, so it is time to start using PTB to open a window where we
%  can present our game to the participant. In this section we are going to
%  open a full window into the second screen. We are going to use the
%  function PsychImaging with the subfunction 'OpenWindow', providing as
%  inputs: the index of the screen where we wish to open the window, a
%  background color for our window, and an optional parameter that will
%  represent the start and end position (x and y pixel coordinates) of the
%  window within the screen. Since we want to draw the window at full
%  screen mode that parameter will be empty (e.g. []). The PsychImaging
%  function returns a pointer to the window we just opened and the
%  dimension in pixels of the opened window. The window pointer will be
%  used later on to direct any drawing functions towards the correct window
[window, windowRect]        = PsychImaging('OpenWindow', screenNumber, expInfo.paletteBlack, []);

%  Now, using the 'windowRect' output, we can calculate the size of the
%  window in pixels along the x and y axes. This information will be used
%  later to draw shapes/texts offset according to that specific window
%  dimension. Drawing objects with coordinates relative to the window size
%  allows us to be more flexible when running the task with different
%  screen resolutions
expInfo.screenXpixels       = windowRect(3);
expInfo.screenYpixels       = windowRect(4);

%  We also want to calculate the center of the window in pixel coordinates.
%  This will be helpful when drawing the fixation cross, for example. We
%  can use the PTB function RectCenter to extract the center pixel
%  coordinates of the window by providing the rectangular dimension of the
%  window from above
[expInfo.Xcenter, expInfo.Ycenter] = RectCenter(windowRect);

%  When drawing objects into a PTB window we need to specify how the screen
%  behaves when two colors overlap and have been provided with an alpha
%  (i.e. transparency) value of <1. Let's use a standard blending function
%  - don't worry too much about this, you can almost always set it as
%  follows when drawing shapes in your task
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%% Training
%  Now that our window is opened, we can start developing the actual game.
%  We are going to start with the tutorial. Organizing the code at a high
%  level using sub-functions is generally preferable. In this case, I have
%  opted to create a sub-function (which is coded below) to perform the
%  training phase. This function will receive, as inputs, the window
%  pointer we want to interact with and the experimental variables we have
%  organised above. It will not produce any output (except on screen)
%doTraining(window, expInfo);

%% Test 
%  After completing the tutorial we can test the participant and collect
%  some results from the trials. We are interested in knowing whether the
%  participant has been able to press the correct key, but also how quick
%  has been to react to the stimuli. As for the training phase we are going
%  to create a separate function for this part. The function takes as input
%  the window pointer we want to interact with and the experimental
%  variables we have organised above. It will return a cell array
%  containing all the data collected during the trials.
results = doTest(window, expInfo);

%  Now that we have collected all of the data we are interested in it can
%  be a good practice saving it in a format that can be easily readable
%  (sometimes it can happen that you will have to go through your data
%  after months). I prefer saving data as a table with column names that
%  are related to the type of data collected. The matlab function
%  cell2table can be used to trasnform a cell array into a table. The
%  function requires as inputs the cell data you want transform and
%  optionally a cell array indicating the name of each column.
results = cell2table(results,'VariableNames',{'Trial' 'Stimulus' 'Key' 'KeyPress' 'RT' 'Correct'});

%  We can finally save our data in the project folder so we can access it a
%  later time. Data can be saved in Matlab special typefile with extension
%  '.mat'. The matlab function 'save' requires the path of the file we
%  are going to create and the name of the workspace variable we
%  want to save into the mat file. Each participant will have its own mat
%  file containing the results of the game. We can use the participant id
%  as the name (hopefully it will be unique).
save(['./Results/' expInfo.pID{1} '.mat'],'results');

%% Closing
%  After the function above has finished executing, we have completed the
%  game. We can now safely close all of the opened PTB windows, and then
%  the script is finished. To do so we can call the Screen sub-function
%  'CloseAll', or its alias 'sca'
sca; % equivalent to Screen('CloseAll')


%% First sub-function: Training phase
function doTraining(window, expInfo)
%  This function handles the training phase of the game. It receives, as
%  inputs, the pointer to the PTB window where we want to display the
%  tutorial and the experimental variables we created at the beginning of
%  this script

%  The tutorial works as follows: First we present a welcome screen
%  explaining the instructions of the game. Second, we show each of the
%  different images and indicate which arrow key needs to be pressed when
%  presented with that image. We are going to allow participants to press
%  only the correct key on the tutorial to make sure they understand this.
%  Finally, we finish the tutorial by presenting some text telling the
%  participant the tutorial phase is finished and that they can go to the
%  testing phase

%  It is good practice to enclose our main task code inside a 'try/catch'
%  statement. Within a try/catch statement, only the code inside the try
%  block gets executed, unless an error arises within that code. In that
%  case, rather than aborting execution of the script, Matlab moves to the
%  code following the 'catch' command, and executes that instead. This
%  means we can add some commands there which can handle the effects of the
%  error that has arisen. Try/catch is helpful when building experiments
%  with PTB because when an error arises and we haven't closed the PTB
%  window, it can be difficult to get back to the Matlab desktop. However,
%  by adding code after the 'catch' statement that closes the PTB window,
%  we can deal with this issue. Without this, the script could terminate -
%  when an error arises, during debugging - and in some cases, block the
%  entire system with an unresponsive PTB window. We would then have to
%  'brute kill' the PTB window with ctrl+alt+del on windows or command +
%  period or command + 0 on Mac
try
    
    % Now let's start drawing onto the screen. Although, as explained in
    % the lectures, we never actually draw directly onto the screen, but
    % rather prepare the entire screen by drawing successive items into the
    % back-buffer before displaying the entire buffer in one go, by calling
    % the 'Flip' Screen sub-function
    
    % Drawing starts from the background and moves into the foreground, so
    % the first thing we are going to do is draw the backgground. For the
    % tutorial we want to put text on a dark grey background. We can use
    % the sub-function 'FillRect' to draw a rectangle on the screen. The
    % function takes, as inputs, the pointer to the PTB window we want to
    % use for the drawing, an RGB color for the filled rectangle, and an
    % optional parameter representing the portion of the window in pixels
    % where to draw the rectangle. Since we are interested in drawing the
    % rectangle in the entire window this parameter will be left empty
    % (e.g. [])
    Screen('FillRect', window, expInfo.paletteDarkGrey, []);
    
    % Next, we will set the font type to be used for the text. We can use
    % the sub-function 'TextFont' which requires, as inputs, the pointer to
    % the PTB window for which we want to set the text preferences, the
    % name of the font to be used, and a number indicating the style (1 for
    % italic, 2 for bold and 3 for italic + bold). Let's set a Helvetica 
    % font in italic and bold for our PTB window
    Screen('TextFont',window, 'Helvetica',3);
    
    % Next, we will set the set the size of the text. We can use the
    % sub-function 'TextSize' which requires, as inputs, the pointer to the
    % PTB window for which we want to set the text preferences, and a
    % number indicating the size of the font
    Screen('TextSize',window, 80);
    
    % Next, let's create a character array variable in which to store our
    % task title
    mTextT = ' __Super Mario Matlab__';
    
    % Now we can start drawing the title. To do so, we can use the PTB
    % functions DrawFormattedText or DrawText. I prefer the former, as it
    % allows greater control over how the text is displayed in the PTB
    % window. DrawformattedText requires, as inputs, a pointer to the PTB
    % window, the text we want to display, screen position on the x axis
    % where we want to draw the text, screen position on the y axis where
    % we want to draw the text, and the color of the text specified as a 3
    % digit RGB array. This function returns, as outputs, the x and y
    % coordinates on the screen where the last text character was drawn,
    % and the coordinates of a rectangular 'bounding box' (in pixels) that
    % encloses the entire text
    
    % In this example, we wish to draw the title on the upper center part
    % of the PTB window. To center the text in the x dimension we can use
    % the text input 'center'. To place the text on the the upper side of
    % the screen we can use the calculated size of the PTB window and
    % display the text 20% of the way down the screen from the top -
    % remembering that, in screen coordinates, (0,0) always corresponds to
    % the top left corner. This has the advantage of being independent of
    % screen resolution. We are also going to store the rectangular
    % bounding box output 'bbox' for use later in the script
    [~, ~, bbox] = DrawFormattedText(window, mTextT, 'center', expInfo.screenYpixels * 0.2, expInfo.paletteRed);
    
    % Next, for aesthetic reasons, we are going to add a frame around the
    % title. We can use the Screen sub-function 'FrameRect' to draw a frame
    % providing, as inputs, a pointer to the PTB window, a three digit RGB
    % color array, the rectangular coordinates of the frame we want to
    % draw, and the thickness of the frame border
    
    % In this example, we will draw a red frame around the title text. We
    % are going to use the rectangular bounding box generated by the
    % previous function, adding 15 pixels of padding in each direction to
    % make it slightly bigger
    Screen('FrameRect', window, expInfo.paletteRed, [bbox(1:2)-15,bbox(3:4)+15],4);
    
    % Next, we are going to write the main body of text on the screen. This
    % includes a message to welcome the participant and the instructions
    % explaining how the game works. Let's prepare that text here. Note
    % that the special command '\n' is used to indicate a new line of text
    mTextI = ['Help Mario to survive against different enemies! Each enemy can be avoid by using a particular arrow key.\n' ...
        '\n In the next part you will learn the what arrow key to use for each different enemy.'];
    
    % We want the main body of text to be smaller than the title, so we are
    % now going to change the text size again
    Screen('TextSize',window, 50);
    
    % Again, let's write the text in the center of the screen. This time we
    % are going to provide an additional input (after the colour) that
    % indicates the maximum number of characters allowed on each line. In
    % this case, we'll set that to 40
    DrawFormattedText(window, mTextI, 'center', 'center', expInfo.paletteGrey, 40);
    
    % Finally, we are going to ask the participant to press any button
    % to continue, using the same text format but a different y axis
    % position on the screen
    mTextC = 'Press any key to continue';
    DrawFormattedText(window, mTextC, 'center', expInfo.screenYpixels * 0.8, expInfo.paletteGrey);
    
    % Now that we have prepared all of the visual content we want on the
    % screen in the back-buffer, we can call the Screen sub-function 'Flip'
    % in order to display it in the PTB window (and clear the current
    % back-buffer)
    Screen('Flip',window);
    
    % Now, we want the participant to take their time to read this text, so
    % we are going to wait for any key press before we continue, by calling
    % the PTB function KbWait. The execution of the code will be stopped at
    % this point until a key press is detected
    KbWait;
    
    % Once a key is pressed the code will continue its execution to the
    % next instruction. Before proceeding, however, we want to make sure
    % that the participant has also released the key that was pressed. We
    % csan do this using the PTB function KbReleaseWait. The execution of
    % the code will be stopped at this point until a key release is
    % detected
    KbReleaseWait;
    
    % We can now clear some of the workspace variables we no longer need
    clear bbox mTextT mTextI mTextC
    
    % Next, we are going to show participants which arrow key should be
    % pressed when they are presented with each enemy. To do so, we are
    % going to draw each enemy on the screen using their image files and
    % then wait for the participant to press the correct key
    
    % First we want to set the background to be black
    Screen('FillRect', window, expInfo.paletteBlack);
    
    % We are now going to loop through each of the image stimuli
    for i = 1:size(expInfo.imagesName,2)
        
        % Then, for each image, we can prepare the text to be displayed in
        % the upper part of the screen. Using the information stored in the
        % expInfo structure, this will include the enemies name and the
        % arrow key that should be pressed when that enemy appears, using
        % the KbName function to get the name of that key back from the
        % numerical code stored in the expInfo.imageKeyPresses array
        mText = ['When ' expInfo.imagesName{i} ' appears you press ' KbName(expInfo.imagesKeyPresses(i))];
        
        % Set the text size
        Screen('TextSize',window, 50);
        
        % Then, as previously for the title, we are going to draw the text
        % in the upper center part of the screen using relative coordinates
        % by taking a proportion of the full height of the window to find a
        % suitable upper position
        DrawFormattedText(window, mText, 'center', expInfo.screenYpixels * 0.2,  expInfo.paletteGrey);
        
        % Next, we are going to draw the image itself. Before doing that we
        % need to load the corresponding image file. We previously stored
        % the location of each image file in the expInfo struct, so we'll
        % take a single entry from that array and use the Matlab function
        % 'imread' to load that image into the workspace
        currImage = imread(expInfo.images{i});
        
        % Image files come in many different sizes and resolutions.
        % However, we want to present them in a similar size on the screen,
        % so we are going to scale the images manually. We can do this by
        % calling the Matlab function 'imresize' which takes as an input
        % the image loaded into the workspace and a number indicating the
        % scaling factor. Let's do that by using the scaling values we
        % stored previously in expInfo
        currImage = imresize(currImage, expInfo.imagesScale(i));
        
        % We also want to flip some - but not all - of the images
        % horizontally. So we will now write an 'if' statement which checks
        % the corresponding entry in the expInfo.imagesFlip array we
        % created earlier, and then we can use the Matlab 'flip' command,
        % if required. This function requires two inputs - the image loaded
        % into the workspace, and the dimension along which we wish to flip
        % that image (1 being vertically, and 2 being horizontally)
        if expInfo.imagesFlip(i)
            currImage = flip(currImage,2); 
        end
        
        % Next, we want to add the scaled and flipped image into the
        % back-buffer, but before we can do that, we need to generate a
        % holder called a 'texture' for that image. To create a texture we
        % can use the Screen sub-function MakeTexture that receives, as
        % inputs, the pointer to the PTB window and the image we want to
        % use for that texure
        imageTexture = Screen('MakeTexture', window, currImage);
        
        % Finally, we can now draw the texture into the back buffer by
        % using the DrawTexture sub-function. For other optional
        % parameters type Screen DrawTexture? in the command window
        Screen('DrawTexture', window, imageTexture);
        
        % We are then ready to display this screen to the participant using
        % the Screen sub-function Flip
        Screen('Flip',window);
        
        % In the next section we are going to wait for the correct key
        % press from the participant. To achieve this, let's first create a
        % variable that will log when the correct key has been pressed
        isCorrectKey = 0;
        
        % We will now use a 'while' loop to continue waiting for as long as
        % the correct key has not been pressed
        while ~isCorrectKey
            
            % We are going to pause execution of the script until the
            % participant presses any key on the keyboard. For this we can
            % use the PTB function KbWait
            KbWait;
            
            % After any key has been pressed, we can then check what key it
            % was and whether it was a key press or release using the PTB
            % function kbCheck. The function returns a 1 if any key,
            % including modifiers, is pressed down, and 0 otherwise, as
            % well as the time in seconds since the beginning of the script
            % that the key was pressed and an array with all of the key
            % presses detected at this point
            [keyIsDown, ~, keyCode] = KbCheck;
            
            % We are only expecting one key press, so we can look in the
            % 256-element keyCode array to find the only value of 1 - that
            % indicates the key that was just pressed. So if kbCheck
            % returned a key press (i.e. if keyIsDown == 1) and that key
            % press is the correct key prompted to the participant, then we
            % can change the value of our isCorrectKey variable so that the
            % while loop is terminated - otherwise, the while loop will
            % continue, waiting for another key press
            keyCode = find(keyCode, 1);
            if keyIsDown == 1
                if(keyCode == expInfo.imagesKeyPresses(i))
                    isCorrectKey = 1;
                end
                
                % Also pause execution of the script until all keys are
                % released
                KbReleaseWait;
            end
        end
        
    end
    
    % We can now clear some of the redundant variables created above
    clear currImage isCorrectKey keyIsDown keyCode i
    
    % We have now presented all of the stimuli once, and waited for the
    % participant to make the corresponding correct key press. Hence, we
    % can tell the participant that the tutorial is finished and that we
    % will shortly proceed to the testing phase, using all the same
    % commands listed above to prepare and display this text
    
    % First, let's prepare the text
    mText = ['Good job! Now you will go through ' int2str(expInfo.nImagesRepeat * size(expInfo.imagesName,2)) ' trials to help Mario.\n \n Good luck!\n \n Press any key to continue'];
    DrawFormattedText(window, mText, 'center', 'center',  expInfo.paletteGrey);
    
    % Then, let's display that text
    Screen('Flip',window);
    
    % Then, let's wait for any key to be pressed and released
    KbWait;
    KbReleaseWait;
    
    % Finally, let's display a blank screen and wait 500ms before exiting
    % the function
    Screen('FillRect', window, expInfo.paletteBlack);
    Screen('Flip',window);    
    WaitSecs(0.5);
    
catch ME
    % This catch block is executed only if an error arises in the try block
    % above. This is a good opportunity to close the PTB window that would
    % otherwise remain stuck on our monitor and need to be closed
    % forcefully
    
    % We are going to call the Screen sub-function ('CloseAll') with
    % the PTB shorthand sca to close the window
    sca;
    
    % In case we have disabled the cursor for this game, we should enable
    % it again
    ShowCursor;
    
    % Finally, we may be interested in seeing the details of the error that
    % arose above, so we can 'rethrow' that error (i.e. display it in the
    % command window) before we exit the function
    rethrow(ME);
    
end

end

%% Second sub-function: Testing phase
function results = doTest(window, expInfo)

    % Before presenting the very first trial, let's prepare some variables.
    % Previously we have set a constant number specifing the number of
    % times each image should be presented to the participant. Since we
    % have four images we want to create an array with the indices of those
    % images (1..4) and repeat them by the number of times each picture
    % needs to be displayed. Let's create these array by using the matlab
    % function 'repmat' that receives as an input the array we want to
    % duplicate and two numbers specifying the number of array copies in
    % the row and column
    trialStructure = repmat(1:size(expInfo.imagesName,2),1,expInfo.nImagesRepeat);

    % Now that we have our indices it's important to shuffle the indices so
    % the participants will not be able to predict the next trial.
    % PTB APIs contains a shuffle function that we can use for this
    % purpose.
    trialStructure = Shuffle(trialStructure);
    % Keep in mind shuffling permutations is better then generating a
    % random array where each element is the index number of the image. The
    % reason is simply because we want to have control over the number of
    % presentations for each stimuli. A solution like the following one
    % could be wrong
    % totalTrials = 8; randi([1 size(expInfo.imagesName,2)],1,totalTrials);
    
    % Whenever you can, it a good practice to preallocate the variables you
    % are going to use in for loop. Let's preallocate our cell array
    % results. We know that this variable will have a number of rows equal
    % to the total number of trials and each of the column will be one
    % variable we are interesting to save from the participant. In this
    % case we are going to save the trial number, the name of the enemy
    % image for that trial, the name of the correct key press, the name of
    % the key the participants responded (if any), the time when the
    % participants key press has been detected, a logical value indicating
    % if the trial was correct or not.
    results = cell(size(trialStructure,2),6);
    
    % We are going to loop through each of the trials for presenting them
    % to the participant
    for nTrial = 1:size(trialStructure,2)
        
        % Let's preallocate a results row with the information we know
        % already relative to the current trial.
        results(nTrial,:) = {nTrial expInfo.imagesName(trialStructure(nTrial)) KbName(expInfo.imagesKeyPresses(trialStructure(nTrial))) '' 0 0};

        % As we did in the tutorial phase we are going first to load the
        % current trial image into the workspace. We have saved previously
        % the paths to our images in expInfo struct so we are going to
        % access that using the index contained in the trialStructure we
        % previously created.
        currImage = imread(expInfo.images{trialStructure(nTrial)});
        % We scale the image
        currImage = imresize(currImage, expInfo.imagesScale(trialStructure(nTrial)));
        % We flip them horizontally
        if expInfo.imagesFlip(trialStructure(nTrial))
            currImage = flip(currImage,2); 
        end

        % PTB do not work with images variables directly. We need to create
        % a texture for drawing it on the back-buffer. Let's create the
        % texture now.
        imageTexture = Screen('MakeTexture', window, currImage);

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

        % We can now start the real trial. Before prompting any image we
        % would like to draw the attantion to the participant. We can do it
        % by displaying a fixation cross. Since the fixation cross will be
        % a separate screen displayed on the PTB window, it s useful to
        % create a specific function for drawing it. That could be useful
        % if for instance your experiment is divided in two different
        % testing phases (you can avoid duplicating the code). Let's create
        % here a function to draw the fixation cross on the screen.
        doFixationCross(window,expInfo);

        % After the fixation cross, we are ready to present the stimulus
        % and collect responses from the participant. In this case we are
        % going to collect only the first key the participant press and
        % discard all of the rest
        try
    
            % We are preparing some variables that will be saved in the
            % results. We are define those variables here so that if a
            % participant gives a null response we will have some default
            % values when saving those variables
            reactTime = 0;
            respKeyCode = 0;

            % We are going to use a logical value that will be
            % help us traking whether a key is being pressed after image
            % presentation (1) or not (0). We will use this variable to
            % discard all following key presses.
            readResponse = 0;

            % It s not time to show our stimulus. Let's then draw our
            % texture to the back-buffer.
            Screen('DrawTexture', window, imageTexture);
    
            % We are now ready to flip the back-buffer and show the screen
            % on the PTB window. This time we are also going the function
            % return which is the time, since start of script execution,
            % when the flip has been completed
            startT = Screen('Flip', window);
            
            % After flipping the screen we are ready to wait for the
            % duration of the image on the screen while waiting for any
            % keyboad press. 
            % A way here could be using the function KbWait and a preoposed
            % solution is below. In KbWait can two optional parameters can
            % be set inidcating the kind of event the function is going to
            % wait (0 for press) and the duration for how long the function
            % is going to wait for an input. The function returns the time
            % when the kbWait function returns and a 256 logical array
            % containing the 1 if a key is being pressed otherwise 0. This
            % method have the limitation that reading the keyboard happens
            % at a fixed time (aournd 5 ms). This method is not preferred
            % because at our best we would like to check the keyboard
            % status as often as we can, so a proposed solution is below

            % [respT, respKeyCode, ~] = KbWait([],0, startT + expInfo.trialDuration);
            % reactTime = respT - startT;
            % if(reactTime < expInfo.trialDuration); WaitSecs(expInfo.trialDuration - reactTime);
            % end

            % Start of the proposed solution. We are going to loop until
            % the duration of the image has not expired by using a current
            % time (currT) which will be updated to the current time at
            % the end of each loop
            currT = startT;

            % We loop until the difference betweent the time now and the
            % time when we flipped the screen is less than the duration of
            % the trial
            while(currT - startT < expInfo.trialDuration)
                
                % To query the keyboard we are going to use the PTB
                % function KbCheck
                [keyIsDown, secs, keyCode, ~] = KbCheck;
                % Let s find if there any one (indicating a key with an
                % event) in the array.
                keyCode = find(keyCode, 1);
                
                % We can now check if kbCheck detected any press event by
                % checking if keyIsDown is equal to one. At the same time
                % we are going to ask if we already registered a key press
                % for this trial by reading readResponse variable
                if(keyIsDown && ~readResponse)

                    % Reaction time will then be the difference between the
                    % time returned from kbCheck and the time when we
                    % flipped our screen
                    reactTime = secs - startT;

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
            
            % After we have completed this trial we can safely clean the
            % screen by setting a black background
            Screen('FillRect', window, [0 0 0]);
            Screen('Flip',window);

            % Finally we can set trial result depending on the user actually
            % pressed a key during the trial
            if (respKeyCode ~= 0)
                results{nTrial,4} = KbName(respKeyCode); 
            else
                results{nTrial,4} = '';
            end

            % Saving reaction time
            results{nTrial,5} = reactTime;

            % Checkign whether the key pressed was the correct one and
            % saving the query to the results
            if(respKeyCode == expInfo.imagesKeyPresses(trialStructure(nTrial)))
                results{nTrial,6} = 1;
            end
    
            % We would like to offer a feedback to the participant that
            % will depend on the correctness of the trial. The feedback
            % will be presented as an auditory cue. Let's prepare a
            % function that will play any sound by receiving as an input a
            % path to an audiofile Previously we have saved the audio files
            % in our experimental variable, so we are going to access that
            % array depending on this is a good trial (2) or not (1)
            playFeedback(expInfo.sounds{results{nTrial,6} + 1});

        catch ME
    
            sca;
            ShowCursor;

            % We don t rethrow the error as we would like to save the data
            % collected so far in any case. If we arrive here we are going
            % to stop the execution of the trial loop, but we are going to
            % get back the results anyway
            %rethrow(ME);
    
        end
    
    end

end
%%
function doFixationCross(window,expInfo)
    
    try
        % A fixation is two line segments. One horizontal and one vertica.
        % Let s create both segments first using the variables saved in
        % expInfo. 
        % Let's set those two lines keeping in mind that these are all
        % relative to a zero coordinate that will be given later on as an
        % input to the function drawing the lines.
        horizontalLine = [-expInfo.fixCrossDimPix expInfo.fixCrossDimPix 0 0];
        verticalLine   = [0 0 -expInfo.fixCrossDimPix expInfo.fixCrossDimPix];
        
        % Let s create a structure where each row is a separate line
        allLines = [horizontalLine; verticalLine];
    
        % To draw multiple lines on the back-buffer we can use the Screen
        % sub-function "DrawLines" which can receive as an input an array
        % of lines, a number indicating the width of the line, an input
        % that can be an array of colors or a single global color (rgb or
        % rgba), the PTB window coordinates where to center the lines and
        % an optional number indicating the smoothness of the line
        Screen('DrawLines', window, allLines, expInfo.fixLineWidthPix, expInfo.paletteWhite, [expInfo.Xcenter expInfo.Ycenter], 2);

        % We are now ready to flip the buck buffer so we are going to do it
        % here
        Screen('Flip',window);

        % Finally before returning the function we are going to wait the
        % execution of the script for the amount of time we specified in
        % our exeperimental variables
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
        
        % Like with the images, audio files need to be imported into the
        % matlab workspace. PTB has an fucntion called 'psychwavread' that
        % reads wav files providing the full path to the file. The function
        % returns the sound information as an array and a frequency
        % indicating the sampling rate of the wave file
        [sWave, freq] = psychwavread(soundFile);

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
end