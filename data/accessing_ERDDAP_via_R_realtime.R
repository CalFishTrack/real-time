
## Prepared by Cyril Michel on 2019-07-10; cyril.michel@noaa.gov

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
## This will tell you the avaialable columns
vars <- db$variables$variable_name
## This will tell you unique StudyID names
as.data.frame(tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", fields = c("Study_ID")))

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



## Download all data (will take a little while, large database).
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/")
## ALTERNATIVELY, download only the data you need, see following code snippets

## Download only data from 1 studyID, here for example, Juv_Green_Sturgeon_2018 study
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Juv_Green_Sturgeon_2018"')

## Download only data from 1 receiver location
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'general_location="MiddleRiver"')

## Download only data from a specific time range (in UTC time)
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'time>=2019-01-01', 'time<=2019-01-10')

## Download data from a combination of conditions. For example, Study_ID="DeerCk-SH-Wild-2019" and general_location="ButteBr_RT"
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="MillCk_SH_Wild_S2019"', 'general_location="ButteBrRT"')

## Download only specific columns for a studyID (or a general location, time frame or other constraint)
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'general_location="MiddleRiver"', fields = c("TagCode","Study_ID"))

## Finally, download a summary of unique records. Say for example you want to know the unique TagCodes detected in the array from a studyID
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", fields = c("TagCode"), distinct = T, 'Study_ID="DeerCk-SH-Wild-2019"')

## Or, number of unique fish detected at each receiver location for a studyID
dat <- tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="DeerCk-SH-Wild-2019"', fields = c("general_location","TagCode"), distinct = T)

## Now, bringing it all together to perform analyses
## Here, as a basic example, the percentage of fish released that were detected at Benicia Bridge for a study

# Find number of fish released per Study ID. NOTE, if a released fish was never detected again, it will have only one row, with blank for a timestamp and detection location info
released <- nrow(tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Winter_H_2019"', fields = c("TagCode"), distinct = T))
benicia <- nrow(tabledap('FEDcalFishTrack', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'Study_ID="Winter_H_2019"', 'general_location="ButteBrRT"', fields = c("TagCode"), distinct = T))
## Percent detected at Benicia:
round(benicia/released*100, 2)

## PLEASE NOTE: IF A DATA REQUEST ABOVE RETURNS SIMPLY "Error: ", THIS LIKELY MEANS THE DATA REQUEST CAME UP WITH ZERO RETURNS
