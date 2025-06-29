library(tidyverse)
library(caret)
library(Hmisc)
library(fpp2)
library(quantmod)
library(scales)
library(readxl)
library(car)
library(ggthemes)

## set working directory
setwd("G:/Shared drives/NSF CoPE internal/GIS_CoPE/GIS_Belize/2_model_inputs_belize/coral_reef_modeling/HRI_database_construction")

## the workspace is already saved in R_workspaces/data_base_construction.RData

### Define the folder paths
Fig_output_folder <- "results/figures"

Table_output_folder <- "results/tables"


# load data
BenthicCover <- read_excel("data/BenthicCover_2023.xlsx", sheet = "Overall")
head(BenthicCover)

# Select the columns needed for the analysis:
# ID, Code and name of sites
# tCORAL: Category group of all Corals codes (average and sd)
# tFMA:	Category group of Fleshy Macroalgae codes (average and sd)
BenthicCover_2023 <- BenthicCover %>%
  select(Code, # code asigned to the survey
         Name, # name of the survey or the reef where the survey took place
         Latitude, 
         Longitude, 
         "Reef Type", #reef large scale morphology
         tCORALavg,	# Coral cover (average) group of all Corals codes
         tCORALstd, # Coral cover (sd) group of all Corals codes
         tFMAavg, # Fleshy Macroalgae cover (average) group of all sp codes
         tFMAstd, # Fleshy Macroalgae cover (sd) group of all sp codes
  ) %>%
  mutate(YEAR = 2023) # add column for year and fill with 2023

head(BenthicCover_2023) 

# Because the values from 2023 are in proportion, it is needed to multiply by 100 to converted in percentage
BenthicCover_2023 <- BenthicCover_2023 %>%
  mutate(tCORALavg = tCORALavg * 100,
         tCORALstd = tCORALstd * 100,
         tFMAavg = tFMAavg * 100,
         tFMAstd = tFMAstd * 100)

# Load data from previous years
# The file contains data from 2011 to 2021
BenthicCoverBySite <- read_excel("data/BenthicPointCoverBySite_2011_2021.xlsx", sheet = "Data")
head(BenthicCoverBySite)

# Select only the columns needed to merge with data from 2023
BenthicCover_2011_2021 <- BenthicCoverBySite %>%
  select(Batch, # needed to filter data from Belize
         Code, # code asigned to the survey
         Site, # name of the survey or the reef where the survey took place
         Date,
         Latitude, 
         Longitude, 
         Depth, #Average depth of survey (meters)
         LCavg,	# % live (average) stony coral coverage
         LCstd, # % live (sd) stony coral coverage
         FMAavg,# % Algae-Macro-Fleshy (average)
         FMAstd) %>% # % Algae-Macro-Fleshy (sd)
  rename(Name = Site,
         tCORALavg = LCavg,
         tCORALstd = LCstd,
         tFMAavg = FMAavg,
         tFMAstd = FMAstd)
head(BenthicCover_2011_2021)

# Separate the column Batch into Country and Year. 
# This is needed to filter only the data from Belize
BenthicCover_filter <- BenthicCover_2011_2021 %>%
  separate(Batch, into = c("Country", "Y"), sep = "-") %>%
  separate(Date, into = c("YEAR", "Month", "Day"), sep = "-")  
head(BenthicCover_filter)

# Select only data from Belize
BenthicCover_filter_2018_2021 <- BenthicCover_filter %>%
  filter(Country == "Belize", YEAR %in% c(2018, 2021)) %>%
  select(-c(Y,Month,Day,Country)) # delete non needed columns

# Merge the two data frames -BenthicCover_2023 y BenthicCover_2011_2021 
Belize_BenthicCover_2018_2023 <- merge(BenthicCover_2023, BenthicCover_filter_2018_2021, 
                             by = c("Code", 
                                    "Name", 
                                    "Latitude", 
                                    "Longitude", 
                                    "tCORALavg", 
                                    "tCORALstd", 
                                    "tFMAavg", 
                                    "tFMAstd",
                                    "YEAR"), all = TRUE)
head(Belize_BenthicCover_2018_2023)

# Inspect differences in the average coral cover among years
# Make a box plot with coral and fleshy algal percentage cover
# Convert the data frame into a long format
data_long <- Belize_BenthicCover_2018_2023 %>%
  pivot_longer(cols = c(tCORALavg, tFMAavg),
               names_to = "variable",
               values_to = "value")

ggplot(data_long, aes(x = YEAR, y = value, fill = variable)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.fill = "white", outlier.color = "black") +
  scale_fill_manual(values = c("#1b9e77", "#d95f02", "#7570b3")) + # Colores personalizados
  labs(
    title = "Percentage Cover of Coral and Fleshy Algae",
    subtitle = "Comparison Across Years",
    x = NULL,
    y = "Cover (%)",
    fill = "Category"
  ) +
  theme_minimal(base_size = 14) + # Tema limpio y elegante
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, vjust = 0.5),
    legend.position = "top"
  )


# Make a line chart with the change in coral % cover a long the years
## group by year and summarize with average
avg_CoralCover <- Belize_BenthicCover_2018_2023 %>%
  group_by(YEAR) %>%
  summarise(avg_cover = mean(tCORALavg), avg_algae = mean(tFMAavg)  ,n = n())

ggplot(avg_CoralCover, aes(x = YEAR, y = avg_cover, group = 1)) +
  geom_line(aes(y = avg_cover, color = "Coral"), linewidth = 1) +
  geom_line(aes(y = avg_algae, color = "Fleshy Algae"), linewidth = 1) +
  geom_point(aes(y = avg_cover, color = "Coral")) +
  geom_point(aes(y = avg_algae, color = "Fleshy Algae")) +
  labs(x = "Year", y = "Average Cover (%)", title = "Average Coral and Fleshy Algae Cover Over Time") +
  scale_y_continuous(limits = c(0, 50)) +  # Set the lower limit to 0
  scale_color_manual(values = c("Coral" = "blue", "Fleshy Algae" = "green")) +
  theme_minimal()

#####################################################################
### summary benthic data
library(gtsummary)

df_coral <- Belize_BenthicCover_2018_2023%>%
  tbl_summary(by = YEAR, 
              include = c(,Name,"Reef Type"),
              label = list(Name ~ "Name",
                           "Reef Type" ~ "Reef Type")) %>%
  modify_header(label = "**Variable**") %>%
  bold_labels() %>%
  modify_caption("**Table 1. Summary of the surveyed sites in the fish dataset from 2016 to 2022 in Florida**")
print(df_coral)

#####################################################################
### FISH ABUNDANCE

# load data
Biomass_fish_2023 <- read_excel("data/FishBiomass_2023.xlsx", sheet = "Overall")
head(Biomass_fish_2023)

# Select the data from commercially important species 
# (snappers, groupers, mackerel, barracuda, grunt, and jacks) 
# Biomass of fish groups are in grams/100m2
Commercial_fish_2023 <- Biomass_fish_2023 %>%
  select(Code, # code asigned to the survey
         Name, # name of the survey or the reef where the survey took place
         Latitude, 
         Longitude, 
         "Reef Type", #reef large sclae morphology
         tLUTJavg,	#  average of the biomass values for all Lutjanidae
         tLUTJstd, # sd of the biomass values for all Lutjanidae
         tSERRavg, # average of the biomass values for all Serranidae
         tSERRstd, # sd of the biomass values for all Serranidae
         tCARAavg, # Average biomass of Jacks (only Bar Jack and Permit)
         tCARAstd, # sd of biomass of Jacks (only Bar Jack and Permit)
         tSPHYavg, # average of the biomass values for barracuda (only Great Barracuda)
         tSPHYstd, # sd of the biomass values for barracuda (only Great Barracuda)
         tHAEMavg, # average of the biomass values for grunts
         tHAEMstd, # sd of the biomass values for grunts
  ) %>%
  mutate(YEAR = 2023) %>% # add column for year and fill with 2023
  mutate(tCommBiomass = tLUTJavg + tSERRavg + tCARAavg + tSPHYavg + tHAEMavg) # sum of all biomass
head(Commercial_fish_2023)

# Load and select data from previous years
Biomass_fish_old <- read_excel("data/FishBiomassBySite_2011_2021.xlsx", sheet = "Data")
head(Biomass_fish_old)

# Select desired columns (snappers, groupers, barracuda, grunts and jacks)
Comm_fish_old <- Biomass_fish_old %>%
  select(Batch, # needed to filter data from Belize
         Code, # code asigned to the survey
         Site, # name of the survey or the reef where the survey took place
         Date,
         Latitude, 
         Longitude, 
         Depth, #Average depth of survey (meters)
         SNAPavg, # Average biomass of Snappers
         SNAPstd, # sd biomass of Snappers
         GROUavg,	# Average biomass of groupers
         GROUstd, # sd biomass of groupers
         JACKavg, # Average biomass of Jacks (only Bar Jack and Permit)
         JACKstd, # sd biomass of Jacks (only Bar Jack and Permit)
         BARRavg, # Average biomass of barracuda (only Great Barracuda)
         BARRstd, # sd biomass of barracuda (only Great Barracuda)
         GRUNavg, # Average biomass of grunts
         GRUNstd # sd biomass of grunts
  ) 
# Rename the column names to match across dataframes
Comm_fish_old <- Comm_fish_old %>%
  rename(Name = Site,  
         tLUTJavg = SNAPavg,
         tLUTJstd = SNAPstd,
         tSERRavg = GROUavg,
         tSERRstd = GROUstd,
         tCARAavg = JACKavg,
         tCARAstd = JACKstd,
         tSPHYavg = BARRavg,
         tSPHYstd = BARRstd,
         tHAEMavg = GRUNavg,
         tHAEMstd = GRUNstd
         )
head(Comm_fish_old)

# Separate the column Batch into Country and Year. 
# This is needed to filter only the data from Belize
Comm_fish_2011_2021 <- Comm_fish_old %>%
  separate(Batch, into = c("Country", "Y"), sep = "-") %>%
  separate(Date, into = c("YEAR", "Month", "Day"), sep = "-")  
head(Comm_fish_2011_2021)

# Select only data from Belize and calculate total biomass for all commercial groups
Comm_fish_2018_2021_BZ <- Comm_fish_2011_2021 %>%
  filter(Country == "Belize", YEAR %in% c(2018, 2021)) %>% # Select data from Belize
  select(-c(Y,Month,Day,Country)) %>% # delete non needed columns
  mutate(tCommBiomass = tLUTJavg + tSERRavg + tCARAavg + tSPHYavg + tHAEMavg) # sum of all biomass

# Merge the two data frames Commercial_fish_2023 y Comm_fish_2011_2021_BZ
Commercial_fish_Biomass <- merge(Commercial_fish_2023, Comm_fish_2018_2021_BZ, 
                                 by = c("Code", 
                                        "Name", 
                                        "Latitude", 
                                        "Longitude", 
                                        "tLUTJavg", 
                                        "tLUTJstd", 
                                        "tSERRavg", 
                                        "tSERRstd",
                                        "tCARAavg",
                                        "tCARAstd",
                                        "tSPHYavg",
                                        "tSPHYstd",
                                        "tHAEMavg",
                                        "tHAEMstd",
                                        "YEAR",
                                        "tCommBiomass"), all = TRUE)
head(Commercial_fish_Biomass)

## group by year and summarize with average
avg_Commercial_biomass <- Commercial_fish_Biomass %>%
  group_by(YEAR) %>%
  summarise(avg_biomass = mean(tCommBiomass), n = n())

# make a line chart
ggplot(avg_Commercial_biomass, aes(x = YEAR, y = avg_biomass, group = 1)) +
  geom_line(color = "#2C3E50", linewidth = 1.2, linetype = "solid") +  # Darker, professional color
  geom_point(color = "#2C3E50", size = 3, shape = 21, fill = "white", stroke = 1.2) +  # Well-defined points
  labs(
    title = "Trend of Average Biomass of Target Species Over Time",
    subtitle = "Measured in 100m² sampling areas",
    x = "Year",
    y = "Average Biomass (g/100m²)"
  ) +
  theme_minimal(base_size = 14) + 
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray50"),
    axis.title.y = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, vjust = 0.5),
    panel.grid.major = element_line(color = "gray85", linetype = "dashed"),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )


##### HERBIVOROUS FISH BIOMASS
# Select the data from herbivorous species in the 2023 data set
# Biomass of fish groups are in grams/100m2

Herbi_fish_2023 <- Biomass_fish_2023 %>%
  select(Code, # code asigned to the survey
         Name, # name of the survey or the reef where the survey took place
         Latitude, 
         Longitude, 
         "Reef Type", #reef large scale morphology
         tACANavg,	#  average of the biomass values for all Acanthuridae
         tACANstd, # sd of the biomass values for all Acanthuridae
         tSCARavg, # average of the biomass values for all Scaridae
         tSCARstd, # sd of the biomass values for all Scaridae
  ) %>%
  mutate(YEAR = 2023) %>% # add column for year and fill with 2023
  mutate(tHerbiBiomass = tACANavg + tSCARstd) # sum of all biomass
head(Herbi_fish_2023) 

# select herbivorous data from previous years
Herbi_fish_old <- Biomass_fish_old %>%
  select(Batch, # needed to filter data from Belize
         Code, # code asigned to the survey
         Site, # name of the survey or the reef where the survey took place
         Date,
         Latitude, 
         Longitude, 
         Depth, #Average depth of survey (meters)
         PARRavg, # Average biomass of Scaridae
         PARRstd, # sd biomass of Scaridae
         SURGavg,	# Average biomass of Acanthuridae
         SURGstd, # sd biomass of Acanthuridae
  ) 

# Rename the column names to match across dataframes
Herbi_fish_old <- Herbi_fish_old %>%
  rename(Name = Site,  
         tACANavg = PARRavg,
         tACANstd = PARRstd,
         tSCARavg = SURGavg,
         tSCARstd = SURGstd)
head(Herbi_fish_old)

# Separate the column Batch into Country and Year. 
# This is needed to filter only the data from Belize
Herbi_fish_2011_2021 <- Herbi_fish_old %>%
  separate(Batch, into = c("Country", "Y"), sep = "-") %>%
  separate(Date, into = c("YEAR", "Month", "Day"), sep = "-")  
head(Herbi_fish_2011_2021)

# Select only data from Belize and calculate total biomass for all herbivorous groups
Herbi_fish_2018_2021_BZ <- Herbi_fish_2011_2021 %>%
  filter(Country == "Belize", YEAR %in% c(2018, 2021) ) %>% # Select data from Belize
  select(-c(Y,Month,Day,Country)) %>% # delete non needed columns
  mutate(tHerbiBiomass = tACANavg + tSCARstd) # sum of all biomass

head(Herbi_fish_2018_2021_BZ)

# Merge the two data frames Herbi_fish_2023 y Herbi_fish_2018_2021_BZ 
Herbivorous_fish_Biomass <- merge(Herbi_fish_2023, Herbi_fish_2018_2021_BZ, 
                                  by = c("Code", 
                                         "Name", 
                                         "Latitude", 
                                         "Longitude", 
                                         "tACANavg", 
                                         "tACANstd", 
                                         "tSCARavg", 
                                         "tSCARstd",
                                         "YEAR",
                                         "tHerbiBiomass"), all = TRUE)
head(Herbivorous_fish_Biomass)

## group by year and summarize with average
avg_herbi_biomass <- Herbivorous_fish_Biomass %>%
  group_by(YEAR) %>%
  summarise(avg_biomass = mean(tHerbiBiomass), n = n())

# make a line chart
ggplot(avg_herbi_biomass, aes(x = YEAR, y = avg_biomass, group = 1)) +
  geom_line(color = "#2C3E50", linewidth = 1.2, linetype = "solid") +  # Professional dark blue
  geom_point(color = "#2C3E50", size = 3, shape = 21, fill = "white", stroke = 1.2) +  # Well-defined points
  labs(
    title = "Trend of Herbivorous Fish Biomass Over Time",
    subtitle = "Measured in 100m² sampling areas",
    x = "Year",
    y = "Average Biomass (g/100m²)"
  ) +
  theme_minimal(base_size = 14) + 
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray50"),
    axis.title.y = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, vjust = 0.5),
    panel.grid.major = element_line(color = "gray85", linetype = "dashed"),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )

#### make a single plot for fish
# Combine the data into a single dataframe for plotting
Commercial_fish_Biomass$category <- "Target Species"
avg_herbi_biomass$category <- "Herbivorous Fish"

combined_data <- rbind(avg_Commercial_biomass, avg_herbi_biomass)

# Create the plot
ggplot(combined_data, aes(x = YEAR, y = avg_cover, group = category, color = category)) +
  geom_line(linewidth = 1.2) + 
  geom_point(size = 3, shape = 21, fill = "white", stroke = 1.2) + 
  scale_color_manual(values = c("Target Species" = "#2C3E50", "Herbivorous Fish" = "#E74C3C")) + # Dark blue & contrast red
  labs(
    title = "Trends in Biomass Over Time",
    subtitle = "Measured in 100m² sampling areas",
    x = "Year",
    y = "Average Biomass (g/100m²)",
    color = "Fish Type"
  ) + 
  theme_minimal(base_size = 14) + 
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray50"),
    axis.title.y = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, vjust = 0.5),
    panel.grid.major = element_line(color = "gray85", linetype = "dashed"),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )


## create the final data bases integrating average by year by site for all variables
## dataframes: 
#Belize_BenthicCover
#Commercial_fish_Biomass
#Herbivorous_fish_Biomass

## data set with avergae values and sd of corals, algae, fish family, and total biomass of fish

ResponseVariables <- merge(Belize_BenthicCover_2018_2023, Commercial_fish_Biomass, 
                                  by = c("Code", 
                                         "Name", 
                                         "Latitude", 
                                         "Longitude",
                                         "YEAR",
                                         "Depth",
                                         "Reef Type"), all = TRUE)

ResponseVariables_full <- merge(ResponseVariables, Herbivorous_fish_Biomass, 
                                by = c("Code", 
                                       "Name", 
                                       "Latitude", 
                                       "Longitude",
                                       "YEAR",
                                       "Depth",
                                       "Reef Type"), all = TRUE)

ResponseVariables_full$YEAR <- as.character(ResponseVariables_full$YEAR)

# Save the data frame as a CSV file
write.csv(ResponseVariables_full, file = file.path(Table_output_folder, "ResponseVariables_full.csv"), row.names = FALSE)

ResponseVariables_full <- read.csv("results/tables/ResponseVariables_full.csv")

ResponseVariables_avg <- ResponseVariables_full %>%
  dplyr::group_by(Name, Latitude, Longitude, "Reef Type") %>%
  dplyr::summarize(
    tCommBiomass_avg = mean(tCommBiomass, na.rm = TRUE),
    tHerbiBiomass_avg = mean(tHerbiBiomass, na.rm = TRUE),
    tCORALavg_avg = mean(tCORALavg, na.rm = TRUE),
    tFMAavg_avg = mean(tFMAavg, na.rm = TRUE),
    .groups = "drop"
  )

# Mostrar la tabla resultante
print(ResponseVariables_avg)

# Save the data frame as a CSV file
write.csv(ResponseVariables_avg, file = file.path(Table_output_folder,"ResponseVariables_input.csv"), row.names = FALSE)

ResponseVariables_input <- read.csv("results/tables/ResponseVariables_input.csv")
#######
# Dispersion plot to visually check for some tendencies
ggplot(ResponseVariables_input, aes(x = tCommBiomass_avg, y = tCORALavg_avg)) +
  geom_point() +
  labs(x = "Commercial fish abundance", y = "Coral cover")

ggplot(ResponseVariables_input, aes(x = tHerbiBiomass_avg, y = tFMAavg_avg)) +
  geom_point() +
  labs(x = "Herbivorous fish abundance", y = "Fleshy Algae cover")

