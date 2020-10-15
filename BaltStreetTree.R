# This script is used for standardizing Baltimore Street tree data
# By: Lindsay Darling

#TODO Remove dead trees and stumps?

# started on: Oct 15, 2020

# load useful libraries
library(tidyverse)
library(magrittr) 
library(sf)

# read in the i-Tree data
BaltStreetTree <- st_read(file.path('RawTreeData',
                                    'BaltStreetTree.shp'))   
unique(BaltStreetTree$SPP)
BaltStreetTree %<>%  
  mutate(data_source = 'BaltStreetTree',
         dbh_cm = `DBH`*2.54,
         tree_ID = `ID`,
         obs_year = lubridate::year(as.Date(`Inv_Date`, format = '%m/%d/%Y')))%>%
  
  rename(genus_species = `SPP`, 
         latitude = `X_COORD`,
         longitude = `Y_COORD`) %>%
  
  mutate(genus_species=recode(genus_species,
                              'unknown tree' = 'Unknown spp.'))%>%
 
  mutate_if(is.character,
            str_replace_all, pattern = " x", replacement = "")%>% 
  
  separate(genus_species, into = c("genus", "species"),sep = " ", remove = TRUE) %>%
  
  mutate(species=recode(species, 
                              'x' = 'hybrid'))%>% #TODO what do want to do with hybrids?
 
  mutate(species=replace_na(species,'spp.')) %>%

  mutate(`genus_species` = paste0(genus, ' ', species)) %>%
  
  select(data_source,
         tree_ID,
         obs_year,
         genus,
         species,
         genus_species,
         dbh_cm,
         latitude,
         longitude)

#checks

unique(BaltStreetTree$genus_species)
head(BaltStreetTree)

# save out the shapefile
st_write(BaltStreetTree, file.path('CleanTreeData','BaltStreetTree.shp'), layer = NULL, driver = 'ESRI Shapefile')




