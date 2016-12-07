library(ecb)
library(curl)
library(xml2)
library(httr)
library(rsdmx)
library(rvest)
library(dplyr)

#8. Long-term interest rate 10 yr maturity 

Long_ir <- import('https://raw.githubusercontent.com/Camila-RV/VieiraKhanna_Assignment3/master/data_raw/longterm_interestrate.csv')

key <- "IRS.M..L.L40.CI.0000.EUR.N.Z"
Long_ir <- get_data(key, filter = list(startPeriod = "2000", 
                                       endPeriod = "2015"))

desc <- head(get_description("IRS.M..L.L40.CI.0000.EUR.N.Z"), 18)
strwrap(desc, width = 80)

Long_ir <- Long_ir %>% select(ref_area, obstime, "Long_int" = obsvalue)

head(Long_ir)


   



