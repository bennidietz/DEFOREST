folderDir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(folderDir)
require(rgdal)
require(raster)

yearly_deforestation <- readOGR(dsn = ".", layer = "yearly_deforestation")
# -73.85386, -43.99998, -17.68834, 5.205482  (xmin, xmax, ymin, ymax)
# crop: -66.20014 -65.38620 -9.690152 -8.892918

def = yearly_deforestation
def = def[def$IMAGE_DATE == '2019-08-01',]


b = as(raster::extent(-66.20014, -65.38620, -9.690152, -8.892918), "SpatialPolygons")
yearly_deforestation_cropped = crop(yearly_deforestation, b)
plot(yearly_deforestation_cropped)

save(yearly_deforestation_cropped,file="croppedYearlyDeforestationBiome.Rda")



require(ggplot2)
df = fortify(yearly_deforestation_cropped)
ggplot()+
  geom_polygon(data = df, aes(x = long, y = lat))+ # group = group?
  theme_bw()


require(sf)
shape <- read_sf(dsn = ".", layer = "accumulated_deforestation_1988_2007")
