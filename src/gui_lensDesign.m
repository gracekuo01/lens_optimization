function varargout = gui_lensDesign(varargin)
% GUI_LENSDESIGN MATLAB code for gui_lensDesign.fig
%      GUI_LENSDESIGN, by itself, creates a new GUI_LENSDESIGN or raises the existing
%      singleton*.
%
%      H = GUI_LENSDESIGN returns the handle to a new GUI_LENSDESIGN or the handle to
%      the existing singleton*.
%
%      GUI_LENSDESIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LENSDESIGN.M with the given input arguments.
%
%      GUI_LENSDESIGN('Property','Value',...) creates a new GUI_LENSDESIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_lensDesign_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_lensDesign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_lensDesign

% Last Modified by GUIDE v2.5 17-Dec-2015 18:37:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_lensDesign_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_lensDesign_OutputFcn, ...
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


% --- Executes just before gui_lensDesign is made visible.
function gui_lensDesign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_lensDesign (see VARARGIN)

% Choose default command line output for gui_lensDesign
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_lensDesign wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_lensDesign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1,'Data');
data = cell2mat(cellfun(@str2num, data, 'UniformOutput', 0));

clear camera
for i = 1:size(data,1)
    camera(i) = struct('R', data(i,1),   'd', data(i,2), 'n', data(i,3),   'sd', data(i,4));
end
viz_camera(camera, handles.axes1);
set(handles.efl, 'string', calc_efl(camera));

    



% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



function efl_Callback(hObject, eventdata, handles)
% hObject    handle to efl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of efl as text
%        str2double(get(hObject,'String')) returns contents of efl as a double


% --- Executes during object creation, after setting all properties.
function efl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to efl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
