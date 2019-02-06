#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      rpetrakis
#
# Created:     29/10/2018
# Copyright:   (c) rpetrakis 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def main():
    import arcpy
    import os

    # folder with input rasters (TIF)
    ws = r'P:\WalkerCoconino\Projects\Roy\PLACE\Layers\Raster\GEE\For_WriteUp\Multiband\Updated\ParseTesting_ModelOutput'  ### change this folder

    # definition of the classes
    classes = "0 0 0;1 1 1"

    arcpy.env.workspace = ws
    arcpy.env.overwriteOutput = True
    ws_tmp = 'IN_MEMORY'
    arcpy.CheckOutExtension("Spatial")

    # create a list of rasters
    lst_rasters = arcpy.ListRasters()

    # loop through the list of rasters
    cnt = 0
    for raster_name in lst_rasters:
        cnt += 1
        # classify the raster
        raster = os.path.join(ws, raster_name)
        out_ras = os.path.join(ws_tmp, "reclass{0}".format(cnt))
        arcpy.gp.Reclassify_sa(raster, "VALUE", classes, out_ras, "NODATA")

        # print the resulting statistics
        print "\n", raster_name
        PrintStats(out_ras)


def PrintStats(ras):
    # get the statistics and print them
    fld_val = 'Value'
    fld_cnt = 'Count'
    flds = (fld_val, fld_cnt)
    curs = arcpy.SearchCursor(ras, flds)
    for row in curs:
        value = row.getValue(fld_val)
        count = row.getValue(fld_cnt)
        print value, count


if __name__ == '__main__':
    main()