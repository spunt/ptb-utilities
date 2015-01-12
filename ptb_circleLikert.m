% circleLikert
% -----------
% usage:  rating=circleLikert(c,[bottomtext],[scaletext],[colors],[slideposinit],[scanner])
% Nine-point likert scale
%
% inputs:
% - c:           see exptSetup.m ... contains graphics (Window and screen) variables
% optional:
% - bottomtext:    question text.. default blank
% - scaletext: a array of three strings, one for beginning, middle and end
% of scale. Default = blank
% - colors:  a vector of color values - default = rainbow
% - slideposinit: where should the cursor start? default = 5 (the middle)
% - scanner: if set to 1, keys are 1,2 and 3 instead of arrow keys and g
% outputs
% - rating: integer value representing position on scale that was selected
%
% Original Author: Grace Tang, tsmgrace@gmail.com, 2013
% Adapted by: Jared Torre, jared.torre@gmail.com, September 2014 for use
% with ptb-utilities (https://github.com/spunt/ptb-utilities)


function [rating,rt] = ptb_circleLikert(w, defaults, resp_device, resp_set, prompt, scaleText, numEls, respWin, startPoint, colors)
if nargin < 10; colors = [[0 0 255];[50 50 255];[100 100 255];[150 150 255];[245 245 220];[245 165 79];[255 150 50];[255 100 50];[255 75 25]]'; end
if nargin < 9; startPoint = round(numEls/2); end
if nargin < 8; respWin = Inf; end
if nargin < 7; numEls = 9; end
if nargin < 6; scaleText = {'';'';''}; end
if nargin < 5; prompt = ''; end
if nargin < 4; disp('USAGE: ptb_circleLikert(w,defaults,resp_device,resp_set,prompt,scaleText,nemEls,startPoint,colors)'); return; end

%Set up slider bar display start and end based on screen width
c.linestart=w.res(3)/8;
c.lineend=(w.res(3)*7)/8;
c.linelength=(c.lineend-c.linestart);

% Initialize variables related to circle display
c.numEls = numEls; % number of elements on the scale... e.g. for a 1-7 scale, enter 7
c.radius = w.res(4)/20;
c.side = w.res(4)/20;
c.height = 3*w.res(4)/6;
c.circleSep = (c.linelength)/(c.numEls-1);
c.colors = colors;

% Initialize variables related to sliding circle
c.slideRadius = 2*c.radius/3;
c.slidePos = startPoint;

% Set up positions for text display
c.qnHeight = 2*w.res(4)/6;
c.scaleHeight = 3.5*w.res(4)/6;
c.instrHeight = 5*w.res(4)/6;

% Set up the text
c.prompt = prompt;
c.scaleText = scaleText;

% Draw the scale at first
ptb_circleLikertDraw(w,defaults,c)

% Setting up loop to look for responses and adjust slide
slideOnset = GetSecs;
slideDur = GetSecs - slideOnset;

noresp = 1;
rating = [];
resp = [];
rt = [];
while noresp && slideDur < respWin
    
    [keyIsDown secs keyCode] = KbCheck(resp_device);
    keyPressed = find(keyCode);
    if keyIsDown & ismember(keyPressed, resp_set)
        rt = GetSecs - slideOnset;
        resp = KbName(keyPressed);
        noresp = 0;
    end
    
    if numel(strcmp(resp,'2@'))==1 && sum(strcmp(resp,'2@'))==1 && c.slidePos < c.numEls
        c.slidePos = c.slidePos + 1;
        rt = [];
        resp = [];
        noresp = 1;
        ptb_circleLikertDraw(w,defaults,c)
        WaitSecs(.2);
        
    elseif numel(strcmp(resp,'2@'))==1 && sum(strcmp(resp, '1!'))==1 && c.slidePos > 1
        c.slidePos = c.slidePos - 1;
        rt = [];
        resp = [];
        noresp = 1;
        ptb_circleLikertDraw(w,defaults,c)
        WaitSecs(.2);
        
    elseif sum(strcmp(resp, '3#'))==1
        rating=c.slidePos;
        noresp = 0;
        WaitSecs(.2);
        
    else
        rt = [];
        resp = [];
        noresp = 1;
        WaitSecs(.001);
        
    end
    
    slideDur = GetSecs - slideOnset;
end

if isempty(rating)
    rating = c.slidePos;
    rt = -1;
end

end

function ptb_circleLikertDraw(w,defaults,c)

Screen('TextSize',w.win,w.res(4)/20);
DrawFormattedText(w.win, c.prompt,'center',c.qnHeight,w.white);

rects=[];
% Determine position of circles
for x=1:c.numEls
    centerX = c.linestart+c.circleSep*(x-1);
    rects(1,x) = centerX-c.radius;
    rects(2,x) = c.height-c.radius;
    rects(3,x) = centerX+c.radius;
    rects(4,x)= c.height+c.radius;
end

% Draw circles
Screen('FillOval', w.win, c.colors, rects);

% Draw slider
c.slidePosX = (c.slidePos-1)*c.circleSep + c.linestart;
Screen('FillOval', w.win, w.black, [c.slidePosX-c.slideRadius, c.height-c.slideRadius, c.slidePosX+c.slideRadius, c.height+c.slideRadius]);

% Draw legend
Screen('TextSize',w.win,w.res(4)/30);
scalekey=c.scaleText;  % extra spaces so they spread out evenly
% for y=1:3
%     DrawFormattedText(w.win, scalekey{y}, c.linestart+(c.linelength)*(y-1)/2, c.scaleHeight,w.white);
% end
DrawFormattedText(w.win, scalekey{1}, rects(1,1), c.scaleHeight,w.white);
DrawFormattedText(w.win, scalekey{2}, 'center', c.scaleHeight,w.white);
DrawFormattedText(w.win, scalekey{3}, rects(1,c.numEls), c.scaleHeight,w.white);

% % Draw instruction
% Screen('TextSize',w.win,w.res(4)/20);
% DrawFormattedText(w.win, 'Move the indicator left with ''1'' and right with ''2'', then press ''3'' to confirm', 'center', c.instrHeight,w.white,60);

% Display all this so far
Screen('Flip',w.win);
end