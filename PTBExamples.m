%% This script accompanies the "PSychtoolbox (PTB) - a gentle introduction" lectures from the UCL
%  Institute of Cognitive Neuroscience Matlab Course. All course details
%  and content - including pre-recorded lectures, slides, practical
%  exercises and solutions - can be found on the course website:
%  https://moodle.ucl.ac.uk/course/view.php?id=22765
%
%  Andrea Castegnaro, UCL (2022) uceeaca@ucl.ac.uk

% [This scripts contains the code presented during the first PTB lecture.
% We are going to present different simple uses of basic functions
% available in PTB. Every example is contained into different code sections
% (outlined using %% a the beginning of the section) Each section is
% completely standalone so to run them separately you can use ctrl+Enter on
% windows to run only the code written in that section.]

%% Example 1 
% [Opening a PTB window on top left of the screen coordinate.]

% [Let' s start by clearing the workspace]
clear all;

%  [Psychtoolbox needs some initialization. This means means starting the
%  toolbox, initialising the sound, detecting how many screens are
%  available, and deciding which screen we will use to display our task.
%  First, let's initialise PTB. To do this, we use the 'PsychDefaultSetup'
%  function. This function only takes one input - a number 0, 1 or 2. Each
%  value specifies a different type of setup. Don't worry about the details
%  for now - you will almost always use a value of 2. Before doing that we
%  are also saying to PTB to avoid any syncing test relative to our screen.
%  Sync test is used by PTB to make sure the screen flip will happen
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

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

    % [Let's try to open a PTB window. We are going to open a rectangular
    % window on the left upper part of the screen
    % We are going to use the function PsychImaging with the subfunction 'OpenWindow' 
    % providing as an input the index of the screen where to open the window,
    % a color that will be the background color for our window, and an optional
    % parameter that will represent the start and end position (x and y pixel
    % coordinates) of the window within the screen. 
    % Since we want to draw the window at full screen mode that parameter will
    % be empty. The PsychImaging function returns a pointer to the window we
    % just opened and the rectangular dimension in pixels of the openend window.
    % The window pointer will be used later on to instruct any drawing function
    % to the correct window.]
    [window, sourceRect] = PsychImaging('OpenWindow', 0, [0 0 0], [ 100 100 900 700]);

    % [Let s wait for any key presses. See example for PTB key function details]
    KbWait;

    % [After completing the operations we are interested in we have to
    % safely close all of the opened PTB windows. For doing so we can call
    % the Screen sub-function 'CloseAll' to close them all at once.
    % This function have an alias that is called sca.]
    sca; % equivalent to Screen('CloseAll')

catch ME 
    % [The catch block is executed only if an error is raised in the
    % try block. This is a good opportunity to clear the PTB window
    % that otherwise would be stucked on our monitors (and needs to be
    % closed forcefully.]

    % [Closing all PTB window]
    sca; %Screen('CloseAll');

    % [We are interested in looking at the problem that happened at
    % this point so we are literally going to rethrow the error so that
    % it will appear in the Matlab command window and stop the
    % execution of the script
    rethrow(ME);
end

%% Example 2
% [Opening a gray full screen PTB window on the dected external screen (if any)]

% [Let' s start by clearing the workspace]
clear all;

% [Initializing PTB.  See example 1 for details.]
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

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

try
    % Open a full screen PTB window with a gray background color
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0.5 0.5 0.5], []);
    
    % [Let s wait for any key presses. See example for PTB key function details]
    KbWait;

    % [Closing all PTB window]
    sca;
catch ME 

    % [Closing all PTB window]
    sca; %Screen('CloseAll');
    rethrow(ME);

end

%% Example 3
% [Draw a pink line crossing diagonally the PTB window]

% [Let' s start by clearing the workspace]
clear all;

% [Initializing PTB.  See example 1 and 2 for details.]
PsychDefaultSetup(2);

try
    % [Initializing PTB.  See example 1 and 2 for details.]
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    screenNumber = max(screens);

    % [Initializing PTB.  See example 1 and 2 for details.]
    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % [Let's draw a line on the PTB window by using the Screen sub-function
    % 'DrawLine' which requires as an input a RGB color, the x window 
    % coordinate of the start, the y window coordinate of the start, the x
    % window coordinate of the end, the y window coordinate of the end and
    % finally a number representing the thickness. Let s draw a pink line
    % across our PTB winbdow
    Screen('DrawLine', window, [1 0 1], 0, 0, sourceRect(3), sourceRect(4), 10);

    % [As explained in the lectures everytime we are drawing any item
    % using the Screen function what we are actually doing is writing
    % to a back-buffer which is not the actual PTB window. Once we have
    % prepared the back-buffer in order to display it on the PTB window
    % we have to call the Screen sub-function 'Flip' to literally flip
    % the back-buffer into the window (and clear the current
    % back-buffer). Since we have all the elements in the current
    % screen we can call it now. 
    Screen('Flip',window);

    % [Let s wait for some seconds]
    WaitSecs(3);

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;

    rethrow(ME);

end

%% Example 4
% By using lines let's draw a fixation cross in the center of the screen

% [Let' s start by clearing the workspace]
clear all;

% [Initializing PTB.  See example 1 and 2 for details.]
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % [Since we are going to draw at the center of the screen we want also
    % to calculate the center of the window in pixel coordinate.
    % We can use the PTB function RectCenter to extract the center pixel
    % coordinates of the windows by providing the rectangular dimension of the
    % window.]
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % [A fixation cross is composed by two lines. Let's create here the
    % coordinate for those lines. The coordinates here created are not
    % actual pixels but the relative coordinate to the line center that
    % will be added later on when calling the function. LineOne is an
    % horizontal line with 200 pixels length and lineTwo is a vertical line
    % with 200 pixels length.]
    lineOne = [-100 100 0 0];
    lineTwo = [0 0 -100 100];
    allLines = [lineOne; lineTwo];

    % [We can now finally draw the lines toghether using the Screen
    % sub-function 'DrawLines' which takes a matrix of coordinates, a color
    % and the center where the lines coordinate are relative to.]
    Screen('DrawLines', window, allLines, 10, [1 1 1], [windowCenterX windowCenterY]);

    % [Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window. Let s do it here]
    Screen('Flip',window);

    WaitSecs(3);

    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;
    ShowCursor;
    rethrow(ME);

end

%% Example 5
% Drawing a green rectnagle on the upper right part of the screen

% [Let' s start by clearing the workspace]
clear all;

% [Initializing PTB.  See example 1 and 2 for details.]
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % [Getting the center of the PTB window]
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % [Let s draw a rectangle on the upper right part of the screen. We 
    Screen('FillRect', window, [0 1 0], [windowCenterX 80 sourceRect(3)-80 windowCenterY])

    % [Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window. Let s do it here]
    Screen('Flip',window);

    WaitSecs(3);

    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;
    ShowCursor;
    rethrow(ME);

end

%% Example 6
% Drawing two rectangles with transparency to see how the overlap works

clear all;

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

try

    % [Let s hide the mouse cursor using the PTB function HideCursor.]
    HideCursor;
    % Get the number of screen available in the current system. That is useful
    % when we have more than one screen attached
    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Getting the center of the window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);
    
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % [Let's draw two overalapping rectangles by setting the alpha
    % transparency of both to 0.5 to see how the color pixels combine on
    % the overlapping parts]

    % [First we draw an yellow rectangle towards the center of the screen
    % using the FillRect sub-function (for details look at example 5).
    % Notice how the color has been added another number indicating the
    % transparency of the image.]
    Screen('FillRect', window, [1 1 0 0.5], [windowCenterX-300 windowCenterY-300 windowCenterX+100 windowCenterY+100]);

    % [Next, we draw a blue rectangle overlapping with the previous one
    % using the Screen 'FillRect' sub-function (for details look at example
    % 5).
    % Notice how the color has been added another number indicating the
    % transparency of the image.]
    Screen('FillRect', window, [0 0 1 0.5], [windowCenterX-100 windowCenterY-100 windowCenterX+300 windowCenterY+300]);

    % [Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window. Let s do it here]
    Screen('Flip',window);

    WaitSecs(3);

    % [Let s unhide the mouse using the PTB function HideCursor.]
    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME
    sca;
    ShowCursor;
    rethrow(ME);
end

%% Example 7
% [In this example we are going to draw an image on the center of the screen. The image
% will be loaded from the Assets folder contained into our project folder.
% Drawing an image on the PTB requires more steps. The first step is load
% the image from a file into the matlab workspace. The second one is to
% prepare a container that PTB can read for displaying the image on the
% screen. This container is a texture. Third step we can finally instruct
% PTB to draw the texture on the window.

% [Let' s clear the workspace]
clear all;

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

% [Sometimes you will have to load external files to present stimuli into
% your experiment whether these are images or audios. It is a good practice
% to keep the experimental files in a separate folder, but in doing so, we
% have to make sure the folders where experimental files are kept are added
% to the matlab search path otherwise we will not able to load them.
% Let's add folders to the Matlab search path using the function
% 'addpath' which requires as an input the path to the folder we would like
% to add. We use the speacial character './' to indicate start from the
% current folder.]
addpath('./Assets');

try

    % [Let s hide the mouse cursor using the PTB function HideCursor.]
    HideCursor;
    % Get the number of screen available in the current system. That is useful
    % when we have more than one screen attached
    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Getting the center of the window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % [First, we have to load the image in the matlab workspace from a
    % file. Let's use the matlab function 'imread' to load the image into
    % the workspace. The function requires the path to the file we want to
    % load and returns a multidimensional array containing the 
    currImage = imread('./Assets/Goomba.png');

    % [Pictures comes with different sizes and resolutions. However
    % we want to present them in a similar portion of the screen,
    % so we are going to scale the images manually. We can use it
    % by calling the matlab function 'imresize' which takes as an
    % input the information of an image loaded into the workspace
    % and a number indicating the scaling factor. Let's do that by
    % using the scaling values we saved previously in expInfo.] 
    currImage = imresize(currImage, 0.5);

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
    % using the DrawTexture sub-function by providing the texture we have
    % just created.]
    Screen('DrawTexture', window, imageTexture);

    % [Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window. Let s do it here]
    Screen('Flip',window);

    % [Wait some seconds.]
    WaitSecs(3);

    % [Let s unhide the mouse using the PTB function HideCursor.]
    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;
    ShowCursor;
    rethrow(ME);

end

%% Example 8
% [In this example we are going to draw only a portion of image on the
% center of the screen. For details on how to load images refer to the
% previous example.]

% [Let' s clear the workspace]
clear all;

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

addpath('./Assets');

try

    % [Let s hide the mouse cursor using the PTB function HideCursor.]
    HideCursor;
    % Get the number of screen available in the current system. That is useful
    % when we have more than one screen attached
    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % Getting the center of the window
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);
    
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % [Loading the image on the workspace]
    currImage = imread('./Assets/Goomba.png');
    
    % [Making it into a PTB texture]
    imageTexture = Screen('MakeTexture', window, currImage);

    % [We can now finally draw the texture into the back buffer by
    % using the DrawTexture sub-function by providing the texture we have
    % just created. We just want to show the eyes of this image, so we are
    % going to do that by using sourceRect. We are also going to scale the
    % texture by providing a specific portion of the image where it has to
    % fit. This is an alternative on using the imresize function.]
    Screen('DrawTexture', window, imageTexture, [450 300 1000 650], [windowCenterX-350 windowCenterY-350 windowCenterX+350 windowCenterY+350]);

    % [Once we finish drawing to the back-buffer we can flip it to make it
    % visible to the user on the PTB window. Let s do it here.]
    Screen('Flip',window);

    % [Wait some seconds.]
    WaitSecs(3);

    % [Let s unhide the mouse using the PTB function HideCursor.]
    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;
    ShowCursor;
    rethrow(ME);

end

%% Example 9
% [In this example we are going to draw only a portion of image on the
% center of the screen. For details on how to load images refer to the
% previous example.]

% [Let' s clear the workspace]
clear all;

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

addpath('./Assets');

try

    % [Let s hide the mouse cursor using the PTB function HideCursor.]
    HideCursor;
    % [Get the number of screen available in the current system. That is useful
    % when we have more than one screen attached
    screens = Screen('Screens');
    screenNumber = max(screens);

    [window, sourceRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0], []) ;

    % [Getting the center of the window]
    [windowCenterX, windowCenterY] = RectCenter(sourceRect);

    % [There are different function to set the text properties such as
    % font, size and style. Once these functions are called all texts
    % object drawn will have these properties. You can eventually change
    % them after have drawn some text on the back-buffer to affect new text
    % that will be written afterwards.]
    % To change the font we can call the SCreen sub-function TextFont which
    % requires as an input the name of the desidered font
    Screen('TextFont',window, 'Courier New');
    % To change the text size we can call the SCreen sub-function TextSize which
    % requires as an input a numeber indicatin the desired text size
    Screen('TextSize',window, 30);
    % [To change the font type we can use the sub-function 'TextFont' which
    % requires the name of the font to be used, the pointer to the window
    % we want to set the text preferences, a  number indicating the style
    % (1 for italic, 2 for bold and 3 for italic+bold).]
    Screen('TextStyle', window, 1+2); 

    % [Let s draw a text by using the PTB function DrawFormatted text whihc
    % requires the text, the starting window x coordinate, the starting
    % window y coordinate, Notice that when using the special character
    % 'center' the starting coordinate here will be used to center the
    % text. The function returns the coordinates of the last character drawn
    % and a rectangle enclosing the entire text.
    [nx, ny, bbox] = DrawFormattedText(window, 'Here is some text displayed on the center of the PTB window...', 'left', 'center', [1 0 1]);

    % [Let s draw a text also by using the PTB function DrawText. This
    % function requires the start coordinate for the text and a color. We
    % are going to use the information from the previous function call to
    % make the text appear beneath the previous one.
    [a,cc] = Screen('DrawText', window, 'And this is just after the previous one...', bbox(1), ny + 20, [0, 1, 0]);

    Screen('Flip',window);

    % [Wait some seconds.]
    KbWait;

    % [Let s unhide the mouse using the PTB function HideCursor.]
    ShowCursor;

    % [Closing all PTB window]
    sca;

catch ME

    % [Closing all PTB window]
    sca;
    ShowCursor;
    rethrow(ME);
end

%% Example 10
% [In this example we are going to show how to wait for keyboard presses
% and how to check which arrow key is being pressed.]

% [Let' s clear the workspace]
clear all;

Screen('Preference', 'SkipSyncTests', 1);

% [For operating with the keyboard we still require some initialization
% that luckily can be handled by using the default setup. So let's do it
% here.]
PsychDefaultSetup(2);

addpath('./Assets');

try

    % [We are going to stop the exection of the script until
    % the user presses a key on the keyboard. For this we can
    % use the PTB function KbWait that waits for any key
    % press.]
    KbWait;

    % [Right after a key is being pressed we can now then ask what kind of
    % key was and what kind of the movement was detected
    % e.g. a release or a press. The PTB function kbCheck can
    % be used for checking this information. The function
    % returns 1 if any key, including modifiers e.g. Shift/alt is down, 0
    % otherwise, returns the time in seconds since the beginning of the
    % script and an array with all of the key detected at this point. Since
    % we are following the 'KbCheck' after a KbWait we are sure one key is
    % being pressed so we are going to return only the keyCode of that
    % pressed key.]
    [~, ~, keyCode] = KbCheck;

    % [At this point we are expecting only one key press. Since
    % keyCode is a 256-element array we are going to find the
    % only 1 in the array. That index is the keycode pressed at
    % this time. Let's find it by using the Matlab function find which
    % receive as an input an array and the desired number we are looking for
    % and returns an array of indices indicating the position of the array
    % elements that are equal to the desired number
    keyCode = find(keyCode, 1);

    % [We can now finally print to the command window the name of the
    % keyboard that has been pressed. For this we use the PTB function
    % 'KbName' that holds a mapping between the integers and the keyboard
    % names. Tip: Keyboard names are unique in PTB. Run KbName('KeyNames')
    % in the command window to print out the mapping PTB uses between names
    % and code for keys for your system.]
    disp(['You pressed key ' num2str(keyCode) ' which is ' KbName(keyCode)]);

catch ME

    disp(ME.message);

end
