#water_map is an X x Y x T binary array indicating inundated areas with TRUE values
#gage_index is an X x Y array where the value is the column index for the gage that corresponds to the pixel.
#gage_height is an T x S array with time-series of gage heights with

#CREATE water_map ARRAY

if(exists('water_map')) {
Y=dim(water_map)[[1]] #ROWS
X=dim(water_map)[[2]]#COLUMNS
T=dim(water_map)[[3]] #TIME STEPS
ts_wm=dimnames(water_map)[[3]] #YEAR-MONTH OF WATER MAPS

#READ GAGE HEIGHTS
gage_height=read.table(file=ENTER FILE NAME IN QUOTES, row.names=TRUE)
S=dim(gage_height)[[2]] #GAGES

#HARMONIZE TIME STEPS OF WATER MAP AND GAGE HEIGHTS
ts_gh=dimnames(gage_height)
gage_height=gage_height[ts_gh %in% ts_wm,]
gage_height=gage_height[match(ts_gh,ts_wm),]

mod_coef=array(NA,dim(Y,X))
mod_pvalue=array(NA,dim(Y,X))

for(x in 1:X) {for(y in 1:Y) {gi=gage_index[y,x]
		tmp.mod=lm(water[y,x,]~gage_height[,gi])
		mod_coef[y,x]=summary(tmp.mod)$coefficients[,2]
		mod_pvalue[y,x]=summary(tmp.mod)$p.value[,2]
		}} #CLOSE MODEL LOOP
		
} #CLOSE WATER MAP CONDITIONAL

