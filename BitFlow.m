%%
imaqreset;
vid = videoinput('bitflow');
src = getselectedsource(vid);


% Configure the object for manual trigger mode.
triggerconfig(vid, 'Manual');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start(vid);

isrunning(vid);
islogging(vid);
disp(vid.FramesAcquired);

trigger(vid);
vid.FramesAcquired
image = getdata(vid,1);
vid.FramesAcquired
vid.FramesAvailable
isrunning(vid);
islogging(vid);

%% speed test
tic;
for i = 1:10
    m = getsnapshot(vid);
end
toc;

%% speed test
% fig = imshow(rand(512));

tic;
for i = 1:10
    trigger(vid);
    wait(vid,3,'logging');
    vid.FramesAcquired
    vid.FramesAvailable
    m = getdata(vid,1);
    vid.FramesAvailable
    
%     set(fig, 'CData', m);
%     drawnow;
end
toc;

%%
stop(vid);
delete(vid);
clear vid;
