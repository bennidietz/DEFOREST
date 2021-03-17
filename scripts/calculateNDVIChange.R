rm(list = ls())

library(raster)
library(gdalcubes)
library(magrittr)
gdalcubes_options(threads=8)

folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
setwd("..")
setwd("./data")

IMAGE_DIR = paste(getwd(), "/L8_cropped", sep = "")

col = create_image_collection(list.files(IMAGE_DIR, recursive = TRUE, pattern=".tif", full.names  = TRUE), "L8_SR")

# only use "clear" pixels
L8.clear_mask = image_mask("PIXEL_QA", values=c(322, 386, 834, 898, 1346, 324, 388, 836, 900, 1348), invert = TRUE)

v = cube_view(srs="EPSG:3857", extent=col, dx=250, dy=250, dt="P1Y", resampling = "average", aggregation = "median")

raster_cube(col, v, L8.clear_mask) %>%
  select_bands(c("B04", "B05")) %>%
  apply_pixel("(B05-B04)/(B05+B04)") %>%
  write_tif("./L8cube",prefix = "NDVI_")

#WIP

compareNDVI = function(t0, t1, RA = c(748363, 843076, -479150, -409565)) {
  #t0 <- list.files("LC080010662013041901T1-SC20191205091853")
  #t0_stack <- stack(file.path("LC080010662013041901T1-SC20191205091853", t0))
  
  #t1 <- list.files("LC080010662013050501T1-SC20191205091541")
  #t1_stack <- stack(file.path("LC080010662013050501T1-SC20191205091541", t1))
  
  t0_crop <- crop(t0_stack, RA)
  t1_crop <- crop(t1_stack, RA)
  
  plotRGB(t0_crop,r=3, g=2, b=1, stretch = "lin", axes=TRUE, main="Real color composit t0")
  plotRGB(t1_crop,r=4, g=3, b=2, stretch = "lin", axes=TRUE, main="Real color composit t1")
  
  #NDVI t0
  band4_t0_crop = raster(t0_crop, layer = 4)
  band3_t0_crop = raster(t0_crop, layer = 3)
  NDVI_t0_crop = (band4_t0_crop - band3_t0_crop) / (band4_t0_crop + band3_t0_crop)
  
  #NDVI t1
  band5_t1_crop = raster(t1_crop, layer = 5)
  band4_t1_crop = raster(t1_crop, layer = 4)
  NDVI_t1_crop = (band5_t1_crop - band4_t1_crop) / (band5_t1_crop + band4_t1_crop)
  
  m <- matrix(c(-Inf, 0, NA, 0, 0.3, 1, 0.3, 0.4, 2, 0.4, 0.5, 3, 0.5, 0.6, 4, 0.6, 1, 5), ncol = 3, byrow=TRUE)
  
  rc_t0_crop <- reclassify(NDVI_t0_crop, m)
  
  rccut_t0_crop <- ratify(rc_t0_crop)
  rat_t0_crop <- levels(rccut_t0_crop)[[1]]
  rat_t0_crop$NDVI_class <- c("very low NDVI", "low NDVI", "medium NDVI", "high NDVI", "very high NDVI")
  levels(rccut_t0_crop) <- rat_t0_crop
  
  
  rc_t1_crop <- reclassify(NDVI_t1_crop, m)
  
  rccut_t1_crop <- ratify(rc_t1_crop)
  rat_t1_crop <- levels(rccut_t1_crop)[[1]]
  rat_t1_crop$NDVI_class <- c("very low NDVI", "low NDVI", "medium NDVI", "high NDVI", "very high NDVI")
  levels(rccut_t1_crop) <- rat_t1_crop
  
  levelplot(rccut_t0_crop, col.regions=rev(terrain.colors(5)), main="t0 NDVI values")
  levelplot(rccut_t1_crop, col.regions=rev(terrain.colors(5)), main="t1 NDVI values")
  
  #reletive NDVI distribution
  result_t0_crop <- prop.table(table(getValues(rc_t0_crop)))
  result_t0_crop %>% {.*100} %>%
    round(0)
  
  result_t1_crop <- prop.table(table(getValues(rc_t1_crop)))
  result_t1_crop %>% {.*100} %>%
    round(0)
}


