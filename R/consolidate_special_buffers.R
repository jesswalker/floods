path.in <- "D:/projects/place/data/tables/test"
setwd(path.in)
files <- list.files(path.in, pattern = "*.csv")

df <- data.frame()
for (file in files) {

for (i in 2:11) {
  print(i)
  filename <- paste0("out", i, ".csv")
  x <-  read.csv(filename, header = T)
  x$date <- as.Date(paste0("2011-",i, "-01"), format = "%Y-%m-%d")
  df <- rbind(df, x)
}

}
df <- df[, c('date', 'huc8', 'X0', 'X1', 'X2')]
names(df) <- c('fid', 'huc8', 'water', 'date')

write.csv(df, file = "D:/projects/place/data/tables/test/buffers_2011_contiguous.csv", row.names = FALSE)


df <- do.call(rbind, lapply(files, read.csv, header=T))
