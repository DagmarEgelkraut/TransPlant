#####################
#### CH_CALANDA  ####
#####################

source("R/ImportData/community_CH_Calanda/load_comm_cal.r")

#### Import Community ####
ImportCommunity_CH_Calanda <- function(){

  #load cover data and metadata
  community_CH_Calanda_raw <- load_cover_CH_Calanda()
  
  return(community_CH_Calanda_raw)
}

#### Cleaning Code ####
# Cleaning Calanda community data
CleanCommunity_CH_Calanda <- function(community_CH_Calanda_raw) {
  dat <- community_CH_Calanda_raw %>% 
    mutate(Treatment = case_when(Treatment == "veg_away" & Site %in% c("Cal", "Nes") ~ "Warm", 
                                 Treatment == "veg_home" & Site %in% c("Nes","Pea","Cal") ~ "LocalControl")) %>%
    rename(destSiteID = Site, originSiteID = turf_type, Cover = Cov_Rel1, Year = year, SpeciesName = Species_Name, Collector = Botanist_Rel1, destPlotID = plot_id) %>% 
    mutate(Cover=if_else(grepl("^\\d", Cover), Cover, NA_character_)) %>% 
    mutate(Cover = as.numeric(gsub("[-|,]", ".", Cover))) %>%
    mutate(UniqueID = paste(Year, originSiteID, destSiteID, destPlotID, sep='_')) %>%
    #add block ID 
    rename(destBlockID=Block) %>% 
    # only select control, local control, warm/down transplant
    filter(Treatment %in% c("LocalControl", "Warm")) %>% 
    mutate(UniqueID = paste(Year, originSiteID, destSiteID, destPlotID, sep='_'))  %>% 
    mutate(destPlotID = as.character(destPlotID), destBlockID = if (exists('destBlockID', where = .)) as.character(destBlockID) else NA) %>% 
    ungroup()
    
  dat2 <- dat %>%  
    filter(!is.na(Cover)) %>%
    group_by_at(vars(-SpeciesName, -Cover)) %>%
    summarise(SpeciesName = "Other",Cover = 100 - sum(Cover)) %>%
    bind_rows(dat) %>% 
    filter(Cover > 0)  %>% #omg so inelegant
    mutate(Total_Cover = sum(Cover), Rel_Cover = Cover / Total_Cover) %>% 
    ungroup()

  comm <- dat2 %>% filter(!SpeciesName %in% c('Other'))
  cover <- dat2 %>% filter(SpeciesName %in% c('Other')) %>% ungroup() %>% 
    select(UniqueID, SpeciesName, Cover, Rel_Cover) %>% group_by(UniqueID, SpeciesName) %>% summarize(OtherCover=sum(Cover), Rel_OtherCover=sum(Rel_Cover)) %>%
    rename(CoverClass=SpeciesName) 
  return(list(comm=comm, cover=cover))
}


# Clean taxa list (add these to end of above)
CleanTaxa_CH_Calanda <- function(community_CH_Calanda) {
  taxa <- unique(community_CH_Calanda$SpeciesName)
  return(taxa)
}

# Clean metadata
CleanMeta_CH_Calanda <- function(community_CH_Calanda) {
  dat <- community_CH_Calanda %>% ungroup() %>% 
    select(-c('SpeciesName', 'Cover', 'Total_Cover', 'Rel_Cover')) %>% 
    distinct()  %>% 
    mutate(Elevation = as.numeric(recode(destSiteID, 'Pea'='2800', 'Cal'='2000', 'Nes'='1400')),
           Gradient = "CH_Calanda",
           Country = as.character("Switzerland"),
           YearEstablished = 2012,
           PlotSize_m2 = 0.75) 
  
  return(dat)
}



#### IMPORT, CLEAN AND MAKE LIST #### 
ImportClean_CH_Calanda <- function(){
  
  ### IMPORT DATA
  community_CH_Calanda_raw = ImportCommunity_CH_Calanda()
  
  ### CLEAN DATA SETS
  cleaned_CH_Calanda = CleanCommunity_CH_Calanda(community_CH_Calanda_raw)
  community_CH_Calanda = cleaned_CH_Calanda$comm
  cover_CH_Calanda = cleaned_CH_Calanda$cover
  meta_CH_Calanda = CleanMeta_CH_Calanda(community_CH_Calanda) 
  taxa_CH_Calanda = CleanTaxa_CH_Calanda(community_CH_Calanda)
 
  
  # Make list
  CH_Calanda = list(meta = meta_CH_Calanda,
                  community = community_CH_Calanda,
                  cover = cover_CH_Calanda,
                  taxa = taxa_CH_Calanda)
  
  return(CH_Calanda)
}

