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
preservef948c08534d0d8c6

<br/>
<br/>

preservef4b8413ef01c4679
<br/>
<br/>



# *Yolo Bypass released Hatchery-origin Chinook salmon*

<br/>

## 2018-2019 Season (PROVISIONAL DATA)

<br/>

## Project Status

Telemetry Study Template for this study can be found [here](https://github.com/CalFishTrack/real-time/blob/master/data/Telemetry_Study_Summary_RiceProject.pdf?raw=true)


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

tagcodes <- read.csv("qry_HexCodes.txt", stringsAsFactors = F, colClasses=c("TagID_Hex"="character"))

tagcodes$RelDT <- as.POSIXct(tagcodes$RelDT, format = "%m/%d/%Y %I:%M:%S %p", tz = "Etc/GMT+8")
latest <- read.csv("latest_download.csv", stringsAsFactors = F)

study_tagcodes <- tagcodes[tagcodes$StudyID == "UCDYBAgRear",]
 

if (nrow(study_tagcodes) == 0){
  cat("Project has not yet begun")
}else{
  cat(paste("Project began on ", min(study_tagcodes$RelDT), ", see tagging details below:", sep = ""))
  
  study_tagcodes$Release <- "Release Sac"
  study_tagcodes[study_tagcodes$Rel_loc == "YB_ToeDrain_I5", "Release"] <- "Release Yolo"

  
  
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
                             FUN = mean),
                         by = c("Release"))
  release_stats <- merge(release_stats,
                         aggregate(list(Mean_weight = study_tagcodes$Weight),
                             by= list(Release = study_tagcodes$Release),
                             FUN = mean),
                         by = c("Release"))
  
  release_stats[,c("Mean_length", "Mean_weight")] <- round(release_stats[,c("Mean_length", "Mean_weight")],1)
  
  release_stats$First_release_time <- format(release_stats$First_release_time, tz = "Etc/GMT+8")
  
  release_stats$Last_release_time <- format(release_stats$Last_release_time, tz = "Etc/GMT+8")
  
  kable(release_stats, format = "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left")
}                       
```

```
## Project began on 2019-04-25 20:00:00, see tagging details below:
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
   <td style="text-align:left;"> Release Sac </td>
   <td style="text-align:left;"> 2019-04-26 20:00:00 </td>
   <td style="text-align:left;"> 2019-04-26 20:00:00 </td>
   <td style="text-align:right;"> 245 </td>
   <td style="text-align:left;"> SacElkLanding </td>
   <td style="text-align:right;"> 207.738 </td>
   <td style="text-align:right;"> 82.1 </td>
   <td style="text-align:right;"> 6.7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Release Yolo </td>
   <td style="text-align:left;"> 2019-04-25 20:00:00 </td>
   <td style="text-align:left;"> 2019-04-26 20:00:00 </td>
   <td style="text-align:right;"> 480 </td>
   <td style="text-align:left;"> YB_ToeDrain_I5 </td>
   <td style="text-align:right;"> 159.500 </td>
   <td style="text-align:right;"> 82.9 </td>
   <td style="text-align:right;"> 7.2 </td>
  </tr>
</tbody>
</table>

<br/>

## Real-time Fish Detections

***Data current as of <span style="color:red">2019-07-29 16:00:00</span>. All times in Pacific Standard Time.***

<br/>
<br/>

<center>
#### Detections at Benicia Bridge
</center>


```r
library(reshape2)

setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

detects_study <- read.csv("detects_UCDYBAgRear.csv", stringsAsFactors = F)
detects_study$DateTime_PST <- as.POSIXct(detects_study$DateTime_PST, format = "%Y-%m-%d %H:%M:%S", "Etc/GMT+8")

if(nrow(detects_study)>0){

  detects_study <- merge(detects_study, study_tagcodes[,c("TagID_Hex", "RelDT", "StudyID", "Release", "tag_life")], by.x = "TagCode", by.y = "TagID_Hex")

}

detects_benicia <- detects_study[detects_study$general_location %in% c("Benicia_west", "Benicia_east"),]

if (nrow(detects_benicia)>0) {
  detects_benicia <- merge(detects_benicia,aggregate(list(first_detect = detects_benicia$DateTime_PST), by = list(TagCode= detects_benicia$TagCode), FUN = min))
  
  detects_benicia$Day <- as.Date(detects_benicia$first_detect, "Etc/GMT+8")
  
  starttime <- as.Date(min(detects_benicia$RelDT), "Etc/GMT+8")
  endtime <- min(as.Date(c(Sys.time())), max(as.Date(detects_benicia$RelDT)+(detects_benicia$tag_life*1.5)))
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
  barplot(t(daterange2[,1:ncol(daterange2)]), beside = T, col=rainbow(rel_num), 
          xlab = "", ylab = "Number of fish arrivals per day", 
          ylim = c(0,max(daterange2[,1:ncol(daterange2)], na.rm = T)*1.2), 
          las = 2, xlim=c(0,max(barp)+1), cex.lab = 1.5, yaxt = "n", xaxt = "n")#, 
          #legend.text = colnames(daterange2[,1:ncol(daterange2)-1]),
          #args.legend = list(x ='topright', bty='n', inset=c(-0.2,0)), title = "Release Group")
  legend(x ='topleft', legend = colnames(daterange2)[1:ncol(daterange2)], fill= rainbow(rel_num), horiz = T, title = "Release Group")
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

<img src="pageYoloFR_2019_files/figure-html/print figure of fish detections at Benicia-1.png" width="960" />


<br/>
<br/>

<center>
#### Minimum survival to Benicia Bridge East Span (using CJS survival model)
</center>

<br/>


```r
setwd(paste(file.path(Sys.getenv("USERPROFILE"),"Desktop",fsep="\\"), "\\Real-time data massaging\\products", sep = ""))

library(RMark)

study_count <- nrow(study_tagcodes)
gen_locs <- read.csv("realtime_locs.csv", stringsAsFactors = F)


if (nrow(detects_benicia) == 0){
  "No detections yet"
} else {

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
    
  WR.surv <- cbind(c("ALL", groups), WR.surv)
  
  colnames(WR.surv) <- c("Release Group", "Survival (%)", "SE", "95% lower C.I.", "95% upper C.I.", "Detection efficiency (%)")
  
  print(kable(WR.surv, row.names = F, "html") %>%
          kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, position = "left"))

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
   <td style="text-align:right;"> 6.2 </td>
   <td style="text-align:right;"> 0.9 </td>
   <td style="text-align:right;"> 4.7 </td>
   <td style="text-align:right;"> 8.2 </td>
   <td style="text-align:right;"> 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Release Sac </td>
   <td style="text-align:right;"> 17.6 </td>
   <td style="text-align:right;"> 2.4 </td>
   <td style="text-align:right;"> 13.3 </td>
   <td style="text-align:right;"> 22.8 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Release Yolo </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 0.3 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> NA </td>
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
  
  for (j in sort(unique(study_tagcodes$release))) {
    
    if(nrow(detects_study[detects_study$release == j,]) > 0 ) {
    
      temp <- detects_study[detects_study$release == j,]
      
        arrivals1 <- aggregate(list(DateTime_PST = temp$DateTime_PST), by = list(general_location = temp$general_location, TagCode = temp$TagCode), FUN = min)
  
      rel_count <- nrow(study_tagcodes[study_tagcodes$release == j,])
  
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
   <td style="text-align:left;"> TowerBridge </td>
   <td style="text-align:left;"> 2019-04-26 23:26:42 </td>
   <td style="text-align:left;"> 2019-04-27 19:01:58 </td>
   <td style="text-align:left;"> 2019-05-16 22:29:53 </td>
   <td style="text-align:right;"> 195 </td>
   <td style="text-align:right;"> 26.90 </td>
   <td style="text-align:right;"> 172.000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> I80-50_Br </td>
   <td style="text-align:left;"> 2019-04-26 23:58:33 </td>
   <td style="text-align:left;"> 2019-04-28 04:30:10 </td>
   <td style="text-align:left;"> 2019-06-16 12:16:18 </td>
   <td style="text-align:right;"> 190 </td>
   <td style="text-align:right;"> 26.21 </td>
   <td style="text-align:right;"> 170.748 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough1 </td>
   <td style="text-align:left;"> 2019-04-27 15:11:44 </td>
   <td style="text-align:left;"> 2019-04-30 22:00:41 </td>
   <td style="text-align:left;"> 2019-05-12 21:11:49 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 2.90 </td>
   <td style="text-align:right;"> 119.208 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana </td>
   <td style="text-align:left;"> 2019-04-27 11:33:46 </td>
   <td style="text-align:left;"> 2019-04-30 13:36:33 </td>
   <td style="text-align:left;"> 2019-05-21 05:16:58 </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:right;"> 12.14 </td>
   <td style="text-align:right;"> 119.058 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgiana_Slough2 </td>
   <td style="text-align:left;"> 2019-04-27 16:18:56 </td>
   <td style="text-align:left;"> 2019-05-02 02:03:34 </td>
   <td style="text-align:left;"> 2019-05-26 00:44:35 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 3.03 </td>
   <td style="text-align:right;"> 118.758 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sac_BlwGeorgiana2 </td>
   <td style="text-align:left;"> 2019-04-27 11:41:53 </td>
   <td style="text-align:left;"> 2019-04-30 14:14:23 </td>
   <td style="text-align:left;"> 2019-05-21 04:51:50 </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 12.69 </td>
   <td style="text-align:right;"> 118.398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_east </td>
   <td style="text-align:left;"> 2019-04-29 02:51:51 </td>
   <td style="text-align:left;"> 2019-05-04 18:34:05 </td>
   <td style="text-align:left;"> 2019-05-14 17:27:08 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 6.21 </td>
   <td style="text-align:right;"> 52.240 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Benicia_west </td>
   <td style="text-align:left;"> 2019-04-29 02:57:28 </td>
   <td style="text-align:left;"> 2019-05-04 18:24:19 </td>
   <td style="text-align:left;"> 2019-05-14 17:38:08 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 6.07 </td>
   <td style="text-align:right;"> 52.040 </td>
  </tr>
</tbody>
</table>

```r
rm(list = ls())
cleanup(ask = F)
```
