vid = videoinput('ni');
preview(vid);

m = double(getsnapshot(vid));
figure;imshow(m,[]);
figure;hist(m(:),100);
disp(std(m(:)));

triggerconfig(vid, 'Manual');
vid.FramesPerTrigger = 4;
vid.TriggerRepeat = Inf;

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start(vid);
isrunning(vid)
islogging(vid)
vid.FramesAcquired

trigger(vid);
wait(vid,3,'logging');
vid.FramesAcquired
vid.FramesAvailable
[m, time] = getdata(vid,4);
figure;imshow(m,[]);
vid.FramesAvailable