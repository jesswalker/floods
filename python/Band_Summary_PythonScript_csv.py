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
    import arcpy, os, csv

    # folder with input rasters (TIF)
    ws = r'D:\\projects\place\data\test'  ### change this folder

    # definition of the classes
    classes = "0 0 0; 1 1 1"

    arcpy.env.workspace = ws
    arcpy.env.overwriteOutput = True
    ws_tmp = 'IN_MEMORY'
    arcpy.CheckOutExtension("Spatial")

    # create a list of rasters
    lst_rasters = arcpy.ListRasters()
    print lst_rasters

    # open the csv file and set the format
    with open(os.path.join(ws, 'results.csv'), 'w') as file:
        writer = csv.writer(file, delimiter = ',', lineterminator = '\n',)

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

            # get the statistics and print them
            fld_val = 'Value'
            fld_cnt = 'Count'
            flds = (fld_val, fld_cnt)
            curs = arcpy.SearchCursor(out_ras, flds)
            for row in curs:
                value = row.getValue(fld_val)
                count = row.getValue(fld_cnt)
                print value, count
                writer.writerow([raster_name, value, count])


if __name__ == '__main__':
    main()