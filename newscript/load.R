folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
library(stars)

load("croppedRefData.Rda")

subdir = IMAGE_DIR = paste(getwd(), "/L8cube", sep="")
f = paste0(subdir, "/", list.files(subdir))
(st = read_stars(f))
plot(merge(st))
plot(merge(st), breaks = "equal")

subdir = IMAGE_DIR = paste(getwd(), "/L8cube_subregion", sep="")
f = paste0(subdir, "/", list.files(subdir))
(st = read_stars(f))
plot(merge(st))


# dim(st)[1] # x dim
# dim(st)[2] # y dim
# 
# subtractNDVIs = function(index1, index2):
#   threshold = -0.05
#   third = read_stars((f[3]))
#   third$`NDVI_2015-02-02.tif`[threshold>=st$NDVI_2017.07.01.tif-st$NDVI_2017.06.15.tif] = 1
#   third$`NDVI_2015-02-02.tif`[threshold<st$NDVI_2017.07.01.tif-st$NDVI_2017.06.15.tif] = 0
#   plot(third)
  