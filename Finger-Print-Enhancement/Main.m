function varargout = Main(varargin)
% MAIN MATLAB code for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 24-Jan-2020 17:16:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.Load_Image,'enable','on');
set(handles.Binarize_Image,'enable','off');
set(handles.Thining_image,'enable','off');
set(handles.Find_Minuta,'enable','off');
set(handles.Remove_Flase_Minutia,'enable','off');

set(handles.Orignal_Image,'enable','off');
set(handles.Skeleton,'enable','off');
set(handles.Termination,'enable','off');
set(handles.Bifurcation,'enable','off');
set(handles.Save_Minutia,'enable','off')


% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_Image.
function Load_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[f,rep]=uigetfile('*.jpg');
OriginalImage =imread([rep,f]);
OriginalImage = imresize(OriginalImage,[300 300]);
set(handles.Original_Image,'enable','on');
set(handles.Display,'enable','on');
set(handles.Original_Image,'value',1);
setappdata(handles.Main,'OriginalImage',OriginalImage);

Display_Callback(handles.Display,eventdata,handles);



% --- Executes on button press in Binarize_Image.
function Binarize_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Binarize_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I=getappdata(handles.Main,'Original_Image');
if get(handles.Binarize_Image,'value')==1
    BinarizedImage=I(:,:,1)>160;
end

setappdata(handles.Main,'BinarizedImage',BinarizedImage);

set(handles.Thining_image,'enable','on')

axes(handles.axes1)
image(255*BinarizedImage),colormap(gray)
set(gca,'tag','axes1')



% --- Executes on button press in Thining_image.
function Thining_image_Callback(hObject, eventdata, handles)
% hObject    handle to Thining_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I=getappdata(handles.Main,'BinarizedImage');
Skeleton=bwmorph(~I,'thin','inf');

setappdata(handles.Main,'Skeleton',Skeleton);

set(handles.Skeleton,'enable','on')
set(handles.FindMinutia,'enable','on')

axes(handles.axes1)
image(255*Skeleton)
set(gca,'tag','axes1')
% --- Executes on button press in FindMinutia.
function FindMinutia_Callback(hObject, eventdata, handles)
% hObject    handle to FindMinutia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I=getappdata(handles.Main,'Skeleton');
axes(handles.axes1)
imshow(255*I)

fun=@minutie;
L = nlfilter(I,[3 3],fun);

%% Termination
LFin=(L==1);
LFinLab=bwlabel(LFin);
propFin=regionprops(LFinLab,'Centroid');
CentroidFin=round(cat(1,propFin(:).Centroid));
CentroidFinX=CentroidFin(:,1);
CentroidFinY=CentroidFin(:,2);
axes(handles.axes1)
hold on
plot(CentroidFinX,CentroidFinY,'ro')

%% Bifurcation
LSep=(L==3);
LSepLab=bwlabel(LSep);
propSep=regionprops(LSepLab,'Centroid','Image');
CentroidSep=round(cat(1,propSep(:).Centroid));
CentroidSepX=CentroidSep(:,1);
CentroidSepY=CentroidSep(:,2);
plot(CentroidSepX,CentroidSepY,'go')
hold off
set(gca,'tag','axes1')



setappdata(handles.Main,'CentroidFinX',CentroidFinX);
setappdata(handles.Main,'CentroidFinY',CentroidFinY);
setappdata(handles.Main,'CentroidSepX',CentroidSepX);
setappdata(handles.Main,'CentroidSepY',CentroidSepY);

set(handles.Remove_Flase_Minutia,'enable','on')
set(handles.Termination,'enable','on')
set(handles.Bifurcation,'enable','on')
set(handles.ExportMinutia,'enable','on');


% --- Executes on button press in Find_Minuta.
function Find_Minuta_Callback(hObject, eventdata, handles)
% hObject    handle to Find_Minuta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Remove_Flase_Minutia.
function Remove_Flase_Minutia_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_Flase_Minutia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CentroidFinX=getappdata(handles.Main,'CentroidFinX');
CentroidFinY=getappdata(handles.Main,'CentroidFinY');
CentroidSepX=getappdata(handles.Main,'CentroidSepX');
CentroidSepY=getappdata(handles.Main,'CentroidSepY');
D=6;
%% Process 1
Distance=DistEuclidian([CentroidSepX CentroidSepY],[CentroidFinX CentroidFinY]);
SpuriousMinutae=Distance<D;
[i,j]=find(SpuriousMinutae);
CentroidSepX(i)=[];
CentroidSepY(i)=[];
CentroidFinX(j)=[];
CentroidFinY(j)=[];
%% Process 2
Distance=DistEuclidian([CentroidSepX CentroidSepY]);
SpuriousMinutae=Distance<D;
[i,j]=find(SpuriousMinutae);
CentroidSepX(i)=[];
CentroidSepY(i)=[];

%% Process 3
Distance=DistEuclidian([CentroidFinX CentroidFinY]);
SpuriousMinutae=Distance<D;
[i,j]=find(SpuriousMinutae);
CentroidFinX(i)=[];
CentroidFinY(i)=[];


I=getappdata(handles.Main,'Skeleton');
axes(handles.axes1)
imshow(255*I)
hold on
plot(CentroidFinX,CentroidFinY,'ro')
plot(CentroidSepX,CentroidSepY,'go')
hold off
set(gca,'tag','axes1')

setappdata(handles.Main,'CentroidFinX',CentroidFinX);
setappdata(handles.Main,'CentroidFinY',CentroidFinY);
setappdata(handles.Main,'CentroidSepX',CentroidSepX);
setappdata(handles.Main,'CentroidSepY',CentroidSepY);

set(handles.ManualROI,'enable','on')
set(handles.AutomaticROI,'enable','on')
set(handles.RegionOfInterest,'enable','on')


% --- Executes on button press in Save_Minutia.
function Save_Minutia_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Minutia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CentroidSepX=getappdata(handles.Main,'CentroidSepX');
CentroidSepY=getappdata(handles.Main,'CentroidSepY');
OrientationSep=getappdata(handles.Main,'OrientationSep');
MinutiaSep=[CentroidSepX CentroidSepY OrientationSep];
CentroidFinX=getappdata(handles.Main,'CentroidFinX');
CentroidFinY=getappdata(handles.Main,'CentroidFinY');
OrientationFin=getappdata(handles.Main,'OrientationFin');
MinutiaFin=[CentroidFinX CentroidFinY OrientationFin];
prompt = {'Enter file name:'};
dlg_title = 'Input for Minutia Save';
num_lines = 1;
def = {'Sharmini'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
saveMinutia(answer{1},MinutiaFin,MinutiaSep);


% --- Executes on button press in Display.
function Display_Callback(hObject, eventdata, handles)
% hObject    handle to Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2)
g1=get(handles.Original_Image,'value');
g3=get(handles.Skeleton,'value');
if g1==1
    image(getappdata(handles.Main,'OriginalImage'));
elseif g3==1
    image(255*getappdata(handles.Main,'Skeleton'));
else
    image(ones(200,200,3));
end


hold on
h1=get(handles.Termination,'value');
h2=get(handles.Bifurcation,'value');
if h1==1
    CentroidFinX=getappdata(handles.Main,'CentroidFinX');
    CentroidFinY=getappdata(handles.Main,'CentroidFinY');
    plot(CentroidFinX,CentroidFinY,'ro','linewidth',2)
    OrientationFin=getappdata(handles.Main,'OrientationFin');
    length(OrientationFin)
    if ~isempty(OrientationFin)

        dxFin=sin(OrientationFin)*5;
        dyFin=cos(OrientationFin)*5;
        hold on

        plot([CentroidFinX CentroidFinX+dyFin]',...
            [CentroidFinY CentroidFinY-dxFin]','r','linewidth',2)
    end
end
if h2==1
    CentroidSepX=getappdata(handles.Main,'CentroidSepX');
    CentroidSepY=getappdata(handles.Main,'CentroidSepY');
    plot(CentroidSepX,CentroidSepY,'go','linewidth',2)
    OrientationSep=getappdata(handles.Main,'OrientationSep');
    if ~isempty(OrientationSep)
        dxSep=sin(OrientationSep)*5;
        dySep=cos(OrientationSep)*5;
        OrientationLinesX=[CentroidSepX CentroidSepX+dySep(:,1);CentroidSepX CentroidSepX+dySep(:,2);CentroidSepX CentroidSepX+dySep(:,3)]';
        OrientationLinesY=[CentroidSepY CentroidSepY-dxSep(:,1);CentroidSepY CentroidSepY-dxSep(:,2);CentroidSepY CentroidSepY-dxSep(:,3)]';

        plot(OrientationLinesX,OrientationLinesY,'g','linewidth',2)
    end
end
hold off
set(gca,'tag','axes2')



% --- Executes on button press in Termination.
function Termination_Callback(hObject, eventdata, handles)
% hObject    handle to Termination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Termination


% --- Executes on button press in Bifurcation.
function Bifurcation_Callback(hObject, eventdata, handles)
% hObject    handle to Bifurcation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bifurcation


% --- Executes on button press in Original_Image.
function Original_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Original_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Original_Image
if get(hObject,'value')==1
    set(handles.WhiteImage,'value',0)
    set(handles.Skeleton,'value',0)
end


% --- Executes on button press in Skeleton.
function Skeleton_Callback(hObject, eventdata, handles)
% hObject    handle to Skeleton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Skeleton
if get(hObject,'value')==1
    set(handles.Original_Image,'value',0)
    set(handles.White_image,'value',0)
end


% --- Executes on button press in White_image.
function White_image_Callback(hObject, eventdata, handles)
% hObject    handle to White_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of White_image
if get(hObject,'value')==1
    set(handles.Original_Image,'value',0)
    set(handles.Skeleton,'value',0)
end


% --- Executes on button press in Region_of_Interest.
function Region_of_Interest_Callback(hObject, eventdata, handles)
% hObject    handle to Region_of_Interest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Orientation.
function Orientation_Callback(hObject, eventdata, handles)
% hObject    handle to Orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Validation.
function Validation_Callback(hObject, eventdata, handles)
% hObject    handle to Validation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Orignal_Image.
function Orignal_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Orignal_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Orignal_Image


% --- Executes on button press in White_Image.
function White_Image_Callback(hObject, eventdata, handles)
% hObject    handle to White_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of White_Image
