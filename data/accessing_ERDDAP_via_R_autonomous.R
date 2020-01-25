
## Prepared by Cyril Michel on 2019-07-16; cyril.michel@noaa.gov

###########################################################################
#### HOW TO PULL IN AUTONOMOUS RECEIVER FISH DETECTION DATA INTO R ########
###########################################################################

## install and load the 'rerddap' library
library(rerddap)

## It is important to delete your cache if you want the newest data. 
## If not, when you rerun the same data queries as before, the command will likely return the old cached data and not the newest data
## If data is unlikely to change or be amended, not deleting your cache will speed up some data queries
cache_delete_all()

## Find out details on the database
db <- info('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/")
## This will tell you columns and their data types in database
vars <- db$variables
## This will tell you unique StudyID names
as.data.frame(tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", fields = c("study_id")))

## the following fields (along with associated metadata) are the most important fields for most analyses.
## Setting them as "important_fields" here will allow you to return only these fields in data queries
important_fields <- c("fish_id", # (Unique fish identification number, different from TagID, which can get reused by manufacturer)
                      "tag_id_hex", # (TagID code, in hexadecimal format)
                      "time", # (Detection Date/time, UTC)
                      "study_id", # (unifying name for all fish released in a year for a study)
                      "fish_release_date", # (Date/time of fish release, Pacific Standard Time - i.e., no DST offset)
                      "release_location", # (Release location name)
                      "release_latitude", # (Release location latitude, decimal degrees)
                      "release_longitude", # (Release location longitude, decimal degrees)
                      "release_river_km", # (Release River Kilometer - distance from Golden Gate, km)
                      "receiver_general_location", # (a unifying name when several receivers cover one location)
                      "receiver_location", # (Receiver Location (GPS name))
                      "receiver_general_latitude", # (General Location latitude, decimal degrees)
                      "receiver_general_longitude", # (General Location longitude, decimal degrees)
                      "receiver_river_km" # (Receiver River Kilometer - distance from Golden Gate, km)
                      )

# Download all data (will take a LONG while, large database). NOT RECOMMENDED!!!
# dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/")

# ALTERNATIVELY, download only the data you need, see following code snippets

## Download only data from 1 studyID, here for example, ColemanLateFall_2018 study, with only "important fields". If all fields are desired, remove the "fields" command
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="Winter_H_2018"', fields = important_fields)

# ## Download only data from 1 receiver location
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'receiver_general_location="GoldenGateW"', fields = important_fields)

## Download only data from a specific time range (in UTC time)
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'time>=2019-01-01', 'time<=2019-01-02', fields = important_fields)

## Download data from a combination of conditions. For example, study_id="ColemanLateFall_2018" and receiver_general_location="GoldenGateW"
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="ColemanLateFall_2018"', 'receiver_general_location="GoldenGateW"', fields = important_fields)

## Finally, download a summary of unique records. Say for example you want to know the unique Fish_ID codes detected in the array from a studyID
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="MillCk_Wild_2018"', fields = c("fish_id"), distinct = T)

## Or, number of unique fish detected at each receiver location for a studyID
dat <- tabledap('FED_JSATS', url = "http://oceanview.pfeg.noaa.gov/erddap/", 'study_id="MillCk_Wild_2018"', fields = c("receiver_general_location","fish_id"), distinct = T)

## PLEASE NOTE: IF A DATA REQUEST ABOVE RETURNS SIMPLY "Error: ", THIS LIKELY MEANS THE DATA REQUEST CAME UP WITH ZERO RETURNS
