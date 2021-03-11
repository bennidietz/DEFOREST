# Beispielskript für Termin 03: Prädiktoren berechnen

rm(list=ls()) # remove all variables from current environment
library(raster)
################################################################################
# set working directory (location of the images)'
setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/02_FE/S2B_MSIL1C_20190418T104029_N0207_R008_T32ULC_20190418T125423.SAFE/GRANULE/L1C_T32ULC_A011045_20190418T104115/IMG_DATA/")

# read a stack for the 10m channels and one for teh 20m channels:
senstack_10 <- stack("T32ULC_20190418T104029_B02.jp2",
                     "T32ULC_20190418T104029_B03.jp2",
                     "T32ULC_20190418T104029_B04.jp2",
                     "T32ULC_20190418T104029_B08.jp2")

senstack_20 <- stack("T32ULC_20190418T104029_B05.jp2",
                     "T32ULC_20190418T104029_B06.jp2",
                     "T32ULC_20190418T104029_B07.jp2",
                     "T32ULC_20190418T104029_B11.jp2",
                     "T32ULC_20190418T104029_B12.jp2",
                     "T32ULC_20190418T104029_B8A.jp2")
# crop to the extent of the study area
senstack_10 <- crop(senstack_10,c(390309.5, 418741.3, 5746125.4,5768919.6))
senstack_20 <- crop(senstack_20,c(390309.5, 418741.3, 5746125.4,5768919.6))

#resample to 20m, stack all channels, write to disk.
senstack_20_res <- resample(senstack_20,senstack_10)
senstack_all <- stack(senstack_10,senstack_20_res)
writeRaster(senstack_all,"/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/Sen_TileA.grd",
            overwrite=TRUE)

################################################################################
#do all the same for the second tile:
rm(list=ls())
setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/02_FE/S2B_MSIL1C_20190418T104029_N0207_R008_T32UMC_20190418T125423.SAFE/GRANULE/L1C_T32UMC_A011045_20190418T104115/IMG_DATA/")

senstack_10 <- stack("T32UMC_20190418T104029_B02.jp2",
                     "T32UMC_20190418T104029_B03.jp2",
                     "T32UMC_20190418T104029_B04.jp2",
                     "T32UMC_20190418T104029_B08.jp2")
senstack_20 <- stack("T32UMC_20190418T104029_B05.jp2",
                     "T32UMC_20190418T104029_B06.jp2",
                     "T32UMC_20190418T104029_B07.jp2",
                     "T32UMC_20190418T104029_B11.jp2",
                     "T32UMC_20190418T104029_B12.jp2",
                     "T32UMC_20190418T104029_B8A.jp2")

senstack_10 <- crop(senstack_10,c(390309.5, 418741.3, 5746125.4,5768919.6))
senstack_20 <- crop(senstack_20,c(390309.5, 418741.3, 5746125.4,5768919.6))
senstack_20_res <- resample(senstack_20,senstack_10)
senstack_all <- stack(senstack_10,senstack_20_res)

writeRaster(senstack_all,"/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/Sen_TileB.grd",
            overwrite=TRUE)


################################################################################
# create a mosaic of both tiles
setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/")
tileA <- stack("Sen_TileA.grd")
tileB <- stack("Sen_TileB.grd")
combined <- mosaic(tileA,tileB,fun=mean)

#adapt layer names (make sure they match!)
identical(substr(names(tileA),nchar(names(tileA))-2,nchar(names(tileA))),
          substr(names(tileB),nchar(names(tileB))-2,nchar(names(tileB))))
names(combined) <- substr(names(tileA),nchar(names(tileA))-2,nchar(names(tileA)))

#calculate the NDVI and add as additonal layer to the stack
combined$NDVI <- (combined$B08-combined$B04)/(combined$B08+combined$B04)


