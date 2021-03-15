# Libraries
library(ggplot2)
library(dplyr)
library(scales)
library(Amelia)
library(lubridate)
library(xts)
library(openair)
library(tidyr)
library(gganimate)

# read data
#test<-read.csv("drop_na_test.csv")
wku_ts <- read.csv("wailuku_2010_master.csv") #15 min WKU with some lower frequency at storms
hbb_ts <- read.csv("MASTER_DATASHEET_HBB_text_new.csv") #15 minute data, 2010 - 2016

hbb_ts$saltppt <-as.numeric(hbb_ts$saltppt) #not sure why but saltppt comes through as character, so i convert to numeric here

#convert NAs to blanks because blanks in csv files become NA if df. Nt sure why all numeric vectors are also changed the chr vectors... skipping for now!
#hbb_ts[is.na(hbb_ts)] <- "" #this code replaces NAs (e.g. were blank before import) with blanks in the dataframe. Changes the dataframe.
#wku_ts[is.na(wku_ts)]<- "" #this code replaces NAs
#drop_na(hbb_ts) # this command drops the entire row if there is an NA... not what I want

#convert date column to R dates
hbb_ts$date<-parse_date_time(hbb_ts$date, orders = "mdyHM")
wku_ts$date<-parse_date_time(wku_ts$date, orders = "mdyHM")

#change the frequency of hbb_ts to hourly, save in new data frames. but currently this only averages the time column?!??!
hbb_ts_h<-timeAverage(hbb_ts, avg.time = "hour", statistic = "mean")
wku_ts_h<-timeAverage(wku_ts, avg.time = "hour", statistic = "mean")

#merge hourly time series on a common time index. Since wku is longer time series, right join hbb to wku?
#first make xts objects from hourly data
hbb_h_xts<-xts(hbb_ts_h, order.by = hbb_ts_h$date) #this generates an xts object using new column 'date' date as index
wku_h_xts<-xts(wku_ts_h, order.by = wku_ts_h$date) #this generates an xts object using new column 'date' date as index

hbb_wku_h_xts<-merge(wku_h_xts, hbb_h_xts, join = "left", fill =NA)
#hbb_wku_h<-data.frame(date1=index(hbb_wku_h_xts), coredata(hbb_wku_h_xts)) #this line converts the xts to a df with index added as a column. useful for exporting but can graph straight from xts object which is simpler

ggplot(hbb_wku_h_xts, aes(x = Index, y = as.numeric(logcms))) + 
  geom_line()
  #transition_reveal = "hour" #why do numeric columns come out of xts as characters????!!!!???

#check for missing values using Amelia
missmap(hbb_ts,main = "Missing vs Observed")

# Most basic bubble plot
p <- ggplot(hbb_d, aes(x=as.Date(index), y=Doper)) +
  geom_line() + 
  xlab("") +
  scale_x_date(date_breaks = '6 months')
p

