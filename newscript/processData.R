folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
library(stars)
library(sf)
library(caret)

load("croppedRefData.Rda")

# assuming (reference) data as .tif --> raster("filename.tif")

subdir = IMAGE_DIR = paste(getwd(), "/L8cube", sep="")
f = paste0(subdir, "/", list.files(subdir))
(st = read_stars(f))
plot(merge(st))
plot(merge(st), breaks = "equal")

subdir = IMAGE_DIR = paste(getwd(), "/L8cube_subregion", sep="")
f = paste0(subdir, "/", list.files(subdir))
(st = read_stars(f))
plot(merge(st))


# NDVI change
ndvi_before = raster(f[3])
ndvi_after = raster(f[4])


r = raster(f[3])
projection(croppedRefData)
# "+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"
projection(r)
# "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs"

sampleDat_proj <- st_transform(
  croppedRefData,
  crs="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"
)


# load new reference data
load("wholeRefData.RData")
plot(refData$AM2002 == 1 & refData$AM2006 == 0)


# extract only those raster pixels that are 
# within the polygons of the reference data
ndvi_before = raster(f[3])
ndvi_before$pixelID = 1:nrow(ndvi_before)
ext = extract(ndvi_before, croppedRefData, df=TRUE)
# add a counter for determining the id of each polygone in the reference data
croppedRefData$PolyID <- 1:nrow(croppedRefData)
# merge information for polygons with NDVI data
merged <- merge(ext,croppedRefData,by.x="ID",by.y="PolyID")

save(merged,file="trainingsdata.RData")

################################################################################
# Devide dataset in training data and test data
################################################################################
selection <- createDataPartition(dat$Klasse,p = 0.2,list=FALSE)
trainDat <- dat[selection,]
testDat <- dat[-selection,]

################################################################################
# Model initialization and training
################################################################################
library(caret)
predictors <- c("NDVI")
model <- train(trainDat[,predictors],trainDat$Klasse,method="rf",
               importance=TRUE,ntree=500)
print(model)

################################################################################
# Model prediction
################################################################################
prediction <- predict(model,trainDat)
ctab <- table(prediction,trainDat$Klasse)
confusionMatrix(prediction,trainDat$Klasse)

################################################################################
# Calculation of Kappa Index
################################################################################

po= (300+1500+20)/2195 #TODO
pe= (420*470+1625*1600+100*175)/(2195^2)
KI <- (po-pe)/(1-pe)
KI
                      
################################################################################
# Visulization of results
################################################################################
spplot(prediction)
cols <- c("green","beige")
spplot(prediction,col.regions=cols,maxpixels=ncell(prediction)*0.5)

# subtractNDVIs = function(index1, index2):
#   threshold = -0.05
#   third = read_stars((f[3]))
#   third$`NDVI_2015-02-02.tif`[threshold>=st$NDVI_2017.07.01.tif-st$NDVI_2017.06.15.tif] = 1
#   third$`NDVI_2015-02-02.tif`[threshold<st$NDVI_2017.07.01.tif-st$NDVI_2017.06.15.tif] = 0
#   plot(third)