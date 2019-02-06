#  This script loads polygon river extents,
#  converts them from geographic to UTM,
#  rasterizes them,
#  them retrieves the amount of river area in each HUC.
#  JWalker 11/20/18

rm(list=ls())

# Load required libraries
library(sf)
library(raster)
library(rgdal)
library(sp)
library(tidyverse)

# Load HUCs as shapefile
path.in <- "D:/projects/place/gis/data"
huc8_name <- "WBDHU8_Central_Valley/WBDHU8_Central_Valley_UMT10_stripped.shp"
huc8s <- shapefile(file.path(path.in, huc8_name))

# make sure hucs projection is UTM
huc8s <- spTransform(huc8s, crs("+init=epsg:32610"))

# Load river extents as shapefiles                            
stream_name <- "rg_ex_monthly_water_2011_02_clip_dissolve_prox.shp"
stream <- shapefile(file.path(path.in, "test", stream_name))

stream <-  st_read("rg_ex_monthly_water_2011_02_clip_dissolve_prox.shp")

# Reproject to UTM prior to converting to raster
# UTM 10N = EPSG 32610
stream_utm <- spTransform(stream, crs("+init=epsg:32610"))
crs.utm <- CRS("+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

#####  Raster
# Create a raster that has the extent of the shapefile
r <-  raster(ext = extent(stream_utm), crs = projection(stream_utm), res = 30)

# Set values of raster to 1
values(r) <- 1

# Mask to show only raster cells
stream_outline <- raster::mask(r, stream_utm)

# Convert to 30m raster 
r.streams <- rasterize(stream_utm, r)

proj4string(huc8s_utm) <- crs.utm
proj4string(r.streams) <- crs.utm

over(huc8s_utm, r.streams)

result <- data.frame() #empty result dataframe 

system.time(
  for (i in 1:nrow(huc8s_utm)) { #this is the number of polygons to iterate through
    huc <- huc8s_utm[i,] #selects a single polygon
    message('cropping')
    clip1 <- crop(r.streams, extent(huc)) #crops the raster to the extent of the polygon, I do this first because it speeds the mask up
    message('clipping ')
    clip2 <- mask(clip1, huc) #crops the raster to the polygon boundary
    message('extracting')
    ext <- extract(clip2, huc) #extracts data from the raster based on the polygon bound
    message('creating table')
    tab <- lapply(ext, table) #makes a table of the extract output
    s <- sum(tab[[1]])  #sums the table for percentage calculation
    mat <- as.data.frame(tab) 
    mat2 <- as.data.frame(tab[[1]]/s) #calculates percent
    final <- cbind(single@data$NAME, mat, mat2$Freq) #combines into single dataframe
    result <- rbind(final,result)
  })








#
#test <- intersect(huc8s_utm, r.streams)
crs(r.streams)
crs(r)
crs(huc8s_utm)
huc8s_utm <- spTransform(huc8s, crs("+init=epsg:32610"))
