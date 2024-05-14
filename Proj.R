library(readxl)
install.packages("tidyverse")
library(tidyverse)
install.packages("dplyr")
library(dplyr)
install.packages("lubridate")
library(lubridate)

q1_2020 <- read_excel("C:/Users/khanb/OneDrive/Desktop/Project - Cyclistic Data/raw_data/Divvy_Trips_2020_Q1.xlsx")
q1_2019 <- read_excel("C:/Users/khanb/OneDrive/Desktop/Project - Cyclistic Data/raw_data/Divvy_Trips_2019_Q1.xlsx")


colnames(q1_2020)
colnames(q1_2019)

q1_2019 <- rename(q1_2019,c("ride_id" = "ride_id","rideable_type" = "bikeid","started_at"="start_time","ended_at" = "end_time"
                            ,"start_station_name" = "from_station_name"
                            ,"start_station_id" = "from_station_id"
                            ,"end_station_name" = "to_station_name"
                            ,"end_station_id" = "to_station_id"
                            ,"member_casual" = "usertype"))

str(q1_2019)
str(q1_2020)

q1_2019 <- q1_2019 %>% mutate(ride_id = as.character(ride_id),rideable_type = as.character(rideable_type))
all_trips <- bind_rows(q1_2020,q1_2019)
View(all_trips)

all_trips <- all_trips %>% select(-c("start_lat", "start_lng","end_lat", "end_lng","tripduration","birthyear", "gender"))
colnames(all_trips)
nrow(all_trips)
dim(all_trips)
head(all_trips)
str(all_trips)
summary(all_trips)

all_trips <- all_trips %>% mutate(member_casual = recode(member_casual,"Subscriber"="member", "Customer"= "casual"))
all_trips$date <- as.Date(all_trips$started_at)
all_trips$month <- format(all_trips$date,"%m")
all_trips$day <- format(all_trips$date,"%d")
all_trips$year <- format(all_trips$date,"%y")
all_trips$day_of_week <- format(all_trips$date,"%A")

all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)
str(all_trips)

all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
View(all_trips)

all_trips_v2 <- all_trips %>% filter(ride_length>=0 & start_station_name != "HQ QR")
View(all_trips_v2)
mean(all_trips_v2$ride_length)
median(all_trips_v2$ride_length)
max(all_trips_v2$ride_length)
min(all_trips_v2$ride_length)

aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)


all_trips_v2$day_of_week <-ordered(all_trips_v2$day_of_week, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"))
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

summary <- all_trips_v2 %>% mutate(weekday =wday(started_at, label=TRUE)) %>% group_by(member_casual, weekday) %>% summarise(number_of_rides =n(), average_duration = mean(ride_length)) %>% arrange(member_casual, weekday)

View(summary)

ggplot(summary) + geom_col(mapping = aes(x = weekday, y = average_duration, fill = member_casual))
write.csv(summary, file = "avg_ride_length.csv")
