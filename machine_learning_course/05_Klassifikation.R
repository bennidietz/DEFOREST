rm(list=ls())
library(raster)
library(sf)
library(caret)

setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/")
### Trainingsdaten laden:
trainDat <- get(load("trainingsdaten.RData"))

################################################################################
# Subset der Daten erstellen (sonst rechnet es sehr lange)
################################################################################
selection <- createDataPartition(trainDat$Klasse,p = 0.2,list=FALSE)
trainDat <- trainDat[selection,]

################################################################################
# Modelltraining
################################################################################
# Prädiktoren definieren:
predictors <- c("B02","B03","B04","B08","B8A","B05","B06","B07","B11","B12",
                "NDVI","SD_NDVI_3","SD_NDVI_5")
model <- train(trainDat[,predictors],trainDat$Klasse,method="rf",
               importance=TRUE,ntree=500)
#Alternative:
#model <- train(trainDat[,3:15],trainDat$Klasse,method="rf",
#               importance=TRUE,ntree=500)

print(model)

################################################################################
# Modellvorhersage
################################################################################
sentinel <- stack("Stack/stack.grd")
prediction <- predict(sentinel,model)

################################################################################
# Ergebnisvisualisierung
################################################################################
spplot(prediction)
#einigermaßen sinnvolle Farben definieren:
cols <- c("green","beige","blue","lightgreen",
          "darkgreen",
          "forestgreen",
          "lightblue",
          "red","greenyellow")
# und nochmal in schöner plotten:
spplot(prediction,col.regions=cols,maxpixels=ncell(prediction)*0.5)

################################################################################
# Abschätzung der Variablenwichtigkeit
################################################################################

plot(varImp(model))
