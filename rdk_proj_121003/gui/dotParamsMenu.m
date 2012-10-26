function varargout = dotParamsMenu(varargin)
% DOTPARAMSMENU M-file for dotParamsMenu.fig
%      DOTPARAMSMENU, by itself, creates a new DOTPARAMSMENU or raises the existing
%      singleton*.
%
%      H = DOTPARAMSMENU returns the handle to a new DOTPARAMSMENU or the handle to
%      the existing singleton*.
%
%      DOTPARAMSMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOTPARAMSMENU.M with the given input arguments.
%
%      DOTPARAMSMENU('Property','Value',...) creates a new DOTPARAMSMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dotParamsMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dotParamsMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dotParamsMenu

% Last Modified by GUIDE v2.5 08-Dec-2008 19:11:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dotParamsMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @dotParamsMenu_OutputFcn, ...
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


% --- Executes just before dotParamsMenu is made visible.
function dotParamsMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dotParamsMenu (see VARARGIN)

% Choose default command line output for dotParamsMenu
handles.output = hObject;

data.differentsizes = get( handles.DifferentSizes_checkbox, 'Value');
data.differentcolors = get( handles.DifferentColors_checkbox, 'Value');
data.density = str2double( get( handles.Density_edit, 'String') );
data.deg = str2double( get( handles.Deg_edit, 'String') );
data.f_kill = str2double( get( handles.Fkill_edit, 'String') );
data.shape = get( handles.Shape_popupmenu, 'Value')-1;
data.dimensionality = get( handles.Dimensionality_popupmenu, 'Value')+1;
tmp = get(handles.Distrib_popupmenu,'String');
data.distrib = tmp{get(handles.Distrib_popupmenu,'Value')};
data.useDotDefaults = 0;

% Update handles structure
handles.data = data;

guidata(hObject, handles);

% UIWAIT makes dotParamsMenu wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;



% --- Outputs from this function are returned to the command line.
function varargout = dotParamsMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.data;
delete(handles.figure1);
return;

% --- Executes on button press in DifferentSizes_checkbox.
function DifferentSizes_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to DifferentSizes_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

differentsizes = get(hObject,'Value');
handles.data.differentsizes = differentsizes;
guidata(hObject, handles);
return;


% --- Executes on button press in DifferentColors_checkbox.
function DifferentColors_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to DifferentColors_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

differentcolors = get(hObject,'Value');
handles.data.differentcolors = differentcolors;
guidata(hObject, handles);
return;


function Density_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Density_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Density_edit as text

density = str2double(get(hObject,'String'));
handles.data.density = density;
guidata(hObject, handles);
return;



% --- Executes during object creation, after setting all properties.
function Density_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Density_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Deg_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Deg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Deg_edit as text
deg = str2double(get(hObject,'String'));
handles.data.deg = deg;
guidata(hObject, handles);
return;


% --- Executes during object creation, after setting all properties.
function Deg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Deg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fkill_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Fkill_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f_kill = str2double(get(hObject,'String'));
handles.data.f_kill = f_kill;
guidata(hObject, handles);
return;


% --- Executes during object creation, after setting all properties.
function Fkill_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fkill_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Shape_popupmenu.
function Shape_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Shape_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shape_index = get(hObject,'Value');
shape = shape_index-1;
handles.data.shape = shape;
guidata(hObject, handles);
return;



% --- Executes during object creation, after setting all properties.
function Shape_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Shape_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Dimensionality_popupmenu.
function Dimensionality_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Dimensionality_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(hObject,'String');
dimensionality = str2double( contents{get(hObject,'Value')} );
handles.data.dimensionality = dimensionality;
guidata(hObject, handles);
return;


% --- Executes during object creation, after setting all properties.
function Dimensionality_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dimensionality_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Distrib_popupmenu.
function Distrib_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Distrib_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
distrib = contents{get(hObject,'Value')};
handles.data.distrib = distrib;
guidata(hObject, handles);
return;


% --- Executes during object creation, after setting all properties.
function Distrib_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Distrib_popupmenu (see GCBO)
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
