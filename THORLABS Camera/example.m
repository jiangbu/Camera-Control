%% Open Camera, ROI is hard coded
[cam_handle, FRAME_STRUCT] = OPEN_CAMERA_TL_DCx_64bit_square();

%% set exposure time. 
% Read comments in 'SET_PIXCLK_EXPTIME_FPS_TL_DCx_64bit.cpp' for details
SET_PIXCLK_EXPTIME_FPS_TL_DCx_64bit(cam_handle, 30, 10, 90);

%% acquire a snapshot
frame = GRAB_FRAME_TL_DCx_64bit(cam_handle, FRAME_STRUCT);

%% Close Camera
CLOSE_CAMERA_TL_DCx_64bit(cam_handle, FRAME_STRUCT);

