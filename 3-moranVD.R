#1.Calculamos la I de Moran de nuestra variable dependiente
moran <- moran.test(lima$TDECX10, nb2listw(nb))
moran #con la matriz de contiguidad reina

moran2 <- moran.test(lima$TDECX10, nb2listw(nb2))
moran2 #con la matriz de distancias
#Hay autocorrelación espacial significativa y positiva.

#2.Ahora veremos la I de Moran local
  #2.1. Primero, de manera exploratoria, veamos la distribucion
  #de la tasa de decesos
  tm_shape(lima)+
  tm_fill(col="TDECX10",style = "quantile", n=3,  title = "Tasa de decesos")+
  tm_layout(frame = FALSE,legend.outside = TRUE)+
  tm_borders(lwd=0.01)
  #2.2. Calculamos la I de Moran local
  local<-localmoran(lima$TDECX10, nb2listw(nb))
  lisamap1<-cbind(lima,local)
  names(lisamap1)
  #2.3.La graficamos
  tm_shape(lisamap1)+
    tm_fill(col="Ii",style = "quantile", n=3,  title = "I de Moran local")+
    tm_layout(frame = FALSE,legend.outside = TRUE)+
    tm_borders(lwd=0.01)
  #2.4.Vemos en el plano cartesiano
  moran.plot(lima$TDECX10, listw=nb2listw(nb), xlab="Tasa de decesos estandarizada", 
             ylab="Tasa de decesos estandarizada para los vecinos",
             main=c("Gráfico de dispersión de la I de Moran para la Tasa de decesos", "en los distritos de Lima y Callao"))
  
  
  #2.5.Creamos un mapa con los cuadrantes por colores
  cuadrantes <- vector(mode="numeric",length=nrow(local))
  
    #2.4.1.Centramos la variable de interés alrededor de su promedio
    p.tdec <- lima$TDECX10 - mean(lima$TDECX10)     
  
    #2.4.2.Centramos la I de Moran local alrededor de su promedio
    p.local <- local[,1] - mean(local[,1])    
  
    #2.4.3.Establecemos el umbral de significancia
    signif <- 0.05 
  
  #Y ahora si creamos los cuadrantes
  cuadrantes[p.tdec >0 & p.local>0] <- 4  
  cuadrantes[p.tdec <0 & p.local<0] <- 1      
  cuadrantes[p.tdec <0 & p.local>0] <- 2
  cuadrantes[p.tdec >0 & p.local<0] <- 3
  cuadrantes[local[,5]>signif] <- 0 #la significancia está en la col n° 5
  #Lo que hacemos aqui es crear un objeto que nos diga a que cuadrante
  #pertenece cada distrito, y si es que significativo o no.
  
  #Creamos el mapa
  brks <- c(0,1,2,3,4)
  colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")
  lisamap2=select(lima,1)
  plot(lisamap2,border="lightgray",
       col=colors[findInterval(cuadrantes,brks,all.inside=FALSE)])
  box()
  legend("bottomleft", 
         legend = c("insignificant","low-low","low-high","high-low","high-high"),
         fill=colors,bty="n")

#3.Exporto el archivo vectorial para representarlo mejor en QGIS
lisamap1=cbind(lisamap1,cuadrantes)
names(lisamap1)
lisamap1=select(lisamap1,14:20)
write_sf(lisamap1, 
"turuta/lisamap-lima.gpkg")
