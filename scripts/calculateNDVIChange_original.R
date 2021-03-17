library(raster)
library(rasterVis)
library(dplyr)

rm(list = ls())

folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
setwd("..")
setwd("./data")

L8 <- list.files("LC080010662013041901T1-SC20191205091853")
L8_stack <- stack(file.path("LC080010662013041901T1-SC20191205091853", L8))

L5 <- list.files("LC080010662013050501T1-SC20191205091541")
L5_stack <- stack(file.path("LC080010662013050501T1-SC20191205091541", L5))

AI1 <- extent(c(748363, 843076, -479150, -409565))

L5_AI1 <- crop(L5_stack, AI1)
L8_AI1 <- crop(L8_stack, AI1)

#plotRGB(L5_AI1,r=3, g=2, b=1, stretch = "lin", axes=TRUE, main="Echtfarbkomposit der Landsat 5 Szene")
#plotRGB(L8_AI1,r=4, g=3, b=2, stretch = "lin", axes=TRUE, main="Echtfarbkomposit der Landsat 8 Szene")

#NDVI L5 AI1
band4_L5_AI1 = raster(L5_AI1, layer = 4)
band3_L5_AI1 = raster(L5_AI1, layer = 3)
NDVI_L5_AI1 = (band4_L5_AI1 - band3_L5_AI1) / (band4_L5_AI1 + band3_L5_AI1)

#NDVI L8 AI1
band5_L8_AI1 = raster(L8_AI1, layer = 5)
band4_L8_AI1 = raster(L8_AI1, layer = 4)
NDVI_L8_AI1 = (band5_L8_AI1 - band4_L8_AI1) / (band5_L8_AI1 + band4_L8_AI1)

m <- matrix(c(-Inf, 0, NA, 0, 0.3, 1, 0.3, 0.4, 2, 0.4, 0.5, 3, 0.5, 0.6, 4, 0.6, 1,5), ncol = 3, byrow=TRUE)

rc_L5_AI1 <- reclassify(NDVI_L5_AI1, m)

rccut_L5_AI1 <- ratify(rc_L5_AI1)
rat_L5_AI1 <- levels(rccut_L5_AI1)[[1]]
rat_L5_AI1$NDVI_class <- c("very low NDVI", "low NDVI", "medium NDVI", "high NDVI", "very high NDVI")
levels(rccut_L5_AI1) <- rat_L5_AI1


rc_L8_AI1 <- reclassify(NDVI_L8_AI1, m)

rccut_L8_AI1 <- ratify(rc_L8_AI1)
rat_L8_AI1 <- levels(rccut_L8_AI1)[[1]]
rat_L8_AI1$NDVI_class <- c("very low NDVI", "low NDVI", "medium NDVI", "high NDVI", "very high NDVI")
levels(rccut_L8_AI1) <- rat_L8_AI1

levelplot(rccut_L5_AI1, col.regions=rev(terrain.colors(5)), main="Landsat5 NDVI-Werte der AI1")
levelplot(rccut_L8_AI1, col.regions=rev(terrain.colors(5)), main="Landsat8 NDVI-Werte der AI1")

# Relative NDVI-Verteilung L5_AI1
result_L5_AI1 <- prop.table(table(getValues(rc_L5_AI1)))
result_L5_AI1 %>% {.*100} %>%
  round(0)

result_L8_AI1 <- prop.table(table(getValues(rc_L8_AI1)))
result_L8_AI1 %>% {.*100} %>%
  round(0)


