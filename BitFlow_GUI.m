function varargout = BitFlow_GUI(varargin)
% BITFLOW_GUI MATLAB code for BitFlow_GUI.fig
%      BITFLOW_GUI, by itself, creates a new BITFLOW_GUI or raises the existing
%      singleton*.
%
%      H = BITFLOW_GUI returns the handle to a new BITFLOW_GUI or the handle to
%      the existing singleton*.
%
%      BITFLOW_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BITFLOW_GUI.M with the given input arguments.
%
%      BITFLOW_GUI('Property','Value',...) creates a new BITFLOW_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BitFlow_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BitFlow_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BitFlow_GUI

% Last Modified by GUIDE v2.5 03-Sep-2015 15:43:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BitFlow_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BitFlow_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BitFlow_GUI is made visible.
function BitFlow_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BitFlow_GUI (see VARARGIN)

% Choose default command line output for BitFlow_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BitFlow_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BitFlow_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
vid = videoinput('bitflow');
% src = getselectedsource(vid);
% Configure the object for manual trigger mode.
triggerconfig(vid, 'Manual');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
start(vid);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
stop(vid);


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
global H_image;
% Hint: get(hObject,'Value') returns toggle state of togglebutton1
while get(hObject,'Value')
    tstart = tic;
    trigger(vid);
    wait(vid,5,'logging');
    image = getdata(vid,1);
    set(H_image, 'CData', image);
    drawnow;
    telapsed = toc(tstart);
    fps = 1/telapsed;
    fps = round(fps, 3);
    set(handles.text3, 'String', num2str(fps));
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global H_image;
H_image = imshow(rand(1024),[]);
% Hint: place code in OpeningFcn to populate axes1
