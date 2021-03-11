# Beispielskript für Termin 02: Fernerkundungsdaten in R

rm(list=ls()) # remove all variables from current environment
library(raster)

# set working directory (location of the images)'
setwd("/home/hanna/Documents/Lehre/Muenster/SoSe_2019/ML/Daten_Uebung/02_FE/S2B_MSIL1C_20190418T104029_N0207_R008_T32ULC_20190418T125423.SAFE/GRANULE/L1C_T32ULC_A011045_20190418T104115/IMG_DATA/")

# read and plot a single raster Layer (den roten Kanal)
red <- raster("T32ULC_20190418T104029_B04.jp2")
red
plot(red)

# read and plot a raster Stack (only images with same geometry possible)
senstack <- stack("T32ULC_20190418T104029_B02.jp2","T32ULC_20190418T104029_B03.jp2",
                  "T32ULC_20190418T104029_B04.jp2","T32ULC_20190418T104029_B08.jp2")
senstack
plot(senstack)
spplot(senstack)

# Crop to Area of interest
#drawExtent() #interaktive eckkoordinatenauswahl: click in image
senstack_crop <- crop(senstack,c(396260, 409060, 5749550, 5763830))

# Plot Echt und Falschfarbkomposit
plotRGB(senstack_crop,stretch="lin",r=3,g=2,b=1)
plotRGB(senstack_crop,stretch="lin",r=4,g=3,b=2)

# Plot als Pdf rausschreiben
pdf("test.pdf",width=6,height=8)
plotRGB(senstack_crop,stretch="lin",r=4,g=3,b=2,maxpixels=500000000)
dev.off()

