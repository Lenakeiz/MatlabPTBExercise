%% This script accompanies the "Psychophysics toolbox (PTB) - a gentle 
%  introduction" lectures from the UCL Institute of Cognitive Neuroscience
%  Matlab Course. All course details and content - including pre-recorded
%  lectures, slides, practical exercises and solutions - can be found on
%  the course website: https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) uceeaca@ucl.ac.uk
%
%  In the first lecture, we are going to demonstrate some simple functions
%  available within PTB. Every example is contained in a different code
%  section (differentiated by the double comment symbol %% at the beginning
%  of each section). Each section is therefore completely standalone and
%  can be executed by clicking 'Run section' or using the relevant keyboard
%  shortcut (control and enter on a Windows machine)


%% Example 1: Open a PTB window at the top left of the screen

%  Let's start by clearing the workspace
clear all;

%  Psychtoolbox needs some initialization. This means starting the toolbox,
%  initialising the sound, detecting how many screens are available, and
%  deciding which screen we will use to display our task. First, let's
%  initialise PTB. To do this, we use the 'PsychDefaultSetup' function.
%  This function only takes one input - a number 0, 1 or 2. Each value
%  specifies a different type of setup. Don't worry about the details for
%  now - you will almost always use a value of 2. Before doing that, we
%  also need to ask PTB to avoid carrying out any sync test of our monitor.
%  This sync test is performed automatically by PTB to make sure the screen
%  'flip' (i.e. display command) is in line with the screen refresh rate
%  (measured in Hz). Nowadays, it is not really necessary as refresh rates
%  are generally very high for modern monitors, so we are going to prevent
%  PTB performing this initial check as it could also generate irrelevant
%  errors
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

%  Next, it is good practice to enclose our main task code inside a
%  'try/catch' statement. Within a try/catch statement, only the code
%  inside the try block gets executed, unless an error arises with that
%  code. In that case, rather than aborting execution of the script, Matlab
%  moves to the code following the 'catch' command, and executes that code
%  instead. This means we can add some commands there which can handle the
%  effects of the error that has arisen. Try/catch is helpful when building
%  experiments with PTB because when an error arises and we haven't closed
%  the PTB window, it can be difficult to get back to the Matlab desktop.
%  However, by adding code after the 'catch' statement that closes the PTB
%  window, we can deal with this issue. Without this, the script could
%  terminate - when an error arises, during debugging - and in some cases,
%  block the entire system with an unresponsive PTB window. We would then
%  have to 'brute kill; the PTB window with ctrl+alt+del on windows or
%  command + period or command + 0 on Mac
try

    % Next, let's try to open a PTB window. We are going to open a
    % rectangular window on the upper left part of the screen. We are going
    % to use the function PsychImaging with the subfunction 'OpenWindow';
    % then provide, as a second input, the index of the screen where we
    % want to open the window; then a three digit code that will dictate
    % the background color of the window; then an optional parameter that
    % will represent the start and end position (x and y pixel coordinates)
    % of the window within the screen. Since we want to draw the window at
    % full screen mode that parameter will be empty. As outputs, the
    % PsychImaging function returns a pointer to the window we just opened
    % and the rectangular dimension in pixels of the opened window. The
    % window pointer will be used later on to direct any drawing function
    % towards the window we wish to display its output in.
    [window, sourceRect] = PsychImaging('OpenWindow', 0, [0 0 0], []);

    % Now, let's wait for any key press (see Example 10 for PTB basic
    % keyboard functions)
    KbWait;

    % After completing the operations we are interested in we have to
    % safely close all of the opened PTB windows. To do so, we can call
    % the Screen sub-function 'CloseAll' to close them all at once.
    % Alternatively, this function has an alias 'sca':
    sca; % equivalent to Screen('CloseAll')

catch ME 
    % This catch block is executed only if an error is raised in the
    % try block above. This is a good opportunity to clear the PTB window
    % that would otherwise remain stuck on our monitors (and need to be
    % closed forcefully)

    % Closing all PTB windows
    sca; %Screen('CloseAll');

    % We may also be interested in looking at the details of the error that
    % caused our task to crash, so we are going to 'rethrow' the error so 
    % that it will appear in the Matlab command window
    rethrow(ME);
end


%% Example 2: Open a gray full screen PTB window on the detected screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

%  In most experimental setups you will have more than one screen. We can
%  use the sub-function 'Screens' of the 'Screen' PTB function to detect
%  how many screens are present in the current system. The function returns
%  a numerical array where each number represents a different available
%  monitor. Usually the numbers should follow the numbering you find in
%  Windows Display Settings (and equivalent for Mac)
screens         = Screen('Screens');

%  If you have a two screen setup I usually set the 'external' one, which
%  presents the task to the user, as number 2 (with more than two monitors
%  I always set the external screen as the highest number in the Windows
%  display settings. In this way, no matter what the experimental setup is,
%  the script will always select the appropriate external screen by
%  choosing the highest number in the array returned by the previous
%  function. Let's get that number by using the matlab function 'max',
%  which returns the maximum value inside an array
screenNumber    = max(screens);

try
    % Open a full screen PTB window with a gray background color
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0.5 0.5 0.5], []);
    
    % Now, let's wait for any key press (see Example 10 for PTB basic
    % keyboard functions)
    KbWait;

    % Close all PTB windows
    sca;

catch ME 

    % Close all PTB windows
    sca; % Equivalent to Screen('CloseAll');
    
    % Return details of the error
    rethrow(ME);

end


%% Example 3: Draw a pink line diagonally crossing the PTB window

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try
    
    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Let's draw a pink line on the PTB window using the Screen
    % sub-function 'DrawLine' which requires as inputs: a three digit RGB
    % color, the x window coordinate of the start point, the y window
    % coordinate of the start point, the x window coordinate of the end
    % point, the y window coordinate of the end point and, finally, a
    % number controlling the thickness
    Screen('DrawLine', window, [1 0 1], 0, 0, sourceRect(3), sourceRect(4), 10);

    % As explained in the lectures, every time we draw any item using the
    % Screen function we are actually writing to a back-buffer which is not
    % the actual PTB window. Once we have prepared the back-buffer we can
    % display it on the PTB window by calling the Screen sub-function
    % 'Flip' to show that back-buffer (and clear the current back-buffer).
    % Since we have all the desired elements in the current screen we can
    % call it now
    Screen('Flip',window);

    % Now, let's wait for any key press (see Example 10 for PTB basic
    % keyboard functions)
    KbWait;

    % Close all PTB windows
    sca;

catch ME

    % Close all PTB windows
    sca;

    % Return details of the error
    rethrow(ME);

end


%% Example 4: Using lines, draw a fixation cross in the center of the screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Since we are going to draw at the center of the screen, we need to
    % know the appropriate pixel coordinates. We can use the PTB function
    % RectCenter to extract those coordinates from the relevant PTB window
    % by providing the rectangular dimension of that window, which are
    % output by the function above
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % A fixation cross is composed of two lines. First, let's create the
    % coordinates for those lines (as xstart, xend, ystart, and yend). The
    % coordinates given here are not actual pixel indices, but the
    % coordinates relative to the center of the screen - which will be
    % added later on when calling the function. LineOne is a horizontal
    % line of 200 pixels length and lineTwo is a vertical line of 200
    % pixels length
    lineOne = [-100 100 0 0];
    lineTwo = [0 0 -100 100];
    allLines = [lineOne; lineTwo];

    % Finally, we can now draw the lines together using the Screen
    % sub-function 'DrawLines' which takes, as inputs, a the pointer to the
    % PTB window, a matrix of coordinates, a color, and the center point
    % that the line coordinates are specified relative to
    Screen('DrawLines', window, allLines, 10, [1 1 1], [windowCenterX windowCenterY]);

    % Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window
    Screen('Flip',window);

    % Now, let's wait for any key press (see Example 10 for PTB basic
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


%% Example 5: Draw a green rectangle on the upper right part of the screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
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

    % Now, let's draw a rectangle on the upper right part of the screen
    % using the Screen sub-function 'FillRect' which takes, as inputs, a
    % pointer to the PTB window, a color, and a set of coordinates that
    % dictates the position and dimensions of the rectangle
    Screen('FillRect', window, [0 1 0], [windowCenterX 80 sourceRect(3)-80 windowCenterY])

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


%% Example 6: Draw two rectangles with transparency

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % In this example, let's hide the mouse cursor using the PTB function 
    % HideCursor
    HideCursor;
    
    % Select the external screen with the highest numerical ID    
    screens = Screen('Screens');
    screenNumber = max(screens);

    % Open a new PTB window
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Get the center coordinates of the PTB window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);
    
    % Next, we need to define a 'blending' function for our PTB window,
    % which controls how the transparency of different objects is defined
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Now, let's draw two overalapping rectangles and set the 'alpha' value
    % (i.e. transparency) of both to 0.5, to demonstrate how the color
    % pixels combine on the overlapping parts

    % First we'll draw a yellow rectangle towards the center of the screen
    % using the FillRect sub-function (for details, see Example 5). Notice
    % how the three digit color index is now followed by another number,
    % indicating the transparency of that image
    Screen('FillRect', window, [1 1 0 0.5], [windowCenterX-300 windowCenterY-300 windowCenterX+100 windowCenterY+100]);

    % Next, we'll draw a blue rectangle overlapping with the previous one,
    % again, using the FillRect sub-function (for details, see Example 5).
    % Notice how the three digit color index is now followed by another
    % number, indicating the transparency of that image
    Screen('FillRect', window, [0 0 1 0.5], [windowCenterX-100 windowCenterY-100 windowCenterX+300 windowCenterY+300]);

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


%% Example 7: Draw an image in the center of the screen
%  In this example we are going to draw an image in the center of the
%  screen. The image will be loaded from the Assets folder contained in the
%  material downloaded from the course website. Drawing an image in PTB
%  requires a few steps. The first step is to load the image from a file
%  into the Matlab workspace. Second, to prepare a 'container' that PTB can
%  read for displaying the image on the screen - this container is called a
%  'texture'. Finally, we can instruct PTB to draw the texture on the
%  screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

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

    % Then, load an image into the matlab workspace from a *.png file.
    % Let's use the Matlab function 'imread' to load the image into the
    % workspace. This function requires the path to the file we want to
    % load and returns a multidimensional array containing the image
    currImage = imread('./Assets/Goomba.png');

    % Pictures come in different sizes and resolutions. However, we want to
    % present them in a similar size on the screen, so we are going to
    % scale the images manually. We can do this by calling the Matlab
    % function 'imresize' which takes, as inputs, the multidimensional
    % image arry loaded into the workspace and a number indicating the
    % scaling factor (in this case, 0.5)
    currImage = imresize(currImage, 0.5);

    % Next we want to prepare the images for display in the PTB window,
    % keeping in mind that every time we draw something on the screen we
    % are actually drawing to the back-buffer. In PTB, before we can draw
    % to the back-buffer, we need a 'holder' for that image. In this case
    % the holder is called a 'texture'. To create a texture we can use the
    % Screen sub-function MakeTexture that takes, as inputs, the pointer to
    % the PTB window and the image we want to use
    imageTexture = Screen('MakeTexture', window, currImage);

    % Now, finally, we can draw the texture into the back buffer by using
    % the DrawTexture sub-function and providing, as input, the texture we
    % have just created
    Screen('DrawTexture', window, imageTexture);

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


%% Example 8: Draw only a portion of an image on the center of the screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

%  Add the image folder to the Matlab path
addpath('./Assets');

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
    
    % Set the image transparency method
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Load an image into the workspace
    currImage = imread('./Assets/Goomba.png');
    
    % Turn that image into a PTB rexture
    imageTexture = Screen('MakeTexture', window, currImage);

    % We will now draw the texture into the back buffer using the
    % DrawTexture sub-function and providing, as inputs, the pointer to the
    % PTB window and the texture we have just created. In this case,
    % however, we will also provide two additional inputs. First, we just
    % want to show the eyes of this image, so we will define an additional
    % input that dictates which area of the image we wish to show, in pixel
    % coordinates. Second, we will define the size of the region in which
    % this image should appear, in pixel coordinates, as an alternative to
    % using the imresize function
    Screen('DrawTexture', window, imageTexture, [450 300 1000 650], [windowCenterX-350 windowCenterY-350 windowCenterX+350 windowCenterY+350]);

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


%% Example 9: Display text in the centre of the screen

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

%  Add the image folder to the Matlab path
addpath('./Assets');

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

    % In PTB, there are different functions to set text properties such as
    % font, size and style. Once these functions are called, all text
    % objects drawn will have the specified properties. You can then change
    % the properties again, after you have drawn some text into the
    % back-buffer, to affect any further text that is written afterwards
    
    % To change the font we can call the Screen sub-function TextFont which
    % requires, as inputs, the pointer to the PTB window and the name of
    % the desired font:
    Screen('TextFont',window, 'Courier New');
    
    % To change the text size we can call the Screen sub-function TextSize
    % which requires, as inputs, the pointer to the PTB window and a number
    % indicating the desired text size:
    Screen('TextSize',window, 30);
    
    % To change the font style we can use the sub-function TextStyle
    % which requires, as inputs, the pointer to the PTB window and a number
    % indicating the style (1 for italic, 2 for bold and 3 for italic+bold)
    Screen('TextStyle', window, 3); 

    % We can then draw the text using the PTB function DrawFormatted text
    % which requires, as inputs, the pointer to the PTB window, the text
    % itself, the starting window x coordinate, the starting window y
    % coordinate, and a three digit RGB color. Notice that we can also use
    % the inputs 'left' and 'center' to define the starting coordinates as
    % the left hand side of the screen, vertically centered. The function
    % returns the coordinates of the last character drawn (nx and ny) and a
    % rectangle enclosing the entire text (bbox)
    [nx, ny, bbox] = DrawFormattedText(window, 'Here is some text displayed on the center of the PTB window...', 'left', 'center', [1 0 1]);

    % Next, let's draw some text using the alternative PTB function
    % DrawText. This function requires a pointer to the PTB window, the
    % start coordinate for the text and a color. We are going to use the
    % outputs from the previous function to make the text appear beneath
    % that text on screen (i.e. with the same initial x coordinate, which
    % is the first entry in 'bbox'; and an initial y coordinate that is
    % twenty pixels after the final y coordinate of the previous text)
    [a,cc] = Screen('DrawText', window, 'And this is just after the previous one...', bbox(1), ny + 20, [0, 1, 0]);

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


%% Example 10: Waiting for keyboard presses and checking which key is being pressed

%  Let's start by clearing the workspace
clear all;

%  Initialise PTB (see Example 1 for details)
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

%  Add the image folder to the Matlab path
addpath('./Assets');

try

    % First, we are going to pause the execution of the script until the
    % user presses a key on the keyboard. For this we can use the PTB
    % function KbWait that waits for any key press (as in all the examples
    % above)
    KbWait;

    % Right after a key is pressed, we can ask which key that was and what
    % kind of movement was detected (e.g. a release or a press) using the
    % PTB function kbCheck. This function returns three outputs: a 1 if any
    % key (including modifiers, e.g. shift/alt) is pressed and 0 otherwise;
    % the time in seconds since the beginning of the script that the key
    % was pressed; and a numerical array containing the indices all of key
    % presses detected at this point. Since we are using KbCheck
    % immediately after KbWait we can be fairly sure one key has been
    % pressed so we are just going to ask for the keyCode of that key
    [~, ~, keyCode] = KbCheck;

    % At this point we are expecting only one key press. Since keyCode is a
    % 256-element array we are going to find the only value of '1' in the
    % array. That index is the key that was pressed at this time. Let's
    % find it using the Matlab function 'find' which receive as an input
    % the array we wish to search and the number we are searching for, and
    % returns an array of indices indicating the position of the array
    % elements that are equal to the desired number
    keyCode = find(keyCode, 1);

    % Finally, we can print to the command window the name of the key that
    % has been pressed. To do this, we will use the PTB function KbName,
    % which holds the mapping between the integer codes output by KbCheck
    % and the actual names of the keys on the keyboard. Note that these key
    % names are unique in PTB. Run KbName('KeyNames') in the command window
    % to display this mapping at any time
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode)]);

catch ME

    % Display any error message
    disp(ME.message);

end