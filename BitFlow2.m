%%
imaqreset;
vid = videoinput('bitflow');
% src = getselectedsource(vid);

% Configure the object for manual trigger mode.
triggerconfig(vid, 'Manual');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start(vid);

%----------------------------
trigger(vid);
wait(vid,5,'logging');
image = getdata(vid,1);
%----------------------------
%%
stop(vid);
delete(vid);
clear vid;
