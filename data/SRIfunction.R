## Affiliation and adjacency matrices for Dominink & Natalia:
## Make networks
require(tidyverse)
library(asnipe)
library(dplyr)
library(tidyr)
library(adehabitatHR)
library(igraph)
require(sna)
library(data.table)
## GBI function
get_affiliation=function(data){
  mat=as.matrix(data[,id_columns])
  mat=mat[mat!=""]
  mat=mat[is.na(mat)==F]
  ids=sort(unique(as.vector(mat)))
  ind.by.group=matrix(nrow=length(ids), ncol=nrow(data))
  for(i in 1:ncol(ind.by.group)){
    ind.by.group[match(as.character(data[i,id_columns]),as.character(ids)),i]=1
  }
  ind.by.group[is.na(ind.by.group)]=0
  rownames(ind.by.group)=ids
  colnames(ind.by.group)=as.character(data$obs_id)
  return(ind.by.group)
}
## cleaned observation dataset
# load("foc_nearfinal_20250521.dat")
## Maybe I used an old version?
load("foc_nearfinal_20250521.dat")
id_columns = grep("^ID", names(foc_nearfinal))
foc_final = foc_nearfinal
foc_final = setorder(foc_final, Date, DateTime)

# foc_final$Date = as.Date(foc_final$Date, format = "%Y-%m-%d")
foc_final$obs_id = 1:nrow(foc_final)
foc_final$Focal = iconv(foc_final$Focal, from = "ISO-8859-1", to = "UTF-8")
timeseries = foc_final %>%
  mutate(n_elephants = apply(foc_final[id_columns], 1, function(x)sum(x != "")))

timeseries$obsday = as.numeric(timeseries$Date - min(timeseries$Date))
timeseries = timeseries %>% group_by(obsday) %>% mutate(ind = cur_group_id()) %>% ungroup() ## keep track of days to combine sightings

## IDS
load("ID reference sheets/allfinalids_20250327.dat")
## Get rid of individuals that were only ever seen once
## number of individual sightings in each year
ind_focal = foc_final %>%
  pivot_longer(id_columns, names_to = NULL, values_to = "ID")
ind_focal = ind_focal[which(ind_focal$ID != ""),]
indsightcounts = ind_focal %>%
  filter(ID %in% allfinalids$ID) %>%
  mutate(Year = year(Date)) %>%
  group_by(Year, ID) %>%
  summarise(nsights = n()) %>%
  filter(Year < 2019) %>%
  group_by(ID) %>%
  mutate(nyear = seq_along(Year)) %>%
  group_by(ID) %>%
  filter(nyear == max(nyear)) %>%
  filter(nsights == 1)

fewsights = indsightcounts %>% filter(nyear == 1)
# allfinalids %>% filter(ID %in% fewsights$ID) %>%View()
allfinalids = allfinalids %>%
  filter(!ID %in% fewsights$ID)

allfinalidlist = allfinalids %>% dplyr::select(ID)
# load("allfinalidlist.dat")

## Annual networks
## separate by year
require(lubridate)
foc_2007 = timeseries %>%
  filter(year(Date) == 2007)
foc_2008 = timeseries %>%
  filter(year(Date) == 2008)
foc_2009 = timeseries %>%
  filter(year(Date) == 2009)
foc_2010 = timeseries %>%
  filter(year(Date) == 2010)
foc_2011 = timeseries %>%
  filter(year(Date) == 2011)
foc_2012 = timeseries %>%
  filter(year(Date) == 2012)
foc_2013 = timeseries %>%
  filter(year(Date) == 2013)
foc_2014 = timeseries %>%
  filter(year(Date) == 2014)
foc_2015 = timeseries %>%
  filter(year(Date) == 2015)
foc_2016 = timeseries %>%
  filter(year(Date) == 2016)
foc_2017 = timeseries %>%
  filter(year(Date) == 2017)
foc_2018 = timeseries %>%
  filter(year(Date) == 2018)

foc_names = list(foc_2007, foc_2008, foc_2009, foc_2010, foc_2011, foc_2012, foc_2013, foc_2014, foc_2015, foc_2016, foc_2017, foc_2018)

years = 2007:2018

## Make yearly networks
raw_affs = lapply(foc_names, function(x) get_affiliation(x))
newaffs = lapply(raw_affs, function(x) x[rownames(x) %in% allfinalids$ID,]) ## only include approved IDs
# # save(raffs, file = "raffs_20250619.dat")
# 
## Use day index and rowSums to combine groups with overlapping IDs
tempveclist = lapply(foc_names, function(x){
  tempvec = x$ind
})

## load saved affiliation matrices and temporal vectors
# load("raffs_20250619.dat")
# load("tempveclist_20250619.dat")
# ncol(raffs[[1]])
# length(tempveclist[[1]])
# newaffs = lapply(raffs, function(x) x[rownames(x) %in% allfinalids$ID,])

# splist = lapply(seq_along(newaffs), function(i) get_sampling_periods(association_data = t(newaffs[[i]]),association_times=tempveclist[[i]], sampling_period = 1,data_format = "gbi"))
# 
# adjs_all=lapply(splist, function(x) get_network(x, data_format = "SP"))

## Get just year one so they can verify
# load("raffs.dat") ## this is from way back..
## 2007 network
aff07 = t(newaffs[[1]])
tempvec07 = tempveclist[[1]]
# sp07 = get_sampling_periods(association_data = aff07, association_times=tempvec07, sampling_period = 1,data_format = "gbi")
# adj07 = get_network(sp07, data_format = "SP")
source("SRIfunction.R")
adjnew = makeSRI(aff07,tempvec07)

oldadj = read.csv(file = "C:/Users/amads/Documents/Github/AsianElephants/Adjacency matrices for Dominik and Natalia/AEadj2007.csv", check.names=FALSE)
oldadj = oldadj[,-1]
rownames(oldadj) <- colnames(oldadj)
oldadj=as.matrix(oldadj)
# plot(adj07, oldadj)
plot(adjnew, oldadj)

## 2018 network
oldadj18 = read.csv(file = "C:/Users/amads/Documents/Github/AsianElephants/Adjacency matrices for Dominik and Natalia/AEadj2018.csv", check.names=FALSE)
oldadj18 = oldadj18[,-1]
rownames(oldadj18) <- colnames(oldadj18)
oldadj18=as.matrix(oldadj18)

aff18 = t(newaffs[[12]])
tempvec18 = tempveclist[[12]]
adjnew = makeSRI(aff18,tempvec18)
plot(adjnew, oldadj18)

affmat18 = cbind(tempvec18, aff18)
colnames(affmat18)[1] <- "obsday"
write.csv(affmat18, file = "Adjacency matrices for Dominik and Natalia/affmat18.csv", row.names=F)
# write.csv(tempvec18, file = "Adjacency matrices for Dominik and Natalia/tempvec18.csv", row.names=F)




#############
## Go through each adj and see if there are differences for all years
## new adjs
adjnewlist = lapply(seq_along(newaffs), function(i) makeSRI(t(raffs[[i]]),tempveclist[[i]]))

## old adjs
filenames = list.files(path = "C:/Users/amads/Documents/Github/AsianElephants/Adjacency matrices for Dominik and Natalia/adjacency matrices", full.names = T)

csvlist = lapply(filenames, read.csv)

oldadjlist = lapply(csvlist, function(x){
  tempdf = x[,-1]
  rownames(tempdf) <- colnames(tempdf)
  as.matrix(tempdf)
})

par(mfrow=c(3,4))
for(i in 1:12){
  adj1 = adjnewlist[[i]]
  adj2 = oldadjlist[[i]]
  print(plot(adj1,adj2))
  cor(adj1, adj2)
}

## 2007 and 2008 are where the corrections took place - every other year is the same

## All affiliation matrices
afftemplist = lapply(seq_along(newaffs), function(i){
  afftemp = cbind(tempveclist[[i]], t(newaffs[[i]]))
  colnames(afftemp)[1] <- "obsday"
  write.csv(afftemp, file = paste0("Adjacency matrices for Dominik and Natalia/affiliation matrices/affmat", years[i], ".csv"), row.names=F)
})


## Resent adjacency matrices for 2007-08: 
lapply(1:2, function(i) write.csv(adjnewlist[[i]], file = paste0("C:/Users/amads/Documents/Github/AsianElephants/Adjacency matrices for Dominik and Natalia/adjacency matrices/AEadjupdated", years[i], ".csv")))


## Load dataframes from May
# dflist = list()
# for(i in 1:12){
#   dflist[[i]] = read.csv(file = paste0("AEdf", years[i], ".csv"))
# }
# 
# dflist
# load("allfinalids.dat")
# raw_affs = lapply(dflist, function(x) get_affiliation(x))
# raffs = lapply(raw_affs, function(x) x[rownames(x) %in% allfinalids$ID,]) ## only include approved IDs

## Use day index and rowSums to combine groups with overlapping IDs
# tempveclist = lapply(dflist, function(x){
#   tempvec = x$ind
# })
# 
# newaff07 = t(raffs[[1]])
# newsp07 = get_sampling_periods(association_data = newaff07, association_times=tempveclist[[1]], sampling_period = 1,data_format = "gbi")
# 
# newadj07 = get_network(newsp07, data_format = "SP")
# plot(newadj07, oldadj)
# 
# difadj = makeSRI(newaff07, tempveclist[[1]])
# plot(difadj, oldadj)
# 
# plot(newadj07, difadj)
