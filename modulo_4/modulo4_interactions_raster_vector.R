##########################################################################################
################## Módulo sobre interacción entre fuentes de datos?
##########################################################################################

# puntos planteados:
# - hacer un gráfico con el cuantil normal y valores atípicos por Categorías 
# - cruz entre puntos y raster
# - cruz entre poligonos y raster
# - reclasificar un raster


#############################################################a############################# 
# Actualizado 2017/07/26
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# setwd("C:/Users/dannunzio/Documents/countries/congo_brazza/formation_R/module_1/")
getwd()

library(rgdal) 
library(foreign) 
library(raster) 
library(rgeos)
library(tmap)
library(dplyr)
library(maps)


### Leer archivos
raster <- raster("raster/bioko_uso_suelos.tif")
poly   <- readOGR(dsn="vector/gaul_livel1.shp",
                  layer="gaul_livel1")
points <- readOGR(dsn="vector/puntos_systematicos.shp",
                  layer="puntos_systematicos")
table  <- read.csv("tablas/BIOKO_collectedData_earthaa_bioko_CE_2017_04_02_on_070417_114427_CSV.csv")
gfc_tc <- raster("raster/bioko_gfc_clean_nd.tif")

### Resolucion producto GFC en metros
projection(gfc_tc)
res(gfc_tc)*111320

### Extraire la valeur du raster (nouvelle colonne "UTCATF") pour chaque point du fichier biomasse 
table$uso_suelo <- extract(raster,table[,c("location_x","location_y")])
head(table)

rcl <- data.frame(cbind(unique(gfc_tc),
                        c(0,1,1,1,1,2,2,2,2,rep(20,11),rep(30,11),rep(40,12),rep(50,5))
                        )
                  )

reclass <- reclassify(gfc_tc,rcl)

writeRaster(reclass,"raster/reclass.tif")

### Estadisticas zonales

### Extraer una zona
bioko <- poly[grep("Bioko Sur",poly$ADM1_NAME),]

### Crear raster con resolucion 10 veces menos
agg <- aggregate(reclass,fact=10,fun=max)

ext <- as.data.frame(extract(agg,bioko,method="simple"))
table(ext)


### applicar zonal a todas regiones
(list <- poly$ADM1_NAME[grep("Bioko",poly$ADM1_NAME)])

### Crear una funcion zonal
mi_zonal <- function(dpt,raster){
  table(data.frame(
    extract(raster,
            poly[poly$ADM1_NAME == dpt,]
    )
  )
  )
}

### Applicar funcion zonal a los zonas de interes
sapply(list,function(x){mi_zonal(x,agg)})



