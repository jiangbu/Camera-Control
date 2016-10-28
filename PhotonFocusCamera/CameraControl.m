%% Create a video input object.
vid = videoinput('bitflow');

%% creat a preview window
figure('Name', 'Camera Preview Window'); 
uicontrol('String', 'Close', 'Position',[0 20 50 20],'Callback', 'close(gcf)');  
% uicontrol('String', 'Preview', 'Position',[100 20 50 20], 'Callback', 'startpreview(vid)');
uicontrol('String', 'Stop', 'Position',[100 20 50 20],'Callback', 'closepreview()');
uicontrol('String', 'Snap', 'Position',[200 20 50 20],'Callback', 'snap_tmp = getsnapshot(vid);');
uicontrol('String', 'Save', 'Position',[300 20 50 20],'Callback', 'm_file_save_Callback(snap_tmp);');

vidRes = vid.VideoResolution; 
nBands = vid.NumberOfBands; 
hImage = image( zeros(vidRes(2), vidRes(1), nBands) ); 
axis image;
preview(vid, hImage); 