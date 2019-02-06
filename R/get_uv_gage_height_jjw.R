#get_uv_gage_height.R
#DOWNLOAD UNIT-VALUE (MEASURED) GAGE HEIGHTS FROM NWIS AND CALCULATE MEDIAN DAILY VALUES
#THIS SCRIPT DOES NOT ADJUST FOR TIME ZONE AND USES REPORTED DATE, WHICH MAY BE UTC NOT LOCAL


library(dataRetrieval)
library(data.table) #fread

path.out <- "D:/projects/place/data/tables/medians"

# -------------------------------------------------------
# Stream gage - read in gage metadata for CV HUCs
# -------------------------------------------------------

# Narrow the list of desired gages based on the data available in each

huc_info <- "D:/projects/place/data/tables/central_valley_huc8_nwis_info.csv"

if (file.exists(huc_info)) {
  message('Getting existing HUC8 info file')
  g <-  read.csv(huc_info, header = T)
} else {
  message('Generating HUC8 info file')
  hucs_all <- 
     c('18020002', '18020003','18020004', '18020005', '18020104', '18020111', '18020115',
               '18020116', '18020121', '18020122', '18020123', '18020125', '18020126', '18020128', '18020129', '18020151',
               '18020152', '18020153', '18020154', '18020155', '18020156', '18020157', '18020158', '18020159', '18020161',
               '18020162', 
              c('18020163', '18030001', '18030002', '18030003', '18030004', '18030005', '18030006', '18030007',
              '18030009', '18030010', '18030012', '18040001', '18040002','18040003', '18040006', '18040007',
              '18040008', '18040009', '18040010', '18040011', '18040012', '18040013', '18040014', '18040051')

# Get general info about all gages in Central Valley HUCs from NWIS
  gage_info <- function(x) {
    df <- fread(sprintf("https://waterservices.usgs.gov/nwis/site/?format=rdb&huc=%s&seriesCatalogOutput=true&siteStatus=all&hasDataTypeCd=dv,aw", x), check.names = FALSE, header = TRUE)
  }

# Consolidate all files
  g <- do.call(rbind, lapply(hucs_all, gage_info))
}  

# ------------------------------------------------
# Stream gage - set criteria for gage selection
# ------------------------------------------------

# Format dates of data retrieval
  g$begin_date <- as.Date(g$begin_date, format = "%Y-%m-%d")
  g$end_date <- as.Date(g$end_date, format = "%Y-%m-%d")

#write.csv(g, file = "D:/projects/place/data/tables/central_valley_huc8_nwis_info.csv", row.names = FALSE

# Get gages that have an end date past 2010
  g.sub <- subset(g, end_date > "2010-01-01")

# site_no needs to be a character
  g.sub$site_no <- as.character(g.sub$site_no)

# Get unique sites
sites <- unique(g.sub$site_no)

# Make sure site names have 8 characters; others aren't recognized in the automatic retrieval URL
sites <- subset(sites, nchar(sites) == 8)

# Make a file with unique sites and corresponding HUC #
site_info <- as.data.frame(g[, c('site_no', 'huc_cd')])
site_info <- site_info[-1, ]
site_info <- unique(site_info[c("site_no", "huc_cd")])


#ENTER SITES OR READ LIST OF SITES FROM A CSV FILE (ONE COLUMN WITH USGS STAIDs)
nsites <- length(sites)
dtst <- as.Date('1984-01-01') #START DATE
dtend <- as.Date('2017-01-01') #END DATE
tmp.days <- data.frame(seq(dtst, dtend, 'day')) #VECTOR OF DATES
colnames(tmp.days) <-  "date"

ghdv <- tmp.days

# ------------------------------------------------
# Read data into file
# ------------------------------------------------

for (site in sites) {
  
  message(paste0('Getting info for site ', site))
  uv_available <- whatNWISdata(site = site) #DATA AVAILABLE FROM NWIS
  tmp.uva <- (uv_available$parm_cd == '00065') & (uv_available$data_type_cd %in% c('uv', 'iv', 'rt')) #LOGICAL VARIABLE INDICATING WHETHER GAGE HEIGHT DATA ARE AVAILBLE
  
  #If available, read unit values of gage height in feet
  if(sum(tmp.uva) > 0) {
    uv_available <- uv_available[tmp.uva, ] 
    
    if (max(uv_available$end_date, na.rm = TRUE) >= dtst) {
      tmp <- readNWISuv(site, parameterCd = '00065', startDate = dtst, endDate = dtend)
      if (dim(tmp)[1] != 0) {
        ghuv <- tmp[c("dateTime", "X_00065_00000")]
	
#CALCULATE DAILY MEDIAN
        tmp$date = as.Date(ghuv[, 1])
        tmp = tapply(ghuv[, 2], tmp$date, median, na.rm = TRUE)
        tmp <- as.data.frame.table(tmp)
        colnames(tmp) <- c('date', site)
        tmp$date <- as.Date(tmp$date, format = "%Y-%m-%d")
        ghdv <- merge(ghdv, tmp, by = 'date', all.x = TRUE)
        
        
# Calculate monthly median
        tmp.uvmonths = format(tmp$date, format='%Y-%m')
        GHmv=tapply(GHuv[,2],tmp.uvmonths,median,na.rm=TRUE)

      }
    }
  }
}
#write.csv(ghdv, file = file.path(path.out, paste0(as.character(site), '_median_gage_height_dv.csv')), 
          row.names = FALSE)
