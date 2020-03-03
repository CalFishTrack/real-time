---
title: CalFishTrack

output:
  html_document:
    code_folding: hide
    toc: true
    toc_float: true
  #prettydoc::html_pretty:
  #  theme: cayman
  #  toc: true
---


#  *Central Valley Enhanced*
#  *Acoustic Tagging Project*
preserve6c4114247f0f6150

<br/>
<br/>

preserve8c5e781a0a7e7f27

<br/>
<br/>

# **Hatchery-origin late-fall run Chinook salmon**

<br/>

## 2019-2020 Season (PROVISIONAL DATA)

<br/>

---
## Project Status
***

Telemetry Study Template for this study can be found [here](https://github.com/CalFishTrack/real-time/blob/master/data/Telemetry_Study_Summary_NOAA_CNFH_late-fall-run_2020.pdf?raw=true)


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

tagcodes <- read.csv("qry_HexCodes.txt", stringsAsFactors = F, colClasses=c("TagID_Hex"="character"))

tagcodes$RelDT <- as.POSIXct(tagcodes$RelDT, format = "%m/%d/%Y %I:%M:%S %p", tz = "Etc/GMT+8")
latest <- read.csv("latest_download.csv", stringsAsFactors = F)

study_tagcodes <- tagcodes[tagcodes$StudyID == "ColemanLateFall_2020",]
 

if (nrow(study_tagcodes) == 0){
  cat("Project has not yet begun")
}else{
  cat(paste("Project began on ", min(study_tagcodes$RelDT), ", see tagging details below:", sep = ""))


  study_tagcodes$Release <- "Week 1"
  #study_tagcodes[study_tagcodes$RelDT > as.POSIXct("2019-05-17"), "Release"] <- "Week 2"

  
  
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
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left")
}                       
```

```
## Project began on 2019-12-05 07:20:00, see tagging details below:
```

<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
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
   <td style="text-align:left;"> Week 1 </td>
   <td style="text-align:left;"> 2019-12-05 07:20:00 </td>
   <td style="text-align:left;"> 2019-12-05 12:20:00 </td>
   <td style="text-align:right;"> 603 </td>
   <td style="text-align:left;"> BattleCk_CNFH </td>
   <td style="text-align:right;"> 517.344 </td>
   <td style="text-align:right;"> 149.2 </td>
   <td style="text-align:right;"> 40.3 </td>
  </tr>
</tbody>
</table>

***
<br/>

## Real-time Fish Detections

***Data current as of <span style="color:red">2020-03-02 18:00:00</span>. All times in Pacific Standard Time.***


<br/>
<center>
#### Detections at Butte City Bridge versus Sacramento River flows at Butte City
</center>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

library(CDECRetrieve)
library(reshape2)

detects_study <- fread("C:/Users/field/Desktop/Real-time data massaging/products/Study_detection_files/detects_ColemanLateFall_2020.csv")
detects_study$DateTime_PST <- as.POSIXct(detects_study$DateTime_PST, format = "%Y-%m-%d %H:%M:%S", "Etc/GMT+8")

if(nrow(detects_study)>0){
  detects_study <- merge(detects_study, study_tagcodes[,c("TagID_Hex", "RelDT", "StudyID", "Release", "tag_life")], by.x = "TagCode", by.y = "TagID_Hex")
}

#detects_study <- detects_study[detects_study$recv != 17135,]

detects_butte <- detects_study[detects_study$general_location == "ButteBrRT",]

#wlk_flow <- read.csv("wlk.csv")

if (nrow(detects_butte) == 0){
  "No detections yet"
} else {
  
  detects_butte <- merge(detects_butte,aggregate(list(first_detect = detects_butte$DateTime_PST), by = list(TagCode= detects_butte$TagCode), FUN = min))
  
  detects_butte$Day <- as.Date(detects_butte$first_detect, "Etc/GMT+8")
  
  starttime <- as.Date(min(detects_butte$RelDT), "Etc/GMT+8")
  ## Endtime should be either now, or end of predicted tag life, whichever comes first
  endtime <- min(as.Date(c(Sys.time())), max(as.Date(detects_butte$RelDT)+(detects_butte$tag_life*1.5)))
  

  BTC_flow <- cdec_query("BTC", "20", "H", starttime, endtime+1)

  BTC_flow$datetime <- as.Date(BTC_flow$datetime)
  BTC_flow_day <- aggregate(list(parameter_value = BTC_flow$parameter_value),
                            by = list(Day = BTC_flow$datetime),
                            FUN = mean, na.rm = T)


  daterange <- data.frame(Day = seq.Date(from = starttime, to = endtime, by = "day"))

  rels <- unique(study_tagcodes[study_tagcodes$StudyID == unique(detects_butte$StudyID), "Release"])
  rel_num <- length(rels)
  rels_no_detects <- as.character(rels[!(rels %in% unique(detects_butte$Release))])

  tagcount <- aggregate(list(unique_tags = detects_butte$TagCode), by = list(Day = detects_butte$Day, Release = detects_butte$Release ), FUN = function(x){length(unique(x))})
  tagcount1 <- dcast(tagcount, Day ~ Release)

  daterange1 <- merge(daterange, tagcount1, all.x=T)

  if(length(rels_no_detects)>0){
    for(i in rels_no_detects){
      daterange1 <- cbind(daterange1, x=NA)
      names(daterange1)[names(daterange1) == 'x'] <- paste(i)
    }
  }

  daterange2 <- merge(daterange1, BTC_flow_day, by = "Day", all.x = T)

  rownames(daterange2) <- daterange2$Day
  daterange2$Day <- NULL

  par(mar=c(6, 5, 2, 5) + 0.1)
  barp <- barplot(t(daterange2[,1:ncol(daterange2)-1]), plot = FALSE, beside = T)
  barplot(t(daterange2[,1:ncol(daterange2)-1]), beside = T, col=viridis_pal()(rel_num),
          xlab = "", ylab = "Number of fish arrivals per day",
          ylim = c(0,max(daterange2[,1:ncol(daterange2)-1], na.rm = T)*1.2),
          las = 2, xlim=c(0,max(barp)+1), cex.lab = 1.5, yaxt = "n", xaxt ="n")#,
  #border=NA
  #legend.text = colnames(daterange2[,1:ncol(daterange2)-1]),
  #args.legend = list(x ='topright', bty='n', inset=c(-0.2,0)), title = "Release Group")
  legend(x ='topleft', legend = colnames(daterange2)[1:ncol(daterange2)-1], fill= viridis_pal()(rel_num), horiz = T, title = "Release")
  ybreaks <- if(max(daterange2[,1:ncol(daterange2)-1], na.rm = T) < 4) {max(daterange2[,1:ncol(daterange2)-1], na.rm = T)} else {5}
  xbreaks <- if(ncol(barp) > 10) {seq(1, ncol(barp), 2)} else {1:ncol(barp)}
  barpmeans <- colMeans(barp)
  axis(1, at = barpmeans[xbreaks], labels = rownames(daterange2[xbreaks,]), las = 2)
  axis(2, at = pretty(0:max(daterange2[,1:ncol(daterange2)-1], na.rm = T), ybreaks))

  par(new=T)

  plot(x = barpmeans, daterange2$parameter_value, yaxt = "n", xaxt = "n", ylab = "", xlab = "", col = "blue", type = "l", lwd=2, xlim=c(0,max(barp)+1), ylim = c(min(daterange2$parameter_value, na.rm = T), max(daterange2$parameter_value, na.rm=T)*1.1))#, ylab = "Returning adults", xlab= "Outmigration year", yaxt="n", col="red", pch=20)
  axis(side = 4)#, labels = c(2000:2016), at = c(2000:2016))
  mtext("Flow (cfs) at Butte City", side=4, line=3, cex=1.5, col="blue")
}
```

<img src="pageCHLF_2020_files/figure-html/print figure of fish detections at Butte-1.png" width="960" />

<br/>
<br/>

<center>
#### Detections at Tower Bridge (downtown Sacramento) versus Sacramento River flows at Wilkins Slough
</center>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

library(CDECRetrieve)
library(reshape2)

detects_tower <- detects_study[detects_study$general_location == "TowerBridge",]

#wlk_flow <- read.csv("wlk.csv")

if (nrow(detects_tower) == 0){
  "No detections yet"
} else {
  
  detects_tower <- merge(detects_tower,aggregate(list(first_detect = detects_tower$DateTime_PST), by = list(TagCode= detects_tower$TagCode), FUN = min))
  
  detects_tower$Day <- as.Date(detects_tower$first_detect, "Etc/GMT+8")
  
  starttime <- as.Date(min(detects_tower$RelDT), "Etc/GMT+8")
  ## Endtime should be either now, or end of predicted tag life, whichever comes first
  endtime <- min(as.Date(c(Sys.time())), max(as.Date(detects_tower$RelDT)+(detects_tower$tag_life*1.5)))
  

  wlk_flow <- cdec_query("WLK", "20", "H", starttime, endtime+1)

  wlk_flow$datetime <- as.Date(wlk_flow$datetime)
  wlk_flow_day <- aggregate(list(parameter_value = wlk_flow$parameter_value),
                            by = list(Day = wlk_flow$datetime),
                            FUN = mean, na.rm = T)


  daterange <- data.frame(Day = seq.Date(from = starttime, to = endtime, by = "day"))

  rels <- unique(study_tagcodes[study_tagcodes$StudyID == unique(detects_tower$StudyID), "Release"])
  rel_num <- length(rels)
  rels_no_detects <- as.character(rels[!(rels %in% unique(detects_tower$Release))])

  tagcount <- aggregate(list(unique_tags = detects_tower$TagCode), by = list(Day = detects_tower$Day, Release = detects_tower$Release ), FUN = function(x){length(unique(x))})
  tagcount1 <- dcast(tagcount, Day ~ Release)

  daterange1 <- merge(daterange, tagcount1, all.x=T)

  if(length(rels_no_detects)>0){
    for(i in rels_no_detects){
      daterange1 <- cbind(daterange1, x=NA)
      names(daterange1)[names(daterange1) == 'x'] <- paste(i)
    }
  }

  daterange2 <- merge(daterange1, wlk_flow_day, by = "Day", all.x = T)

  rownames(daterange2) <- daterange2$Day
  daterange2$Day <- NULL

  par(mar=c(6, 5, 2, 5) + 0.1)
  barp <- barplot(t(daterange2[,1:ncol(daterange2)-1]), plot = FALSE, beside = T)
  barplot(t(daterange2[,1:ncol(daterange2)-1]), beside = T, col=viridis_pal()(rel_num),
          xlab = "", ylab = "Number of fish arrivals per day",
          ylim = c(0,max(daterange2[,1:ncol(daterange2)-1], na.rm = T)*1.2),
          las = 2, xlim=c(0,max(barp)+1), cex.lab = 1.5, yaxt = "n", xaxt ="n")#,
  #border=NA
  #legend.text = colnames(daterange2[,1:ncol(daterange2)-1]),
  #args.legend = list(x ='topright', bty='n', inset=c(-0.2,0)), title = "Release Group")
  legend(x ='topleft', legend = colnames(daterange2)[1:ncol(daterange2)-1], fill= viridis_pal()(rel_num), horiz = T, title = "Release")
  ybreaks <- if(max(daterange2[,1:ncol(daterange2)-1], na.rm = T) < 4) {max(daterange2[,1:ncol(daterange2)-1], na.rm = T)} else {5}
  xbreaks <- if(ncol(barp) > 10) {seq(1, ncol(barp), 2)} else {1:ncol(barp)}
  barpmeans <- colMeans(barp)
  axis(1, at = barpmeans[xbreaks], labels = rownames(daterange2[xbreaks,]), las = 2)
  axis(2, at = pretty(0:max(daterange2[,1:ncol(daterange2)-1], na.rm = T), ybreaks))

  par(new=T)

  plot(x = barpmeans, daterange2$parameter_value, yaxt = "n", xaxt = "n", ylab = "", xlab = "", col = "blue", type = "l", lwd=2, xlim=c(0,max(barp)+1), ylim = c(min(daterange2$parameter_value, na.rm = T), max(daterange2$parameter_value, na.rm=T)*1.1))#, ylab = "Returning adults", xlab= "Outmigration year", yaxt="n", col="red", pch=20)
  axis(side = 4)#, labels = c(2000:2016), at = c(2000:2016))
  mtext("Flow (cfs) at Wilkins Slough", side=4, line=3, cex=1.5, col="blue")
}
```

<img src="pageCHLF_2020_files/figure-html/print figure of fish detections at Tower-1.png" width="960" />

<br/>
<br/>

<center>
#### Detections at Benicia Bridge
</center>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

detects_benicia <- detects_study[detects_study$general_location %in% c("Benicia_west", "Benicia_east"),]

if (nrow(detects_benicia)>0) {
  detects_benicia <- merge(detects_benicia,aggregate(list(first_detect = detects_benicia$DateTime_PST), by = list(TagCode= detects_benicia$TagCode), FUN = min))
  
  detects_benicia$Day <- as.Date(detects_benicia$first_detect, "Etc/GMT+8")
  
  starttime <- as.Date(min(detects_benicia$RelDT), "Etc/GMT+8")
  #endtime <- as.Date(c(Sys.time()))#, max(detects_benicia$first_detect)+60*60*24)))
  #wlk_flow <- cdec_query("COL", "20", "H", starttime, endtime+1)
  #wlk_flow$datetime <- as.Date(wlk_flow$datetime)
  #wlk_flow_day <- aggregate(list(parameter_value = wlk_flow$parameter_value), by = list(Day = wlk_flow$datetime), FUN = mean, na.rm = T)
  
  daterange <- data.frame(Day = seq.Date(from = starttime, to = endtime, by = "day"))
  
  rels <- unique(study_tagcodes[study_tagcodes$StudyID == unique(detects_benicia$StudyID), "Release"])
  rel_num <- length(rels)
  rels_no_detects <- as.character(rels[!(rels %in% unique(detects_benicia$Release))])
  
  tagcount <- aggregate(list(unique_tags = detects_benicia$TagCode), by = list(Day = detects_benicia$Day, Release = detects_benicia$Release ), FUN = function(x){length(unique(x))})
  tagcount1 <- dcast(tagcount, Day ~ Release)
                    
  daterange1 <- merge(daterange, tagcount1, all.x=T)
  
  if(length(rels_no_detects)>0){
    for(i in rels_no_detects){
      daterange1 <- cbind(daterange1, x=NA)
      names(daterange1)[names(daterange1) == 'x'] <- paste(i)
    }
  }
  
  #daterange2 <- merge(daterange1, wlk_flow_day, by = "Day", all.x = T)
  daterange2 <- daterange1
  
  rownames(daterange2) <- daterange2$Day
  daterange2$Day <- NULL
  
  par(mar=c(6, 5, 2, 5) + 0.1)
  barp <- barplot(t(daterange2[,1:ncol(daterange2)]), plot = FALSE, beside = T)
  barplot(t(daterange2[,1:ncol(daterange2)]), beside = T, col=viridis_pal()(rel_num), 
          xlab = "", ylab = "Number of fish arrivals per day", 
          ylim = c(0,max(daterange2[,1:ncol(daterange2)], na.rm = T)*1.2), 
          las = 2, xlim=c(0,max(barp)+1), cex.lab = 1.5, yaxt = "n", xaxt = "n")#, 
          #legend.text = colnames(daterange2[,1:ncol(daterange2)-1]),
          #args.legend = list(x ='topright', bty='n', inset=c(-0.2,0)), title = "Release Group")
  legend(x ='topleft', legend = colnames(daterange2)[1:ncol(daterange2)], fill= viridis_pal()(rel_num), horiz = T, title = "Release")
  ybreaks <- if(max(daterange2[,1:ncol(daterange2)], na.rm = T) < 4) {max(daterange2[,1:ncol(daterange2)], na.rm = T)} else {5}
  xbreaks <- if(ncol(barp) > 10) {seq(1, ncol(barp), 2)} else {1:ncol(barp)}
  barpmeans <- colMeans(barp)
  axis(1, at = barpmeans[xbreaks], labels = rownames(daterange2)[xbreaks], las = 2)
  axis(2, at = pretty(0:max(daterange2[,1:ncol(daterange2)], na.rm = T), ybreaks))
  box()

#par(new=T)

#plot(x = barpmeans, daterange2$parameter_value, yaxt = "n", xaxt = "n", ylab = "", xlab = "", col = "blue", type = "l", lwd=2, xlim=c(0,max(barp)+1), ylim = c(min(daterange2$parameter_value, na.rm = T), max(daterange2$parameter_value, na.rm=T)*1.1))#, ylab = "Returning adults", xlab= "Outmigration year", yaxt="n", col="red", pch=20)
#axis(side = 4)#, labels = c(2000:2016), at = c(2000:2016))
#mtext("Flow (cfs) at Colusa Bridge", side=4, line=3, cex=1.5, col="blue")

}else{
  print("No detections at Benicia yet")
}
```

<img src="pageCHLF_2020_files/figure-html/print figure of fish detections at Benicia-1.png" width="960" />


<br/>
<br/>

</center>
#### Minimum survival to Tower Bridge (using CJS survival model)
##### If Yolo Bypass Weirs are overtopping during migration, fish may have taken that route, and therefore this is a minimum estimate of survival
</center>

<br/>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

library(data.table)
library(RMark)

gen_locs <- read.csv("realtime_locs.csv", stringsAsFactors = F)

study_count <- nrow(study_tagcodes)

if (nrow(detects_tower) == 0){
  "No detections yet"
} else {
  
  ## Only do survival to Sac for now
  test <- detects_study[detects_study$rkm > 168 & detects_study$rkm < 175,]
  
  ## Create inp for survival estimation
  
  inp <- as.data.frame(dcast(test, TagCode ~ rkm, fun.aggregate = length))
  
  ## Sort columns by river km in descending order
  # Count number of genlocs
  gen_loc_sites <- ncol(inp)-1
  
  if(gen_loc_sites <2){
    "Detections at only one location so far, survival cannot yet be estimated"
  }else{
  
    inp <- inp[,c(1,order(names(inp[,2:(gen_loc_sites+1)]), decreasing = T)+1)]
  
    inp <- merge(study_tagcodes, inp, by.x = "TagID_Hex", by.y = "TagCode", all.x = T)
    
    inp2 <- inp[,(ncol(inp)-gen_loc_sites+1):ncol(inp)]
    inp2[is.na(inp2)] <- 0
    inp2[inp2 > 0] <- 1
    
    inp <- cbind(inp, inp2)
    groups <- as.character(sort(unique(inp$Release)))
  
    inp[,groups] <- 0
    for (i in groups) {
      inp[as.character(inp$Release) == i, i] <- 1
    }
    
    if(length(unique(inp[,groups])) > 1){
      inp$inp_final <- paste("1",apply(inp2, 1, paste, collapse=""), " ",apply(inp[,groups], 1, paste, collapse=" ")," ;",sep = "")
      write.table(inp$inp_final,"WRinp.inp",row.names = F, col.names = F, quote = F)
      WRinp <- convert.inp("WRinp.inp", group.df=data.frame(rel=groups))
      WR.process <- process.data(WRinp, model="CJS", begin.time=1, groups = "rel") 
      
      WR.ddl <- make.design.data(WR.process)
    
      WR.mark.all <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time),p=list(formula=~time)), silent = T, output = F)
    
      WR.mark.rel <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time*rel),p=list(formula=~time)), silent = T, output = F)
    
      WR.surv <- round(WR.mark.all$results$real[1,c("estimate", "se", "lcl", "ucl")] * 100,1)
      WR.surv <- rbind(WR.surv, round(WR.mark.rel$results$real[seq(from=1,to=length(groups)*2,by = 2),c("estimate", "se", "lcl", "ucl")] * 100,1))
      WR.surv$Detection_efficiency <- NA
      WR.surv[1,"Detection_efficiency"] <-   round(WR.mark.all$results$real[gen_loc_sites+1,"estimate"] * 100,1)
    
      WR.surv <- cbind(c("ALL", groups), WR.surv)
    }
    if(length(unique(inp[,groups])) < 2){
      inp$inp_final <- paste("1",apply(inp2, 1, paste, collapse=""), " ", 1,sep = "")
      write.table(inp$inp_final,"WRinp.inp",row.names = F, col.names = F, quote = F)
      WRinp <- convert.inp("WRinp.inp")
      WR.process <- process.data(WRinp, model="CJS", begin.time=1) 
      
      WR.ddl <- make.design.data(WR.process)
    
      WR.mark.all <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time),p=list(formula=~time)), silent = T, output = F)
    
      WR.mark.rel <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time),p=list(formula=~time)), silent = T, output = F)
    
      WR.surv <- round(WR.mark.all$results$real[1,c("estimate", "se", "lcl", "ucl")] * 100,1)
      WR.surv <- rbind(WR.surv, round(WR.mark.rel$results$real[seq(from=1,to=length(groups)*2,by = 2),c("estimate", "se", "lcl", "ucl")] * 100,1))
      WR.surv$Detection_efficiency <- NA
      WR.surv[1,"Detection_efficiency"] <- round(WR.mark.all$results$real[gen_loc_sites+1,"estimate"] * 100,1)
    
      WR.surv <- cbind(c("ALL", groups), WR.surv)
    }

    
    colnames(WR.surv) <- c("Release", "Survival (%)", "SE", "95% lower C.I.", "95% upper C.I.", "Detection efficiency (%)")
    
    print(kable(WR.surv, row.names = F, "html") %>%
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))
  }
}
```

<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Release </th>
   <th style="text-align:right;"> Survival (%) </th>
   <th style="text-align:right;"> SE </th>
   <th style="text-align:right;"> 95% lower C.I. </th>
   <th style="text-align:right;"> 95% upper C.I. </th>
   <th style="text-align:right;"> Detection efficiency (%) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ALL </td>
   <td style="text-align:right;"> 60.4 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 56.4 </td>
   <td style="text-align:right;"> 64.2 </td>
   <td style="text-align:right;"> 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Week 1 </td>
   <td style="text-align:right;"> 60.4 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 56.4 </td>
   <td style="text-align:right;"> 64.2 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table>

<br/>
<br/>

</center>
#### Reach-specific survival and probability of entering Georgiana Slough
</center>

<br/>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))


if (nrow(detects_study) == 0){
  "No detections yet"
} else {
  
  ## Only do survival to Georg split for now
  test2 <- detects_study[detects_study$general_location %in% c("ButteBrRT","TowerBridge", "I80-50_Br", "Sac_BlwGeorgiana", "Sac_BlwGeorgiana2", "Georgiana_Slough1", "Georgiana_Slough2"),]
  
  ## We can only do multistate model if there is at least one detection in each route
  
  if(nrow(test2[test2$general_location %in% c("Sac_BlwGeorgiana", "Sac_BlwGeorgiana2"),]) == 0 |
     nrow(test2[test2$general_location %in% c("Georgiana_Slough1", "Georgiana_Slough2"),]) == 0){
    "Too few detections: routing probability cannot be estimated"
  }else{
    
    ## Make tagcode character
    study_tagcodes$TagID_Hex <- as.character(study_tagcodes$TagID_Hex)
    ## Make a crosstab query with frequencies for all tag/location combination
    test2$general_location <- factor(test2$general_location, levels = c("ButteBrRT","TowerBridge", "I80-50_Br", "Sac_BlwGeorgiana", "Sac_BlwGeorgiana2", "Georgiana_Slough1", "Georgiana_Slough2"))
    test2$TagCode <- factor(test2$TagCode, levels = study_tagcodes$TagID_Hex)
    mytable <- table(test2$TagCode, test2$general_location) # A will be rows, B will be columns
    
    ## Change all frequencies bigger than 1 to 1. Here you could change your minimum cutoff to 2 detections, and then make another command that changes all detections=1 to 0
    mytable[mytable>0] <- "A"
    
    ## Order in order of rkm
    mytable2 <- mytable[, c("ButteBrRT","TowerBridge", "I80-50_Br", "Sac_BlwGeorgiana", "Sac_BlwGeorgiana2", "Georgiana_Slough1", "Georgiana_Slough2")]
    
    ## Now sort the crosstab rows alphabetically
    mytable2 <- mytable2[order(row.names(mytable2)),]
    
    mytable2[which(mytable2[, "Sac_BlwGeorgiana"]=="A"), "Sac_BlwGeorgiana"] <- "A"
    mytable2[which(mytable2[, "Sac_BlwGeorgiana2"]=="A"), "Sac_BlwGeorgiana2"] <- "A"
    mytable2[which(mytable2[, "Georgiana_Slough1"]=="A"), "Georgiana_Slough1"] <- "B"
    mytable2[which(mytable2[, "Georgiana_Slough2"]=="A"), "Georgiana_Slough2"] <- "B"
    
    ## Make a crosstab query with frequencies for all weekly Release groups
    #test2$Release <- factor(test2$Release)
    #mytable3 <- table(test2$TagCode, test2$Release) # A will be rows, B will be columns
    
    ## Change all frequencies bigger than 1 to 1. Here you could change your minimum cutoff to 2 detections, and then make another command that changes all detections=1 to 0
    #mytable3[mytable3>0] <- 1
    
    ## Order in order of rkm
    #mytable4 <- mytable3[, order(colnames(mytable3))]
    
    ## Now sort the crosstab rows alphabetically
    #mytable4 <- mytable4[order(row.names(mytable4)),]
    
    ## Now order the study_tagcodes table the same way
    study_tagcodes <- study_tagcodes[order(study_tagcodes$TagID_Hex),]
    
    ## Paste together (concatenate) the data from each column of the crosstab into one string per row, add to tagging_meta.
    ## For this step, make sure both are sorted by FishID
    study_tagcodes$inp_part1 <- apply(mytable2[,1:3],1,paste,collapse="")
    study_tagcodes$inp_partA <- apply(mytable2[,4:5],1,paste,collapse="")
    study_tagcodes$inp_partB <- apply(mytable2[,6:7],1,paste,collapse="")
    #study_tagcodes$inp_group <- apply(mytable4,1,paste,collapse=" ")
    
    ## We need to have a way of picking which route to assign to a fish if it was detected by both georg and blw-georg recvs
    ## We will say that the last detection at that junction is what determines the route it took
    
    ## find last detection at each genloc
    departure <- aggregate(list(depart = test2$DateTime_PST), by = list(TagID_Hex = test2$TagCode, last_location = test2$general_location), FUN = max)
    ## subset for just juncture locations
    departure <- departure[departure$last_location %in% c("Sac_BlwGeorgiana", "Sac_BlwGeorgiana2", "Georgiana_Slough1", "Georgiana_Slough2"),]
    ## Find genloc of last known detection per tag
    last_depart <- aggregate(list(depart = departure$depart), by = list(TagID_Hex = departure$TagID_Hex), FUN = max)
    
    last_depart1 <- merge(last_depart, departure)
    study_tagcodes <- merge(study_tagcodes, last_depart1[,c("TagID_Hex", "last_location")], by = "TagID_Hex", all.x = T)
    
    ## Assume that the Sac is default pathway, and for fish that were detected in neither route, it would get a "00" in inp so doesn't matter anyway
    study_tagcodes$inp_final <- paste("A",study_tagcodes$inp_part1, study_tagcodes$inp_partA," 1 ;", sep = "")
    
    ## now put in exceptions...fish that were seen in georgiana last
    study_tagcodes[study_tagcodes$last_location %in% c("Georgiana_Slough1", "Georgiana_Slough2"), "inp_final"] <- paste("A",study_tagcodes[study_tagcodes$last_location %in% c("Georgiana_Slough1", "Georgiana_Slough2"), "inp_part1"], study_tagcodes[study_tagcodes$last_location %in% c("Georgiana_Slough1", "Georgiana_Slough2"), "inp_partB"]," 1 ;", sep = "")
    
    write.table(study_tagcodes$inp_final,"WRinp_multistate.inp",row.names = F, col.names = F, quote = F)
    
    WRinp <- convert.inp("WRinp_multistate.inp")
    
    dp <- process.data(WRinp, model="Multistrata") 
    
    ddl <- make.design.data(dp)
    
    #### p ####
    # Can't be seen at 2B or 3B or 4B (butte, tower or I80)
    ddl$p$fix=NA
    ddl$p$fix[ddl$p$stratum == "B" & ddl$p$time %in% c(2,3,4)]=0
    
    #### Psi ####
    # Only 1 transition allowed:
    # from A to B at time interval 4 to 5
    
    ddl$Psi$fix=0
    # A to B can only happen for interval 3-4
    ddl$Psi$fix[ddl$Psi$stratum=="A"&
                  ddl$Psi$tostratum=="B" & ddl$Psi$time==4]=NA
    
    #### Phi a.k.a. S ####
    ddl$S$fix=NA
    # None in B for reaches 1,2,3,4 and fixing it to 1 for 5 (between two georg lines). All getting fixed to 1
    ddl$S$fix[ddl$S$stratum=="B" & ddl$S$time %in% c(1,2,3,4,5)]=1
    
    # For route A, fixing it to 1 for 5 (between two blw_georg lines)
    ddl$S$fix[ddl$S$stratum=="A" & ddl$S$time==5]=1
    ## We use -1 at beginning of formula to remove intercept. This is because different routes probably shouldn't share the same intercept
    
    p.timexstratum=list(formula=~-1+stratum:time)
    Psi.stratumxtime=list(formula=~-1+stratum:time)
    S.stratumxtime=list(formula=~-1+stratum:time)
    
    ## Run model a first time
    S.timexstratum.p.timexstratum.Psi.timexstratum=mark(dp,ddl, model.parameters=list(S=S.stratumxtime,p= p.timexstratum,Psi=Psi.stratumxtime), realvcv = T, silent = T, output = F)
    
    ## Identify any parameter estimates at 1, which would likely have bad SE estimates.
    profile.intervals <- which(S.timexstratum.p.timexstratum.Psi.timexstratum$results$real$estimate %in% c(0,1) & !S.timexstratum.p.timexstratum.Psi.timexstratum$results$real$fixed == "Fixed")
    
    ## Rerun model using profile interval estimation for the tricky parameters
    S.timexstratum.p.timexstratum.Psi.timexstratum=mark(dp,ddl, model.parameters=list(S=S.stratumxtime,p= p.timexstratum,Psi=Psi.stratumxtime), realvcv = T, profile.int = profile.intervals, silent = T, output = F)
    
    results <- S.timexstratum.p.timexstratum.Psi.timexstratum$results$real
    
    results_short <- results[rownames(results) %in% c("S sA g1 c1 a0 o1 t1",
                                                      "S sA g1 c1 a1 o2 t2",
                                                      "S sA g1 c1 a2 o3 t3",
                                                      "S sA g1 c1 a3 o4 t4",
                                                      "p sA g1 c1 a1 o1 t2",
                                                      "p sA g1 c1 a2 o2 t3",
                                                      "p sA g1 c1 a3 o3 t4",
                                                      "p sA g1 c1 a4 o4 t5",
                                                      "p sB g1 c1 a4 o4 t5",
                                                      "Psi sA toB g1 c1 a3 o4 t4"
                                                      ),]
    
    
    results_short <- round(results_short[,c("estimate", "se", "lcl", "ucl")] * 100,1)
    
    results_short$Measure <- c("Survival from release to Butte City","Survival from Butte City to TowerBridge (minimum estimate since fish may have taken Yolo Bypass)", "Survival from TowerBridge to I80-50_Br", "% arrived from I80-50_Br to Georgiana Slough confluence (not survival because fish may have taken Sutter/Steam)","Detection probability at Butte City",
                               "Detection probability at TowerBridge", "Detection probability at I80-50_Br", "Detection probability at Blw_Georgiana", "Detection probability at Georgiana Slough",
                               "Routing probability into Georgiana Slough (Conditional on fish arriving to junction)")
    
    results_short <- results_short[,c("Measure", "estimate", "se", "lcl", "ucl")]
    colnames(results_short) <- c("Measure", "Estimate", "SE", "95% lower C.I.", "95% upper C.I.")

    print(kable(results_short, row.names = F, "html") %>%
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))
  }
}
```

<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Measure </th>
   <th style="text-align:right;"> Estimate </th>
   <th style="text-align:right;"> SE </th>
   <th style="text-align:right;"> 95% lower C.I. </th>
   <th style="text-align:right;"> 95% upper C.I. </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Survival from release to Butte City </td>
   <td style="text-align:right;"> 75.5 </td>
   <td style="text-align:right;"> 1.9 </td>
   <td style="text-align:right;"> 71.6 </td>
   <td style="text-align:right;"> 79.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Survival from Butte City to TowerBridge (minimum estimate since fish may have taken Yolo Bypass) </td>
   <td style="text-align:right;"> 80.4 </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 76.2 </td>
   <td style="text-align:right;"> 84.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Survival from TowerBridge to I80-50_Br </td>
   <td style="text-align:right;"> 100.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 99.5 </td>
   <td style="text-align:right;"> 100.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> % arrived from I80-50_Br to Georgiana Slough confluence (not survival because fish may have taken Sutter/Steam) </td>
   <td style="text-align:right;"> 60.9 </td>
   <td style="text-align:right;"> 2.6 </td>
   <td style="text-align:right;"> 55.8 </td>
   <td style="text-align:right;"> 65.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detection probability at Butte City </td>
   <td style="text-align:right;"> 86.3 </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:right;"> 82.4 </td>
   <td style="text-align:right;"> 89.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detection probability at TowerBridge </td>
   <td style="text-align:right;"> 99.5 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 97.8 </td>
   <td style="text-align:right;"> 99.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detection probability at I80-50_Br </td>
   <td style="text-align:right;"> 99.5 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 97.8 </td>
   <td style="text-align:right;"> 99.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detection probability at Blw_Georgiana </td>
   <td style="text-align:right;"> 100.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 100.0 </td>
   <td style="text-align:right;"> 100.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detection probability at Georgiana Slough </td>
   <td style="text-align:right;"> 100.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 96.2 </td>
   <td style="text-align:right;"> 100.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Routing probability into Georgiana Slough (Conditional on fish arriving to junction) </td>
   <td style="text-align:right;"> 23.8 </td>
   <td style="text-align:right;"> 2.9 </td>
   <td style="text-align:right;"> 18.6 </td>
   <td style="text-align:right;"> 29.8 </td>
  </tr>
</tbody>
</table>

<br/>
<br/>

<center>
#### Minimum survival to Benicia Bridge East Span (using CJS survival model)
</center>

<br/>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

if (nrow(detects_benicia) == 0){
  "No detections yet"
} else {
  
  benicia <- read.csv("benicia_surv.csv", stringsAsFactors = F)
  benicia$RelDT <- as.POSIXct(benicia$RelDT)

  ## Only do survival to Benicia here
  test3 <- detects_study[detects_study$rkm < 53,]
  
  ## Create inp for survival estimation
  
  inp <- as.data.frame(dcast(test3, TagCode ~ rkm, fun.aggregate = length))
  
  ## Sort columns by river km in descending order
  # Count number of genlocs
  gen_loc_sites <- ncol(inp)-1
  
  inp <- inp[,c(1,order(names(inp[,2:(gen_loc_sites+1)]), decreasing = T)+1)]

  inp <- merge(study_tagcodes, inp, by.x = "TagID_Hex", by.y = "TagCode", all.x = T)
  
  inp2 <- inp[,(ncol(inp)-gen_loc_sites+1):ncol(inp)]
  inp2[is.na(inp2)] <- 0
  inp2[inp2 > 0] <- 1
  
  inp <- cbind(inp, inp2)
  groups <- as.character(sort(unique(inp$Release)))

  inp[,groups] <- 0
  for (i in groups) {
    inp[as.character(inp$Release) == i, i] <- 1
  }
  
  if(length(groups) > 1){
    inp$inp_final <- paste("1",apply(inp2, 1, paste, collapse=""), " ",apply(inp[,groups], 1, paste, collapse=" ")," ;",sep = "")
  }else{
    inp$inp_final <- paste("1",apply(inp2, 1, paste, collapse=""), " ",inp[,groups]," ;",sep = "")
  }
  
  
  write.table(inp$inp_final,"WRinp.inp",row.names = F, col.names = F, quote = F)
  
  if(length(groups) > 1){
  
    WRinp <- convert.inp("WRinp.inp", group.df=data.frame(rel=groups))
    WR.process <- process.data(WRinp, model="CJS", begin.time=1, groups = "rel") 
    
    WR.ddl <- make.design.data(WR.process)
    
    WR.mark.all <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time),p=list(formula=~time)), silent = T, output = F)
    
    WR.mark.rel <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time*rel),p=list(formula=~time)), silent = T, output = F)
    
    WR.surv <- round(WR.mark.all$results$real[1,c("estimate", "se", "lcl", "ucl")] * 100,1)
    WR.surv <- rbind(WR.surv, round(WR.mark.rel$results$real[seq(from=1,to=length(groups)*2,by = 2),c("estimate", "se", "lcl", "ucl")] * 100,1))
    
  }else{
    
    WRinp <- convert.inp("WRinp.inp")
    WR.process <- process.data(WRinp, model="CJS", begin.time=1) 
    
      
    WR.ddl <- make.design.data(WR.process)
    
    WR.mark.all <- mark(WR.process, WR.ddl, model.parameters=list(Phi=list(formula=~time),p=list(formula=~time)), silent = T, output = F)

    WR.surv <- round(WR.mark.all$results$real[1,c("estimate", "se", "lcl", "ucl")] * 100,1)
    
  }
  
  WR.surv$Detection_efficiency <- NA
  WR.surv[1,"Detection_efficiency"] <- round(WR.mark.all$results$real[gen_loc_sites+1,"estimate"] * 100,1)
    
  WR.surv <- cbind(Release = c("ALL", groups), WR.surv)

  WR.surv1 <- WR.surv
  colnames(WR.surv1) <- c("Release Group", "Survival (%)", "SE", "95% lower C.I.", "95% upper C.I.", "Detection efficiency (%)")

  print(kable(WR.surv1, row.names = F, "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))    
  
  ## Find mean release time per release group, and ALL
  reltimes <- aggregate(list(RelDT = study_tagcodes$RelDT), by = list(Release = study_tagcodes$Release), FUN = mean)
  reltimes <- rbind(reltimes, data.frame(Release = "ALL", RelDT = mean(study_tagcodes$RelDT)))

  ## Assign whether the results are tentative or final
  quality <- "tentative"
  if(endtime < as.Date(c(Sys.time()))) { quality <- "final"}
  WR.surv <- merge(WR.surv, reltimes, by = "Release", all.x = T)
  
  WR.surv$RelDT <- as.POSIXct(WR.surv$RelDT, origin = '1970-01-01')
  
  ## remove old benicia record for this studyID
  benicia <- benicia[!benicia$StudyID == unique(study_tagcodes$StudyID),]
  
  benicia <- rbind(benicia, data.frame(WR.surv, StudyID = unique(study_tagcodes$StudyID), data_quality = quality))
  
  write.csv(benicia, "benicia_surv.csv", row.names = F, quote = F) 
  
}
```

<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Release Group </th>
   <th style="text-align:right;"> Survival (%) </th>
   <th style="text-align:right;"> SE </th>
   <th style="text-align:right;"> 95% lower C.I. </th>
   <th style="text-align:right;"> 95% upper C.I. </th>
   <th style="text-align:right;"> Detection efficiency (%) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ALL </td>
   <td style="text-align:right;"> 17.1 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:right;"> 14.3 </td>
   <td style="text-align:right;"> 20.3 </td>
   <td style="text-align:right;"> 99 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Week 1 </td>
   <td style="text-align:right;"> 17.1 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:right;"> 14.3 </td>
   <td style="text-align:right;"> 20.3 </td>
   <td style="text-align:right;"> 99 </td>
  </tr>
</tbody>
</table>
<br/>
<br/>

<center>
#### Detections statistics at all realtime receivers
</center>

<br/>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

if (nrow(detects_study) == 0){
  "No detections yet"
} else {

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
              caption = "Detections for all releases combined",
              "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))
  
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
            caption = paste("Detections for",j,"release groups", sep = " "),
            "html")
      
      print(kable_styling(final_stats, bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))
      
    } else {
      cat("\n\n\\pagebreak\n")
      print(paste("No detections for",j,"release group yet", sep=" "), quote = F)
      cat("\n\n\\pagebreak\n")
    }
  }
}
```

<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
<caption>Detections for all releases combined</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> general_location </th>
   <th style="text-align:left;"> First_arrival </th>
   <th style="text-align:left;"> Mean_arrival </th>
   <th style="text-align:left;"> Last_arrival </th>
   <th style="text-align:right;"> Fish_count </th>
   <th style="text-align:right;"> Percent_arrived </th>
   <th style="text-align:right;"> rkm </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ButteBrRT </td>
   <td style="text-align:left;"> 2019-12-08 08:17:20 </td>
   <td style="text-align:left;"> 2019-12-09 17:42:30 </td>
   <td style="text-align:left;"> 2020-01-18 08:40:21 </td>
   <td style="text-align:right;"> 393 </td>
   <td style="text-align:right;"> 65.17 </td>
   <td style="text-align:right;"> 344.108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TowerBridge </td>
   <td style="text-align:left;"> 2019-12-10 05:54:03 </td>
   <td style="text-align:left;"> 2019-12-12 09:22:54 </td>
   <td style="text-align:left;"> 2020-02-16 08:52:01 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 60.36 </td>
   <td style="text-align:right;"> 172.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> I80-50_Br </td>
   <td style="text-align:left;"> 2019-12-10 06:25:55 </td>
   <td style="text-align:left;"> 2019-12-12 09:59:52 </td>
   <td style="text-align:left;"> 2020-02-16 12:19:51 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 60.36 </td>
   <td style="text-align:right;"> 170.748 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MiddleRiver </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 150.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough1 </td>
   <td style="text-align:left;"> 2019-12-11 12:32:33 </td>
   <td style="text-align:left;"> 2019-12-15 02:00:45 </td>
   <td style="text-align:left;"> 2020-01-28 22:24:39 </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:right;"> 9.12 </td>
   <td style="text-align:right;"> 119.208 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana </td>
   <td style="text-align:left;"> 2019-12-11 11:45:06 </td>
   <td style="text-align:left;"> 2019-12-13 23:46:08 </td>
   <td style="text-align:left;"> 2020-01-29 22:06:53 </td>
   <td style="text-align:right;"> 172 </td>
   <td style="text-align:right;"> 28.52 </td>
   <td style="text-align:right;"> 119.058 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough2 </td>
   <td style="text-align:left;"> 2019-12-11 12:43:08 </td>
   <td style="text-align:left;"> 2019-12-13 08:34:31 </td>
   <td style="text-align:left;"> 2019-12-29 02:27:41 </td>
   <td style="text-align:right;"> 51 </td>
   <td style="text-align:right;"> 8.46 </td>
   <td style="text-align:right;"> 118.758 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana2 </td>
   <td style="text-align:left;"> 2019-12-11 12:40:49 </td>
   <td style="text-align:left;"> 2019-12-14 00:34:03 </td>
   <td style="text-align:left;"> 2020-01-29 22:25:03 </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> 28.19 </td>
   <td style="text-align:right;"> 118.398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_east </td>
   <td style="text-align:left;"> 2019-12-14 19:39:48 </td>
   <td style="text-align:left;"> 2019-12-21 02:51:48 </td>
   <td style="text-align:left;"> 2020-02-04 14:09:57 </td>
   <td style="text-align:right;"> 102 </td>
   <td style="text-align:right;"> 16.92 </td>
   <td style="text-align:right;"> 52.240 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_west </td>
   <td style="text-align:left;"> 2019-12-14 19:42:19 </td>
   <td style="text-align:left;"> 2019-12-21 04:27:32 </td>
   <td style="text-align:left;"> 2020-02-04 14:12:19 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 16.75 </td>
   <td style="text-align:right;"> 52.040 </td>
  </tr>
</tbody>
</table>
<table class="table table-striped table-hover table-condensed table-responsive" style="width: auto !important; ">
<caption>Detections for Week 1 release groups</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> general_location </th>
   <th style="text-align:left;"> First_arrival </th>
   <th style="text-align:left;"> Mean_arrival </th>
   <th style="text-align:left;"> Last_arrival </th>
   <th style="text-align:right;"> Fish_count </th>
   <th style="text-align:right;"> Percent_arrived </th>
   <th style="text-align:right;"> rkm </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ButteBrRT </td>
   <td style="text-align:left;"> 2019-12-08 08:17:20 </td>
   <td style="text-align:left;"> 2019-12-09 17:42:30 </td>
   <td style="text-align:left;"> 2020-01-18 08:40:21 </td>
   <td style="text-align:right;"> 393 </td>
   <td style="text-align:right;"> 65.17 </td>
   <td style="text-align:right;"> 344.108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TowerBridge </td>
   <td style="text-align:left;"> 2019-12-10 05:54:03 </td>
   <td style="text-align:left;"> 2019-12-12 09:22:54 </td>
   <td style="text-align:left;"> 2020-02-16 08:52:01 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 60.36 </td>
   <td style="text-align:right;"> 172.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> I80-50_Br </td>
   <td style="text-align:left;"> 2019-12-10 06:25:55 </td>
   <td style="text-align:left;"> 2019-12-12 09:59:52 </td>
   <td style="text-align:left;"> 2020-02-16 12:19:51 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 60.36 </td>
   <td style="text-align:right;"> 170.748 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MiddleRiver </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:left;"> 2020-01-01 20:32:34 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 150.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough1 </td>
   <td style="text-align:left;"> 2019-12-11 12:32:33 </td>
   <td style="text-align:left;"> 2019-12-15 02:00:45 </td>
   <td style="text-align:left;"> 2020-01-28 22:24:39 </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:right;"> 9.12 </td>
   <td style="text-align:right;"> 119.208 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana </td>
   <td style="text-align:left;"> 2019-12-11 11:45:06 </td>
   <td style="text-align:left;"> 2019-12-13 23:46:08 </td>
   <td style="text-align:left;"> 2020-01-29 22:06:53 </td>
   <td style="text-align:right;"> 172 </td>
   <td style="text-align:right;"> 28.52 </td>
   <td style="text-align:right;"> 119.058 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough2 </td>
   <td style="text-align:left;"> 2019-12-11 12:43:08 </td>
   <td style="text-align:left;"> 2019-12-13 08:34:31 </td>
   <td style="text-align:left;"> 2019-12-29 02:27:41 </td>
   <td style="text-align:right;"> 51 </td>
   <td style="text-align:right;"> 8.46 </td>
   <td style="text-align:right;"> 118.758 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana2 </td>
   <td style="text-align:left;"> 2019-12-11 12:40:49 </td>
   <td style="text-align:left;"> 2019-12-14 00:34:03 </td>
   <td style="text-align:left;"> 2020-01-29 22:25:03 </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> 28.19 </td>
   <td style="text-align:right;"> 118.398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_east </td>
   <td style="text-align:left;"> 2019-12-14 19:39:48 </td>
   <td style="text-align:left;"> 2019-12-21 02:51:48 </td>
   <td style="text-align:left;"> 2020-02-04 14:09:57 </td>
   <td style="text-align:right;"> 102 </td>
   <td style="text-align:right;"> 16.92 </td>
   <td style="text-align:right;"> 52.240 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_west </td>
   <td style="text-align:left;"> 2019-12-14 19:42:19 </td>
   <td style="text-align:left;"> 2019-12-21 04:27:32 </td>
   <td style="text-align:left;"> 2020-02-04 14:12:19 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 16.75 </td>
   <td style="text-align:right;"> 52.040 </td>
  </tr>
</tbody>
</table>

```r
## Set fig height for next plot here, based on how long fish have been at large
figheight <- max(c(1,as.numeric(difftime(Sys.Date(), min(study_tagcodes$RelDT), units = "days")) / 5))
```

<br/>
<br/>
<center>
#### Fish arrivals per day
</center>

<br/>

##### Gray tiles = receiver location was operational, white tiles = receiver location non-operational 

```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

if (nrow(detects_study) == 0){
  "No detections yet"
} else {
  
  beacon_by_day <- fread("beacon_by_day.csv", stringsAsFactors = F)
  beacon_by_day$day <- as.Date(beacon_by_day$day)
  
  arrivals$day <- as.Date(arrivals$DateTime_PST)
  
  arrivals_per_day <- aggregate(list(New_arrivals = arrivals$TagCode), by = list(day = arrivals$day, general_location = arrivals$general_location), length)
  arrivals_per_day$day <- as.Date(arrivals_per_day$day)

  ## Now subset to only look at data for the correct beacon for that day
  beacon_by_day <- as.data.frame(beacon_by_day[which(beacon_by_day$TagCode == beacon_by_day$beacon),])
  
  ## Now only keep beacon by day for days since fish were released
  beacon_by_day <- beacon_by_day[beacon_by_day$day >= as.Date(min(study_tagcodes$RelDT)),]  
  
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

<img src="pageCHLF_2020_files/figure-html/print tables of fish detections per day-1.png" width="480" />

```r
rm(list = ls())
cleanup(ask = F)
```
