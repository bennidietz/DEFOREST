rm(list=ls())
library(raster)
library(sf)
library(caret)

setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/")

################################################################################
### Projections
################################################################################
sampleDat <- read_sf("sample_data/sample_data.shp")
roads <- read_sf("04_projections/roads.shp")
sentinel <- stack("Stack/stack.grd")


plotRGB(sentinel,stretch="lin",r=3,g=2,b=1,axes=T)
plot(roads,add=TRUE)
plot(sampleDat,add=TRUE) #hier passiert nichts. also kein "on the fly"

### Umprojizieren:
sampleDat_proj <- st_transform(sampleDat,crs="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
#oder: st_transform(sampleDat,crs=projection(sentinel))

plotRGB(sentinel,stretch="lin",r=3,g=2,b=1,axes=T)
plot(sampleDat_proj,add=T,col="red")

################################################################################
### Sentinel Daten für Polygone extrahieren
################################################################################
extr <- extract(sentinel,sampleDat_proj,df=TRUE)
#Info über PolygonID ergänzen:
sampleDat_proj$PolyID <- 1:nrow(sampleDat_proj)
#Merge:
merged <- merge(extr,sampleDat_proj,by.x="ID",by.y="PolyID")
#Merge mit Landnutzungsinfo:
lookup <- data.frame("ID"=1:9,
                     "Klasse"=c("Gewaesser","Siedlungsgebiet","Feld_bepfl","Feld_unbepfl",
                                "Laubwald","Nadelwald","Mischwald","Renat_Feuchtw","StrGruenland"))
merged <- merge(merged,lookup,by.x="class",by.y="ID")
save(merged,file="trainingsdaten.RData")

################################################################################
### Deskriptive und visuelle Datenanalyse
################################################################################
boxplot(merged$NDVI~merged$Klasse)
boxplot(merged$SD_NDVI_3~merged$Klasse)

featurePlot(merged[,c(3:6,13)], factor(merged$Klasse),plot="pairs",
            auto.key = list(columns = 2)) 
