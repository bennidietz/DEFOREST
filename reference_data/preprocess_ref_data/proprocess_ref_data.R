# packages
library(raster)

# set working directory
folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)

# function to proprocess data
preprocessData = function(tifFileName) {
  baseData = raster(tifFileName)
  baseData[baseData!=7] = 0
  baseData[baseData==7] = 1
  reprojectedImage = projectRaster(baseData, crs = "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
  b = as(raster::extent(-66.20014, -65.38620, -9.690152, -8.892918), "SpatialPolygons")
  croppedData = crop(reprojectedImage, b)
}

ref2001 = preprocessData("AMZ_2000_9_2001_8.tif")
ref2002 = preprocessData("AMZ_2001_9_2002_8.tif")
ref2003 = preprocessData("AMZ_2002_9_2003_8.tif")
ref2004 = preprocessData("AMZ_2003_9_2004_8.tif")
ref2005 = preprocessData("AMZ_2004_9_2005_8.tif")
ref2006 = preprocessData("AMZ_2005_9_2006_8.tif")
ref2007 = preprocessData("AMZ_2006_9_2007_8.tif")
ref2008 = preprocessData("AMZ_2007_9_2008_8.tif")
ref2009 = preprocessData("AMZ_2008_9_2009_8.tif")
ref20010 = preprocessData("AMZ_2009_9_2010_8.tif")
ref20011 = preprocessData("AMZ_2010_9_2011_8.tif")
ref20012 = preprocessData("AMZ_2011_9_2012_8.tif")
ref20013 = preprocessData("AMZ_2012_9_2013_8.tif")
ref20014 = preprocessData("AMZ_2013_9_2014_8.tif")
ref20015 = preprocessData("AMZ_2014_9_2015_8.tif")
ref20016 = preprocessData("AMZ_2015_9_2016_8.tif") # jetzt erst aktualisiert wahrscheinlich überschrieben
ref20017 = preprocessData("AMZ_2016_9_2017_8.tif") 
ref20018 = preprocessData("AMZ_2017_9_2018_8.tif")

save(ref2001,file="refData2001.RData")
save(ref2002,file="refData2002.RData")
save(ref2003,file="refData2003.RData")
save(ref2004,file="refData2004.RData")
save(ref2005,file="refData2005.RData")
save(ref2006,file="refData2006.RData")
save(ref2007,file="refData2007.RData")
save(ref2008,file="refData2008.RData")
save(ref2009,file="refData2009.RData")
save(ref2010,file="refData2010.RData")
save(ref2011,file="refData2011.RData")
save(ref2012,file="refData2012.RData")
save(ref2013,file="refData2013.RData")
save(ref2014,file="refData2014.RData")
save(ref2015,file="refData2015.RData")
save(ref2016,file="refData2016.RData")
save(ref2017,file="refData2017.RData")
save(ref2018,file="refData2018.RData")

refData = ref2001
refData$AM2001 = ref2001$layer
refData$AM2002 = ref2002$layer
refData$AM2003 = ref2003$layer
refData$AM2004 = ref2004$layer
refData$AM2005 = ref2005$layer
refData$AM2006 = ref2006$layer
refData$AM2007 = ref2007$layer
refData$AM2008 = ref2008$layer
refData$AM2009 = ref2009$layer
refData$AM2010 = ref2010$layer
refData$AM2011 = ref2011$layer
refData$AM2012 = ref2012$layer
refData$AM2013 = ref2013$layer
refData$AM2014 = ref2014$layer
refData$AM2015 = ref2015$layer
refData$AM2016 = ref2016$layer
refData$AM2017 = ref2017$layer
refData$AM2018 = ref2018$layer

save(refData,file="wholeRefData")
