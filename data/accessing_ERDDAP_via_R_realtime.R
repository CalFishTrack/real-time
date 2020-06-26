
## Prepared by Cyril Michel on 2019-07-10; cyril.michel@noaa.gov
## Updated on 2020-06-25

#################################################################
#### HOW TO PULL IN REAL-TIME FISH DETECTION DATA INTO R ########
#################################################################

## install and load the 'rerddap' library
library(rerddap)

## It is important to delete your cache if you want the newest data. 
## If not, when you rerun the same data queries as before, the command will likely return the old cached data and not the newest data
## If data is unlikely to change or be amended, not deleting your cache will speed up some data queries
cache_delete_all()

## Find out details on the database
db <- info('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/")
## This will tell you the available columns
vars <- db$variables$variable_name
## This will tell you unique study_id names (unifying name for all fish released in a year for a study)
unique_studies <- tabledap('FEDcalFishTrack', url = "https://oceanview.pfeg.noaa.gov/erddap/", fields = c("Study_ID"))
## This will tell you unique receiver_general_location (a unifying name describing 1 location covered by 1 or more individual receivers)
unique_genlocs <- tabledap('FEDcalFishTrack', url = "https://oceanview.pfeg.noaa.gov/erddap/", fields = c("general_location"))

## Below is the metadata for each field
##  "TagCode", TagID code, in hexadecimal format
##  "Study_ID", unifying name for all fish released in a year for a study
##  "release_time", Date/time of fish release, Pacific Standard Time - i.e., no DST offset
##  "location", Receiver location name
##  "recv", receiver serial number
##  "time", Detection Date/time, UTC
##  "local_time", Detection Date/time, Pacific Standard Time - i.e., no DST offset
##  "latitude", receiver location latitude, decimal degrees
##  "longitude", receiver location longitude, decimal degrees
##  "general_location", a unifying name when several receivers cover one location
##  "river_km", General Location River Kilometer - distance from Golden Gate, km
##  "length", fork length of fish, in mm
##  "weight", fish weight, in gr
##  "release_river_km", Release River Kilometer - distance from Golden Gate, km
##  "tag_life", expected life of tag's battery, in days



## Download all data (will take a little while, large database).
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/")
## ALTERNATIVELY, download only the data you need, see following code snippets

## Download only data from 1 studyID, here for example, Juv_Green_Sturgeon_2018 study
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Juv_Green_Sturgeon_2018"')

## Download data from 2 or more studyIDs, here for example, DeerCk fish tagged in 2018 and 2019.
datalist <- list() #Make a blank list for saving detection data in the loop below
studyids <- c("DeerCk-Wild-2018", "DeerCk-Wild-2019") #Make a vector of the studyID names you are interested in
for (i in studyids){
  constraint <-  noquote(paste0("'Study_ID=\"",i,"\"'"))
  datalist[[i]] <- tabledap('FEDcalFishTrack', url = "https://oceanview.pfeg.noaa.gov/erddap/", str2lang(constraint))
}
dat <- do.call(rbind,datalist) #append the lists into one dataframe

## Download only data from 1 receiver location
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'general_location="MiddleRiver"')

## Download only data from a specific time range (in UTC time)
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'time>=2019-01-01', 'time<=2019-01-10')

## Download data from a combination of conditions. For example, Study_ID="DeerCk-SH-Wild-2019" and general_location="ButteBr_RT"
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="MillCk_SH_Wild_S2019"', 'general_location="ButteBrRT"')

## Download only specific columns for a studyID (or a general location, time frame or other constraint)
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'general_location="MiddleRiver"', fields = c("TagCode","Study_ID"))

## Finally, download a summary of unique records. Say for example you want to know the unique TagCodes detected in the array from a studyID
## This would include fish released but never detected, as they get assigned 1 row of detection data with blank for a timestamp and detection location info
unique_fish <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", fields = c("TagCode"), distinct = T, 'Study_ID="DeerCk-SH-Wild-2019"')

## Or, number of unique fish detected at each receiver location for a studyID
unique_fish_v_recvs <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="DeerCk-SH-Wild-2019"', fields = c("general_location","TagCode"), distinct = T)

## PLEASE NOTE: IF A DATA REQUEST ABOVE RETURNS SIMPLY "Error: ", THIS LIKELY MEANS THE DATA REQUEST CAME UP WITH ZERO RETURNS


#_________________________________________________________________________________________________________


#### The following code snippets can help with simple data manipulations, analyses, and visualizations once you've imported your data in R ####

## First, lets format time so R reads it as a Posixct time
dat$local_time <- as.POSIXct(dat$local_time, origin = '1970-01-01', tz = "Etc/GMT+8")

#### Find first, last, and count of detections per fish per general location ####
detect_minmaxcount <- aggregate(list(first_detect = dat$local_time), by = list(Study_ID = dat$Study_ID, TagCode = dat$TagCode, general_location = dat$general_location), min)
detect_minmaxcount <- merge(detect_minmaxcount, aggregate(list(last_detect = dat$local_time), by = list(Study_ID = dat$Study_ID, TagCode = dat$TagCode, general_location = dat$general_location), max))
detect_minmaxcount <- merge(detect_minmaxcount, aggregate(list(detect_count = dat$local_time), by = list(Study_ID = dat$Study_ID, TagCode = dat$TagCode, general_location = dat$general_location), length))
detect_minmaxcount <- detect_minmaxcount[order(detect_minmaxcount$TagCode, detect_minmaxcount$first_detect),]

#### Find number of fish released and detected at Benicia per Study ID. ####
## NOTE, if a released fish was never detected again, it will exist in the detection data. 
## These fish will have only one row, with blank for a timestamp and detection location info
released <- nrow(tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Winter_H_2019"', fields = c("TagCode"), distinct = T))
benicia <- nrow(tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Winter_H_2019"', 'general_location="ButteBrRT"', fields = c("TagCode"), distinct = T))
## Percent detected at Benicia:
round(benicia/released*100, 2)

#### Make a map of detection locations ####
## first format some fields as necessary
dat$latitude <- as.numeric(dat$latitude)
dat$longitude <- as.numeric(dat$longitude)
## summarize data by unique fish visits per receiver general location
detect_summary <- aggregate(list(fish_count = dat$TagCode), by = list(general_location = dat$general_location), function(x){length(unique(x))})
detect_summary <- merge(detect_summary, aggregate(list(latitude = dat$latitude, longitude = dat$longitude), by = list(general_location = dat$general_location), mean))

library(ggplot2)
library(mapdata)
library(ggrepel)

## Set boundary box for map
xlim <- c(-123, -121)
ylim <- c(37.5, 40.6)
usa <- map_data("worldHires", ylim = ylim, xlim = xlim)
rivers <- map_data("rivers", ylim = ylim, xlim = xlim)
rivers <- rivers[rivers$lat < max(ylim),]
ggplot() +
  geom_polygon(data = usa, aes(x = long, y = lat, group = group), fill = "grey80") +
  geom_path(data = rivers, aes(x = long, y = lat, group = group), size = 1, color = "white", lineend = "round") +
  geom_point(data = detect_summary, aes(x = longitude, y = latitude), shape=23, fill="blue", color="darkred", size=3) +
  geom_text_repel(data = detect_summary, aes(x = longitude, y = latitude, label = fish_count)) +
  theme_bw() + ylab("latitude") + xlab("longitude") +
  coord_fixed(1.3, xlim = xlim, ylim = ylim) +
  ggtitle("Location of study detections w/ count of unique fish visits")
