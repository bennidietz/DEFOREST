rm(list=ls())
library(raster)
library(sf)
library(caret)
setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/")
### Trainingsdaten laden:
dat <- get(load("trainingsdaten.RData"))

################################################################################
# Subset der Daten erstellen (sonst rechnet es sehr lange)
################################################################################
selection <- createDataPartition(dat$Klasse,p = 0.2,list=FALSE)
trainDat <- dat[selection,]
testDat <- dat[-selection,]
################################################################################
# Modelltraining
################################################################################
# Prädiktoren definieren:
predictors <- c("B02","B03","B04","B08","B8A","B05","B06","B07","B11","B12",
                "NDVI","SD_NDVI_3","SD_NDVI_5")
model <- train(trainDat[,predictors],trainDat$Klasse,method="rf",
               importance=TRUE,ntree=500)


################################################################################
#Trainingsfehler
################################################################################
prediction <- predict(model,trainDat)
ctab <- table(prediction,trainDat$Klasse)
confusionMatrix(prediction,trainDat$Klasse)
################################################################################
#Berechnung: Kappa (bsp Kursfolien)
################################################################################

po= (300+1500+20)/2195
pe= (420*470+1625*1600+100*175)/(2195^2)
KI <- (po-pe)/(1-pe)
KI

################################################################################
#test Fehler
################################################################################
test_pred <- predict(model,testDat)
confusionMatrix(testDat$Klasse,test_pred)

################################################################################
#Kreuzvalidierung
################################################################################
ctrl <- trainControl(method="cv",number = 10)

model_cv <- train(trainDat[,predictors],trainDat$Klasse,method="rf",
               importance=TRUE,ntree=150,trControl=ctrl)

model_cv
model_cv$resample

############################################################################
#Räunmlich
###############################################################################
library(CAST)

ind <- CreateSpacetimeFolds(trainDat,spacevar="ID",k=10)
str(ind)
ctrl <- trainControl(method="cv",index=ind$index)

model_spcv <- train(trainDat[,predictors],trainDat$Klasse,method="rf",
                  importance=TRUE,ntree=150,trControl=ctrl)
model_spcv
model_spcv
boxplot(model_spcv$resample$Kappa)
