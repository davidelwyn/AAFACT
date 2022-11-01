%% Main Script for Coordinate System Toolbox
clear, clc, close all

% This main code only requires the users bone model input. Select the
% folder where the file is and then select the bone model(s) you wish the
% apply a coordinate system to.

% Currently, this code works for all bones from the tibia and fibula
% through the metatarsals. It also has an option for multiple coordinate
% systems for the talus, tibia and fibula.

% While it's not neccessary, naming your file with the laterality (_L_ or
% _Left_ etc.) and the name of the bone (_Calcaneus) will speed up the
% process. I recommend a file name similar to this for ease:
% group_#_bone_laterality.stl (ex. ABC_01_Tibia_Right.stl)

% Determine the files in the folder selected
FolderPathName = uigetdir('*.*', 'Select folder with your bones');
addpath(FolderPathName)
files = dir(fullfile(FolderPathName, '*.*'));
files = files(~ismember({files.name},{'.','..'}));

temp = strfind(FolderPathName,'\');
FolderName = FolderPathName(temp(end)+1:end); % Extracts the folder name selected

%% Load all files into list
temp = struct2cell(files);
list_files = temp(1,:);

% Select the models that you want a coordinate system of
[files_indx,~] = listdlg('PromptString',{'Select your bone files'}, 'ListString', list_files, 'SelectionMode','multiple');

all_files = list_files(files_indx)'; % stores all files selected

% Lists for detemining bone and side
list_bone = {'Talus', 'Calcaneus', 'Navicular', 'Cuboid', 'Medial_Cuneiform','Intermediate_Cuneiform',...
    'Lateral_Cuneiform','Metatarsal1','Metatarsal2','Metatarsal3','Metatarsal4','Metatarsal5',...
    'Tibia','Fibula'};
list_bone2 = {'Talus', 'Calcaneus', 'Navicular', 'Cuboid', 'Medial_Cuneiform','Intermediate_Cuneiform',...
    'Lateral_Cuneiform','First_Metatarsal','Second_Metatarsal','Third_Metatarsal','Fourth_Metatarsal','Fifth_Metatarsal',...
    'Tibia','Fibula'};
list_side_folder = {'Right','_R','Left','_L'};
list_side = {'Right','Left'};

%% Iterate through each model selected
for m = 1:length(all_files)
    clear bone_indx side_folder_indx side_indx

    % Extract the name and file extension from the file
    FileName = char(all_files(m));
    [~,name,ext] = fileparts(FileName);
    disp(name)

    % Looks through the folder name for the bone name
    for n = 1:length(list_bone)
        if any(string(extract(FolderName,list_bone(n))) == string(list_bone(n))) ||...
                any(string(extract(FolderName,lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                any(string(extract(FolderName,upper(list_bone(n)))) == upper(string(list_bone(n)))) ||...
                any(string(extract(FolderName,list_bone2(n))) == string(list_bone2(n))) ||...
                any(string(extract(FolderName,lower(list_bone2(n)))) == lower(string(list_bone2(n)))) ||...
                any(string(extract(FolderName,upper(list_bone2(n)))) == upper(string(list_bone2(n))))
            bone_indx = n;
        end
    end

    % If the folder doesn't have the bone name, this looks through the file
    % name for the bone name
    if exist('bone_indx') == 0
        for n = 1:length(list_bone)
            if any(string(extract(FileName,list_bone(n))) == string(list_bone(n))) ||...
                    any(string(extract(FileName,lower(list_bone(n)))) == lower(string(list_bone(n)))) ||...
                    any(string(extract(FileName,upper(list_bone(n)))) == upper(string(list_bone(n)))) ||...
                    any(string(extract(FileName,list_bone2(n))) == string(list_bone2(n))) ||...
                    any(string(extract(FileName,lower(list_bone2(n)))) == lower(string(list_bone2(n)))) ||...
                    any(string(extract(FileName,upper(list_bone2(n)))) == upper(string(list_bone2(n))))
                bone_indx = n;
            end
        end
    end

    % If the folder and the file don't have the bone name, the user must select
    % the bone name
    if exist('bone_indx') == 0
        [bone_indx,~] = listdlg('PromptString', [{strcat('Select which bone this file is:'," ",string(FileName))} {''}], 'ListString', list_bone,'SelectionMode','single');
    end

    % Looks through the folder name for the bone side
    for n = 1:length(list_side_folder)
        if any(string(extract(FolderName,list_side_folder(n))) == string(list_side_folder(n))) ||...
                any(string(extract(FolderName,lower(list_side_folder(n)))) == lower(string(list_side_folder(n)))) ||...
                any(string(extract(FolderName,upper(list_side_folder(n)))) == upper(string(list_side_folder(n))))
            side_folder_indx = n;
        end
    end

    % If the folder doesn't have the bone side, this looks through the file
    % name for the bone side
    if exist('side_folder_indx') == 0
        for n = 1:length(list_side_folder)
            if any(string(extract(FileName,list_side_folder(n))) == string(list_side_folder(n))) ||...
                    any(string(extract(FileName,lower(list_side_folder(n)))) == lower(string(list_side_folder(n)))) ||...
                    any(string(extract(FileName,upper(list_side_folder(n)))) == upper(string(list_side_folder(n))))
                side_folder_indx = n;
            end
        end
    end

    % If the folder and the file don't have the bone side, the user must select
    % the bone side
    if exist('side_folder_indx') && side_folder_indx <= 2
        side_indx = 1;
    elseif exist('side_folder_indx') && side_folder_indx >= 3
        side_indx = 2;
    else
        [side_indx,~] = listdlg('PromptString', [{strcat('Select which side this file is:'," ",string(FileName))} {''}], 'ListString', list_side,'SelectionMode','single');
    end

    %% Load in file based on file type
    if ext == ".k"
        nodes = LoadDataFile(FileName);
    elseif ext == ".stl"
        TR = stlread(FileName);
        nodes = TR.Points;
        conlist = TR.ConnectivityList;
    elseif ext == ".particles"
        nodes = load(FileName);
    elseif ext == ".vtk"
        nodes = LoadDataFile(FileName);
    elseif ext == ".ply"
        ptCloud = pcread(FileName);
        nodes = ptCloud.Location;
    else
        disp('This is not an acceptable file type at this time, please choose either a ".k", ".stl", ".vtk", ".ply" or ".particles" file type.')
        return
    end

    nodes_original = nodes;

    if side_indx == 1
        nodes = nodes.*[1,1,-1]; % Flip all rights to left
    end

    % List of different coordinate systems to choose from
    list_talus = {'Talonavicular CS','Tibiotalar CS','Subtalar CS'};
    list_tibia = {'Center of Mass CS','Center of Tibiotalar Facet CS'};
    list_fibula = {'Center of Mass CS','Center of Talofibular Facet CS'};
    list_calcaneus = {'Calcaneocuboid CS','Subtalar CS'};
    list_yesno = {'Yes','No'};

    if bone_indx == 1
        [bone_coord,~] = listdlg('PromptString', {'Select which talar CS.'}, 'ListString', list_talus,'SelectionMode','single');
    elseif bone_indx == 2
        [bone_coord,~] = listdlg('PromptString', {'Select which calcaneus CS.'}, 'ListString', list_calcaneus,'SelectionMode','single');
    elseif bone_indx == 13
        [bone_coord,~] = listdlg('PromptString', {'Select which tibia CS.'}, 'ListString', list_tibia,'SelectionMode','single');
    elseif bone_indx == 14
        [bone_coord,~] = listdlg('PromptString', {'Select which fibula CS.'}, 'ListString', list_fibula,'SelectionMode','single');
    else
        bone_coord = [];
    end

    %% Plot Original
    %     figure()
    %     plot3(nodes(:,1),nodes(:,2),nodes(:,3),'k.')
    %     hold on
    %     xlabel('X')
    %     ylabel('Y')
    %     zlabel('Z')
    %     axis equal

    %% ICP to Template
    % Align users model to the prealigned template model. This orients the
    % model in a fashion that the superior region is in the positive Z
    % direction, the anterior region is in the positive Y direction, and the
    % medial region is in the positive X direction.
    [nodes,cm_nodes] = center(nodes);
    better_start = 1;
    [aligned_nodes, RTs] = icp_template(bone_indx, nodes, bone_coord, better_start);

    %% Performs coordinate system calculation
    [Temp_Coordinates, Temp_Nodes, Temp_Coordinates_Unit] = CoordinateSystem(aligned_nodes, bone_indx, bone_coord);

    if bone_indx == 1 && bone_coord == 3 % Secondary CS for Talus Subtalar
        [Temp_Coordinates_temp, Temp_Nodes_temp, Temp_Coordinates_Unit_temp] = CoordinateSystem(aligned_nodes, 1, 2);

        Temp_Coordinates = [0 0 0; ((Temp_Coordinates(2,:) + Temp_Coordinates_temp(2,:)).'/2)'
            0 0 0; ((Temp_Coordinates(4,:) + Temp_Coordinates_temp(4,:)).'/2)'
            0 0 0; ((Temp_Coordinates(6,:) + Temp_Coordinates_temp(6,:)).'/2)'];

        Temp_Coordinates_Unit = [0 0 0; ((Temp_Coordinates_Unit(2,:) + Temp_Coordinates_Unit_temp(2,:)).'/2)'
            0 0 0; ((Temp_Coordinates_Unit(4,:) + Temp_Coordinates_Unit_temp(4,:)).'/2)'
            0 0 0; ((Temp_Coordinates_Unit(6,:) + Temp_Coordinates_Unit_temp(6,:)).'/2)'];
    end

    %% Reorient and Translate to Original Input Origin and Orientation
    [nodes_final, coords_final, coords_final_unit] = reorient(Temp_Nodes, Temp_Coordinates, Temp_Coordinates_Unit, cm_nodes, side_indx, RTs);

    %% Final Plotting
    figure()
    plot3(nodes_original(:,1),nodes_original(:,2),nodes_original(:,3),'k.')
    hold on
    arrow(coords_final(1,:),coords_final(2,:),'FaceColor','g','EdgeColor','g','LineWidth',5,'Length',10)
    arrow(coords_final(3,:),coords_final(4,:),'FaceColor','b','EdgeColor','b','LineWidth',5,'Length',10)
    arrow(coords_final(5,:),coords_final(6,:),'FaceColor','r','EdgeColor','r','LineWidth',5,'Length',10)
    legend(' Nodal Points',' AP Axis',' SI Axis',' ML Axis')
    title(strcat('Coordinate System of'," ", char(FileName)),'Interpreter','none')
    text(coords_final(2,1),coords_final(2,2),coords_final(2,3),'   Anterior','HorizontalAlignment','left','FontSize',15,'Color','g');
    text(coords_final(4,1),coords_final(4,2),coords_final(4,3),'   Superior','HorizontalAlignment','left','FontSize',15,'Color','b');
    if side_indx == 1
        text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Lateral','HorizontalAlignment','left','FontSize',15,'Color','r');
    elseif side_indx == 2
        text(coords_final(6,1),coords_final(6,2),coords_final(6,3),'   Medial','HorizontalAlignment','left','FontSize',15,'Color','r');
    end
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal

    %% Save both coordinate systems to spreadsheet
    A = ["Subject"
        "Bone Model"
        "Side"];
    B = [name
        list_bone(bone_indx)
        list_side(side_indx)];
    C = ["Coordinate System at Original Orientation"
        "Origin"
        "AP Axis"
        "SI Axis"
        "ML Axis"
        "Coordinate System at (0,0,0)"
        "Origin"
        "AP Axis"
        "SI Axis"
        "ML Axis"];
    D = ["X" "Y" "Z"];

    if bone_indx == 1 && bone_coord == 1
        name = strcat('TN_',name);
    elseif bone_indx == 1 && bone_coord == 2
        name = strcat('TT_',name);
    elseif bone_indx == 1 && bone_coord == 3
        name = strcat('ST_',name);
    elseif bone_indx == 2 && bone_coord == 1
        name = strcat('CC_',name);
    elseif bone_indx == 2 && bone_coord == 2
        name = strcat('ST_',name);
    end

    if length(name) > 31
        name = name(1:31);
    end

    xlfilename = strcat(FolderPathName,'\CoordinateSystem_',FolderName,'.xlsx');
    writematrix(A,xlfilename,'Sheet',name);
    writecell(B,xlfilename,'Sheet',name,'Range','B1');
    writematrix(C,xlfilename,'Sheet',name,'Range','A5');
    writematrix(D,xlfilename,'Sheet',name,'Range','B5')
    writematrix(D,xlfilename,'Sheet',name,'Range','B10')
    writematrix(coords_final_unit(1,:),xlfilename,'Sheet',name,'Range','B6');
    writematrix(coords_final_unit(2,:),xlfilename,'Sheet',name,'Range','B7');
    writematrix(coords_final_unit(4,:),xlfilename,'Sheet',name,'Range','B8');
    writematrix(coords_final_unit(6,:),xlfilename,'Sheet',name,'Range','B9');
    writematrix(Temp_Coordinates_Unit(1,:),xlfilename,'Sheet',name,'Range','B11');
    writematrix(Temp_Coordinates_Unit(2,:),xlfilename,'Sheet',name,'Range','B12');
    writematrix(Temp_Coordinates_Unit(4,:),xlfilename,'Sheet',name,'Range','B13');
    writematrix(Temp_Coordinates_Unit(6,:),xlfilename,'Sheet',name,'Range','B14');
end

%% Better Starting Point
if length(all_files) == 1 || all(any(isnan(coords_final_unit(:,:))))
    accurate_answer = questdlg('Is the coordinate system accurately assigned to the model?',...
        'Coordiante System','Yes','No','Yes');
    better_starting_point(accurate_answer,nodes,bone_indx,bone_coord,side_indx,FileName,name,list_bone,list_side,FolderPathName,FolderName,cm_nodes,nodes_original)
end
