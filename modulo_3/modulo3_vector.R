##########################################################################################
################## Módulo de Gestión de formatos vectoriales                       ####### 
##########################################################################################

# Puntos primeras:
# - leer, modificar, escribir un archivo DBF
# - leer, editar, exportar un archivo vectorial (forma)
# - recuperar los arreglos detallados (puntos, líneas, polígonos)
# - transformar un archivo de trama archivo vectorial

########################################################################################### 
# Actualizado 2017/07/26
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

setwd("/media/dannunzio/OSDisk/Users/dannunzio/Documents/R/formation_geospatiale/espanol/data/")
getwd()

library(rgdal) 
library(foreign)
library(raster) 
library(rgeos) 
library(dplyr) 

### Leer un DBF: "read.dbf"
df     <- read.dbf("vector/GNQ_contour_geo_buffer005.dbf")

### Leer un shapefile: fonction "readOGR"
poly_admin <- readOGR(dsn="vector/GNQ_contour_geo_buffer005.shp",
                      layer="GNQ_contour_geo_buffer005")

point_admin <- readOGR(dsn="vector/mis_points.shp",
                       layer="mis_points")

### caracteristicas del vector : "summary"
summary(poly_admin)

names(df)[1] <- "algo"



### Re-Proyectar un vector
poly_utm <- spTransform(poly_admin,CRS("+init=epsg:32631"))

### Extraer information sobre sistema de proyeccion y dimension
my_crs <- projection(poly_utm)
my_ext <- extent(poly_utm)

extent(poly_admin)

### Crear un raster vacio con resolucion de 1000m sobre la misma extension
temp   <- raster(poly_utm,resolution=1000,
                 ext=my_ext,crs=my_crs)

### Llenar el raster con los valores del vector 
poly_utm@data$FID <- as.numeric(poly_utm@data$FID)

raster <- rasterize(x=poly_utm,y=temp,
                    field="FID",
                    background=0,fun='first',
                    update=TRUE)

# ######### Puntos regulares sobre un raster: "sampleRegular"
tmp <- as.data.frame(sampleRegular(raster,100000,xy=TRUE))

# ######### Convertir en un formato vector: "SpatialPointsDataFrame"
points_utm <-SpatialPointsDataFrame(
  coords = tmp[,c(1,2)],
  data   = data.frame(tmp),
  proj4string=CRS("+init=epsg:32631")
)
names(points_utm) <- c("x_coord","y_coord","val")
table(points_utm$val)

points_utm@data$id <- row(points_utm)[,1]

# ######### Exportar en SHP
writeOGR(obj=points_utm,dsn="vector/puntos_systematicos.shp",layer="puntos_systematicos",driver = "ESRI Shapefile")


### Visualizar los dos
plot(raster)
plot(poly_utm,add=TRUE)

### Extraer BIOKO
bioko <-poly_utm[poly_utm$FID=="1",]
bioko

### Visualizar Bioko en AZUL
plot(bioko,add=T,col="blue")

### Extraer continente
continente <-poly_utm[poly_utm$FID == 2,]
plot(continente,add=T,col="red")

### Fusion
union <- gUnion(continente,bioko)
plot(union)

### Seleccionnar puntos por su localisazione
pts_bioko <- points_utm[bioko,]
plot(pts_bioko)

### Numero de puntos por cada elemento de un vector de poligonos
poly_utm_ifn <- aggregate(x = points_utm["id"],by = poly_utm,FUN = length)

poly_utm$IFN_pts <- poly_utm_ifn@data$id
poly_utm@data

### Fusion de attributos espaciales
points_utm$DPT <- aggregate(x = poly_utm["FID"], by = points_utm,FUN=first)$FID
table(points_utm$DPT)

