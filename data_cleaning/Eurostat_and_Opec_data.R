library(rvest)
library(dplyr)
library(plyr)
library(RJSONIO)
library(WDI)
library(rio)

### DEPENDENT VARIABLES
 
### Renewable Energy Generation

solar <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_105a_1_Data.csv')
wind1 <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_105a_2_Data.csv')
wind2 <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_105a_3_Data.csv')
wind3 <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_105a_4_Data.csv')

#select the necessary columns
solar <- select(solar, GEO, TIME, Value)
wind1 <- select(wind1, GEO, TIME, Value)
wind2 <- select(wind2, GEO, TIME, Value)
wind3 <- select(wind3, GEO, TIME, Value)

#assigning numeric variable

solar[,'Value'] <- as.numeric(gsub(",", "",solar[,'Value'])) # gsub replaces "," in numbers to "" before converting them to numeric
wind1[,'Value'] <- as.numeric(gsub(",", "",wind1[,'Value']))
wind2[,'Value'] <- as.numeric(gsub(",", "",wind2[,'Value'])) 
wind3[,'Value'] <- as.numeric(gsub(",", "",wind3[,'Value']))

#assigning NA = zero generation
#solar[is.na(solar)] <- 0
#wind1[is.na(wind1)] <- 0
#wind2[is.na(wind2)] <- 0
#wind3[is.na(wind3)] <- 0

#creating dependent variables
re_generation <- merge(wind1, wind2, by = c('GEO', 'TIME'), all.x = T)
re_generation <- merge(re_generation, wind3 , by = c('GEO', 'TIME'), all.x = T)
re_generation$wind_gen <- re_generation$Value.x+ re_generation$Value.y+ re_generation$Value
re_generation <- select(re_generation, GEO, TIME, wind_gen)
re_generation <- merge(re_generation, solar, by = c('GEO', 'TIME'), all.x = T)
names(re_generation)[4] <- "solar_gen" 
re_generation$re_gen <- re_generation$wind_gen + re_generation$solar_gen

# Share of electricity produced from renewable energy sources and the gross national electricity consumption
re_pc_elec <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_ind_335a_1_Data.csv')
re_pc_elec <- re_pc_elec[-which(re_pc_elec$GEO == "European Union (28 countries)"),]
re_pc_elec <- re_pc_elec[which(re_pc_elec$INDIC_EN == "Share of renewable energy in electricity"),]
re_pc_elec[,5] <- as.numeric(re_pc_elec[,5])
names(re_pc_elec)[5] <- "re_pc_elec"
re_pc_elec$INDIC_EN <- NULL #deleting unnecessary columns
re_pc_elec$UNIT <- NULL #deleting unnecessary columns

# Share of electricity produced from renewable energy sources and the gross national electricity consumption
elec_total <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/nrg_105a_1_total_consumption.csv')
elec_total <- elec_total[-which(elec_total$GEO == c("Euro area (19 countries)","European Union (28 countries)")),]
elec_total <- elec_total[which(elec_total$UNIT == "Gigawatt-hour"),]
elec_total[,'Value'] <- as.numeric(gsub(",", "",elec_total[,'Value'])) # gsub replaces "," in numbers to "" before converting them to numeric
names(elec_total)[6] <- "elec_total"
elec_total <- elec_total[,-(3:5),drop=FALSE]  #deleting unnecessary columns
elec_total$`Flag and Footnotes` <- NULL #deleting unnecessary columns

### INDEPENDENT VARIABLES

###Eurostat

### Energy technologies patent applications to the EPO by priority year

energy_patent <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/patents_eu.csv')

#select the necessary columns
head(energy_patent)
energy_patent <- select(energy_patent, GEO, TIME, Value)
head(energy_patent)

#treat value column as numeric + clean missing values
energy_patent[,3] <- as.numeric(energy_patent[,3])
names(energy_patent)[3] <- "patents"
summary(energy_patent$Value)

### Long term interest rates (10 year bond yields) 

interest_rates <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/interest_rates_annual.csv')

#select the necessary columns
head(interest_rates)
interest_rates <- select(interest_rates, GEO, TIME, Value)

#treat value column as numeric + clean missing values
interest_rates[,3] <- as.numeric(interest_rates[,3])
summary(interest_rates$Value)
names(interest_rates)[3] <- "interest_rate"
#interest_rates <- subset(x = interest_rates,!is.na(Value))
#summary(interest_rates)

###OPEC

### Oil prices

oil_price <- import('https://raw.githubusercontent.com/tarun-hertie/Final_Paper/master/data_raw/crude_opec_all.csv')

#treat value column as numeric + clean missing values
oil_price[,2] <- as.numeric(oil_price[,2])
summary(oil_price $Value)
names(oil_price)[1] <- "TIME"
names(oil_price)[2] <- "oil_price"
names(oil_price)[3] <- "GEO"
head(oil_price)

### Merging the Eurostat databases
Combine_EuroStat <- merge(re_generation, elec_total, by =c("GEO","TIME"), all.x = TRUE, all.y = TRUE)
Combine_EuroStat <- merge(Combine_EuroStat, energy_patent, by =c("GEO","TIME"), all.x = TRUE, all.y = TRUE)
Combine_EuroStat <- merge(Combine_EuroStat, interest_rates, by =c("GEO","TIME"), all.x = TRUE, all.y = TRUE)
Combine_EuroStat$GEO[Combine_EuroStat$GEO == "Germany (until 1990 former territory of the FRG)" ] <- "Germany"
Combine_EuroStat <- merge(Combine_EuroStat, oil_price, by =c("GEO","TIME"), all.x = TRUE, all.y = TRUE)
names(Combine_EuroStat)[1] <- "country" 
names(Combine_EuroStat)[2] <- "year"

rm(list = c("wind1", "wind2", "wind3","solar","energy_patent","interest_rates","oil_price",
            "re_generation", "re_pc_elec", "elec_total"))


