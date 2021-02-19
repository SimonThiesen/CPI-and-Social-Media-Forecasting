library(forecast)
library(stats)
library(datasets)
library(readxl)
library(tibble)
library(lmtest)
library(GGally)
library(mctest)
library(tseries)
library(ggplot2)
library(vars)


case2 <- read_excel("Datasets/SocialMediaDK.xlsx")
case1 <- read_excel("Datasets/CPIDK.xlsx")

health <- ts(case1$Health, frequency = 12)
food <- ts(case1$Food, frequency = 12)
com <- ts(case1$Communication, frequency = 12)
edu <- ts(case1$Education, frequency = 12)


#Q1
#Checking the correlogram
tsdisplay(health)
tsdisplay(food)
tsdisplay(com)
tsdisplay(edu)

#Checking for unit root
adf.test(health)
adf.test(food)
adf.test(com)
adf.test(edu)



#Q2
insamp <- ts(case1[1:120, 3], frequency = 12)
outsamp <- ts(case1[121:167, 3])


fit <- Arima(health, order = c(1,1,0), include.drift = TRUE)
plot(fcast, main = 'HCPI - ARIMA (1,1,0)')
fcast <- forecast(fit, h=47)
lines(health)

tsdisplay(resid(fit))
accuracy(fcast, outsamp)

movavg <- ma(insamp, order=12, centre=TRUE)
fcast1 <- forecast(movavg, h=47)

plot(fcast1, main = 'Moving Average')
lines(health)

accuracy(fcast1, outsamp)


movavg1 <- ma(health, order=12, centre=TRUE)
fcast2 <- forecast(movavg1, h=20)

plot(fcast2, main = 'Moving Average Forecast 20 periods')
accuracy(fcast2)


#Q3
linmod <- lm(health ~ food + com + edu)
adf.test(resid(linmod)) #Does the residuals have a Unit root? If so, then differencing it
tsdisplay(resid(linmod))
summary(linmod)
plot(linmod)
bptest(linmod) # If heteroskedasticity /then arch/garch
 # Autocorrelation? - AR approach
dwtest(linmod)



#Q4

#DIFFERENCING BECAUSE THERE IS A UNIT ROOT - TO GET RID OF HETEROSKEDASTICITY AND AUTOCORRELATION
linmod1 <- lm(diff(health) ~ diff(food) + diff(com) + diff(edu))
bptest(linmod1)
dwtest(linmod1)
summary(linmod1)
tsdisplay(resid(linmod1))





linmod1 <- lm(diff(health) ~ diff(food) + diff(com) + diff(edu))
fcast33 <- forecast(linmod1, h=20)
plot(fcast33, main = 'HCPI - Valid regression')

tsdisplay(resid(fit3))
accuracy(fcast)


#Q5

adf.test(ip)
adf.test(cpi)

# Combining the two vectors 
combinedvector <- ts(cbind(health, com, edu, food), frequency = 12)

po.test(combinedvector) #Phillips-Ouliaris test (2-step Engle-Granger test)
#null hypothesis of this test: no cointegration
#At 5% level, this p-value indicates we can reject H0. Y & x are therefor conintegrated in this case


#------doing it manually with Engle-Granger test------------

#Assuming it's white noise even though it might not be, the above test is more accurate
#Two methods are geared for different things

#Explaining y by x
fit <- lm(ip ~ cpi)

adf.test(resid(linmod))


#Q6

#Creating a vector/Matrix of the variables
z <- log(combinedvector[1:120, 1:4])
dz <- diff(z) #Because of Unit Root

VARselect(z, lag.max = 10, type="const")[["selection"]]
var <- VAR(z, p=1, type="const")
summary(var)
#Tells me roots of the charcteristic polynomial
#Stability = Each root below 1

#diagnostics - checking if it correctly determined
serial.test(var, lags.pt=10, type="PT.asymptotic")

#Diagnostics
var.stable <- stability(var, type = "OLS-CUSUM")
plot(var.stable)
roots(var)


plot(irf(var,boot = TRUE, ci=0.95))

plot(fevd(var1, n.ahead = 10))

arch.test(var)

#BECAUSE THERE STILL IS HETEROSKEDASTICITY WE WILL TRANSFORM THE VARIABLES


# Fixing the heteroskedasticity problem

eps.rbci <- ts(resid(var$varresult$health))
eps.luspop <- ts(resid(var$varresult$com))
eps.lr <- ts(resid(var$varresult$edu))
eps.lr1 <- ts(resid(var$varresult$food))
#epsilon of each variable

#doing it for consumer sentiment
rbci.garch <- garch(eps.rbci, order= c(1,1))
summary(rbci.garch)
#significans of a1 and b1 meaning GARCH setting is appropriate

#normalizing the series to get rid of heteroskedasticity
rbci.hhat <- ts(2*rbci.garch$fitted.values[-1,1]^2)
healthstar <- health[1:118]/sqrt(rbci.hhat)

luspop.garch <- garch(eps.luspop, order= c(1,1))
summary(luspop.garch)
luspop.hhat <- ts(2*luspop.garch$fitted.values[-1,1]^2)
comstar <- com[1:118]/sqrt(luspop.hhat)

lr.garch <- garch(eps.lr, order= c(1,1))
summary(lr.garch)
ls.hhat <- ts(2*lr.garch$fitted.values[-1,1]^2)
edustar <- edu[1:118]/sqrt(ls.hhat)

lr1.garch <- garch(eps.lr1, order= c(1,1))
summary(lr1.garch)
ls1.hhat <- ts(2*lr1.garch$fitted.values[-1,1]^2)
foodstar <- food[1:118]/sqrt(ls1.hhat)
#we don't really need the normalization on the price series, and there is no GARCH effect apperant
#No need to do VAR settings on the price equation

# Repeating the VAR analysis with the heteroskedasticity-corrected series

dzstar <- ts(cbind(foodstar,edustar,comstar, healthstar))
#binding it all again

#p=2 was getting rid of auto correlation
#Using the 5th row, because we have transformed the data (lots of na's)
var3 <- VAR(dzstar, p=2, type="const")
summary(var3)
serial.test(var3, lags.pt=10, type="PT.asymptotic")
arch.test(var3)

#var3 has no autocorrelation and heteroskedasticity and therefor
#is something we can interpret

# Let us check if we actually need to use a VAR specification for forecasting.

plot(irf(var3,boot = TRUE, ci=0.95))
plot(fevd(var3))
roots(var3)

#all variables are to their own - this means we don't need a VAR specification
#probably next use a auto regressive approach and exponential smoothing 


fcast5 <- forecast(var3, h=25)
plot(fcast5)


#Only checking accruracy for LTN and out of sample period colmumn 2(ltn)
accuracy(fcast5$forecast$healthstar, outsamp[1:25])




#case 2

case2 <- read_excel("Datasets/SocialMediaDK.xlsx")

fb <- ts(case2$Facebook, frequency = 12)


tsdisplay(fb)
adf.test(fb)


decompSalesAdd <- decompose(fb, type = "additive") #for additive decomposition
decompSalesMult <- decompose(fb, type = "multiplicative") #for multiplicative decomposition

plot(decompSalesAdd)
plot(decompSalesMult)


#Både trend og seasonality?
trend <- seq(1:length(fb))
month <- seasonaldummy(fb)


CMA <- ma(fb, order=12, centre=TRUE)
linmod <- lm(CMA ~ trend, na.action = "na.exclude")
CMAT <- linmod$fitted.values
Cycle <- na.exclude(CMA) / CMAT
ts.plot(Cycle)
abline(h=1, col="green")



#Q3

tw <- log(ts(case2$Twitter, frequency = 12))
li <- log(ts(case2$LinkedIn, frequency = 12))

adf.test(tw)
adf.test(li)
lfb <- log(fb)

#Creating a vector/Matrix of the variables
z <- ts(cbind(diff(lfb), diff(tw), li), frequency = 12)
dz <- z[2:129, 1:3]

VARselect(dz, lag.max = 10, type="const")[["selection"]]
var <- VAR(dz, p=1, type="const")
summary(var)
#Tells me roots of the charcteristic polynomial
#Stability = Each root below 1

#diagnostics - checking if it correctly determined
serial.test(var, lags.pt=10, type="PT.asymptotic")

#Diagnostics
var1.stable <- stability(varcase2, type = "OLS-CUSUM")
plot(var1.stable)
roots(var1)


plot(irf(var,boot = TRUE, ci=0.95))

plot(fevd(var1, n.ahead = 10))

arch.test(var)

# Fixing the heteroskedasticity problem

eps.lfb <- ts(resid(var$varresult$diff.lfb.))
eps.tw <- ts(resid(var$varresult$diff.tw.))
eps.li <- ts(resid(var$varresult$li))
#epsilon of each variable

#doing it for consumer sentiment
lfb.garch <- garch(eps.lfb, order= c(1,1))
summary(lfb.garch)
#significans of a1 and b1 meaning GARCH setting is appropriate

#normalizing the series to get rid of heteroskedasticity
lfb.hhat <- ts(2*lfb.garch$fitted.values[-1,1]^2)
fbstar <- diff(fb)[1:126]/sqrt(lfb.hhat)

tw.garch <- garch(eps.tw, order= c(1,1))
summary(tw.garch)
tw.hhat <- ts(2*tw.garch$fitted.values[-1,1]^2)
twstar <- diff(tw)[1:126]/sqrt(tw.hhat)

li.garch <- garch(eps.li, order= c(1,1))
summary(li.garch)
li.hhat <- ts(2*li.garch$fitted.values[-1,1]^2)
listar <- li[1:126]/sqrt(li.hhat)
#we don't really need the normalization on the price series, and there is no GARCH effect apperant
#No need to do VAR settings on the price equation

# Repeating the VAR analysis with the heteroskedasticity-corrected series

dzstar1 <- ts(cbind(fbstar,twstar, listar))
dstar <- diff(dzstar1)
#binding it all again
VARselect(dzstar1[2:125, 1:3], lag.max = 10, type="const")[["selection"]]


varcase2 <- VAR(dzstar1[2:125,1:3], p=3, type="const")
summary(varcase2)
serial.test(varcase2, lags.pt=10, type="PT.asymptotic")
arch.test(varcase2)

#var3 has no autocorrelation and heteroskedasticity and therefor
#is something we can interpret

# Let us check if we actually need to use a VAR specification for forecasting.

plot(irf(varcase2,boot = TRUE, ci=0.95))
plot(fevd(varcase2))

#all variables are to their own - this means we don't need a VAR specification
#probably next use a auto regressive approach and exponential smoothing 



#Q2
insamp1 <- ts(case2[1:81, 2], frequency = 12)
outsamp1 <- ts(case2[82:129, 2])


fit5 <- HoltWinters(insamp1)
fcast7 <- forecast(fit5, h = 48)
plot(fcast7)
lines(fb)

accuracy(fcast7, outsamp1)



fit8 <- Arima(fb, order = c(1,1,0), include.drift = TRUE)
fcast10 <- forecast(fit8, h=48)
plot(fcast10, main = 'FB - ARIMA (1,1,0)') %>% 
lines(fb)



accuracy(fcast10, outsamp1)

fit15 <- HoltWinters(tw)
fcast15 <- forecast(fit15, h = 12)
plot(fcast15, main = 'Twitter Projection')

li <- ts(case2$LinkedIn, frequency = 12)

fit16 <- HoltWinters(li)
fcast16 <- forecast(fit16, h = 12)
plot(fcast16, main = 'LinkedIn Projection')

fit17 <- HoltWinters(fb)
fcast17 <- forecast(fit17, h = 12)
plot(fcast17, main = 'Facebook Projection')


#Combined forecast

dm.test(residuals(fcast7), residuals(fcast10), h=length(outsamp1))
#We can't reject H0, meaning that the forecast accuracy are equal.
#Even though RMSE is lower on the ARIMA, the forecast method are equally good at forecasting

#justified the choice of methods, they are two different methods and they are equally good in their accuracy according to the dm.test


# # Finally let us check if combining these two forecasts will lead to an improvement in terms of RMSE. 
combfit <- lm(outsamp1 ~ fcast7$mean + fcast10$mean)
combfcast <- ts(combfit$fitted.values, frequency = 12)

accuracy(combfcast, outsamp1)
#once they are combined, the forecast methods has reduced the RMSE to 15.59





