function varargout = motionParamsMenu(varargin)
% MOTIONPARAMSMENU M-file for motionParamsMenu.fig
%      MOTIONPARAMSMENU, by itself, creates a new MOTIONPARAMSMENU or raises the existing
%      singleton*.
%
%      H = MOTIONPARAMSMENU returns the handle to a new MOTIONPARAMSMENU or the handle to
%      the existing singleton*.
%
%      MOTIONPARAMSMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTIONPARAMSMENU.M with the given input arguments.
%
%      MOTIONPARAMSMENU('Property','Value',...) creates a new MOTIONPARAMSMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before motionParamsMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to motionParamsMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motionParamsMenu

% Last Modified by GUIDE v2.5 12-Dec-2008 16:06:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motionParamsMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @motionParamsMenu_OutputFcn, ...
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


% --- Executes just before motionParamsMenu is made visible.
function motionParamsMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to motionParamsMenu (see VARARGIN)

% Choose default command line output for motionParamsMenu
handles.output = hObject;

% Set defaults
tmp = get( handles.FigMotionMode_popupmenu,'String' );
data.motion.fig_mode = tmp{get(handles.FigMotionMode_popupmenu,'Value')};
data.motion.fig_deg_per_sec = str2double(get(handles.FigDegPerSec_edit,'String'));
data.motion.fig_dir_rads = str2double(get(handles.FigDirRads_edit,'String'));

% Not yet hooked to callback
data.motion.fig_direction_mode  = 'uniform'; %{'opposing', 'uniform'}

tmp = get( handles.BgMotionMode_popupmenu,'String' );
data.motion.bg_mode = tmp{get(handles.BgMotionMode_popupmenu,'Value')};
data.motion.bg_deg_per_sec = str2double(get(handles.BgDegPerSec_edit,'String'));
data.motion.bg_dir_rads = str2double(get(handles.BgDirRads_edit,'String'));

% Not yet hooked to callback
data.motion.bg_direction_mode  = 'uniform'; %{'opposing', 'uniform'}

tmp = get( handles.FigBgMode_popupmenu,'String' );
data.motion.fig_bg_mode = tmp{get(handles.FigBgMode_popupmenu,'Value')};

% Update handles structure
handles.output = data.motion;
handles.data = data;
guidata(hObject, handles);

% UIWAIT makes motionParamsMenu wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;


% --- Outputs from this function are returned to the command line.
function varargout = motionParamsMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% output
varargout{1} = handles.data.motion;
% quit
delete(handles.figure1);
return;


% --- Executes on selection change in FigMotionMode_popupmenu.
function FigMotionMode_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FigMotionMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents     = get(hObject,'String');
fig_mode =  contents{get(hObject,'Value')};
handles.data.motion.fig_mode = fig_mode;
guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function FigMotionMode_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigMotionMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Go_pushbutton.
function Go_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Go_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
return;


function FigDegPerSec_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FigDegPerSec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FigDegPerSec_edit as text
%        str2double(get(hObject,'String')) returns contents of FigDegPerSec_edit as a double
fig_deg_per_sec = str2double(get(hObject,'String'));
handles.data.motion.fig_deg_per_sec = fig_deg_per_sec;
guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function FigDegPerSec_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigDegPerSec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BgMotionMode_popupmenu.
function BgMotionMode_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to BgMotionMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents     = get(hObject,'String');
bg_mode =  contents{get(hObject,'Value')};
handles.data.motion.bg_mode = bg_mode;
guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function BgMotionMode_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BgMotionMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BgDegPerSec_edit_Callback(hObject, eventdata, handles)
% hObject    handle to BgDegPerSec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bg_deg_per_sec = str2double(get(hObject,'String'));
handles.data.motion.bg_deg_per_sec = bg_deg_per_sec;
guidata(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function BgDegPerSec_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BgDegPerSec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FigDirRads_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FigDirRads_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig_dir_rads = str2double(get(hObject,'String'));
handles.data.motion.fig_dir_rads = fig_dir_rads;
guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function FigDirRads_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigDirRads_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BgDirRads_edit_Callback(hObject, eventdata, handles)
% hObject    handle to BgDirRads_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bg_dir_rads = str2double(get(hObject,'String'));
handles.data.motion.bg_dir_rads = bg_dir_rads;
guidata(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function BgDirRads_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BgDirRads_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FigDir_popupmenu.
function FigDir_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FigDir_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FigDir_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FigDir_popupmenu


% --- Executes during object creation, after setting all properties.
function FigDir_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigDir_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BgDir_popupmenu.
function BgDir_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to BgDir_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns BgDir_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BgDir_popupmenu


% --- Executes during object creation, after setting all properties.
function BgDir_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BgDir_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FigBgMode_popupmenu.
function FigBgMode_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FigBgMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents     = get(hObject,'String');
fig_bg_mode =  contents{get(hObject,'Value')};
handles.data.motion.fig_mode = fig_bg_mode;
guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function FigBgMode_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigBgMode_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


