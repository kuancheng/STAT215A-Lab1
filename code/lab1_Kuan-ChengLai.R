library(ggplot2)
library(dplyr)
library(reshape2)
#Setup working directory
setwd("~/Desktop/STAT215A/STAT215A-Lab1/data/")
#Load logger's data
log <- read.csv('sonoma-data-log.csv',header = T)
net <- read.csv('sonoma-data-net.csv',header = T)
all <- read.csv('sonoma-data-all.csv',header = T)
loc <- read.table('mote-location-data.txt',header = T)

#Check summary of each variable
#It seems that there are a bunch of NA values and erroneous readings.
select(log,voltage,humidity,humid_temp, hamatop) %>% summary()
select(all,voltage,humidity,humid_temp, hamatop) %>% summary()
select(net,voltage,humidity,humid_temp, hamatop) %>% summary()

#Data Cleaning--------------------------------------------------------------------
#1. Omit those datasets with NA readings.
#I found that those value variables are all missed at the same time
log_omit <- na.omit(log)
net_omit <- na.omit(net)
all_omit <- na.omit(all)

#2. I deleted those readings from motes with voltage out of 2.4 to 3.
#Since the readings out of that range are dubious and we can not make 
#sure if it's wrong reading or right reading

#We can find that when voltage lower than 2.4, some of the temperature will below zero which doesnot make sense
err_temp_df1 <- filter(all_omit, voltage < 2.4, humid_temp < 100) %>% mutate(err_temp = humid_temp < 0)
ggplot(err_temp_df1) +
  geom_point(aes(x = voltage, y= humid_temp,colour = err_temp),alpha = 0.4)

#We can find that when voltage larger than 3, some of the temperature will larger than 100
err_temp_df2 <- filter(all_omit, voltage > 3) %>% mutate(err_temp = humid_temp > 100)
ggplot(err_temp_df2) +
  geom_point(aes(x = voltage, y= humid_temp,colour = err_temp),alpha = 0.4)

#After we omit those data, the range of data seems reasonable.
all_omit <- filter(all_omit, voltage <=3 , voltage > 2.4)
#We can also find that other variables value are in an reasonable range 
summary(all_omit)

ggplot(all_omit) +
  geom_point(aes(x = voltage, y= humid_temp),alpha = 0.4)

#3. Check the duplicates of the data
#We can see that there are actually 8244 pairs of duplicates in the dataset
group_by(all_omit, nodeid, epoch) %>% summarise(n=n()) %>%
  ungroup() %>% group_by(n) %>% summarise(total=n())

all_omit <- mutate(all_omit, row_id = 1:nrow(all_omit))
duplicates <- group_by(all_omit, nodeid, epoch) %>% mutate(count = n()) %>% filter(count == 2)
dup_id <- duplicates$row_id
dup_id <- dup_id[seq(1,length(dup_id),by=2)]
#Take average for those interested values
for(i in dup_id){
  all_omit$humidity[i] = (all_omit$humidity[i] + all_omit$humidity[i+1])/2
  all_omit$humid_temp[i] = (all_omit$humid_temp[i] + all_omit$humid_temp[i+1])/2
  all_omit$humid_adj[i] = (all_omit$humid_adj[i] + all_omit$humid_adj[i+1])/2
  all_omit$hamatop[i] = (all_omit$hamatop[i] + all_omit$hamatop[i+1])/2
  all_omit$hamabot[i] = (all_omit$hamabot[i] + all_omit$hamabot[i]+1)/2
}
all_omit <- all_omit[-(dup_id+1),]


#4 Combined distance variables and we decided to use this to analyze
names(loc)[1] = "nodeid"
all_analyzed<- left_join(select(all_omit, nodeid, epoch, voltage,humidity,humid_temp,humid_adj,hamatop,hamabot),
                                    select(loc,nodeid,Height),
                                    by="nodeid")


#Part2----------------Data Exploring--------------------------------------------------------
#Check the range of temperature
ggplot(all_analyzed, aes(x = humid_temp)) + geom_density()
#Check the range of relative humidity
ggplot(all_analyzed, aes(x = humidity)) + geom_density()
#chech the range of PAR 
ggplot(all_analyzed,aes(x = hamatop)) + geom_density()
ggplot(all_analyzed,aes(x = hamabot)) + geom_density()
## We find that temperature and relative humidity all show tri models, it probabaly something
#related to each other, we assume that lower temperature can cause higher relative humidity
#if the moisture stays the same

#We can support this assupmtion by the following scatter plot of temperature and humidity
ggplot(all_analyzed,aes(x = humid_temp, y = humidity)) + geom_point(alpha = 0.2)

#Check time series
ggplot(all_analyzed,aes(x = epoch, y = humid_temp)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = humidity)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = hamatop)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = hamabot)) + geom_point(alpha = 0.2)

#We actually cannot really clear see any relationship clearly just by these graphs.
#Only thing we can know is that those patterns cycle similar thru each day.
#Probably we need to add height into account


#We see that once the height of node is high, the variablity is also high as well
#it probably because the climate varied a lot in higher height.
ggplot(all_analyzed,aes(x = Height, y = humid_temp)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = Height, y = humidity)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = Height, y = hamatop)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = Height, y = hamabot)) + geom_point(alpha = 0.2)

ggplot(all_analyzed,aes(x = epoch, y = humid_temp, colour = Height)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = humidity, colour = Height)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = hamatop, colour = Height)) + geom_point(alpha = 0.2)
ggplot(all_analyzed,aes(x = epoch, y = hamabot, colour = Height)) + geom_point(alpha = 0.2)



#Findings
#1. If higher location got erroroneous readings and NA more frequently
na_index <- as.numeric(is.na(all$humid_temp))
all_node_na <- filter(all, is.na(humid_temp)) %>% select(nodeid)
#we found these three node all located in higher location.
filter(loc,(nodeid ==128 |nodeid ==15|nodeid ==122))

all_analyzed_height <- na.omit(all_analyzed)
all_analyzed_height$Height_fac <- ifelse(all_analyzed_height$Height > 45,"High","Low")
ggplot(all_analyzed_height, aes(x=Height_fac, y=humid_temp, fill=Height_fac)) + geom_boxplot()
ggplot(all_analyzed_height, aes(x=Height_fac, y=humidity, fill=Height_fac)) + geom_boxplot()
ggplot(all_analyzed_height, aes(x=Height_fac, y=hamatop, fill=Height_fac)) + geom_boxplot()
ggplot(all_analyzed_height, aes(x=Height_fac, y=hamabot, fill=Height_fac)) + geom_boxplot()
#We found that higher location usually has higher variations of each features of climate, which could probably
#damage the equipment quickly

