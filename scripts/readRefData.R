rm(list = ls())

library("raster")

folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
setwd("..")
setwd("./data")

#NDVI data - adjust path!
NDVIData = raster(paste(getwd(), "ndvi/NDVI_2018-12.tif", sep = "/"))

#downloaded from: http://terrabrasilis.dpi.inpe.br/en/download-2/
#accumulated deforestation data

refDataPath = paste(getwd(), "shp/accumulated_deforestation_1988_2007_biome.shp", sep="/")
refData = read_sf(refDataPath)

#reproject
refDataProj = st_transform(refData, crs="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

#extract
extractedData = extract(NDVIData, refDataProj, df=TRUE)
