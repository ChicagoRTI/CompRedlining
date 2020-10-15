# This script is used for standardizing Indianapolis Street tree data
# By: Lindsay Darling

#TODO maybe remove stumps and change names of unknown trees

# started on: Oct 15, 2020

# load useful libraries
library(tidyverse)
library(magrittr) 
library(sf)

# read in the i-Tree data
IndyStreetTree <- st_read(file.path('RawTreeData',
                                    'Indpls 2014-16 Tree Inventory',
                                    'TreeInventoryPublic_Shapefile',
                                    'TreeInventory.shp'))   %>%
  mutate(data_source = 'IndyStreetTree',
         dbh_cm = `DBH`*2.54,
         obs_year = lubridate::year(as.Date(`DATE_COLLE`, format = '%Y/%m/%d')))%>%
  
  rename(genus_species = `SCINAME`,
         latitude = `X_COORD`,
         longitude = `Y_COORD`,
         tree_ID = `OBJECTID`) %>%

  separate(genus_species, into = c("genus", "species"),sep = " ", remove = TRUE) %>%
 
  mutate(species=recode(species,'species' = 'spp.'))%>%
  
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

head(IndyStreetTree)

# save out the shapefile
st_write(IndyStreetTree, file.path('CleanTreeData','IndyStreetTree.shp'), layer = NULL, driver = 'ESRI Shapefile')




