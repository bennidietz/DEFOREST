# load necessary packages
library(raster)

# read landuse data of Mato Grosso
folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
setwd("..")
setwd("./data")
setwd("./landuse_mato_grosso")

imageOfYear = function(yearString) {
  fileName = paste('mt_',yearString,'_v3_1.tif', sep="")
  return (raster(fileName))
}

cellCountOfRaster = function(raster, index) {
  rasterValues = values(raster)
  return ( length(subset(rasterValues, rasterValues == index)) )
}

areaOfRasterIndex = function(raster, index) {
  return ( cellCountOfRaster(raster, index) * res(raster)^2 )
}

stringOutputCellCount = function(raster, index) {
  count = cellCountOfRaster(raster, index)
  percent = (count * 100 / length(raster[!is.na(raster)]))
  return ( paste(count, " (",format(round(percent, 2), nsmall = 2) ,"%)", sep="") )
}

analyseChange = function(startYear, endYear) {
  startForest = imageOfYear(startYear) == 3 # 1 if forest; 0 if not forest
  endForest = imageOfYear(endYear) == 3 # 1 if forest; 0 if not forest
  diffForestRaster = startForest - endForest
  plot(diffForestRaster)
  print(paste("Number of cells remainins the same:",
              stringOutputCellCount(diffForestRaster, 0)))
  print(paste("Number of cells for new forest:",
              stringOutputCellCount(diffForestRaster, -1)))
  print(paste("Number of cells deforested:",
              stringOutputCellCount(diffForestRaster, 1)))
}

analyseChange("2006", "2016")
