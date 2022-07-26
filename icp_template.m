function [aligned_nodes, flip_out, tibfib_switch, Rot, Tra, Rr] = icp_template(bone_indx,nodes,bone_coord)

addpath('Template_Bones')
if bone_indx == 1 && bone_coord == 1
    TR_template = stlread('Talus_Template.stl');
    a = 2;
elseif bone_indx == 1 && bone_coord == 2
    TR_template2 = stlread('Talus_Template2.stl');
    TR_template = stlread('Talus_Template.stl');
    nodes_template2 = TR_template2.Points;
    con_template2 = TR_template2.ConnectivityList;
    a = 2;
elseif bone_indx == 2
    TR_template = stlread('Calcaneus_Template.stl');
    a = 2;
elseif bone_indx == 3
    TR_template = stlread('Navicular_Template.stl');
    a = 1;
elseif bone_indx == 4
    TR_template = stlread('Cuboid_Template.stl');
    a = 2;
elseif bone_indx == 5
    TR_template = stlread('Medial_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 6
    TR_template = stlread('Intermediate_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 7
    TR_template = stlread('Lateral_Cuneiform_Template.stl');
    a = 3;
elseif bone_indx == 8
    TR_template = stlread('Metatarsal1_Template.stl');
    a = 2;
elseif bone_indx == 9
    TR_template = stlread('Metatarsal2_Template.stl');
    a = 2;
elseif bone_indx == 10
    TR_template = stlread('Metatarsal3_Template.stl');
    a = 2;
elseif bone_indx == 11
    TR_template = stlread('Metatarsal4_Template.stl');
    a = 2;
elseif bone_indx == 12
    TR_template = stlread('Metatarsal5_Template.stl');
    a = 2;
elseif bone_indx == 13 && bone_coord == 1
    TR_template = stlread('Tibia_Template.stl');
    a = 3;
elseif bone_indx == 13 && bone_coord == 2
    TR_template = stlread('Tibia_Template_Facet.stl');
    a = 3;
elseif bone_indx == 14 && bone_coord == 1
    TR_template = stlread('Fibula_Template.stl');
    a = 3;
elseif bone_indx == 14 && bone_coord == 2
    TR_template = stlread('Fibula_Template_Facet.stl');
    a = 3;
end

nodes_template = TR_template.Points;
con_temp = TR_template.ConnectivityList;

if bone_indx == 13 || bone_indx == 14
    nodes_template_length = (max(nodes_template(:,a)) - min(nodes_template(:,a)));
    max_nodes_length = max([(max(nodes(:,1)) - min(nodes(:,1))) (max(nodes(:,2)) - min(nodes(:,2))) (max(nodes(:,3)) - min(nodes(:,3)))]);
    if nodes_template_length/2 > max_nodes_length
        temp = find(nodes_template(:,3) < (min(nodes_template(:,a)) + max_nodes_length));
        nodes_template = [nodes_template(temp,1) nodes_template(temp,2) nodes_template(temp,3)];
        x = [-20:4:10]';
        y = [-10:4:20]';
        [x y] = meshgrid(x,y);
        z = (min(nodes_template(:,a)) + max_nodes_length) .* ones(length(x(:,1)),1);
        k = 1;
        for n = 1:length(z)
            for m = 1:length(z)
                plane(k,:) = [x(m,n) y(m,n) z(1)];
                k = k + 1;
            end
        end

        nodes_template = [nodes_template(:,1) nodes_template(:,2) nodes_template(:,3);
            plane(:,1) plane(:,2) plane(:,3)];

        if bone_coord == 1
        cm_x = mean(nodes_template(:,1));
        cm_y = mean(nodes_template(:,2));
        cm_z = mean(nodes_template(:,3));

        input_ox = nodes_template(:,1) - cm_x;
        input_oy = nodes_template(:,2) - cm_y;
        input_oz = nodes_template(:,3) - cm_z;

        centered_nodes_template = [input_ox input_oy input_oz];
        nodes_template = centered_nodes_template;
        end
        tibfib_switch = 2;

    else
        tibfib_switch = 1;
    end
else
    tibfib_switch = 1;
end

multiplier = (max(nodes_template(:,a)) - min(nodes_template(:,a)))/(max(nodes(:,a)) - min(nodes(:,a)));
if multiplier > 1
    nodes = nodes*multiplier;
end

[R1,T1,ER1] = icp(nodes_template',nodes',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
temp_nodes = (R1*(nodes') + repmat(T1,1,length(nodes')))';
[R1_0,T1_0,ER1_0] = icp(nodes_template',temp_nodes',200,'Matching','kDtree','WorstRejection',0.1);
temp_nodes_0 = (R1_0*(temp_nodes') + repmat(T1_0,1,length(temp_nodes')))';

nodesz90 = temp_nodes*rotz(90);
nodesz180 = temp_nodes*rotz(180);
nodesz270 = temp_nodes*rotz(270);

[Rz90,Tz90,ERz90] = icp(nodes_template',nodesz90',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rz90_wr,Tz90_wr,ERz90_wr] = icp(nodes_template',nodesz90',200,'Matching','kDtree','WorstRejection',0.1);
[Rz180,Tz180,ERz180] = icp(nodes_template',nodesz180',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rz180_wr,Tz180_wr,ERz180_wr] = icp(nodes_template',nodesz180',200,'Matching','kDtree','WorstRejection',0.1);
[Rz270,Tz270,ERz270] = icp(nodes_template',nodesz270',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rz270_wr,Tz270_wr,ERz270_wr] = icp(nodes_template',nodesz270',200,'Matching','kDtree','WorstRejection',0.1);

nodesy90 = temp_nodes*roty(90);
nodesy180 = temp_nodes*roty(180);
nodesy270 = temp_nodes*roty(270);

[Ry90,Ty90,ERy90] = icp(nodes_template',nodesy90',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Ry90_wr,Ty90_wr,ERy90_wr] = icp(nodes_template',nodesy90',200,'Matching','kDtree','WorstRejection',0.1);
[Ry180,Ty180,ERy180] = icp(nodes_template',nodesy180',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Ry180_wr,Ty180_wr,ERy180_wr] = icp(nodes_template',nodesy180',200,'Matching','kDtree','WorstRejection',0.1);
[Ry270,Ty270,ERy270] = icp(nodes_template',nodesy270',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Ry270_wr,Ty270_wr,ERy270_wr] = icp(nodes_template',nodesy270',200,'Matching','kDtree','WorstRejection',0.1);

nodesx90 = temp_nodes*rotx(90);
nodesx180 = temp_nodes*rotx(180);
nodesx270 = temp_nodes*rotx(270);

[Rx90,Tx90,ERx90] = icp(nodes_template',nodesx90',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rx90_wr,Tx90_wr,ERx90_wr] = icp(nodes_template',nodesx90',200,'Matching','kDtree','WorstRejection',0.1);
[Rx180,Tx180,ERx180] = icp(nodes_template',nodesx180',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rx180_wr,Tx180_wr,ERx180_wr] = icp(nodes_template',nodesx180',200,'Matching','kDtree','WorstRejection',0.1);
[Rx270,Tx270,ERx270] = icp(nodes_template',nodesx270',200,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
[Rx270_wr,Tx270_wr,ERx270_wr] = icp(nodes_template',nodesx270',200,'Matching','kDtree','WorstRejection',0.1);

ER_all = [ER1(end),ER1_0(end),ERz90(end),ERz90_wr(end),ERz180(end),ERz180_wr(end),ERz270(end),ERz270_wr(end),...
    ERy90(end),ERy90_wr(end),ERy180(end),ERy180_wr(end),ERy270(end),ERy270_wr(end),...
    ERx90(end),ERx90_wr(end),ERx180(end),ERx180_wr(end),ERx270(end),ERx270_wr(end)];

format long g
ER_min = min(ER_all);
% ER_count = numel(find(ER_all == ER_min))
% 
% if ER_count ~= 1


if ER1(end) == ER_min
    aligned_nodes = temp_nodes;
    flip_out = [1 0 0; 0 1 0; 0 0 1];
    Rot = R1;
    Tra = T1;
elseif ER1_0(end) == ER_min
    aligned_nodes = temp_nodes_0;
    flip_out = [1 0 0; 0 1 0; 0 0 1];
    Rot = R1_0;
    Tra = T1_0;
elseif ERz90(end) == ER_min
    aligned_nodes = (Rz90*(nodesz90') + repmat(Tz90,1,length(nodesz90')))';
    flip_out = -rotz(90);
    Rot = Rz90;
    Tra = Tz90;
elseif ERz90_wr(end) == ER_min
    aligned_nodes = (Rz90_wr*(nodesz90') + repmat(Tz90_wr,1,length(nodesz90')))';
    flip_out = -rotz(90);
    Rot = Rz90_wr;
    Tra = Tz90_wr;
elseif ERz180(end) == ER_min
    aligned_nodes = (Rz180*(nodesz180') + repmat(Tz180,1,length(nodesz180')))';
    flip_out = rotz(180);
    Rot = Rz180;
    Tra = Tz180;
elseif ERz180_wr(end) == ER_min
    aligned_nodes = (Rz180_wr*(nodesz180') + repmat(Tz180_wr,1,length(nodesz180')))';
    flip_out = rotz(180);
    Rot = Rz180_wr;
    Tra = Tz180_wr;
elseif ERz270(end) == ER_min
    aligned_nodes = (Rz270*(nodesz270') + repmat(Tz270,1,length(nodesz270')))';
    flip_out = -rotz(270);
    Rot = Rz270;
    Tra = Tz270;
elseif ERz270_wr(end) == ER_min
    aligned_nodes = (Rz270_wr*(nodesz270') + repmat(Tz270_wr,1,length(nodesz270')))';
    flip_out = -rotz(270);
    Rot = Rz270_wr;
    Tra = Tz270_wr;
elseif ERy90(end) == ER_min
    aligned_nodes = (Ry90*(nodesy90') + repmat(Ty90,1,length(nodesy90')))';
    flip_out = -roty(90);
    Rot = Ry90;
    Tra = Ty90;
elseif ERy90_wr(end) == ER_min
    aligned_nodes = (Ry90_wr*(nodesy90') + repmat(Ty90_wr,1,length(nodesy90')))';
    flip_out = -roty(90);
    Rot = Ry90_wr;
    Tra = Ty90_wr;
elseif ERy180(end) == ER_min
    aligned_nodes = (Ry180*(nodesy180') + repmat(Ty180,1,length(nodesy180')))';
    flip_out = roty(180);
    Rot = Ry180;
    Tra = Ty180;
elseif ERy180_wr(end) == ER_min
    aligned_nodes = (Ry180_wr*(nodesy180') + repmat(Ty180_wr,1,length(nodesy180')))';
    flip_out = roty(180);
    Rot = Ry180_wr;
    Tra = Ty180_wr;
elseif ERy270(end) == ER_min
    aligned_nodes = (Ry270*(nodesy270') + repmat(Ty270,1,length(nodesy270')))';
    flip_out = -roty(270);
    Rot = Ry270;
    Tra = Ty270;
elseif ERy270_wr(end) == ER_min
    aligned_nodes = (Ry270_wr*(nodesy270') + repmat(Ty270_wr,1,length(nodesy270')))';
    flip_out = -roty(270);
    Rot = Ry270_wr;
    Tra = Ty270_wr;
elseif ERx90(end) == ER_min
    aligned_nodes = (Rx90*(nodesx90') + repmat(Tx90,1,length(nodesx90')))';
    flip_out = -rotx(90);
    Rot = Rx90;
    Tra = Tx90;
elseif ERx90_wr(end) == ER_min
    aligned_nodes = (Rx90_wr*(nodesx90') + repmat(Tx90_wr,1,length(nodesx90')))';
    flip_out = -rotx(90);
    Rot = Rx90_wr;
    Tra = Tx90_wr;
elseif ERx180(end) == ER_min
    aligned_nodes = (Rx180*(nodesx180') + repmat(Tx180,1,length(nodesx180')))';
    flip_out = rotx(180);
    Rot = Rx180;
    Tra = Tx180;
elseif ERx180_wr(end) == ER_min
    aligned_nodes = (Rx180_wr*(nodesx180') + repmat(Tx180_wr,1,length(nodesx180')))';
    flip_out = rotx(180);
    Rot = Rx180_wr;
    Tra = Tx180_wr;
elseif ERx270(end) == ER_min
    aligned_nodes = (Rx270*(nodesx270') + repmat(Tx270,1,length(nodesx270')))';
    flip_out = -rotx(270);
    Rot = Rx270;
    Tra = Tx270;
elseif ERx270_wr(end) == ER_min
    aligned_nodes = (Rx270_wr*(nodesx270') + repmat(Tx270_wr,1,length(nodesx270')))';
    flip_out = -rotx(270);
    Rot = Rx270_wr;
    Tra = Tx270_wr;
end

if bone_indx == 1 && bone_coord == 2
    [Rr,Tr,ERr] = icp(nodes_template2',nodes_template',25,'Matching','kDtree','EdgeRejection',logical(1),'Triangulation',con_temp);
    aligned_nodes = (Rr*(aligned_nodes'))';
else
    Rr = [];
end

if multiplier > 1
    aligned_nodes = aligned_nodes/multiplier;
end

% figure()
% plot3(nodes_template(:,1),nodes_template(:,2),nodes_template(:,3),'.k')
% hold on
% plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'.g')
% % plot3(nodes(:,1),nodes(:,2),nodes(:,3),'.r')
% % % plot3(aligned_nodes(:,1),aligned_nodes(:,2),aligned_nodes(:,3),'.g')
% % % plot3(aligned_nodes(anterior_point,1),aligned_nodes(anterior_point,2),aligned_nodes(anterior_point,3),'r.','MarkerSize',100)
% % % plot3(aligned_nodes(medial_point,1),aligned_nodes(medial_point,2),aligned_nodes(medial_point,3),'g.','MarkerSize',100)
% % % plot3(aligned_nodes(superior_point,1),aligned_nodes(superior_point,2),aligned_nodes(superior_point,3),'b.','MarkerSize',100)
% % legend('template','new nodes','anterior','medial','superior')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal
