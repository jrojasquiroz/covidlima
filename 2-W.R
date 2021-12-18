#Para importar archivos vectoriales y graficarlos
library(sf)
library(sp) #para encontrar los centroides
library(ggspatial) #permite poner norte y escala
library(tmap)

#Para los modelos
library(spdep)
library(spatialreg)
library(rgdal)
library(rgeos)

#1.Importamos el archivo vectorial
lima<-st_read("turuta/consolidado-limaycallao_UTM18S.gpkg")
#Yo trabajo con Geopackage, pero puede ser un shapefile también

#2.Calculamos la matriz de pesos espaciales.
#En este caso, una de contiguidad reina.
nb<-poly2nb(lima, row.names=lima$CODUBIGEO) #https://rpubs.com/quarcs-lab/tutorial-spatial-regression
is.symmetric.nb(nb) #Es simetrica? Nos dice que si

#3.Y, por si caso, una basa en la distancia entre centroides
  #3.1. Importamos el archivo con los centroides, que lo hice en QGIS  
  cents<-st_read("G:/Mi unidad/Documentos personales/QGIS y Econometría espacial - Lambda/trabajofinal/data/limaycallao-distritos-centroides_UTM18S.gpkg")
  #3.2. Encontramos las coordenadas
  coords <- cbind(cents$x,cents$y)
  #3.3. Ahora necesitamos un umbral de distancia. Para encontrarlo, 
  #primero encontramos los k 
  #vecinos más cercanos para k = 1. Esto nos dará una lista, donde cada 
  #punto tiene exactamente un vecino (evitamos islas). 
  #Para ello, utilizamos la función 'knearneigh` de la biblioteca spdep. 
  knn1 <- knearneigh(coords)
  k1 <- knn2nb(knn1)
  #3.4. Y ahora si, el umbral critico 
  critical.threshold <- max(unlist(nbdists(k1,coords)))
  critical.threshold #14320.13
  #3.5. Creamos la matriz de pesos espaciales
  nb2 <- dnearneigh(coords, 0, critical.threshold)
  summary(nb2)
  #3.6.Por si acaso lo graficamos
  plot(nb2, coords, lwd=.2, col="blue", cex = .5)
  
  #He probado con nb (W de contiguidad reina) y 
  #nb2 (W de distancias entre centroides) y los resultados son practicamente
  #los mismos en los modelos. Me quedo con nb por ser usada en un
  #paper con un enfoque similar.