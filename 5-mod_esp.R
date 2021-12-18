#1.Empiezo con un SDM (autocorrelacion espacial en X y Y)
sdm <- lagsarlm(mco.eq, data = lima, nb2listw(nb), type="mixed")
summary(sdm) #El rho no es significativo
summary(impacts(sdm, listw=nb2listw(nb), R=500), zstats = TRUE)

#2.Pruebo un SAR (autocorrelacion espacial en Y)
sar <- lagsarlm(mco.eq, data = lima, nb2listw(nb))
summary(sar) #El rho no es significativo
summary(impacts(sar, listw=nb2listw(nb), R=500), zstats = TRUE) 

#3.Vamos con el SLX, 
slx <- lmSLX(mco.eq, data = lima, nb2listw(nb))
summary(slx) #ninguna variable resulta significativa
summary(impacts(slx, listw=nb2listw(nb), R=500), zstats = TRUE) 

#4.Pruebo con el SEM, SDEM y SAC (estos dos ultimos solo por experimentar)
sem <- errorsarlm(mco.eq, data=lima, nb2listw(nb))
summary(sem) 

sdem <- errorsarlm(mco.eq, data = lima, nb2listw(nb), etype = "emixed")
summary(sdem) 

sac <- sacsarlm(mco.eq, data = lima, nb2listw(nb), type="sac")
summary(sac)
#El resultado se mantiene igual que antes, Lambda no es significativa.

#5.Al parecer nigun modelo espacial es util para evaluar la tasa de decesos por Covid-19
#durante la primera ola. Para estar totalmente seguro, utilizo los indicadores
#de Anselin (2005, p.199).

lmLMtests <- lm.LMtests(mco, 
                        nb2listw(nb), 
                        test=c("LMerr", "LMlag", "RLMerr", "RLMlag", "SARMA"))
lmLMtests #Lo que indican es que, en efecto, es preferible mantener un MCO para este 
          #analisis.
