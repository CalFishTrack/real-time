
## Prepared by Cyril Michel on 2019-07-16; cyril.michel@noaa.gov
## Updated on 2020-06-24

###########################################################################
#### HOW TO PULL IN AUTONOMOUS RECEIVER FISH DETECTION DATA INTO R ########
###########################################################################

## install and load the 'rerddap' library
library(rerddap)

## It is important to delete your cache if you want the newest data. 
## If not, when you rerun the same data queries as before, the command will likely return the old cached data and not the newest data
## If data is unlikely to change or be amended, not deleting your cache will speed up some data queries
cache_delete_all()

#### FIRST LETS DOWNLOAD TAGGED FISH DATA ####
## important fields in the "FED_JSATS_taggedfish" dataset include:
important_fish_fields <- 
      c("fish_id", # (Unique fish identification number, different from tag_id_hex, which can get reused by manufacturer)
        "tag_id_hex", # (TagID code, in hexadecimal format)
        "study_id", # (unifying name for all fish released in a year for a study)
        "fish_type", # (origin of fish, describes species, population, and source. E.g., "CNFH Fall Chinook" represents Coleman National Fish Hatchery Fall-run Chinook salmon)
        "fish_release_date", # (release date/time of fish in Pacific Standard Time, i.e., does not adjust for daylight savings)
        "release_location", # (Release location name)
        "release_latitude", # (Release location latitude, decimal degrees)
        "release_longitude", # (Release location longitude, decimal degrees)
        "release_river_km" # (Release River Kilometer - distance from Golden Gate by river, km)
        )
## We will download only these fields, although this dataset is small enough to quickly download in its entirety if desired
## download the tagged fish dataset
fish <- tabledap('FED_JSATS_taggedfish', url = "https://oceanview.pfeg.noaa.gov/erddap/", fields = important_fish_fields)


#### NEXT LETS DOWNLOAD DETECTION DATA ####
## Find out some general details on the detections database
db <- info('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/")
## This will tell you columns and their data types in database
vars <- db$variables
## This will tell you unique study_id names (unifying name for all fish released in a year for a study)
unique_studies <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", fields = c("study_id"))
## This will tell you unique receiver_general_location (a unifying name describing 1 location covered by 1 or more individual receivers)
unique_genlocs <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", fields = c("receiver_general_location"))


## the following fields (shown below with associated metadata) are the most important fields for most analyses.
## Setting them as "important_detection_fields" here will allow you to return only these fields in data queries
important_detection_fields <- 
          c("fish_id", # (Unique fish identification number, different from tag_id_hex, which can get reused by manufacturer)
            "local_time", # (Detection Date/time, in Pacific Standard Time, i.e., does not adjust for daylight savings)
            "study_id", # (unifying name for all fish released in a year for a study)
            "receiver_general_location", # (a unifying name describing 1 location covered by 1 or more individual receivers)
            "receiver_general_river_km", # (Receiver River Kilometer of the group of receivers- distance from Golden Gate, km)
            "receiver_location", # (Individual Receiver Location name)
            "latitude", # (Individual Receiver Location latitude, decimal degrees)
            "longitude" # (Individual Receiver Location longitude, decimal degrees)
            )

#*********************************************************************************************
#********************************** IMPORTANT ************************************************
#*********************************************************************************************
# Downloading the entire detection dataset exceeds the 2GB limit per download.
# We recommend downloading only the detection data you need, or at least, downloading the detection data in batches
# See following code snippets for help
#*********************************************************************************************

## Download only data from 1 studyID, here for example, Winter-run 2018 study, with only "important fields". If all fields are desired, remove the "fields" command
dat <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'study_id="Winter_H_2018"', fields = important_detection_fields)

## Download data from 2 or more studyIDs, here for example, Red Bluff diversion dam tagged fish in 2017 and 2018, with only "important fields". If all fields are desired, remove the "fields" command
datalist <- list() #Make a blank list for saving detection data in the loop below
studyids <- c("RBDD_2017", "RBDD_2018") #Make a vector of the studyID names you are interested in
for (i in studyids){
  constraint <-  noquote(paste0("'study_id=\"",i,"\"'"))
  datalist[[i]] <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", str2lang(constraint), fields = important_detection_fields)
}
dat <- do.call(rbind,datalist) #append the lists into one dataframe

## Download only data from 1 general receiver location. Beware: depending on the general receiver location, this could return a lot of data.
dat <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'receiver_general_location="GoldenGateW"', fields = important_detection_fields)

## Download only data from a specific time range (in UTC time)
dat <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'time>=2019-01-01', 'time<=2019-01-02', fields = important_detection_fields)

## Download data from a combination of conditions. For example, study_id="ColemanLateFall_2018" and receiver_general_location="GoldenGateW"
dat <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'study_id="ColemanLateFall_2018"', 'receiver_general_location="GoldenGateW"', fields = important_detection_fields)

## Finally, download a summary of unique records. Say for example you want to know the unique Fish_ID codes detected somewhere in the array from a studyID. 
## This would include fish released but never detected, as they get assigned 1 row of detection data with their release location as a detection location
unique_fish <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'study_id="MillCk_Wild_2017"', fields = c("fish_id"), distinct = T)

## Or, number of unique fish detected at each general receiver location for a studyID. The "distinct = T" command allows us to summarize for only unique records
unique_fish_v_recvs <- tabledap('FED_JSATS_detects', url = "https://oceanview.pfeg.noaa.gov/erddap/", 'study_id="MillCk_Wild_2018"', fields = c("receiver_general_location","fish_id"), distinct = T)

## PLEASE NOTE: IF A DATA REQUEST ABOVE RETURNS SIMPLY "Error: ", THIS LIKELY MEANS THE DATA REQUEST CAME UP WITH ZERO RETURNS


#_________________________________________________________________________________________________________


#### The following code snippets can help with simple data manipulations, analyses, and visualizations once you've imported your data in R ####

## First, lets format time so R reads it as a Posixct time
dat$local_time <- as.POSIXct(dat$local_time, origin = '1970-01-01', format = "%Y-%m-%d %H:%M:%OS", tz = "Etc/GMT+8")

#### Associate detection data to tagging data ####
dat_fish <- merge(dat, fish, by = c("fish_id", "study_id"))

#### Find first, last, and count of detections per fish per general location ####
detect_minmaxcount <- aggregate(list(first_detect = dat$local_time), by = list(study_id = dat$study_id, fish_id = dat$fish_id, receiver_general_location = dat$receiver_general_location), min)
detect_minmaxcount <- merge(detect_minmaxcount, aggregate(list(last_detect = dat$local_time), by = list(study_id = dat$study_id, fish_id = dat$fish_id, receiver_general_location = dat$receiver_general_location), max))
detect_minmaxcount <- merge(detect_minmaxcount, aggregate(list(detect_count = dat$local_time), by = list(study_id = dat$study_id, fish_id = dat$fish_id, receiver_general_location = dat$receiver_general_location), length))
detect_minmaxcount <- detect_minmaxcount[order(detect_minmaxcount$fish_id, detect_minmaxcount$first_detect),]

#### Find number of fish released and detected at Benicia per Study ID. ####
## NOTE, if a released fish was never detected again, it will exist in the detection data. 
## These fish get assigned 1 row of detection data with their release location as a detection location
released <- nrow(tabledap('FED_JSATS_detects', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="Winter_H_2019"', fields = c("fish_id"), distinct = T))
benicia <- nrow(tabledap('FED_JSATS_detects', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="Winter_H_2019"', 'receiver_general_location="BeniciaW"', fields = c("fish_id"), distinct = T))
## Percent detected at Benicia:
round(benicia/released*100, 2)

#### Make a map of detection locations ####
## first format some fields as necessary
dat$latitude <- as.numeric(dat$latitude)
dat$longitude <- as.numeric(dat$longitude)
## summarize data by unique fish visits per receiver general location
detect_summary <- aggregate(list(fish_count = dat$fish_id), by = list(receiver_general_location = dat$receiver_general_location), function(x){length(unique(x))})
detect_summary <- merge(detect_summary, aggregate(list(latitude = dat$latitude, longitude = dat$longitude), by = list(receiver_general_location = dat$receiver_general_location), mean))

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
