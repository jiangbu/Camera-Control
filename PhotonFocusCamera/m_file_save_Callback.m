function m_file_save_Callback(snap)
% hObject    handle to m_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%setappdata(handles.figure1,'img_src');
[filename,pathname]=uiputfile({'*.tif','TIFfiles';},'Snapshot');
if isequal(filename,0) || isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    imwrite(snap,fpath);
end