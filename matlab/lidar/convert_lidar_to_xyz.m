function [lx, ly, lz] = convert_lidar_to_xyz(lidar_struct, data)

    [h, w] = size(data);
    lx = zeros(h, w);
    ly = zeros(h, w);
    lz = zeros(h, w);

    for r=1:h
        for c=1:w
            lx(r,c) = data(r,c)*(cosd(lidar_struct.beam_altitude_angles(r))*cosd(lidar_struct.h_angle(c)));
            ly(r,c) = -data(r,c)*(cosd(lidar_struct.beam_altitude_angles(r))*sind(lidar_struct.h_angle(c)));
            lz(r,c) = data(r,c)*sind(lidar_struct.beam_altitude_angles(r));
        end
    end

end
