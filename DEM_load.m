function [AOI_DEM, AOI_x, AOI_y] = DEM_load(DEM_fname, DEM_MAT_fname)
% load GeoTIFF and import into Matlab space. Generate a UTM-X and UTM-Y
% grid. Use Topotoolbox GRIDobj
%

% Matlab file does not exist, create
AOI_DEM = GRIDobj(DEM_fname);  % convert to grid obj

% top left corner often works fine for NaN location with most DEM
if AOI_DEM.Z(1,1) <= 0 || isnan(AOI_DEM.Z(1,1))
    idx0 = find(AOI_DEM.Z(1,1) == AOI_DEM.Z);
elseif AOI_DEM.Z(1,end) <= 0 || isnan(AOI_DEM.Z(1,end))
    idx0 = find(AOI_DEM.Z(1,end) == AOI_DEM.Z);
elseif AOI_DEM.Z(end, 1) <= 0 || isnan(AOI_DEM.Z(end,1))
    idx0 = find(AOI_DEM.Z(end, 1) == AOI_DEM.Z);
elseif AOI_DEM.Z(end, end) <= 0 || isnan(AOI_DEM.Z(end,end))
    idx0 = find(AOI_DEM.Z(end, end) == AOI_DEM.Z);
end
if exist('idx0', 'var') ~= 0
    AOI_DEM.Z(idx0) = NaN;
end

try
    utm_x1 = AOI_DEM.georef.BoundingBox(1);
catch ME
    switch ME.identifier
        case 'MATLAB:nonExistentField'
            fprintf('No BoundingBox, using XWorldLimits and YWorldLimits.\n');
            utm_x1 = AOI_DEM.georef.SpatialRef.XWorldLimits(1);
            utm_x2 = AOI_DEM.georef.SpatialRef.XWorldLimits(2);
            utm_y1 = AOI_DEM.georef.SpatialRef.YWorldLimits(1);
            utm_y2 = AOI_DEM.georef.SpatialRef.YWorldLimits(2);
    end
    
    if exist('utm_x1') == 0
        utm_x1 = AOI_DEM.georef.BoundingBox(1);
        utm_x2 = AOI_DEM.georef.BoundingBox(2);
        utm_y1 = AOI_DEM.georef.BoundingBox(3);
        utm_y2 = AOI_DEM.georef.BoundingBox(4);
    end
end


[AOI_x, AOI_y] = meshgrid(utm_x1:AOI_DEM.cellsize:utm_x2-AOI_DEM.cellsize, ...
    utm_y1:AOI_DEM.cellsize:utm_y2-AOI_DEM.cellsize);
AOI_y = flipud(AOI_y);
AOI_x = single(AOI_x); AOI_y = single(AOI_y);

save (DEM_MAT_fname,'AOI_DEM', 'AOI_x', 'AOI_y', '-v7.3');
