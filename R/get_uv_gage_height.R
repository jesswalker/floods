#get_uv_gage_height.R
#DOWNLOAD UNIT-VALUE (MEASURED) GAGE HEIGHTS FROM NWIS AND CALCULATE MEDIAN DAILY VALUES
#THIS SCRIPT DOES NOT ADJUST FOR TIME ZONE AND USES REPORTED DATE, WHICH MAY BE UTC NOT LOCAL

library(dataRetrieval)

#ENTER SITES OR READ LIST OF SITE FROM A CSV FILE (ONE COLUMN WITH USGS STAIDs)
sitelist=c('12447390','12205000')
#sitelist=read.csv('sitelist.csv', colClasses='character', header=FALSE)

sitelist=as.vector(t(sitelist))
ns=length(sitelist)
dtst=as.Date('2000-10-01') #START DATE
dtend=as.Date('2017-09-30') #END DATE
tmp.days=seq(dtst,dtend,'day') #VECTOR OF DATES

GHdv=data.frame(array(NA,dim=c(length(tmp.days),ns))) #ARRAY TO RECEIVE DAILY VALUES
dimnames(GHdv)[[1]]=tmp.days
dimnames(GHdv)[[2]]=sitelist

GHmv=data.frame(array(NA,dim=c(length(tmp.days),ns))) #ARRAY TO RECEIVE MONTHLY VALUES
dimnames(GHdv)[[1]]=tmp.days
dimnames(GHdv)[[2]]=sitelist

for (site in sitelist) {uv_available=whatNWISdata(siteNumber = site) #DATA AVAILABLE FROM NWIS

tmp.uva=(uv_available$parm_cd=='00065') & (uv_available$data_type_cd=='uv') #LOGICAL VARIABLE INDICATING WHETHER GAGE HEIGHT DATA ARE AVAILBLE

if(sum(tmp.uva)>0) {uv_available=uv_available[tmp.uva,] #ARE UNIT VALUES AVAILABLE?

{if(max(uv_available$end_date, na.rm=TRUE)>=dtst) {tmp=readNWISuv(site, parameterCd = '00065', startDate=dtst, endDate=dtend)} #READ UNIT-VALUES OF GAGE HEIGHT IN FEET
	
#CALCULATE DAILY MEDIAN
tmp.uvdays=as.Date(GHuv[,1])
tmp=tapply(GHuv[,2],tmp.uvdays,median,na.rm=TRUE)
GHdv[match(names(tmp),dimnames(GHdv)[[1]]),s]=tmp}

write.csv(GHdv,'gage_height_dv.csv')

#CALCULATE MONTHLY MEDIAN
tmp.uvmonths=format(tmp.uvdays, format='%Y-%m')
GHmv=tapply(GHuv[,2],tmp.uvmonths,median,na.rm=TRUE)

write.csv(GHmv,'gage_height_mv.csv')

