# This script is used for standardizing New York Street tree data
# By: Lindsay Darling

#TODO Remove dead trees and stumps?

# started on: Oct 15, 2020

# load useful libraries
library(tidyverse)
library(magrittr) 
library(sf)

# read in the i-Tree data
NYStreetTree <- st_read(file.path('RawTreeData',
                                    'geo_export_6ba3853a-80c5-4589-b553-ecd0ef92a100.shp'))   

NYStreetTree %<>%  
  mutate(data_source = 'NYStreetTree',
         dbh_cm = `tree_dbh`*2.54,
         tree_ID = row_number(),
         obs_year = lubridate::year(as.Date(`created_at`, format = '%m/%d/%Y')))%>%
  
  rename(genus_species = `spc_latin`) %>%
  
  mutate(genus_species=recode(genus_species,
                              'Platanus x acerifolia' = 'Platanus acerifolia',
                              'Gleditsia triacanthos var. inermis' = 'Gleditsia triacanthos',
                              'Lagerstroemia' ='Lagerstroemia',
                              "Acer platanoides 'Crimson King'" = 'Acer platanoides',
                              'Crataegus crusgalli var. inermis' = 'Crataegus crusgalli',
                              'Aesculus x carnea' = 'Aesculus carnea'))%>%

  separate(genus_species, into = c("genus", "species"),sep = " ", remove = TRUE) %>%
 
  mutate(species=replace_na(species,'spp.')) %>%
  
  mutate(genus=replace_na(genus,'Unknown')) %>%
  
  
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

unique(NYStreetTree$genus_species)


# save out the shapefile
st_write(NYStreetTree, file.path('CleanTreeData','NYStreetTree.shp'), layer = NULL, driver = 'ESRI Shapefile')




