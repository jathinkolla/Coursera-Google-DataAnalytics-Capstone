# Data Prep
# Install and load necessary packages
install.packages("tidyverse")
install.packages("DataExplorer")
install.packages("janitor")
install.packages("lubridate")

library(tidyverse)
library(DataExplorer)
library(janitor)
library(lubridate)

# Load 12 months of bikesharing data
df1 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202004.csv", show_col_types = FALSE) 
df2 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202005.csv", show_col_types = FALSE) 
df3 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202006.csv", show_col_types = FALSE) 
df4 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202007.csv", show_col_types = FALSE)
df5 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202008.csv", show_col_types = FALSE) 
df6 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202009.csv", show_col_types = FALSE) 
df7 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202010.csv", show_col_types = FALSE) 
df8 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202011.csv", show_col_types = FALSE) 
df9 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202012.csv", show_col_types = FALSE) 
df10 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202101.csv", show_col_types = FALSE) 
df11 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202102.csv", show_col_types = FALSE) 
df12 <- read_csv("C:/Users/LENOVO/OneDrive/Documents/Capstone/202103.csv", show_col_types = FALSE) 

# View data
glimpse(df1)
glimpse(df2)
glimpse(df3)
glimpse(df4)
glimpse(df5)
glimpse(df6)
glimpse(df7)
glimpse(df8)
glimpse(df9)
glimpse(df10)
glimpse(df11)
glimpse(df12)

# Combine CSVs into a single file and use DataExplorer for advanced data exploration
all_trips <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10,df11,df12)
create_report(all_trips)

# Remove empty columns and rows
all_trips <- janitor::remove_empty(all_trips, which = c("cols"))
all_trips <- janitor::remove_empty(all_trips, which = c("rows"))

# Create columns as follows: date, month, day, year, weekday, start_hour, end_hour, and season
all_trips$date <- as.Date(all_trips$started_at) 
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$weekday <- format(as.Date(all_trips$date), "%A")
all_trips$start_hour = format(as.POSIXct(all_trips$started_at), "%H")
all_trips$end_hour = format(as.POSIXct(all_trips$ended_at), "%H")
all_trips$season <- ifelse (all_trips$month %in% c('06','07','08'), "Summer",
                            ifelse (all_trips$month %in% c('09','10','11'), "Fall",
                                    ifelse (all_trips$month %in% c('12','01','02'), "Winter",
                                            ifelse (all_trips$month %in% c('03','04','05'), "Spring", NA))))

# Calculate ride length and create new column
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

# View the structure of all_trips
str(all_trips)

# Check the data type for ride_length and change it to numeric
is.factor(all_trips$ride_length) 
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length)) 
is.numeric(all_trips$ride_length)

# Omit NAs, negative trip lengths, and maintenance checks
all_trips <- na.omit(all_trips)
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR"| all_trips$start_station_name == "CHECK" | all_trips$start_station_name == "TEST" | all_trips$start_station_name == "DIVVY" |
                              all_trips$start_station_name == "" |
                              all_trips$ride_length < 0),]

# Initial Data Analysis
# Summary statistics for ride_length
summary(all_trips_v2$ride_length)

# Summary statistics for member and casual usage
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# Set levels for weekdays

all_trips_v2$weekday <- ordered(all_trips_v2$weekday, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Weekday Trends
# Average duration by user type and weekday
all_trips_v2 %>%
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n() 
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)

# Ridership by weekday and user type
all_trips_v2$weekday<- ordered(all_trips_v2$weekday, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

ggplot(all_trips_v2, aes(x = weekday, fill = member_casual)) +
  geom_bar(position = "dodge") +
  ggtitle('Daily Ridership by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Weekday') + ylab('Ride Count') + 
  labs(fill='User Type') +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Average ride duration by user type and weekday
all_trips_v2 %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  ggtitle('Average Ride Duration by User Type and Weekday', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) +	
  xlab('Weekday') + ylab('Ride Duration (sec)') + 
  labs(fill='User Type') +
  labs(caption = "NOTE: 1000 sec = 16.6667 min") +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Ride Type Trends
# Count of ride type by user type

all_trips_v2 %>% count(rideable_type, member_casual)

ggplot(all_trips_v2, aes(x = rideable_type, fill = member_casual)) + 
  geom_bar(position = "dodge") +
  ggtitle('Ride Type by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Ride Type') + 	ylab('Ride Count') + 
  labs(fill='User Type') +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Seasonal Trends
# Seasonal trends by user type
all_trips_v2 %>% count(season, member_casual)
ggplot(all_trips_v2, aes(x = season, fill = member_casual)) +
  geom_bar(position = "dodge") +
  ggtitle('Seasonal Trends by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Season') + 	ylab('Ride Count') + 
  labs(fill='User Type') +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Average ride duration by user type and season
seasonal_avg_duration <- all_trips_v2 %>%
  group_by(member_casual, season) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_length)) %>%
  arrange(member_casual, season) 

print(seasonal_avg_duration)

ggplot(seasonal_avg_duration, aes(x = season, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  ggtitle('Average Ride Duration by User Type and Season', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) + 
  xlab('Season') + ylab('Ride Duration (sec)') + 
  labs(fill='User Type') +
  labs(caption = "NOTE: 1000 sec = 16.6667 min") +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Monthly Trends
# Monthly trends by user type
monthly_usercount <- all_trips_v2 %>% count(month, member_casual)

print(monthly_usercount, n=24) 

ggplot(all_trips_v2, aes(x = month, fill = member_casual)) +
  geom_bar(position = "dodge") +
  ggtitle('Monthly Trends by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) +	
  xlab('Month') + 	ylab('Ride Count') + 
  labs(fill='User Type') +
  labs(caption = "NOTE: Months represented in MM format") +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Average ride duration by user type and month
avg_duration <- all_trips_v2 %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_length)) %>%
  arrange(member_casual, month) 

print(avg_duration, n=24)

ggplot(avg_duration, aes(x = month, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") + ggtitle('Average Ride Duration by User Type and Month', subtitle = "April 2020 - March 2021") + theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) + xlab('Month') + ylab('Ride Duration (sec)') + labs(fill='User Type') + labs(caption = "NOTE: 1000 sec = 16.6667 min | Months represented in MM format") + scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Hourly Trends
# Popular start hours by user type
pop_start_hour <- all_trips_v2 %>% count(start_hour, member_casual, sort = TRUE)

casual_start_hour <- filter(pop_start_hour, member_casual == 'casual')

casual_start_hour <- casual_start_hour %>% 
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(casual_start_hour)

member_start_hour <- filter(pop_start_hour, member_casual == 'member')

member_start_hour <- member_start_hour %>%
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(member_start_hour)

# Start hour trends by user type
ggplot(all_trips_v2, aes(x = start_hour, fill = member_casual)) +
  geom_bar(position = "dodge") + 
  ggtitle('Start Hour Trends by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) +	
  xlab('Start Hour (Military Time)') + 	ylab('Ride Count') + 
  labs(fill='User Type') +
  labs(caption = 'NOTE: 0000 / 2400 = 12 a.m.') +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Popular start hours - Casuals
ggplot(casual_start_hour, aes(x = start_hour, y = n)) + 
  geom_bar(stat = "identity", fill="#99cad5", colour="black") +
  ggtitle('Top 10 Start Hours - Casuals', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Start Hour (Military Time)') + ylab('Ride Count') +
  scale_y_continuous(labels = scales::comma) 

# Popular start hours - Members
ggplot(data = member_start_hour, aes(x = start_hour, y = n)) + 
  geom_bar(stat = "identity", fill="#3f93a2", colour="black") +
  ggtitle('Top 10 Start Hours - Members', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Start Hour (Military Time)') + ylab('Ride Count') +
  scale_y_continuous(labels = scales::comma) 

# Popular end hours by user type
pop_end_hour <- all_trips_v2 %>% count(end_hour, member_casual, sort = TRUE) 

print(pop_end_hour, n=48)

member_end_hour <- filter(pop_end_hour, member_casual == 'member', sort = TRUE) 
member_end_hour <- member_end_hour %>%
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(member_end_hour)

casual_end_hour <- filter(pop_end_hour, member_casual == 'casual', sort = TRUE) 
casual_end_hour <- casual_end_hour %>%
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(casual_end_hour)

# End hour trends by user type
ggplot(all_trips_v2, aes(x = end_hour, fill = member_casual)) +
  geom_bar(position = "dodge") + 
  ggtitle('End Hour Trends by User Type', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5)) +	
  xlab('End Hour (Military Time)') + 	ylab('Ride Count') + 
  labs(fill='User Type') +
  labs(caption = 'NOTE: 0000 / 2400 = 12 a.m.') +
  scale_fill_manual(values = c("#99cad5", "#3f93a2"),
                    labels = c("casual","member"))

# Popular end hours - Casuals
ggplot(casual_end_hour, aes(x = end_hour, y = n)) + 
  geom_bar(stat = "identity", fill="#99cad5", colour="black") +
  ggtitle('Top 10 End Hours - Casuals', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('End Hour (Military Time)') + ylab('Ride Count') +
  scale_y_continuous(labels = scales::comma) 

# Popular end hours - Members
ggplot(data = member_end_hour, aes(x = end_hour, y = n)) + 
  geom_bar(stat = "identity", fill="#3f93a2", colour="black") +
  ggtitle('Top 10 End Hours - Members', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('End Hour (Military Time)') + ylab('Ride Count') +
  scale_y_continuous(labels = scales::comma) 

# Station Trends
# Popular start stations by user type
popular_stations <- all_trips_v2 %>% count(start_station_name, member_casual)

print(popular_stations)

# Popular end stations by user type
end_stations <- all_trips_v2 %>% count(end_station_name, member_casual)

print(end_stations)

# Top 10 start stations - Casuals
pop_stations_casual<- filter(popular_stations, member_casual == 'casual')

pop_stations_casual <- pop_stations_casual %>% 
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(pop_stations_casual)

ggplot(data = pop_stations_casual, aes(x = start_station_name, y = n)) + 
  geom_bar(stat = "identity", fill="#99cad5", colour="black") +
  ggtitle('Top 10 Start Stations - Casuals', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Station Name') + ylab('Ride Count') + 
  coord_flip( )

# Top 10 start stations - Members
pop_stations_member<- filter(popular_stations, member_casual == 'member')

pop_stations_member <- pop_stations_member %>% 
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(pop_stations_member)

ggplot(data = pop_stations_member, aes(x = start_station_name, y = n)) + 
  geom_bar(stat = "identity", fill="#3f93a2", colour="black") +
  ggtitle('Top 10 Start Stations - Members', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Station Name') + ylab('Ride Count') + 
  coord_flip( )

# Top 10 end stations - Casuals 
end_stations_casual<- filter(end_stations, member_casual == 'casual') 

end_stations_casual <- end_stations_casual %>% 
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(end_stations_casual)

ggplot(data = end_stations_casual, aes(x = end_station_name, y = n)) + 
  geom_bar(stat = "identity", fill="#99cad5", colour="black") +
  ggtitle('Top 10 End Stations - Casuals', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Station Name') + ylab('Ride Count') + 
  coord_flip( )

# Top 10 end stations - Members 
end_stations_member <- filter(end_stations, member_casual == 'member')

end_stations_member <- end_stations_member %>%
  arrange(desc(n)) %>% 
  slice_head(n=10)

print(end_stations_member)

ggplot(data = end_stations_member, aes(x = end_station_name, y = n)) + 
  geom_bar(stat = "identity", fill="#3f93a2", colour="black") +
  ggtitle('Top 10 End Stations - Members', subtitle = "April 2020 - March 2021") + 
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +	
  xlab('Station Name') + ylab('Ride Count') + 
  coord_flip( )
