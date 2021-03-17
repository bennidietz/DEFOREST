rm(list = ls())

library("raster")

folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
setwd("..")
setwd("./data")

img_path = paste(getwd(), "ndvi/NDVI_2014-06.tif", sep="/")

ndvi_grey = raster(img_path)
ndvi_rgb = brick(img_path)

plot(ndvi_grey)
#plotRGB(ndvi_rgb)
