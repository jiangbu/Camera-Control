vid = videoinput('bitflow');
triggerconfig(vid, 'manual');
% vid.FramesPerTrigger = 1;
% vid.TriggerRepeat = Inf;
start(vid);
preview(vid);
image = getsnapshot(vid);
figure; imshow(image,[]);