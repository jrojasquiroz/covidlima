library(car) #para calcular el VIF
#1.Empezamos calculando un MCO para conocer cómo se comportan 
#nuestras variables
mco.eq<-TDECX10 ~ INFORMAL_PR+HACIN_PROM+TPUB_PR+MUJER_PR +ADULTOMAYOR_PR+
                  DENS_RES+DENS_MERC

mco<-lm(mco.eq, data=lima)
summary(mco)

#2.Veamos la multicolinealidad
mc<-vif(mco)
mc

#3.Del grafico de correlacion, veiamos que ADULTOMAYOR_PR se relacionaba mas
#con hacinamiento, informalidad y % de mujeres. Ademas, densidad residencial y
#de mercados no son significativos, y al quitarlas, el R-cuadrado no disminuye
#en gran proporcion; por tanto tambien se elimnan.
mco.eq<-TDECX10 ~ TPUB_PR+ADULTOMAYOR_PR

mco<-lm(mco.eq, data=lima)
summary(mco)

#2.Veamos la multicolinealidad
mc<-vif(mco)
mc #Ahora si queda listo el modelo MCO

#3.Veamos si sus residuos muestran autocorrelacion espacial
resmoran <- lm.morantest(mco,
                         nb2listw(nb) #necesitamos que la matriz sea un
                                      #objeto listw. Es por un tema de R, no
                                      #de la regresion.
                         )
resmoran #No es estadisticamente significativa
#¿Esto indicaria que posiblemente el SEM no nos ayude? Lo vamos a corroborar
#mas adelante

#4.Algo que me habia olvidado de hacer antes: la autocorrelacion espacial
#de las variables independientes
moran.test(lima$TPUB_PR, nb2listw(nb)) #positiva y significativa
moran.test(lima$ADULTOMAYOR_PR, nb2listw(nb)) #positiva y significativa
moran.test(lima$DENS_RES, nb2listw(nb)) #positiva y significativa
moran.test(lima$DENS_MERC, nb2listw(nb)) #positiva y significativa

#Lo que vemos es una autocorrelación espacial en X y Y, por lo que empezare
#probando con un SDM.
