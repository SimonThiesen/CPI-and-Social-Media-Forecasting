# CPI-and-Social-Media-Forecasting
This repo aims to decompose time series, make transformation of non-stationary data and lastly forecast Consumer Price Index and Social Media user behavior. 
The dataset provided was relatively small due to computational considerations and time constraints.

Full report: [CPI and Social Media Forecasting](https://github.com/SimonThiesen/CPI-and-Social-Media-Forecasting/files/6008634/CPI.and.Social.Media.Forecasting.pdf)

## Some of the topics covered in this repo includes:

* Intepreting correlogram, stochastic- and deterministic components
* Making dynamic model specifications
* Testing OLS assumptions to obtain a valid regression 
* Durbin Watson & Breusch Pagan-testing to test for autocorrelation and homo-/heteroskedasticity respectively
* First differencing and time-trend regression to remove make the data stationary
* Unit root and cointegration testing
* Forecasting with vector autoregressive (VAR) settings


## Findings

### CPI
The Health Consumer Price Index are having a long-term trend upwards and is projected to increase over the next 20 months with an RMSE of 3.53 on the test set.
Furthermore, the HCPI goes very well in hand with the all other Consumer Price Indexes which could indicate
growing prices in general.

If we are looking at all the CPI's combined it seems like they have a long-term relationship, meaning that it is very likely that a change or movement in
one of the variables will have impact on HCPI. 

Statistically a 1 unit increase in CCPI would cause a 0.19 increase in HCPI. This would indicate that a rise in the CCPI could make the HCPI reach higher index levels. 

![HCPI index](https://user-images.githubusercontent.com/69463973/108480695-9035b880-7297-11eb-9dcc-9b98d730fb08.png)

It was not possible to run a forecast in a VAR setting due to one of the roots of characteristic polynomial are above 1, and hence a valid regression cannot be obtained.


### Social Media
The Facebook user percentage are currently below the long run trend, indicating that the user numbers are not vastly increasing.

After initial experiments it was concluded that an exponential smoothing approach consisting of a Holt-Winthers analysis produced the best forecasting result. 
Facebook and Twitter are projected to increase in monthly user percentage in the next 12 months while LinkedIn will decrease. 
Facebook are having the steepest increase in the user percentage compared to Twitter and LinkedIn.

![Facebook projection](https://user-images.githubusercontent.com/69463973/108482118-5960a200-7299-11eb-9dab-640b79cce373.png)

![Twitter_projection](https://user-images.githubusercontent.com/69463973/108482274-8f058b00-7299-11eb-90d3-1d1a29aee50d.png)

![LinkedIn_projection](https://user-images.githubusercontent.com/69463973/108482322-a2185b00-7299-11eb-8684-cd8ece7f078e.png)

To improve the model specifications, it is believed that testing other forecast methods potentially could higher the prediction outcome even further.
