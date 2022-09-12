function [nodes_final, coords_final, coords_final_unit] = reorient(Temp_Nodes,Temp_Coordinates,Temp_Coordinates_Unit,cm_nodes,side_indx,RTs)
% The function reorients the aligned bone and subsequent coordinate system
% back to the bones original orientation.
% It requires the nodes and coordinate systems, as well as the rotation and
% translation matricies.

if isempty(RTs.sR_talus) == 0
    nodes_final_i4 = (inv(RTs.sR_talus)*(Temp_Nodes'))';
    coords_final_i4 = (inv(RTs.sR_talus)*(Temp_Coordinates'))';
    coords_final_unit_i4 = (inv(RTs.sR_talus)*(Temp_Coordinates_Unit'))';
elseif isempty(RTs.sT_tibia) == 0
    nodes_final_i6 = (Temp_Nodes' - repmat(RTs.sT_tibia,1,length(Temp_Nodes')))';
    nodes_final_i5 = (inv(RTs.sR_tibia)*(nodes_final_i6'))';
    nodes_final_i4 = ((nodes_final_i5)*inv(RTs.sflip));

    coords_final_i6 = (Temp_Coordinates' - repmat(RTs.sT_tibia,1,length(Temp_Coordinates')))';
    coords_final_i5 = (inv(RTs.sR_tibia)*(coords_final_i6'))';
    coords_final_i4 = ((coords_final_i5)*inv(RTs.sflip));

    coords_final_unit_i6 = (Temp_Coordinates_Unit' - repmat(RTs.sT_tibia,1,length(Temp_Coordinates_Unit')))';
    coords_final_unit_i5 = (inv(RTs.sR_tibia)*(coords_final_unit_i6'))';
    coords_final_unit_i4 = ((coords_final_unit_i5)*inv(RTs.sflip));
else
    nodes_final_i4 = Temp_Nodes;
    coords_final_i4 = Temp_Coordinates;
    coords_final_unit_i4 = Temp_Coordinates_Unit;
end

nodes_final_i3 = (nodes_final_i4' - repmat(RTs.iT,1,length(nodes_final_i4')))';
nodes_final_i2 = (inv(RTs.iR)*(nodes_final_i3'))';
nodes_final_i1 = ((nodes_final_i2)*inv(RTs.iflip));
nodes_final = [nodes_final_i1(:,1) + cm_nodes(1), nodes_final_i1(:,2) + cm_nodes(2), nodes_final_i1(:,3) + cm_nodes(3)];

coords_final_i3 = (coords_final_i4' - repmat(RTs.iT,1,length(coords_final_i4')))';
coords_final_i2 = (inv(RTs.iR)*(coords_final_i3'))';
coords_final_i1 = ((coords_final_i2)*inv(RTs.iflip));
coords_final = [coords_final_i1(:,1) + cm_nodes(1), coords_final_i1(:,2) + cm_nodes(2), coords_final_i1(:,3) + cm_nodes(3)];

coords_final_unit_i3 = (coords_final_unit_i4' - repmat(RTs.iT,1,length(coords_final_unit_i4')))';
coords_final_unit_i2 = (inv(RTs.iR)*(coords_final_unit_i3'))';
coords_final_unit_i1 = ((coords_final_unit_i2)*inv(RTs.iflip));
coords_final_unit = [coords_final_unit_i1(:,1) + cm_nodes(1), coords_final_unit_i1(:,2) + cm_nodes(2), coords_final_unit_i1(:,3) + cm_nodes(3)];

if side_indx == 1
    nodes_final = nodes_final.*[1,1,-1]; % Flip back to right if applicable
    coords_final = coords_final.*[1,1,-1]; % Flip back to right if applicable
    coords_final_unit = coords_final_unit.*[1,1,-1]; % Flip back to right if applicable
end