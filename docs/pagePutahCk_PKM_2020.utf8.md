---
title: CalFishTrack

output:
  html_document:
    code_folding: hide
    toc: true
    toc_float: true
    includes:
      in_header: GA_Script.html
  #prettydoc::html_pretty:
  #  theme: cayman
  #  toc: true
---

<style>
p.caption {
  font-size: 1.5em;
}
caption {
      font-size: 1.5em;
}
</style>
#  *Central Valley Enhanced*
#  *Acoustic Tagging Project*
preserve3f4b47d3505a73dc

preserve2bfec18874811cc9

<br/>
<br/>

preserve9df98b77c0af04b4

<br/>
<br/>

# **Putah Creek Sacramento pikeminnow**

## 2019-2020 Season (PROVISIONAL DATA)

<br/>

***
## _1. Project Status_
***

Telemetry Study Template for this study can be found [here](https://github.com/CalFishTrack/real-time/blob/master/data/PutahCk_2020_Telemetry Study Summary.pdf?raw=true)


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

tagcodes <- as.data.frame(fread("qry_HexCodes.txt", stringsAsFactors = F))
tagcodes$RelDT <- as.POSIXct(tagcodes$RelDT, format = "%m/%d/%Y %I:%M:%S %p", tz = "Etc/GMT+8")
latest <- read.csv("latest_download.csv", stringsAsFactors = F)

study_tagcodes <- tagcodes[tagcodes$StudyID == "Putah_Creek_PKM_2020",]
 

if (nrow(study_tagcodes) == 0){
  cat("Project has not yet begun")
}else{
  cat(paste("Project began on ", min(study_tagcodes$RelDT), ", see tagging details below:", sep = ""))

  study_tagcodes$Release <- "Release 1"

  
  
  release_stats <- aggregate(list(First_release_time = study_tagcodes$RelDT),
                             by= list(Release = study_tagcodes$Release),
                             FUN = min)
  release_stats <- merge(release_stats,
                         aggregate(list(Last_release_time = study_tagcodes$RelDT),
                             by= list(Release = study_tagcodes$Release),
                             FUN = max),
                         by = c("Release"))
  
                             
  release_stats <- merge(release_stats, aggregate(list(Number_fish_released =
                                                         study_tagcodes$TagID_Hex),
                             by= list(Release = study_tagcodes$Release),
                             FUN = function(x) {length(unique(x))}),
                         by = c("Release"))
  
  release_stats <- merge(release_stats,
                         aggregate(list(Release_location = study_tagcodes$Rel_loc),
                             by= list(Release = study_tagcodes$Release),
                             FUN = function(x) {head(x,1)}),
                         by = c("Release"))
  release_stats <- merge(release_stats,
                         aggregate(list(Release_rkm = study_tagcodes$Rel_rkm),
                             by= list(Release = study_tagcodes$Release),
                             FUN = function(x) {head(x,1)}),
                         by = c("Release"))
  release_stats <- merge(release_stats,
                         aggregate(list(Mean_length = study_tagcodes$Length),
                             by= list(Release = study_tagcodes$Release),
                             FUN = mean, na.rm = T),
                         by = c("Release"))
  release_stats <- merge(release_stats,
                         aggregate(list(Mean_weight = study_tagcodes$Weight),
                             by= list(Release = study_tagcodes$Release),
                             FUN = mean, na.rm = T),
                         by = c("Release"))
  
    release_stats2<-release_stats[,-3]
  colnames(release_stats2)[2]<-"Release time"
  
  release_stats[,c("Mean_length", "Mean_weight")] <- round(release_stats[,c("Mean_length", "Mean_weight")],1)
  
  release_stats$First_release_time <- format(release_stats$First_release_time, tz = "Etc/GMT+8")
  
  release_stats$Last_release_time <- format(release_stats$Last_release_time, tz = "Etc/GMT+8")
  
  kable(release_stats, format = "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive", "bordered"), full_width = F, position = "left")
}                       
```

```
## Project began on 2020-04-22 11:30:00, see tagging details below:
```

<table class="table table-striped table-hover table-condensed table-responsive table-bordered" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Release </th>
   <th style="text-align:left;"> First_release_time </th>
   <th style="text-align:left;"> Last_release_time </th>
   <th style="text-align:right;"> Number_fish_released </th>
   <th style="text-align:left;"> Release_location </th>
   <th style="text-align:right;"> Release_rkm </th>
   <th style="text-align:right;"> Mean_length </th>
   <th style="text-align:right;"> Mean_weight </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Release 1 </td>
   <td style="text-align:left;"> 2020-04-22 11:30:00 </td>
   <td style="text-align:left;"> 2020-05-20 11:50:00 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> Russell Ranch </td>
   <td style="text-align:right;"> 168.9 </td>
   <td style="text-align:right;"> 88.5 </td>
   <td style="text-align:right;"> 7.2 </td>
  </tr>
</tbody>
</table>

<br/>


***
## _2. Detections statistics at all realtime receivers_
***
***Data current as of preservec874d74076068e5f. Updates occur hourly. All times in Pacific Standard Time.***


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

library(CDECRetrieve)
library(reshape2)

detects_study <- fread(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products\\Study_detection_files\\detects_Putah_Creek_PKM_2020.csv", sep = ""))

if (nrow(detects_study) == 0){
  "No detections yet"
} else {
  study_count <- nrow(study_tagcodes)
  gen_locs <- read.csv("realtime_locs.csv", stringsAsFactors = F)
  
  arrivals <- aggregate(list(DateTime_PST = detects_study$DateTime_PST), by = list(general_location = detects_study$general_location, TagCode = detects_study$TagCode), FUN = min)
  
  tag_stats <- aggregate(list(First_arrival = arrivals$DateTime_PST), 
                         by= list(general_location = arrivals$general_location),
                         FUN = min)
  tag_stats <- merge(tag_stats, 
                     aggregate(list(Mean_arrival = arrivals$DateTime_PST), 
                         by= list(general_location = arrivals$general_location),
                         FUN = mean), 
                     by = c("general_location"))
  tag_stats <- merge(tag_stats, 
                     aggregate(list(Last_arrival = arrivals$DateTime_PST), 
                         by= list(general_location = arrivals$general_location),
                         FUN = max), 
                     by = c("general_location"))
  tag_stats <- merge(tag_stats, 
                     aggregate(list(Fish_count = arrivals$TagCode), 
                         by= list(general_location = arrivals$general_location), 
                         FUN = function(x) {length(unique(x))}), 
                     by = c("general_location"))
  tag_stats$Percent_arrived <- round(tag_stats$Fish_count/study_count * 100,2)
      
  tag_stats <- merge(tag_stats, unique(gen_locs[,c("general_location", "rkm")]))
  
  tag_stats <- tag_stats[order(tag_stats$rkm, decreasing = T),]
  
  tag_stats[,c("First_arrival", "Mean_arrival", "Last_arrival")] <- format(tag_stats[,c("First_arrival", "Mean_arrival", "Last_arrival")], tz = "Etc/GMT+8")

  print(kable(tag_stats, row.names = F, 
              caption = "4.1 Detections for all releases combined",
              "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive", "bordered"), full_width = F, position = "left"))
  
  for (j in sort(unique(study_tagcodes$Release))) {
    
    if(nrow(detects_study[detects_study$Release == j,]) > 0 ) {
    
      temp <- detects_study[detects_study$Release == j,]
      
        arrivals1 <- aggregate(list(DateTime_PST = temp$DateTime_PST), by = list(general_location = temp$general_location, TagCode = temp$TagCode), FUN = min)
  
      rel_count <- nrow(study_tagcodes[study_tagcodes$Release == j,])
  
      tag_stats1 <- aggregate(list(First_arrival = arrivals1$DateTime_PST), 
                             by= list(general_location = arrivals1$general_location), 
                             FUN = min)
      tag_stats1 <- merge(tag_stats1, 
                         aggregate(list(Mean_arrival = arrivals1$DateTime_PST), 
                             by= list(general_location = arrivals1$general_location), 
                             FUN = mean), 
                         by = c("general_location"))
      tag_stats1 <- merge(tag_stats1, 
                   aggregate(list(Last_arrival = arrivals1$DateTime_PST), 
                       by= list(general_location = arrivals1$general_location), 
                       FUN = max), 
                   by = c("general_location"))
      tag_stats1 <- merge(tag_stats1, 
                         aggregate(list(Fish_count = arrivals1$TagCode), 
                                   by= list(general_location = arrivals1$general_location), 
                                   FUN = function(x) {length(unique(x))}), 
                         by = c("general_location"))
      
      tag_stats1$Percent_arrived <- round(tag_stats1$Fish_count/rel_count * 100,2)
    
      tag_stats1 <- merge(tag_stats1, unique(gen_locs[,c("general_location", "rkm")]))
    
      tag_stats1 <- tag_stats1[order(tag_stats1$rkm, decreasing = T),]
      
      tag_stats1[,c("First_arrival", "Mean_arrival", "Last_arrival")] <- format(tag_stats1[,c("First_arrival", "Mean_arrival", "Last_arrival")], tz = "Etc/GMT+8")
      
      final_stats <- kable(tag_stats1, row.names = F, 
            caption = paste("4.2 Detections for",j,"release groups", sep = " "),
            "html")
      
      print(kable_styling(final_stats, bootstrap_options = c("striped", "hover", "condensed", "responsive", "bordered"), full_width = F, position = "left"))
      
    } else {
      cat("\n\n\\pagebreak\n")
      print(paste("No detections for",j,"release group yet", sep=" "), quote = F)
      cat("\n\n\\pagebreak\n")
    }
  }
}
```

[1] "No detections yet"

```r
## Set fig height for next plot here, based on how long fish have been at large
figheight <- max(c(3,as.numeric(difftime(Sys.Date(), min(study_tagcodes$RelDT), units = "days")) / 4))
```
<br/>

### 2.2 Fish arrivals per day

```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

if (nrow(detects_study) == 0){
  "No detections yet"
} else {
  
  beacon_by_day <- fread("beacon_by_day.csv", stringsAsFactors = F)
  beacon_by_day$day <- as.Date(beacon_by_day$day)
  
  arrivals$day <- as.Date(format(arrivals$DateTime_PST, "%Y-%m-%d"))
  
  arrivals_per_day <- aggregate(list(New_arrivals = arrivals$TagCode), by = list(day = arrivals$day, general_location = arrivals$general_location), length)
  arrivals_per_day$day <- as.Date(arrivals_per_day$day)

  ## Now subset to only look at data for the correct beacon for that day
  beacon_by_day <- as.data.frame(beacon_by_day[which(beacon_by_day$TagCode == beacon_by_day$beacon),])
  
  ## Now only keep beacon by day for days since fish were released
  beacon_by_day <- beacon_by_day[beacon_by_day$day >= as.Date(min(study_tagcodes$RelDT)) & beacon_by_day$day <= endtime,]  
  
  beacon_by_day <- merge(beacon_by_day, gen_locs[,c("location", "general_location","rkm")], by = "location", all.x = T)

  arrivals_per_day <- merge(beacon_by_day, arrivals_per_day, all.x = T, by = c("general_location", "day"))
  
  arrivals_per_day$day <- factor(arrivals_per_day$day)
  
  ## Remove bench test and other NA locations
  arrivals_per_day <- arrivals_per_day[!arrivals_per_day$general_location == "Bench_test",]
  arrivals_per_day <- arrivals_per_day[is.na(arrivals_per_day$general_location) == F,]
  
  ## Change order of data to plot decreasing rkm
  arrivals_per_day <- arrivals_per_day[order(arrivals_per_day$rkm, decreasing = T),]
  arrivals_per_day$general_location <- factor(arrivals_per_day$general_location, unique(arrivals_per_day$general_location))
  
  
  ggplot(data=arrivals_per_day, aes(x=general_location, y=fct_rev(as_factor(day)))) +
  geom_tile(fill = "lightgray", color = "black") + 
  geom_text(aes(label=New_arrivals)) +
  labs(x="General Location", y = "Date") +
  theme(panel.background = element_blank(), axis.text.x = element_text(angle = 90, hjust = 1))
}
```

[1] "No detections yet"

```r
rm(list = ls())
```
