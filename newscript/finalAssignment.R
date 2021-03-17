---
title: "Deforestation detection"
author:
  - "Christian Terbeck"
  - "Benjamin Dietz"
date: "3/20/2021"
output: html_document
---
  

# import libraries
library(stars)
library(sf)
library(caret)

# setup development environment
folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)

# NDVI data
subdir = IMAGE_DIR = paste(getwd(), "/L8cube_subregion", sep="")
f = paste0(subdir, "/", list.files(subdir))

load("wholeRefData.Rdata")
#plot(refData$AM2016 == 1 & refData$AM2018 == 0)

for (i in f) {
  name = gsub("-", "_", substr(i, nchar(i)-18, nchar(i)-4))
  # NDVI data gets the resolution & extent of refData$AM2015
  #variable = raster(i)
  variable = resample(raster(i), refData$AM2015, method='bilinear')
  assign(name, variable)
}

# help function creates a renames data frame of a raster with a pixelID
preprocessRaster = function(inputRaster, columnName) {
  rasterData = as.data.frame(inputRaster)
  colnames(rasterData)[1] = columnName
  rasterData$pixelID <- 1:nrow(rasterData)
  return(rasterData)
}

# function for creating testdata for data of specific years
createTrainingData = function(startRefRaster, endRefRaster, 
                              startNDVIRaster, endNDVIRaster) {
  # preprocess NDVI data
  startNDVIRaster = preprocessRaster(startNDVIRaster, "startNDVI")
  endNDVIRaster = preprocessRaster(endNDVIRaster, "endNDVI")
  
  output = merge(startNDVIRaster, endNDVIRaster)
  
  # get deforested pixels in reference data
  defRaster = endRefRaster
  defRaster[startRefRaster == 1 & endRefRaster == 0] = 1
  defRaster[!(startRefRaster == 1 & endRefRaster == 0)] = 0
  deforested = preprocessRaster(defRaster, "deforested")
  
  output = merge(output, deforested)
  
  return(output %>% drop_na())
  # r[,1] : reach out to actual data
}

# creating the test data
trainingsData = createTrainingData(
  refData$AM2016, refData$AM2017, NDVI_2016_06_28, NDVI_2017_06_15)

head(trainingsData)

################################################################################
# Take data for both training and testing
################################################################################
split <- createDataPartition(trainingsData$deforested,p = 0.2,list=FALSE)
trainDat <- trainingsData[split,]
testDat <- trainingsData[-split,]

################################################################################
# Model initialization and training
################################################################################
predictors <- c("startNDVI", "endNDVI")
rfModel <- train(trainDat[,predictors],trainDat$deforested,method="rf",
               importance=TRUE,ntree=500,tuneLength = 1)
print(rfModel)


################################################################################
# Model prediction
################################################################################
modelPrediction <- predict(rfModel,trainDat)
ctab <- table(modelPrediction,trainDat$deforested)
confusionMatrix(modelPrediction,trainDat$deforested)

################################################################################
# Calculation of Kappa Index
################################################################################

po= (300+1500+20)/2195 #TODO
pe= (420*470+1625*1600+100*175)/(2195^2)
KI <- (po-pe)/(1-pe)
KI
