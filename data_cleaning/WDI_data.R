library(rvest)
library(dplyr)
library(RJSONIO)
library(WDI)

#INDEPENDENT VARIABLES

#Source: World Bank - World Development Indicators

#1. GDP per capita in constant 2000 US dollars - from 2000 until 2015 in EU-28

## Searching and downloading data
WDIsearch('gdp.*capita.*constant')
dat = WDI(indicator="NY.GDP.PCAP.KD", country=c('AT','BE','BG','HR','CY',
                                                'CZ','DK','EE','FI','FR',
                                                'DE','GR','HU','IE','IT','LV',
                                                'LT','LU','MT','NL','PL',
                                                'PT','RO','SK','SI','ES','SE',
                                                'GB'), start=2000, end=2015)

## Cleaning Data
dim(dat)
head(dat)[,1:4]
dat_GDP <- arrange(dat, country, year)
dat_GDP <- dplyr::rename(dat_GDP, year = year, GDP_capita = NY.GDP.PCAP.KD)
dat_GDP <- select(dat_GDP, iso2c, country, year, GDP_capita)
head(dat_GDP)



#2. Tax on Business

## Searching and downloading dataData available
WDIsearch('IC.TAX.PRFT.CP.ZS', field = 'indicator', cache = NULL)

## Data available only from 2013 onwards
dat = WDI(indicator="IC.TAX.PRFT.CP.ZS", country=c('AT','BE','BG','HR','CY',
                                                   'CZ','DK','EE','FI','FR',
                                                   'DE','GR','HU','IE','IT','LV',
                                                   'LT','LU','MT','NL','PL',
                                                   'PT','RO','SK','SI','ES','SE',
                                                   'GB'), start=2000, end=2015)
## Cleaning Data

head(dat)[,1:4]
business_tax <-arrange(dat, country, year)
business_tax <-dplyr::rename(business_tax, year = year, profit_tax = IC.TAX.PRFT.CP.ZS)
business_tax <- select(business_tax, iso2c, country, year, profit_tax)
head(business_tax)



#3. Energy imports, net (% of energy use)

WDIsearch('EG.IMP.CONS.ZS', field ='indicator', cache = NULL)
dat = WDI(indicator='EG.IMP.CONS.ZS', country=c('AT','BE','BG','HR','CY',
                                                'CZ','DK','EE','FI','FR',
                                                'DE','GR','HU','IE','IT','LV',
                                                'LT','LU','MT','NL','PL',
                                                'PT','RO','SK','SI','ES','SE',
                                                'GB'), start=2000, end=2015)

## Cleaning Data
head(dat)
energy_imp <- arrange(dat, country, year)
energy_imp <- dplyr::rename(energy_imp, year = year, netenergy_imports = EG.IMP.CONS.ZS)
energy_imp <- select(energy_imp, iso2c, country, year, netenergy_imports)
head(energy_imp)




#4. Use of Fossil Fuel
WDIsearch('EG.USE.COMM.FO.ZS', field ='indicator', cache = NULL)
dat = WDI(indicator='EG.USE.COMM.FO.ZS', country=c('AT','BE','BG','HR','CY',
                                                   'CZ','DK','EE','FI','FR',
                                                   'DE','GR','HU','IE','IT','LV',
                                                   'LT','LU','MT','NL','PL',
                                                   'PT','RO','SK','SI','ES','SE',
                                                   'GB'), start=2000, end=2015)
## Cleaning Data
head(dat)
fossilfuel <- arrange (dat, country, year)
fossilfuel <- dplyr::rename(fossilfuel, year = year, fossil_use = EG.USE.COMM.FO.ZS)
head(fossilfuel)
fossilfuel <- select(fossilfuel, iso2c, country, year, fossil_use)
head(fossilfuel)

#5. Renewable energy consumption (% of total final energy consumption)

WDIsearch('EG.ELC.RNEW.ZS', field ='indicator', cache = NULL)
dat = WDI(indicator='EG.ELC.RNEW.ZS', country=c('AT','BE','BG','HR','CY',
                                                   'CZ','DK','EE','FI','FR',
                                                   'DE','GR','HU','IE','IT','LV',
                                                   'LT','LU','MT','NL','PL',
                                                   'PT','RO','SK','SI','ES','SE',
                                                   'GB'), start=2000, end=2015)
## Cleaning Data
head(dat)
re_pc_cons <- arrange (dat, country, year)
re_pc_cons <- dplyr::rename(re_pc_cons, year = year, re_pc_cons = EG.ELC.RNEW.ZS)
head(re_pc_cons)
re_pc_cons <- select(re_pc_cons, iso2c, country, year, re_pc_cons)
head(re_pc_cons)

## Identifying and removing missing values
#summary(fossilfuel$fossil_use)
#fossilfuel <- subset(x = fossilfuel,!is.na(fossil_use))
#summary(fossilfuel$fossil_use)
# NA Removed : There is no data for 2015 for EU-28 countries. 

Combined_WDI <- merge(dat_GDP, energy_imp, by = c('iso2c', 'year'), all.x = T, all.y = T)
Combined_WDI <- merge(Combined_WDI, re_pc_cons, by = c('iso2c', 'year'), all.x = T, all.y = T)
Combined_WDI <- select(Combined_WDI, year, country, GDP_capita, netenergy_imports)

rm(list = c("fossilfuel","re_pc_cons", "energy_imp", "business_tax", "dat_GDP","dat"))

