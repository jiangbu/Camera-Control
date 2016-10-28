function LIVE_SPECTRUM_HAMAMATSU(exposure, roi)
global video_flag camera_flag vid...
      hFig

ROI=roi;
ExpTime=exposure;
% AvgImgNum=Nframes;

camera_flag=0;
video_flag=0;

% SETUP FIGURE
hFig = figure('Toolbar','figure','Name','LIVE SPECTRUM');


% Create axes
axes1 = axes('Parent',hFig,...
    'Position',[0.15 0.2 0.7 0.7]);
box(axes1,'on');
% hold(axes1,'all');

ima_temp = zeros([roi(4), roi(3)]);
imageHandle = imagesc(ima_temp);
% xlabel('Wavelength, a.u.');
% ylabel('Fiber axis');
axis square
colormap(gray)


        uicontrol('Style', 'pushbutton', 'String', 'START/STOP ACQ.',...
        'Position', [10 10 120 30],...
        'Callback', @stop_video);        % Pushbutton string callback
                                         % that calls a function
      
      uicontrol('Style', 'pushbutton', 'String', 'START CAMERA',...
        'Position', [140 10 100 30],...
        'Callback', @start_camera);        % Pushbutton string callback
                                         % that calls a function
                                         
      uicontrol('Style', 'pushbutton', 'String', 'STOP CAMERA',...
        'Position', [250 10 100 30],...
        'Callback', @stop_camera);        % Pushbutton string callback
                                         % that calls a function
                                        
     uicontrol('Style', 'pushbutton', 'String', 'CLOSE WINDOW',...
        'Position', [360 10 100 30],...
        'Callback', @close_window);        % Pushbutton string callback
                                         % that calls a function     
% END SETUP FIGURE

function start_camera(hObj,event)
    if camera_flag~=1
        camera_flag=1;
        % CAMERA INITIALIZATION SEQUENCE
        if camera_flag==1
          % Initialize the camera and see live images 
          s=imaqhwinfo;
          s.InstalledAdaptors;
          s=imaqhwinfo('hamamatsu',1);
          
          
          vid = videoinput('hamamatsu', 1, 'MONO16_2048x2048_FastMode');
          src = getselectedsource(vid);
          vid.FramesPerTrigger = 1;
          src.ExposureTime = 0.05;
          %preview(vid);
          %stoppreview(vid);
          start(vid);
          a1=getdata(vid);
          delete(vid);
          clear a1
          
          % set imaging mode and parameters
          %ImgMode='MONO16_BIN4x4_512x512_FastMode';
          ImgMode='MONO16_2048x2048_FastMode';
          vid = videoinput('hamamatsu', 1, ImgMode);
          src = getselectedsource(vid);
          vid.FramesPerTrigger = 1;
          src.ExposureTime = ExpTime;  % set exposure time/s
          vid.ROIPosition = ROI;
          % Configure the object for manual trigger mode.
          triggerconfig(vid, 'manual');
          
          % Now that the device is configured for manual triggering, call START.
          % This will cause the device to send data back to MATLAB, but will not log
          % frames to memory at this point.

          disp(['Camera parameters are set']);
            
        end
        start(vid)
        disp('CAMERA IS STARTED')
        % END CAMERA INITIALIZATION SEQUENCE
    else
        disp('CAMERA HAS ALREADY BEEN STARTED!')
    end
end


%  return

function stop_video(hObject, eventdata, handles) %#ok<INUSD>
%      global vid
     k=0;
%     s2='NORMAL';
    if video_flag==0
        video_flag=1;
        disp('VIDEO IS STARTED');
        while camera_flag==1 && video_flag==1
            %now grab one image out of the video stream

            spectrum=double(getsnapshot(vid));
            sp_max=max(spectrum(:));
            sp_ave=round(mean(spectrum(:)));
            set(imageHandle, 'CData', spectrum);
                s1=strcat('EXPOSURE = ', num2str(exposure),' s;');
                if (sp_max>=6.55e4)
                    k=k+1;
                    s2=strcat(' OVEREXPOSED: #', num2str(k));
%                     disp(s2);
                else
                    s2=strcat(' MEAN = ',num2str(sp_ave));
                end
                s3=strcat(s1,s2);
                title(s3);
           
        end
%         disp('VIDEO IS STARTED')
    elseif video_flag==1
        video_flag=0;
        
        spectrum=double(getsnapshot(vid));
        sp_max=max(spectrum(:));
        sp_ave=round(mean(spectrum(:)));

        set(imageHandle, 'CData', spectrum);
        s1=strcat('EXPOSURE = ', num2str(exposure),' s;');
        if (sp_max>=6.55e4)
            k=k+1;
            s2=strcat(' OVEREXPOSED: #', num2str(k));
%             disp(s2);
        else
            s2=strcat(' MEAN = ',num2str(sp_ave));
        end
        s3=strcat(s1,s2);
        title(s3);
%         drawnow
        disp('VIDEO IS STOPPED');
        return

    end
%      video_flag

end



function stop_camera(hObj,event) %#ok<INUSD>
% global camera_flag
    % Called when user activates pushbutton
    if camera_flag~=0
        camera_flag=0;
        
        if camera_flag==0
            stop(vid)
            delete(vid); % CLOSE THE CAMERA
            disp('CAMERA IS STOPPED');
            video_flag=0;
        end
    else
        disp('CAMERA HAS ALREADY BEEN STOPPED!')
    end
end
 

function close_window(hObj,event) %#ok<INUSD>
% global camera_flag
    % Called when user activates pushbutton
    if camera_flag~=0
        camera_flag=0;
        
        if camera_flag==0
            stop(vid)
            delete(vid); % CLOSE THE CAMERA
            disp('CAMERA IS STOPPED');
        end
    else
        disp('CAMERA IS STOPPED');
    end
    close(hFig)
end

end
  