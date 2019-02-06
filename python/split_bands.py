#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      jjwalker
#
# Created:     23/11/2018
# Copyright:   (c) jjwalker 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import arcpy, os
arcpy.env.workspace = 'd:\projects\place\data\DSWE'
out_folder = os.path.join(arcpy.env.workspace, 'bands')
in_rasters = arcpy.ListRasters()
print(in_rasters)

for in_raster in in_rasters:
    desc = arcpy.Describe(in_raster)
    for band in desc.children:
        bandName = band.name
        band_path = os.path.join(in_raster, bandName)
        out_path = os.path.join(out_folder, bandName + 'tif')
        arcpy.CopyRaster_management(band_path, out_path)
