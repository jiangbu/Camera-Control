%%
imaqreset;
vid = videoinput('qimaging',1,'MONO16_1600x1200');
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

% The wait function blocks the command line until the hardware trigger fires and
% acquisition completes or until the amount of time specified by the timeout value
% expires.

trigger(vid);
wait(vid,5,'logging');
disp(vid.FramesAcquired);
[image, time] = getdata(vid,1);
vid.FramesAcquired
vid.FramesAvailable
isrunning(vid)
islogging(vid)


%%
stop(vid);
delete(vid);
clear vid;