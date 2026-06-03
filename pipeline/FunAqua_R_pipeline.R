## Technical validation and data visualization pipeline script for the FunAqua data.
# Version 1.0 

# The following pipeline includes R code that was used to visualize the data  and generating majority of the technical validation results under chapters "Sampling coverage" and "Sequencing depth"
# The pipeline also generates a the basic data overview presented in the data paper. 
# It is strongly recommended that the user reads through the pipeline's comments before running the pipeline.

## 0. Generated objects/tables

# Whereever possible, the code will generate required data tables inside their calling functions.
# This is done to reduce the amount of data that is stored.
# However, in some cases it is more efficient to store the data outside of their function.
# In some instances, such as the plots generated for the taxonomic overview, the intermediary tables created for plotting purposes are deleted.
# Between some steps of the pipeline gc() is used to clear up resources that are no longer in use.

# As a general disclaimer, the recommended minimum amount of RAM for running the script is 35GB.
# This is because some of the tasks, such as rarefaction curve calculations, are rather resource-heavy.


# The following objects/tables will be generated throughout the code's run for various purposes:

# Sample metadata tables as data.frame object
#   *metadata - sample metadata corresponding to all samples.
#   *metadatased - sample metadata for sediments.
#   *metadatawat - sample metadata for filtered water samples.
#   *metadatarenamed - metadata table with the sample ID column added back to it.

# OTU tables given as data.frame objects
#   *eukotu - non-fungal eukaryotes OTU table. Removed in later steps of the pipeline.
#   *fungiotu - fungal OTU table.
#   *eukotused - non-fungal eukaryotes OTU table for OTUs detected in sediments. Removed in later steps of the pipeline.
#   *fungiotused - fungal OTU table for OTUs detected in sediments.
#   *eukotuwat - non-fungal eukaryotes OTU table for OTUs detected in water samples. Removed in later steps of the pipeline.
#   *fungiotuwat - fungal OTU table for OTUs detected in water samples.
#   *fungioturenamed - fungal OTU table with the OTU ID column added back to it. Removed in later steps of the pipeline.
#   *otuwithmeta - fungal OTU table combined with sample metadata and taxonomy data. Removed in later steps of the pipeline.
#   *fungiotulong - fungal OTU table in long format. Meaning there are separate rows for every OTU's occurrence in every sample. Removed in later steps of the pipeline.

# Taxonomy tables given as data.frame objects
#   *euktax - non-fungal eukaryotes taxonomy table. Removed in later steps of the pipeline.
#   *fungitax - fungal taxonomy table.
#   *euktaxsed - non-fungal eukaryotes taxonomy table for OTUs found in sediments. Removed in later steps of the pipeline.
#   *fungitaxsed - fungal taxonomy table for OTUs found in sediments.
#   *euktaxwat - non-fungal eukaryotes taxonomy table for OTUs found in water samples. Removed in later steps of the pipeline.
#   *fungitaxwat - fungal taxonomy table for OTUs found in water samples.
#   *combinedtax - combined taxonomy table including both fungal and non-fungal OTUs. Removed in later steps of the pipeline.
#   *fungitaxrenamed - fungal taxonomy table with the OTU ID column added back to it. Removed in later steps of the pipeline.
#   *fungitaxnamesfixed(sed)(wat) - fungal taxonomy labels clarified for unknown taxa. 3 separate tables for both sample types combined, sediment samples and filtered water samples.
#   *fungitaxlongnamesfidxed(sed)(wat) - same as previous, but with sequence numbers added to each OTU.

# Phyloseq objects
#   *fungiphyseq - phyloseq objects pertaining to fungal OTU data.
#   *eukphyseq - phyloseq object pertaining to non-fungal OTU data. Removed in later steps of the pipeline.

# Objects generated for data visualization purposes
#   *samplingmapworld - sampling map depicting all of the sampling areas.
#   *Europe - map data for plotting European sampling points.
#   *samplingnmapeurope - sampling map depicting the European sampling areas.
#   *samplingmap - combined sampling map.
#   *sampleTypeContinentGraph - side-by-side bar chart depicting the number of samples collected from each continent.
#   *sampleTypeBiomeGraph - side-by-side bar chart depicting the number of samples collected from each biome.
#   *heatMapSed - heat map depicting the distribution of sediment samples collected from each biome across continents.
#   *heatMapWat - heat map depicting the distribution of filtered water samples collected from each biome across continents.
#   *specaccumsed - sediment species (OTU) accumulation data for accumulation curve plotting.
#   *specaccumwat - filtered water species (OTU) accumulation data for accumulation curve plotting.
#   *dataframe - dataframe created for heat map generation.
#   *oturichnesstable - table showing how many unique OTUs were detected on all continents from all samples combined.
#   *oturichnesstable2 - table showing how many unique OTUs were detected on all continents from sediment and filtered water samples separately. 
#   *continentrichness - bar chart depicting the number of fungal OTUs detected from each continent.
#   *continentrichness2 - side-by-side barchart depicting the number of unique fungal OTUs detected on each continent from sediment and filtered water samples separately.
#   *combindcontinentrichness - continentrichness and continentrichness2 combined into one figure.
#   *oturichnesstable3 - same as oturichnesstable, but instead of continents, it looks at biomes. Removed in later steps of the pipeline.
#   *oturichnesstable4 - same as oturichnesstable2, but instead of continents, it looks at biomes. Removed in later steps of the pipeline.
#   *biomerichness1 - same as continentrichness, but instead of continents, it shows biomes.
#   *biomerichness2 - same as continentrichness2, but instead of continents, it shows biomes.
#   *combinedbiomerichness - biomerichness1 and biomerichness2 merged into one figure. 
#   *otuwithmetaphylum/class/orderrel - table showing the relative abundance of the OTUs of each fungal phylum/class/order. Removed in later steps of the pipeline.
#   *sediments - same as previous, but limited to sediment samples. Removed in later steps of the pipeline.
#   *water - same as previous, but limited to water samples. Removed in later steps of the pipeline.
#   *otuphylum/class/orderrelcombined - the previous three tables combined. Removed in later steps of the pipeline.
#   *plot_table - table generated for plotting either fungal phyla/class/order relative abundances. Removed in later steps of the pipeline.
#   *stackbarphylum - stacked bar plot showing the relative abundance of each fungal phyla's OTUs.
#   *stackbarclass - same as previous, but for fungal classes.
#   *plot_table2 - table generated for plotting the relative abundance of Ascomycota's orders
#   *plot_table3 - table generated for plotting the relative abundance of Basidiomycota's orders.
#   *plot_table4 - table generated for plotting the relative abundance of Chytridiomycota's orders.
#   *orderheat - heatmap depicting the relative abundance of all fungal orders in relation to all fungal OTUs.
#   *orderheat2 - heatmap depicting the relative abundance of Ascomycota orders in relation to Ascomycota OTUs.
#   *orderheat3 - heatmap depicting the relative abundance of Basidiomycota orders in relation to Basidiomycota OTUs.
#   *orderheat4 - heatmap depicting the relative abundance of Chytridiomycota orders in relation to Chytridiomycota OTUs.
#   *combinedorderheat - orderheat, orderheat2, orderheat3, orderheat4 combined into one figure.

# Data for Good's index calculations
#   *goodsindex - data frame including Good's coverage index values.
#   *eukseqtotal - vector used for storing the number of non-fungal sequences detected in samples.
#   *euksingletons - vector used for storing the number of non-fungal singletons detected in samples.
#   * fungalsingletons - vector used for storing the number of fungal singletons detected in samples.   
#   *fungalseqtotal - vector used for storing the number of fungal sequences detected in samples.
#   *i - used for iterating through the Good's coverage index calculation cycle.

# Functions
#   *calcrelabun - function created for calculating the relative abundance of OTUs of specified taxonomic level. 
#   *calcrelabun2 - same as above, but keeps information about phyla.


## 1. Preparatory steps

### 1.1 Importing the required packages
# Prior to running the pipeline make sure that the required packages are installed.

library(dplyr) # Required for basic data manipulation.
library(tidyverse) # Required for basic data manipulation and graph generation.
library(ggpattern) # Required for producing side-by-side bar charts with a patterned aesthetic.
library(DT) # Required for producing interactive tables.
library(phyloseq) # Required for easier community data manipulation.
library(vegan) # Required for generating rarefaction curves.
library(sf) # Required for drawing the map depicting sampling plots.
library(rworldmap) # Required for drawing the map depicting sampling plots.
library(rnaturalearth) # Required for drawing the map depicting sampling plots.
library(patchwork) # Required for combining some of the plots together.
library(microViz) # Required for cleaning up taxonomic identifications.
library(ggpubr) # Required for combining some figures together.
library(paletteer) # Required for specifying heat maps' colours.

### 1.2 Importing the required files. 
# Before continuing with the pipeline, confirm that the required files are in your working directory.

# Importing the metadata file with the function read_tsv() as the file is tab-delimited.
# Use of the read_tsv() function is necessary for the importing of the metadata file to ensure proper encoding.
metadata <- read_tsv("Funaqua_metadata.tsv", locale = locale(encoding = "UTF-8")) 

# Setting the values from column "sample" as the row names of the metadata table.
metadata <- metadata %>% column_to_rownames(var = "sample_code") 

eukotu = read.table("FunAqua_euk_otu.csv", header = TRUE, sep = ",", row.names = 1) # Importing the non-fungal eukaryotes OTU table.
fungiotu = read.table("FunAqua_fungi_otu.csv", header = TRUE, sep =",", row.names = 1) # Importing the fungi OTU table.
euktax = read.table("FunAqua_euk_tax.csv", header = TRUE, sep = ",", row.names = 1) # Importing the non-fungal eukaryotes taxonomy table.
fungitax = read.table("FunAqua_fungi_tax.csv", header = TRUE, sep = ",", row.names = 1) # Importing the fungal eukaryotes taxonomy table.


### 1.3 Validation of the imported files

# Checking if column names i.e., sample names of the fungal OTU table match the row names i.e., sample names of the metadata table.
# If the column and row names match it returns:"TRUE", which means that the files were imported correctly.

cat("The column names of the fungal OTU table match the row names of the metadata table: ",
    identical(colnames(fungiotu), rownames(metadata)))

# Checking if column names i.e., sample names of the non-fungal OTU table match the row names i.e., sample names of the metadata table
# If the column and row names match it returns:"TRUE", which means that the files were imported correctly.
cat("The column names of the non-fungal OTU table match the row names of the metadata table: ",
    identical(colnames(eukotu), rownames(metadata)))

# Checking if the row names i.e., OTU names of the fungal OTU table and taxonomy table match
# If the row names of the two tables match it returns:"TRUE", which means that the files were imported correctly.
cat("The row names of the fungal OTU table match the row names of the fungal taxonomy table: ",
    identical(rownames(fungiotu), rownames(fungitax)))

# Checking if the row names i.e., the OTU names of the non-fungal OTU table and taxonomy table match
# If the row names of the two tables match it returns:"TRUE", which means that the files were imported correctly.
cat("The row names of the non-fungal OTU table match the row names of the non-fungal taxonomy table: ",
    identical(rownames(eukotu), rownames(euktax)))

# Checking if there are any rows (OTUs) in the non-fungal OTU table that have a sum of row values (occurrences) of 0 i.e., the OTU is not represented by any sample.
# If there are no unrepresented OTUs, it returns: "FALSE".
cat("There are unrepresented non-fungal OTUs: ",any(rowSums(eukotu) == 0))

# Checking if there are any rows (OTUs) in the fungal OTU table that have a sum of row values (occurrences) of 0 i.e., the OTU is not represented by any sample.
# If there are no unrepresented OTUs, it returns: "FALSE".
cat("There are unrepresented fungal OTUs: ", any(rowSums(fungiotu) == 0))

# Checking if there are any columns (samples) in the OTU table that have a sum of column values of 0 i.e., the sample has no OTUs.
# The code checks both the fungal and non-fungal OTUs, as some samples have OTUs from one group, but not the other.
# If there are no samples with no OTUs, it returns: "FALSE".
cat("There are samples without any detected OTUs: ", any(colSums(rbind(eukotu, fungiotu)) == 0 ))

### 1.4 Addition of OTU count and sequence count for each sample

# Adding column fungi_otu_count to the metadata table which includes the number of unique fungal OTUs detected in samples.
metadata$fungi_otu_count <- apply(fungiotu, 2, function(x) sum(x > 0)) 

# Adding column fungi_seq_count to the metadata table which includes the number of fungal sequences detected in samples.
metadata$fungi_seq_count <- colSums(fungiotu)

# Adding column euk_otu_count to the metadata table which includes the number of unique non-fungal OTUs detected in samples.
metadata$euk_otu_count <-apply(eukotu, 2, function(x) sum(x > 0))

# Adding column fungi_seq_count to the metadata table which includes the number of non-fungal sequences detected in samples.
metadata$euk_seq_count <- colSums(eukotu)

# Adding column total_otu_count to the metadata table which includes the total number of OTUs detected in samples.
metadata$total_otu_count <- metadata$fungi_otu_count + metadata$euk_otu_count

# Adding column total_seq_count to the metadata table which includes the total number of OTUs detected in samples.
metadata$total_seq_count <- metadata$fungi_seq_count + metadata$euk_seq_count

### 1.5 Construction of phyloseq objects

# Generating the phyloseq object for fungal data.

fungiphyseq = phyloseq(
  otu_table(as(fungiotu,"matrix"), taxa_are_rows = TRUE), # fungiotu is converted into a matrix before used as input for otu_table().
  tax_table(as(fungitax, "matrix")), # fungitax is converted into a matrix before used as input for tax_table().
  sample_data(metadata))

# Generating the phyloseq object for non-fungal eukaryotes.

eukphyseq = phyloseq(otu_table(as(eukotu,"matrix"), taxa_are_rows = TRUE), #eukotu is converted into a matrix before being used as input for otu_table().
                     tax_table(as(euktax, "matrix")), #euktax is converted into a matrix beefore used as input for tax_table().
                     sample_data(metadata))

# Important note: in the previous steps samples with no fungal or non-fungal OTUs were NOT removed from the phyloseq objects.

### 1.6 Subsetting data into sediment and filtered water data.

# Subsetting the sediment data from the metadata table.
metadatased <- metadata %>% 
  filter(sample_source == "sediment")

# Subsetting the filtered water data from the metadata table.
metadatawat<- metadata %>% 
  filter(sample_source == "water")

# Creating sediment and water sample specific fungal taxonomy and OTU tables.

# Subsetting the fungal otu data to only include OTU data from sediment samples.
fungiotused <- fungiotu[c(row.names(metadatased))]

# Removing the rows (OTUs) which sum to 0 and are thus not present in any sediment samples.
fungiotused <- fungiotused[rowSums(fungiotused[])>0,]

# Subsetting the fungal otu data to only include OTU data from water samples.
fungiotuwat<- fungiotu[c(row.names(metadatawat))]

# Removing the rows (OTUs) which sum to 0 and are thus not present in any water samples.
fungiotuwat <- fungiotuwat[rowSums(fungiotuwat[])>0,]

# Subsetting the fungal taxonomy table to only include taxonomy data from sediment samples.
fungitaxsed <- fungitax[c(row.names(fungiotused)),]

# Subsetting the fungal taxonomy table to only include taxonomy data from  water samples.
fungitaxwat <- fungitax[c(row.names(fungiotuwat)),]

#Creating sediment and water sample specific non-fungal taxonomy and OTU tables.

# Subsetting the non-fungal OTU data to only include OTU data from sediment samples.
eukotused <- eukotu[c(row.names(metadatased))]

# Removing the rows (OTUs) which sum to 0 and are thus not present in any sediment samples.
eukotused <- eukotused[rowSums(eukotused[])>0,]

# Subsetting the non-fungal OTU data to only include OTU data from water samples.
eukotuwat<- eukotu[c(row.names(metadatawat))]

# Removing the rows (OTUs) which sum to 0 and are thus not present in any water samples.
eukotuwat <- eukotuwat[rowSums(eukotuwat[])>0,]

# Subsetting the fungal taxonomy table to only include taxonomy data from sediment samples.
euktaxsed <- euktax[c(row.names(eukotused)),]

# Subsetting the fungal taxonomy table to only include taxonomy data from  water samples.
euktaxwat <- euktax[c(row.names(eukotuwat)),]


## 2. Dataset overview

### 2.1 General overview of sampling coverage

# Returns the number of samples represented by the dataset.
cat("The total number of samples in the dataset: ", nrow(metadata))

# Returns the number of sediment and filtered water samples represented by the dataset.
cat("The total number of sediment samples in the dataset: ", table(metadata$sample_source)[1], 
    "\nThe total number of filtered water samples in the dataset: ", table(metadata$sample_source)[2])

# Returns the number of unique sampling plots.
cat("The total number of sampling plots:",
    as.numeric(metadata %>% summarise(count = n_distinct(plot_name))))

# Returns the number of sampling plots that have both a sediment and filtered water sample.
cat("The number of sampling plots that have both a sediment and filtered water sample:",
    nrow(metadata %>%
           group_by(plot_name) %>%
           filter(all(c("sediment", "water") %in% sample_source)) %>%
           summarise(count = n_distinct(plot_name))))


## 2.2 Overview of the geographic sampling coverage

### 2.2.1 Countries

# This section includes an overview of the countries sampled for the dataset.

# Returns the number of countries represented by the dataset, leaving out the unspecified ones.
cat("The total number of countries represented by the dataset:",
    as.numeric(metadata %>%
                 filter(!(country == "Unspecified")) %>%
                 summarise(count = n_distinct(country))))

# Generates an interactive table that shows how many samples are collected from each country.
DT::datatable(metadata %>%
                group_by(country, sample_source) %>%
                summarise(count = n(), .groups = "drop") %>%
                pivot_wider(names_from = sample_source, 
                            values_from = count, 
                            values_fill = 0) %>%
                rename(
                  "Number of Sediment Samples" = sediment,
                  "Number of Water Samples" = water) %>%
                mutate(`Total Number of Samples` = `Number of Sediment Samples` + 
                         `Number of Water Samples`), 
              options = list(pageLength = 10, order = list(4, "desc")))

# Generates a map for the sampling points

# First the code generated a global view of the sampling points.
samplingmapworld <- ggplot() +
  # Drawing the base map without any points.
  geom_sf(data = (ne_countries(scale = "medium", 
                               returnclass = "sf")), 
          fill = "darkseagreen1", color = "darkgreen") + # Specifying the continents' colour
  # Adding the sampling points of samples using coordinates.
  geom_sf(data = (st_as_sf(metadata , coords = c("long", "lat"), 
                           crs = 4326)), 
          shape = 21, fill = "purple", color ="black", stroke = 0.5, size = 2, alpha = 0.2) +
  theme_void() +
  labs(title = "a)")+
  # Adjusting plot margins and specifying the attributes of the plot background.
  theme(panel.background = element_rect(fill = "lightcyan", colour = NA), 
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
        title = element_text(face = "bold"),
        plot.margin = margin(t = 0, r = 5, b = 0, l = 0)) +
  coord_sf(expand = FALSE)

# Displays the generated world level 
samplingmapworld


# Then the code generates a map of the European sampling points.
# Extracting an European map.
Europe <- ne_countries(scale = "medium", returnclass = "sf")[which(ne_countries(scale = "medium", returnclass = "sf")$continent == "Europe"),]

# Plotting the map.
samplingmapeurope <- ggplot() +
  # Drawing the base map without any points.
  geom_sf(data = Europe, fill = "darkseagreen1", color = "darkgreen") +
  # Adding sampling points using coordinates.
  geom_sf(data = (st_as_sf((metadata %>% filter(continent == "Europe")), 
                           coords = c("long", "lat"), 
                           crs = 4326)), 
          shape = 21, fill = "purple", color ="black", stroke = 0.5, size = 2, alpha = 0.2) +
  # Resizing the map so it zooms properly into Europe.
  coord_sf(xlim = c(-30,55), ylim = c(34,84), expand = FALSE) +
  # Adding figure subtitle
  labs(title = "b)")+
  theme_void()+
  # Adjusting plot margins and specifying the attributes of the plot background.
  theme(panel.background = element_rect(fill = "lightcyan", colour = NA),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
        plot.margin = margin(t = 0, r = 0, b = 0, l = 0),
        title = element_text(face = "bold"),
        panel.spacing = unit(0, "pt")) 
# Displays the European sampling map
samplingmapeurope 

# Combines the two maps together.
samplingmap <- samplingmapworld + samplingmapeurope 

# Displaying the final map
samplingmap

# Uncomment to save the generated map.
#ggsave(file="samplingmap.svg", plot = samplingmap, width = 8, height = 3, bg = "transparent")
#ggsave(file="samplingmap.png", plot = samplingmap, width = 8, height = 3, bg = "transparent")
#ggsave(file="samplingmap.pdf", plot = samplingmap, width = 8, height = 3, bg = "transparent")



### 2.2.2 Continents

# This section includes an overview of the sampling coverage across continents.


# The following code generates a table which includes information about sampling coverage across continents, including: 

# 1. The number of sediment samples collected from each continent
# 2. The number of filtered water samples collected from each continent
# 3. The total number of samples collected from each continent
# 4. Each continent's contribution to the total sediment sample count (%)
# 5. Each continent's contribution to the total filtered water sample count (%)
# 6. The overall proportion (%) of samples originating from each continent

print("The total number of samples collected from each continent, including its proportion of all samples (%)")
metadata %>% 
  count(continent, sample_source) %>% # Generating sample count numbers
  pivot_wider(names_from = sample_source, values_from = n, values_fill = 0) %>% # Converting the data from long format to wide format.
  mutate(
    total = sediment + water, # Calculating the total number of samples.
    `sediment %` = round(sediment / sum(sediment) * 100, 2), # The proportion of sediment samples from the continents relative to all sediment samples.
    `water %` = round(water / sum(water) * 100, 2), # The proportion of filtered water samples from the continents relative to all filtered water samples.
    `total %` = round(total / sum(total) * 100, 2)) # The combined proportion of samples from the continents relative to all samples.

# Generates a side-by-side bar chart that depicts the number of samples collected from each continent.

sampleTypeContinentGraph <- ggplot(
  # Generating a contingency table with the variables sample_source and continent with table() as the input data.frame object for plotting.
  data.frame(table(metadata$sample_source, metadata$continent)),
  # x-axis will depict Freq i.e., the number of samples.
  # y-axis will depict Var2 (continent) reordered in descending order according to the number of samples collected.
  aes(x = Freq, y = reorder(Var2,Freq),pattern = Var1))+
  # Adjusting the aesthetics of the generated bars.
  geom_col_pattern(fill = "white",position = position_dodge2(width = 0.5,padding = 0.2),pattern_density = 0.3, 
                   pattern_fill = "black", pattern_spacing = 0.01, colour = "black")+
  # Manually specifying the pattern fill types of the sample types.
  scale_pattern_manual(values =  c("water" = "none", "sediment" = 'circle'),
                       breaks = c("water", "sediment"))+
  # Adding the number of collected samples next to the bars.
  geom_text(aes(x = Freq, y = Var2, label = Freq, group= Var1),
            position = position_dodge(width = 1), vjust = 0.5, hjust = -0.25, size = 4)+
  # Adding custom labels to the axes and the legend.
  labs(x = "Samples", y = "Continent", pattern = "Sample Type")+
  # Setting the ggplot theme to classic.
  theme_classic()+
  # Changing the size of text.
  theme(text = element_text(family = "sans", size = 15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold"))

# Displaying the generated graph.
sampleTypeContinentGraph

# Uncomment to save the generated plot.
#ggsave(file="SampleTypeContinentGraph.svg", plot = sampleTypeContinentGraph, width = 12, height = 5)
#ggsave(file="SampleTypeContinentGraph.png", plot = sampleTypeContinentGraph, width = 12, height = 5)
#ggsave(file="SampleTypeContinentGraph.pdf", plot = sampleTypeContinentGraph, width = 12, height = 5)
### 2.3 Overview of the biome sampling coverage

### 2.3.1 General overview of biomes

# Returns the total number of biomes represented by the dataset, disregarding the group "other"
cat("The total number of biomes represented by the dataset:",
    as.numeric(metadata %>%
                 filter(!(biome =="aquatic: other")) %>% 
                 summarise(count = n_distinct(biome))))

# The following code generates a table which includes information about sampling coverage across biomes, including: 

# 1. The number of sediment samples collected from each biome
# 2. The number of filtered water samples collected from each biome
# 3. The total number of samples collected from each biome
# 4. Each biome's contribution to the total sediment sample count (%)
# 5. Each biome's contribution to the total filtered water sample count (%)
# 6. The overall proportion (%) of samples originating from each biome

metadata %>% 
  mutate(biome = gsub("^aquatic:\\s*", "", biome)) %>% # Removing the substring "aquatic: " from the biome names for cleaner visualization.
  count(biome, sample_source) %>% # Calculating sample count data
  pivot_wider(names_from = sample_source, values_from = n, values_fill = 0) %>% # Converting the table from long format into wide format
  mutate(
    total = sediment + water, # The total number of samples collected from the biomes 
    `sediment %` = round(sediment / sum(sediment) * 100, 2), # The proportion of the sediment samples from the biomes relative to all sediment samples.
    `water %` = round(water / sum(water) * 100, 2), # The proportion of filtered water samples from the biomes relative to all filtered water samples.
    `total %` = round(total / sum(total) * 100, 2)) # The combined proportion of samples from the biomes relative to all samples.

# Generates a side-by-side bar chart that depicts the number of samples collected from each biome

sampleTypeBiomeGraph <- ggplot(
  # Generating a contingency table with the variables sample_source and biome with table() as the input data.frame object for plotting.
  data.frame(table(metadata$sample_source, metadata$biome)),
  # x-axis will depict Freq i.e., the number of samples.
  # y-axis will depict Var2 (biome) reordered in descending order according to the number of samples collected.
  aes(x = Freq, y = reorder(Var2, Freq), pattern = Var1))+
  # Removing the substring "aquatic: " from the biome names while graphing.
  scale_y_discrete(labels = function(y) {
    y <- gsub("aquatic: ", "", y)
    gsub(" biome", "", y)
  })+
  # Adjusting the aesthetics of the generated bars.
  geom_col_pattern(fill = "white",position = position_dodge2(width = 0.5, padding = 0.2), pattern_density = 0.3, 
                   pattern_fill = "black", pattern_spacing = 0.01, colour = "black")+
  # Manually specifying the pattern fill types of the sample types.
  scale_pattern_manual(values =  c("water" = "none", "sediment" = 'circle'),
                       breaks = c("water", "sediment"))+
  # Adding the number of collected samples next to the bars.
  geom_text(aes(x = Freq, y = Var2, label = Freq, group = Var1),
            position = position_dodge(width = 1), vjust = 0.5, hjust = -0.25, size = 4)+
  # Adding custom labels to the axes and the legend.
  labs(x = "Samples", y = "Biome", pattern = "Sample Type")+
  # Setting the ggplot theme to classic
  theme_classic()+
  # Adjusting the text size.
  theme(text = element_text(family = "sans", size=15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold"))

# Displaying the graph
sampleTypeBiomeGraph

# Uncomment to save the generated plot.
#ggsave(file="sampleTypeBiomeGraph.svg", plot = sampleTypeBiomeGraph, width = 12, height = 5)
#ggsave(file="sampleTypeBiomeGraph.png", plot = sampleTypeBiomeGraph, width = 12, height = 5)
#ggsave(file="sampleTypeBiomeGraph.pdf", plot = sampleTypeBiomeGraph, width = 12, height = 5)

#### 2.3.2 Biome coverage across continents

# This section of the pipeline produces heat maps that depict the distribution of samples from each biome collected on each continent.

# The code will return the following warning after running: "Warning: removed XX rows containing missing values or values outside the scale range (`geom_text()`)"

# This is expected behavior, as some of the table values are NAs because not all biomes are represented on all continents, thus those NA values need to be dropped. 

# The first heat map depicts the combined distribution of both sediment and water samples collected from each biome across all continents. 


# Generates a heat map that depicts the distribution of sediment samples collected from each biome on each continent

heatMapSed <- ggplot(data = { # First step: generating the table from which the frequency data is extracted from.
  dataframe <- data.frame(table( # table() generates a contingency table of a filtered version of the metadata table.
    # Before the variables are extracted for the contingency table, the data is filtered to only include rows representing sediment samples.
    (metadata %>% filter(sample_source == "sediment"))$biome, # Extracting the biome variable as the first contingency table variable. 
    (metadata %>% filter(sample_source == "sediment"))$continent # Extracting the continent variable as the first contingency table variable. 
  ))
  # Second step: calculating the abundance of samples collected from each biome on each continent in percentages.
  dataframe <- dataframe %>%
    group_by(Var2) %>% # The dataframe is temporarily grouped by Var2 (continent).
    mutate(per = (Freq / sum(Freq)) * 100, # Generating a new variable per, which shows how many % each biome's sample makes up of the continent's samples.
           # If the biome frequency is 0, the percentage value is changed to NA for that row.
           # This is done so that the na.value field can be used for scale_fill_distiller() function.
           per = ifelse(Freq == 0, NA, per)) %>%  
    ungroup() # The dataframe is ungrouped.
  dataframe},
  # Mapping aesthetics with aes().
  # x-axis will depict Var2 (continents).
  # y-axis will depict Var1 (biomes).
  # y = reorder(Var1, Freq) - the y axis is reordered in a descending order according to the biome frequency.
  # Fill = per - the colour of the heatmap cells is determined according to the per (percentage) variable.
  aes(x = reorder(Var2, per, FUN = function(z) -max(z, na.rm = TRUE)),
      y = reorder(Var1, per, FUN = function(z) -max(z, na.rm = TRUE)),
      fill = per)) +
  geom_tile() + #Initializes the heatmap base with tile based aesthetics.
  # Scale_fill_distiller() - customization of the heatmap colour scale.
  # name = "Samples (%)" - setting the name of the legend as "Samples (%)"
  # palette = "PuBuGn" - the colour gradient flows from purple to blue to green.
  # na.value = "transparent" - tiles of biomes not represented on the continent will be transparent.
  # direction = 1 - putting the sequence of colours in reverse. Defaults to direction = -1.
  scale_fill_distiller(name = "Samples (%)", palette = "PuBuGn", na.value="transparent", 
                       direction = 1, limits = c(0,80)) +
  # Replacing the substring "aquatic: " with "" on the y-axis for clarity purposes.
  scale_y_discrete(limits = rev, labels = function(y) {
    y <- gsub("aquatic: ", "", y)
    gsub(" biome", "", y)
  })+
  # Setting the ggplot theme as classic.
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 15),
        axis.text.x = element_text(angle = 35, hjust = 1),
        axis.title.y = element_text(margin = margin(r = 10)),
        title = element_text(face = "bold")) +
  # Labelling the heatmap tiles with the percentage values of each biome.
  geom_text(aes(label = round(per, 2)),color="black", size = 4)+
  # Setting the axes labels.
  labs(y = "Biome", x = "Continent")

# Displaying the graph
heatMapSed 

# Uncomment to save the generated plot.
#ggsave(file="heatMapSedGraph.svg", plot = heatMapSed, width =10, height = 6)
#ggsave(file="heatMapSedGraph.png", plot = heatMapSed, width =10, height = 6)
#ggsave(file="heatMapSedGraph.pdf", plot = heatMapSed, width =10, height = 6)

# Generates a heat map that depicts the distribution of filtered samples collected from each biome on each continent.

heatMapWat<-ggplot(data = { # First step: generating the table from which the frequency data is extracted from.
  dataframe <- data.frame(table( # table() generates a contingency table of a filtered version of the metadata table.
    # Before the variables are extracted for the contingency table, the data is filtered to only include rows representing filtered water samples.
    (metadata %>% filter(sample_source == "water"))$biome, # Extracting the biome variable as the first contingency table variable. 
    (metadata %>% filter(sample_source == "water"))$continent # Extracting the continent variable as the first contingency table variable. 
  ))
  # Second step: calculating the abundance of samples collected from each biome on each continent in percentages.
  dataframe <- dataframe %>%
    group_by(Var2) %>% # The dataframe is temporarily grouped by Var2 (continent).
    mutate(per = (Freq / sum(Freq)) * 100, # Generating new a variable per, which shows how many % each biome's sample makes up of the continent's samples.
           # If the biome frequency is 0, the percentage value is changed to NA for that row.
           # This is done so that the na.value field can be used for scale_fill_distiller() function.
           per = ifelse(Freq == 0, NA, per)) %>%  
    ungroup() # The dataframe is ungrouped.
  dataframe},
  # Mapping aesthetics with aes().
  # x-axis will depict Var2 (continents).
  # y-axis will depict Var1 (biomes).
  # y = reorder(Var1, Freq) - the y axis is reordered in a descending order according to the biome frequency.
  # Fill = per - the colour of the heatmap cells is determined according to the per (percentage) variable.
  aes(
    x = reorder(Var2, per, FUN = function(z) -max(z, na.rm = TRUE)),
    y = reorder(Var1, per, FUN = function(z) -max(z, na.rm = TRUE)),
    fill = per)) +
  geom_tile(stat = "identity") + # Initializes the heatmap base with tile based aesthetics.
  # Scale_fill_distiller() - customization of the heatmap colour scale.
  # name = "Samples (%)" - setting the name of the legend as "Samples (%)"
  # palette = "PuBuGn" - the colour gradient flows from purple to blue to green.
  # na.value = "transparent" - tiles of biomes not represented on the continent will be transparent.
  # direction = 1 - putting the sequence of colours in reverse. Defaults to direction = -1.
  scale_fill_distiller(name = "Samples (%)", palette = "PuBuGn", na.value="transparent", 
                       direction = 1) +
  # Replacing the substring "aquatic: " with "" on the y-axis for clarity purposes.
  scale_y_discrete(limits = rev, labels = function(y) {
    y <- gsub("aquatic: ", "", y)
    gsub(" biome", "", y)
  })+
  # Setting the ggplot theme as classic.
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 15),
        axis.text.x = element_text(angle = 35, hjust = 1),
        axis.title.y = element_text(margin = margin(r = 10)),
        title = element_text(face = "bold")) +
  # Labelling the heatmap tiles with the percentage values of each biome.
  geom_text(aes(label = round(per, 2)), color = "black", size = 4)+
  # Setting the axes labels.
  labs(y = "Biome", x = "Continent")
# Displays the graph
heatMapWat

# Uncomment to save the generated plot.
#ggsave(file="heatMapWat.svg", plot = heatMapWat, width = 10, height = 6)
#ggsave(file="heatMapWat.png", plot = heatMapWat, width = 10, height = 6)
#ggsave(file="heatMapWat.pdf", plot = heatMapWat, width = 10, height = 6)

# Combining the sediment and filtered water samples' heatmaps together.
heatMapComb <- ggarrange(heatMapSed, heatMapWat,
                        labels = c("a)", "b)"),
                        ncol = 1, nrow = 2,
                        common.legend = TRUE,
                        legend = "right")
# Displaying the combined plot.
heatMapComb

# Uncomment to save the generated plot.
#ggsave(file="heatMapComb.svg", plot = heatMapComb, width = 12, height = 12)
#ggsave(file="heatMapComb.png", plot = heatMapComb, width = 12, height = 10)
#ggsave(file="heatMapComb.pdf", plot = heatMapComb, width = 12, height = 12)

gc()
### 2.4 Sequencing data overview

#### 2.4.1 General kingdom-wise overview
# Returns the total number of eukaryotic OTUs and sequences.
cat("The total number of eukaryotic OTUs:",
    nrow(fungitax) + nrow(euktax), 
    "\nThe total number of eukaryotic sequences:",
    sum(eukotu) + sum(fungiotu))

# Returns the total number of fungal OTUs and sequences..
cat("The total number of fungal OTUs:",
    nrow(fungitax),
    "\nthe total number of fungal sequences:",
    sum(fungiotu))

# Returns the total number of non-fungal OTUs and sequences.
cat("The total number of non-fungal OTUs:",
    nrow(euktax),
    "\nThe total number of non-fungal sequences:",
    sum(eukotu))

# Occurrence of singletons.

# Returns the total number of singletons detected.
cat("The total number of singleton OTUs in the dataset: ", sum(rowSums(fungiotu) == 1)+sum(rowSums(eukotu) == 1),
    "\nThe number of singletons detected among fungal OTUs: ", sum(rowSums(fungiotu) == 1),
    "\nThe number of singletons detected among non-fungal OTUs: ", sum(rowSums(eukotu) == 1))

# Combining together the taxonomy tables of fungi and non-fungal eukaryotes.
# Additionally, column seq_count will be added to the table, which depicts the number of sequences detected from each OTU.
combinedtax <- rbind(
  {dataframe <- fungitax
  dataframe$seq_count <- rowSums(fungiotu)
  dataframe}, 
  {dataframe <- euktax
  dataframe$seq_count <- rowSums(eukotu)
  dataframe})

# Returns a table of the top 10 most OTU-abundant kingdoms 
# Column "OTU count" shows how many OTUs belong to that kingdom.
# Column "Sequences" shows how many sequences belong to that kingdom
# Column "OTU percentages" shows how many % each kingdom's OTUs make up of all kingdoms
# Column "Sequence percentages" shows how many % each kingdom's sequences make up of all kingdoms


combinedtax %>%
  group_by(Kingdom) %>%
  summarise(
    `OTU count` = n(), 
    Sequences = sum(seq_count)) %>%
  mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 2),
         `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 2)) %>%
  slice_max(`OTU count`, n = 10)

# Returns the number of OTUs that could not be identified on kingdom level.
cat("The number of OTUs un-identified on kingdom level: ",
    nrow((combinedtax %>%
            filter(str_detect(Kingdom, "Eukaryota_reg")))), "(", 
    round((nrow((combinedtax %>%
                   filter(str_detect(Kingdom, "Eukaryota_reg"))))/nrow(combinedtax))*100,3),"%)")

#### 2.4.2 Comparison of fungal and non-fungal OTU distribution between sample types 

# Returns the total number of eukaryotic OTUs and sequences detected in sediment samples.
cat("The total number of eukaryotic OTUs detected in sediment samples:",
    nrow(fungitaxsed)+nrow(euktaxsed),
    "\nThe total number of eukaryotic sequences detected in sediment samples:",
    sum(fungiotused)+sum(eukotused))


# Returns the total number of eukaryotic OTUs and sequences detected in water samples.
cat("The total number of eukaryotic OTUs detected in water samples:",
    nrow(fungitaxwat)+nrow(euktaxwat),
    "\nThe total number of eukaryotic sequences detected in water samples:",
    sum(fungiotuwat)+sum(eukotuwat))

# Returns the number of eukaryotic OTUs that are present in both sample types.
cat("The total number of eukaryotic OTUs present in both sediments and water:",
    length(intersect(rownames(fungiotused), rownames(fungiotuwat)))+
      length(intersect(rownames(eukotused), rownames(eukotuwat))))

# Returns the number of sediment and filtered water samples where fungal OTUs are present.
cat("The number of sediment samples where fungal OTUs were detected:",
    ncol(fungiotused[,colSums(fungiotused[])>0]),
    "\nThe number of filtered water samples where fungal OTUs were detected:",
    ncol(fungiotuwat[,colSums(fungiotuwat[])>0]))


# Returns the number of fungal OTUs and sequences detected in sediment samples.
cat("The number of fungal OTUs detected in sediment samples:",
    nrow(fungitaxsed),
    "\nThe total number of fungal sequences detected in sediment samples:",
    sum(fungiotused))


# Returns the number of fungal OTUs and sequences detected in water samples.
cat("The number of fungal OTUs detected in water samples:",
    nrow(fungitaxwat),
    "\nThe total number of fungal sequences detected in water samples:",
    sum(fungiotuwat))


# Returns the 10 most OTU-abundant eukaryotic kingdoms in sediment samples.
combinedtax[c(row.names(fungitaxsed), row.names(euktaxsed)),] %>%
  group_by(Kingdom) %>%
  summarise(
    otu_count = n()) %>%
  mutate(otu_percentage = round(otu_count / sum(otu_count) * 100, 2)) %>%
  slice_max(otu_count, n = 10)

# Returns the 10 most OTU-abundant eukaryotic kingdoms in filtered water samples.
combinedtax[c(row.names(fungitaxwat), row.names(euktaxwat)),] %>%
  group_by(Kingdom) %>%
  summarise(
    otu_count = n()) %>%
  mutate(otu_percentage = round(otu_count / sum(otu_count) * 100, 2)) %>%
  slice_max(otu_count, n = 10)

gc()
### 2.4.3 General sequencing depth overview

# Median sequencing depth.

# Returns the median number of sequences detected together with the interquartile range.
cat("The median number of high-quality sequences detected:", median(metadata$total_seq_count),
    "( IQR:", quantile(metadata$total_seq_count)[2], "-",
    quantile(metadata$total_seq_count)[4], ")")

# Returns the median number of fungal sequences detected together with the interquartile range.
cat("The median number of fungal sequences detected:", median(metadata$fungi_seq_count),
    "( IQR:", quantile(metadata$fungi_seq_count)[2], "-",
    quantile(metadata$fungi_seq_count)[4], ")")



# Returns the median number of sequences detected in sediment samples together with the interquartile range.
cat("The median number of high-quality sequences detected in sediments:", median((metadata %>% filter(sample_source == "sediment")
)$total_seq_count), "( IQR:",
quantile((metadata %>% filter(sample_source == "sediment")
)$total_seq_count)[2], "-",
quantile((metadata %>% filter(sample_source == "sediment")
)$total_seq_count)[4], ")",
"\nThe median number of high-quality fungal sequences detected in sediments:", median((metadata %>% filter(sample_source == "sediment")
)$fungi_seq_count), "( IQR:",
quantile((metadata %>% filter(sample_source == "sediment")
)$fungi_seq_count)[2], "-",
quantile((metadata %>% filter(sample_source == "sediment")
)$fungi_seq_count)[4], ")")

# Returns the median number of sequences detected in water samples together with the interquartile range.
cat("The median number of high-quality sequences detected in waters:", median((metadata %>% filter(sample_source == "water")
)$total_seq_count), "( IQR:",
quantile((metadata %>% filter(sample_source == "water")
)$total_seq_count)[2], "-",
quantile((metadata %>% filter(sample_source == "water")
)$total_seq_count)[4], ")",
"\nThe median number of high-quality fungal sequences detected in waters:", median((metadata %>% filter(sample_source == "water")
)$fungi_seq_count), "( IQR:",
quantile((metadata %>% filter(sample_source == "water")
)$fungi_seq_count)[2], "-",
quantile((metadata %>% filter(sample_source == "water")
)$fungi_seq_count)[4], ")")

gc()

# Generating rarefaction and species accumulation curves

# Generating an OTU accumulation curve for sediment samples
specaccumsed<- specaccum(t(as(fungiotused, "matrix")), 
                         method = "random", permutations = 100)

# Generating an OTU accumulation curve for filtered water samples
specaccumwat<- specaccum(t(as(fungiotuwat, "matrix")), 
                         method = "random", permutations = 100)

# Specifying the layout for the plots.

layout(matrix(c(1,2,3,
                1,2,3,
                4,4,4,
                4,4,4,
                4,4,4), nrow = 5, byrow = TRUE))

# Specifying plot margins.

par(mar = c(6, 8, 4, 2))

#Generating a preview of the plot layouts.
layout.show(n = 4)

# Generating rarefaction curves for all eukaryotes in all samples
par(family = "sans") #Specifying the font family.

rarecurve(rbind(fungiotu, eukotu), step = 20, label=FALSE, 
          col = adjustcolor(c("sediment" = "red", "water" = "blue")[metadata$sample_source], 
                            alpha.f = 0.5),
          xlab =  expression(bold("Eukaryotic sequences")), 
          ylab =  expression(bold("Eukaryotic OTUs")), 
          lwd=2,
          xlim = c(0,20000),
          main = "",
          cex.lab = 1.5,
          cex.axis = 1.5,
          xaxt = "n", yaxt = "n") # Removing the x- and y-axis labels to rewrite them later.  

# Specifying the axis ticks' position
xticks <- axTicks(1)
# Adding the X-axis tick labels.
axis(1, at = xticks, labels = format(xticks, big.mark = ","), cex.axis = 1.5)

# Specifying the Y-axis ticks' position.
yticks <- axTicks(2)
# Adding the Y-axis tick labels.
axis(2, at = yticks, labels = format(yticks, big.mark = ","), cex.axis = 1.5)

# Adding the sub-plot title.
mtext("a)", side = 3, line = 1, adj = 0, cex = 2, font = 2)

legend("topright", legend = c("sediment", "water"), 
       col = (c("red", "blue")), lty = 1, lwd = 2, cex = 0.85)

# Generating rarefaction curves for fungi in all sediment samples.
par(family = "sans") # Specifying the font family.

rarecurve(fungiotused,
          step = 20, label = FALSE, 
          xlab =  expression(bold("Fungal sequences")), 
          ylab =  expression(bold("Fungal OTUs")),
          col = adjustcolor("red", alpha.f = 0.5),
          main = "",
          xlim = c(0,20000),
          cex.lab = 1.5,
          cex.axis = 1.5,
          lwd = 2,
          xaxt = "n", yaxt = "n") # Removing the x- and y-axis labels to rewrite them later.  

# Specifying the axis ticks' position
xticks <- axTicks(1)
# Adding the X-axis tick labels.
axis(1, at = xticks, labels = format(xticks, big.mark = ","), cex.axis = 1.5)

# Specifying the Y-axis ticks' position.
yticks <- axTicks(2)
# Adding the Y-axis tick labels.
axis(2, at = yticks, labels = format(yticks, big.mark = ","), cex.axis = 1.5)

# Adding the sub-plot title.
mtext("b)", side = 3, line = 1, adj = 0, cex = 2, font = 2)

# Generating rarefaction curves for fungi in filtered water samples.
par(family = "sans") # Specifying the font family.

rarecurve(fungiotuwat,
          step = 20, label = FALSE, 
          xlab =  expression(bold("Fungal sequences")), 
          ylab =  expression(bold("Fungal OTUs")),
          col = adjustcolor("blue", alpha.f = 0.5),
          cex.main = 1.5,
          xlim = c(0,20000),
          cex.lab = 1.5,
          cex.axis = 1.5,
          lwd = 2,
          xaxt = "n", yaxt = "n") # Removing the x- and y-axis labels to rewrite them later.  

# Specifying the axis ticks' position
xticks <- axTicks(1)
# Adding the X-axis tick labels.
axis(1, at = xticks, labels = format(xticks, big.mark = ","), cex.axis = 1.5)

# Specifying the Y-axis ticks' position.
yticks <- axTicks(2)
# Adding the Y-axis tick labels.
axis(2, at = yticks, labels = format(yticks, big.mark = ","), cex.axis = 1.5)

# Adding the sub-plot title.
mtext("c)", side = 3, line = 1, adj = 0, cex = 2, font = 2)

# Plotting the two OTU accumulation curves together

par(family = "sans") # Specifying the font family.

# Plotting the sediment samples' OTU accumulation curve.
plot(specaccumsed,
     ci = 0, col = "red", lwd = 2, las = 1,
     xlab = "", ylab = "",
     xlim = c(0, 1400), ylim = c(0, 35000),
     cex.axis = 1.5, cex.lab = 1.5,
     xaxt = "n", yaxt = "n") # Removing the x- and y-axis labels to rewrite them later.

# Adding the filtered water samples' OTU accumulation curve. 
lines(specaccumwat,
      ci = 0, col = "blue", lwd = 2, lty = "dashed")

# Specifying the X-axis limits.
xticks <- pretty(c(0, 1400))

# Plotting the X-axis, while using commas to separate the thousands.
axis(1, at = xticks, labels = format(xticks, big.mark = ","), cex.axis = 1.5)

# Specifying the Y-axis limits.
yticks <- pretty(c(0, 35000))

# Plotting the Y-axis, while using commas to separate the thousands.
axis(2, at = yticks, labels = format(yticks, big.mark = ","), cex.axis = 1.5, las = 1)

# Adding Labels and annotations
mtext(expression(bold("Fungal OTUs")), side = 2, line = 5, cex = 1.2)
mtext(expression(bold("Cumulative number of samples")), side = 1, line = 3, cex = 1.2)

# Adding line labels
text(1170, 35000, "sediment", cex = 1.5)
text(1355, 27000, "water", cex = 1.5)

# Adding subplot title.
mtext("d)", side = 3, line = 1, adj = 0, cex = 2, font = 2)


# Resetting the plot layout.
par(mfrow = c(1,1))

gc()
# Calculating Good's coverage estimations.

# Initializing the dataframe where the Good's coverage values will be stored 
goodsindex <- data.frame(matrix(NA, nrow = nrow(metadata), ncol = 4))
colnames(goodsindex) <- c("sample", "all", "nonfungi", "fungi")

# Iterating through the OTU data to calculate the indexes
for (i in 1:(ncol(fungiotu))){
  goodsindex$sample[[i]] <- colnames(fungiotu)[i] # Fetching the column (sample name).
  fungalsingletons = sum(fungiotu[i] == 1) # Finding the number of fungal singleton OTUs in the sample.
  fungalseqtotal = sum(fungiotu[i]) # Finding the total number of sequences in the sample.
  euksingletons = sum(eukotu[i] == 1) # Finding the number of non-fungal singleton OTUs in the sample.
  eukseqtotal = sum(eukotu[i]) # Finding the number of non-fungal sequences in the sample.
  goodsindex$all[[i]] = 
    1 - (fungalsingletons + euksingletons) / (fungalseqtotal + eukseqtotal) # Calculating the Good's coverage index for all OTUs.
  goodsindex$nonfungi[[i]] = 1 - euksingletons / eukseqtotal # Calculating the Good's coverage index for non-fungal OTUs.
  goodsindex$fungi[[i]] = 1 - fungalsingletons/fungalseqtotal # Calculating the Good's coverage index for fungal OTUs.
  
}


# Returns the number and percentage of samples that had sufficient overall sequencing coverage.
cat("The number of samples that had sufficient overall sequencing coverage (C > 0.89):",
    nrow(goodsindex[goodsindex$all > 0.89,]), "(", 
    nrow(goodsindex[goodsindex$all > 0.89,])/nrow(metadata)*100,
    "% )")

# Returns the number and percentage of samples where at least 50% of sequences belonged to singleton OTUs.
cat("The number of samples where at least 50% of sequences belonged to singleton OTUs (C < 0.51):",
    nrow(goodsindex[goodsindex$all < 0.51,]), "(", 
    nrow(goodsindex[goodsindex$all < 0.51,])/nrow(metadata)*100,
    "% )")

# Returns the number and percentage of samples that had sufficient fungal sequencing coverage.
cat("The number of samples that had sufficient fungal sequencing coverage (C > 0.89):",
    nrow(goodsindex[goodsindex$fungi > 0.89,]), "(", 
    nrow(goodsindex[goodsindex$fungi > 0.89,])/sum(metadata$fungi_otu_count > 0)*100,
    "% )")

# Returns the number and percentage of samples where at least 50% of the fungal sequences belonged to singleton OTUs.
cat("The number of samples where at least 50% of fungal sequences belonged to singleton OTUs (C < 0.51):",
    nrow(goodsindex[goodsindex$fungi < 0.51,]), "(", 
    nrow(goodsindex[goodsindex$fungi < 0.51,])/sum(metadata$fungi_otu_count > 0)*100,
    "% )")


#Returns the median Good's coverage index value with the interquartile range.
cat("The median Good's index value:",median(goodsindex$all),
    "( IQR:",
    quantile(goodsindex$all)[2], "-",
    quantile(goodsindex$all)[4], ")")


#Returns the median Good's coverage index value for fungi together with the interquartile range.
cat("The median Good's index value (fungal sequences only):", median(goodsindex$fungi, na.rm = TRUE),
    "( IQR:",
    quantile(goodsindex$fungi, na.rm = TRUE)[2], "-",
    quantile(goodsindex$fungi, na.rm = TRUE)[4], ")")

gc()
### 2.4.4 Overview of the continent specific sequencing depth

# Returns a table which includes columns for the following data:
# 1. Samples with fungal OTUs - how many samples from each continent contained fungal OTUs.
# 2. Non-fungal sequences - number of non-fungal sequences detected in samples from each continent.
# 3. Fungal sequences - number of fungal sequences detected in samples from each continent.
# 4. Non-fungal OTUs - number of non-fungal OTUs detected in samples from each continent.
# 5. Fungal OTUs - number of fungal OTUs detected in samples from each continent.

metadata %>%
  group_by(continent) %>% # Grouping the data by the continent column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each continent with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each continent.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each continent.
    .groups = "drop"
  ) %>%
  left_join(
    # First, the OTU data is merged by grouping the data into continents.
    # Then, the number of non-fungal OTUs detected in samples from each continent is calculated.
    
    rowSums(otu_table(prune_taxa(taxa_sums(merge_samples(eukphyseq, "continent")) > 0,
                                 merge_samples(eukphyseq, "continent"))) != 0) %>%
      enframe(name = "continent", value = "Non-fungal OTUs"),
    by = "continent"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each continent.
  left_join(
    rowSums(otu_table(prune_taxa(taxa_sums(merge_samples(fungiphyseq, "continent")) > 0,
                                 merge_samples(fungiphyseq, "continent"))) != 0) %>%
      enframe(name = "continent", value = "Fungal OTUs"),
    by = "continent"
  ) %>%
  print(width = Inf)


# Returns the same type of table with information about sediment samples from each continent.

metadata %>%
  filter(sample_source == "sediment") %>% 
  group_by(continent) %>%
  # Grouping the data by the continent column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each continent with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each continent.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each continent.
    .groups = "drop"
  ) %>%
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums(
            merge_samples(
              subset_samples(eukphyseq, sample_source == "sediment"), # Phyloseq data is subset into sediment data
              "continent")) > 0, 
          merge_samples( subset_samples(eukphyseq, sample_source == "sediment"),"continent"))) != 0) %>% # The phyloseq data is merged based on sample type and continent.
      enframe(name = "continent", value = "Non-fungal OTUs"),
    by = "continent"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each continent.
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums( # Phyloseq data is subset into sediment data
            merge_samples(
              subset_samples(fungiphyseq, sample_source == "sediment"), # Phyloseq data is subset into sediment data.
              "continent")) > 0, 
          merge_samples(subset_samples(fungiphyseq, sample_source == "sediment"),"continent"))) != 0) %>% # The phyloseq data is merged based on sample type and continent.
      enframe(name = "continent", value = "Fungal OTUs"),
    by = "continent"
  ) %>%
  print(width=Inf)

# Returns the same type of table with information about water samples from each continent.

metadata %>%
  filter(sample_source == "water") %>% 
  group_by(continent) %>%
  # Grouping the data by the continent column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each continent with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each continent.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each continent.
    .groups = "drop"
  ) %>%
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums(
            merge_samples(
              subset_samples(eukphyseq, sample_source == "water"), # Phyloseq data is subset into water data
              "continent")) > 0, 
          merge_samples( subset_samples(eukphyseq, sample_source == "water"),"continent"))) != 0) %>% # The phyloseq data is merged based on sample type and continent.
      enframe(name = "continent", value = "Non-fungal OTUs"),
    by = "continent"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each continent.
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums( # Phyloseq data is subset into water data
            merge_samples(
              subset_samples(fungiphyseq, sample_source == "water"), # Phyloseq data is subset into water data.
              "continent")) > 0, 
          merge_samples(subset_samples(fungiphyseq, sample_source == "water"),"continent"))) != 0) %>% # The phyloseq data is merged based on sample type and continent.
      enframe(name = "continent", value = "Fungal OTUs"),
    by = "continent"
  ) %>%
  print(width=Inf)

### Generating bar charts depicting how many OTUs were collected from each continent.

# Adding back the OTU ID column to the fungal OTU table.
fungioturenamed <-  fungiotu %>% rownames_to_column("OTU")
# Adding back the OTU ID column to the fungal taxonomy table.
fungitaxrenamed <-  fungitax %>% rownames_to_column("OTU")
# Adding back the sample ID column to the sample metadata table.
metadatarenamed <- metadata %>% rownames_to_column("sample")
# Selecting the columns necessary for plotting.
metadatarenamed <- metadatarenamed[, c("sample", "sample_source", 
                                     "continent", "biome")]

# converting the OTU table into long format.
fungiotulong <- fungioturenamed %>%
  pivot_longer(
    cols = -OTU,              
    names_to = "sample",
    values_to = "abundance"
  )

# Joining together the taxonomy, long format OTU and sample metadata tables.
otuwithmeta <- fungiotulong %>%
  left_join(metadatarenamed, by = "sample") %>%
  left_join(fungitaxrenamed, by ="OTU") %>%
  group_by(sample_source)


# Generating a table which shows how many unique fungal OTUs were collected from each continent.
# Here, the sediments and filtered water samples are combined together.
oturichnesstable <- otuwithmeta %>%
  group_by(continent) %>%
  dplyr::filter(abundance > 0) %>%
  dplyr::distinct(continent, OTU) %>%
  dplyr::count(continent, name = "fungal_otus_unique")

# Generating a table which shows how many unique fungal OTUs were collected from each continent.
# Here, the number of OTUs is given seperately for both sample types.
oturichnesstable2 <- otuwithmeta %>%
  dplyr::filter(abundance > 0) %>%
  dplyr::distinct(continent, OTU, sample_source) %>%
  dplyr::count(continent, sample_source, name = "fungal_otus_unique")

# Generating the first bar chart.
continentrichness1 <- ggplot(oturichnesstable) +
  # Continents are reordered based on fungal OTU numbers.
  aes(x = reorder(continent, fungal_otus_unique),
      y = fungal_otus_unique) +
  geom_bar(stat ="identity", fill ="black") +
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", 
                                                 scientific = FALSE)) +
  # Adding labels depicting the number of OTUs.
  geom_text(aes(x = reorder(continent, fungal_otus_unique), 
                y = fungal_otus_unique,
                label = format(fungal_otus_unique,
                               big.mark =",",
                               scientific = FALSE)), 
            position = position_dodge(width = 0.9),
            hjust = -0.5,
            size = 3) +
  theme_classic(base_size = 12) +
  labs(x = "Continent", y = "Unique fungal OTUs",
       title= "a)")+
  # Adjusting aesthetic parameters.
  theme(plot.caption = element_text(hjust = 0),
        plot.title.position = "plot",
        text = element_text(family = "sans", size = 15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        axis.text.x = element_text(vjust = 0.5, hjust = 0.5),
        plot.margin = margin(t = 10, b = 0, l = 10, r = 15),
        title = element_text(face = "bold")) +
  # Turning off figure element clipping. This allows the bar chart labels to be displayed properly.
  coord_flip(clip = "off")

# Displaying the generated plot.
continentrichness1

# Generating a figure depicting the number of fungal OTUs detected in sediment and filtered water samples from each continent.
continentrichness2 <- ggplot(oturichnesstable2) +
  aes(x = reorder(continent, fungal_otus_unique), # Reordering the continents by the fungal OTU numbers.
      y = fungal_otus_unique,
      pattern = sample_source) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", 
                                                 scientific = FALSE)) +
  # Adjusting pattern fills for the side-by-side bars.
  geom_col_pattern(fill = "white", 
                   position = position_dodge2(width = 0.5, padding = 0.2), 
                   pattern_density = 0.3, 
                   pattern_fill = "black", pattern_spacing = 0.01, 
                   colour = "black",
                   show.legend = c(fill = FALSE, pattern = TRUE)) +
  # Manually specifying the pattern fill types of the sample types.
  scale_pattern_manual(
    values = c(
      "water" = "none",
      "sediment" = "circle"),
    breaks = c("water", "sediment"),
    name = "Sample Type") +
  # Adding the number of OTUs detected next to each bar.
  geom_text(aes(x = reorder(continent, fungal_otus_unique),
                y = fungal_otus_unique,
                label = format(fungal_otus_unique,
                                       big.mark =",",
                                       scientific = FALSE),
                group = sample_source),
            position = position_dodge(width = 0.9),
            hjust = -0.5,
            size = 3) +
  theme_classic(base_size = 12) +
  labs(x = "Continent", y = "Unique fungal OTUs", pattern = "Sample Type",
       title= "b)")+
  # Adjusting aesthetical parameters.
  theme(plot.margin = margin(t = 5, r = 10, b = 10, l = 10),
        plot.caption = element_text(hjust = 0),
        plot.title.position = "plot",
        text = element_text(family = "sans", size = 15),
        axis.text.x = element_text(vjust = 0.5, hjust = 0.5),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold"))+
  # Turning off figure element clipping. This allows the bar chart labels to be displayed properly.
  coord_flip(clip = "off")

# Displaying the plot.
continentrichness2

# Combining the plots together.
combinedcontinentrichness <- continentrichness1 / continentrichness2

# Displaying the combined plot.
combinedcontinentrichness

# Uncomment to save the generated plot.
#ggsave(file = "continentotusbar.svg", plot = combinedcontinentrichness, width = 7, height = 6)
#ggsave(file = "continentsotusbar.png", plot = combinedcontinentrichness, width = 7, height = 6)
#ggsave(file = "continentstusbar.pdf", plot = combinedcontinentrichness, width = 7, height = 6)


### 2.4.5 Overview of the biome specific sequencing depth

# Returns a table which includes columns for the following data:
# 1. Samples with fungal OTUs - how many samples from each biome contained fungal OTUs.
# 2. Non-fungal sequences - number of non-fungal sequences detected in samples from each biome.
# 3. Fungal sequences - number of fungal sequences detected in samples from each biome.
# 4. Non-fungal OTUs - number of non-fungal OTUs detected in samples from each biome.
# 5. Fungal OTUs - number of fungal OTUs detected in samples from each biome.

metadata %>%
  group_by(biome) %>% # Grouping the data by the biome column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each biome with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each biome.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each biome.
    .groups = "drop"
  ) %>%
  left_join(
    # First, the OTU data is merged by grouping the data into biomes.
    # Then, the number of non-fungal OTUs detected in samples from each biome is calculated.
    
    rowSums(otu_table(prune_taxa(taxa_sums(merge_samples(eukphyseq, "biome")) > 0,
                                 merge_samples(eukphyseq, "biome"))) != 0) %>%
      enframe(name = "biome", value = "Non-fungal OTUs"),
    by = "biome"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each biome.
  left_join(
    rowSums(otu_table(prune_taxa(taxa_sums(merge_samples(fungiphyseq, "biome")) > 0,
                                 merge_samples(fungiphyseq, "biome"))) != 0) %>%
      enframe(name = "biome", value = "Fungal OTUs"),
    by = "biome"
  ) %>%
  print(width = Inf)


# Returns the same type of table with information about sediment samples from each biome.

metadata %>%
  filter(sample_source == "sediment") %>% 
  group_by(biome) %>%
  # Grouping the data by the biome column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each biome with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each biome.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each biome.
    .groups = "drop"
  ) %>%
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums(
            merge_samples(
              subset_samples(eukphyseq, sample_source == "sediment"), # Phyloseq data is subset into sediment data
              "biome")) > 0, 
          merge_samples( subset_samples(eukphyseq, sample_source == "sediment"),"biome"))) != 0) %>% # The phyloseq data is merged based on sample type and biome.
      enframe(name = "biome", value = "Non-fungal OTUs"),
    by = "biome"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each biome.
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums( # Phyloseq data is subset into sediment data
            merge_samples(
              subset_samples(fungiphyseq, sample_source == "sediment"), # Phyloseq data is subset into sediment data.
              "biome")) > 0, 
          merge_samples(subset_samples(fungiphyseq, sample_source == "sediment"),"biome"))) != 0) %>% # The phyloseq data is merged based on sample type and biome.
      enframe(name = "biome", value = "Fungal OTUs"),
    by = "biome"
  ) %>%
  print(width=Inf)

# Returns the same type of table with information about water samples from each biome.

metadata %>%
  filter(sample_source == "water") %>% 
  group_by(biome) %>%
  # Grouping the data by the biome column
  summarise(
    `Samples with fungal OTUs` = sum(fungi_otu_count > 0), # Finds the number of samples from each biome with detected fungal OTUs.
    `Non-fungal sequences` = sum(total_seq_count), # Finds the total number of non-fungal sequences detected from each biome.
    `Fungal sequences` = sum(fungi_seq_count), # Finds the total number of fungal sequences detected from each biome.
    .groups = "drop"
  ) %>%
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums(
            merge_samples(
              subset_samples(eukphyseq, sample_source == "water"), # Phyloseq data is subset into water data
              "biome")) > 0, 
          merge_samples( subset_samples(eukphyseq, sample_source == "water"), "biome"))) != 0) %>% # The phyloseq data is merged based on sample type and biome.
      enframe(name = "biome", value = "Non-fungal OTUs"),
    by = "biome"
  ) %>%
  
  # Same steps as above repeated to retrieve the number of fungal OTUs detected in samples from each biome.
  left_join(
    rowSums(
      otu_table(
        prune_taxa( # Rows with no taxa are discarded
          taxa_sums( # Phyloseq data is subset into water data
            merge_samples(
              subset_samples(fungiphyseq, sample_source == "water"), # Phyloseq data is subset into water data.
              "biome")) > 0, 
          merge_samples(subset_samples(fungiphyseq, sample_source == "water"),"biome"))) != 0) %>% # The phyloseq data is merged based on sample type and biome.
      enframe(name = "biome", value = "Fungal OTUs"),
    by = "biome"
  ) %>%
  print(width = Inf)


# Generating a table which shows how many unique fungal OTUs were collected from each biome.
# Here, the sediments and filtered water samples are combined together.
oturichnesstable3 <- otuwithmeta %>%
  group_by(biome) %>%
  dplyr::filter(abundance > 0) %>%
  dplyr::distinct(biome, OTU) %>%
  dplyr::count(biome, name = "fungal_otus_unique")

# Generating a table which shows how many unique fungal OTUs were collected from each continent.
# Here, the number of OTUs is given seperately for both sample types.
oturichnesstable4 <- otuwithmeta %>%
  dplyr::filter(abundance > 0) %>%
  dplyr::distinct(biome, OTU, sample_source) %>%
  dplyr::count(biome, sample_source, name = "fungal_otus_unique")


biomerichness1 <- ggplot(oturichnesstable3) +
  aes(x = reorder(biome, fungal_otus_unique), # Reordering the biomes based on fungal OTU richness.
      y = fungal_otus_unique)+
  geom_bar(stat ="identity", fill ="black") +
  # Editing the X-axis labels for cleaner figures.
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", 
                                                 scientific = FALSE)) +
  scale_x_discrete(labels = function(x) gsub("aquatic: ", "", x)) +
  geom_text(aes(x = reorder(biome, fungal_otus_unique),
                y = fungal_otus_unique,
                label = format(fungal_otus_unique,
                               big.mark =",",
                               scientific = FALSE)),
            position = position_dodge(width = 0.9),
            hjust = -0.5,
            size = 3) +
  theme_classic(base_size = 12) +
  labs(x = "Biome", y = "Unique fungal OTUs",
       title= "a)")+
  # Adjusting the aesthetic parameters.
  theme(plot.caption = element_text(hjust = 0),
        plot.title.position = "plot",
        text = element_text(family = "sans", size = 15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        axis.text.x = element_text(vjust = 0.5, hjust = 0.5),
        plot.margin = margin(t = 10, r = 5, b = 0, l = 10),
        title = element_text(face = "bold"))+
  
  coord_flip(clip = "off")

biomerichness1

biomerichness2 <- ggplot(oturichnesstable4) +
  aes(x = reorder(biome, fungal_otus_unique),
      y = fungal_otus_unique,
      pattern = sample_source)+
  scale_x_discrete(labels = function(x) gsub("aquatic: ", "", x)) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", 
                                                 scientific = FALSE)) +
  geom_col_pattern(fill = "white",position = position_dodge2(width = 0.5, padding = 0.2), 
                   pattern_density = 0.3, 
                   pattern_fill = "black", pattern_spacing = 0.01, 
                   colour = "black",
                   show.legend = c(fill = FALSE, pattern = TRUE))+
  # Manually specifying the pattern fill types of the sample types.
  scale_pattern_manual(
    values = c(
      "water" = "none",
      "sediment" = "circle"),
    breaks = c("water", "sediment"),
    name = "Sample Type")+
  
  geom_text(aes(x = reorder(biome, fungal_otus_unique),
                y = fungal_otus_unique,
                label = format(fungal_otus_unique,
                               big.mark =",",
                               scientific = FALSE),
                group = sample_source),
            position = position_dodge(width = 0.9),
            hjust = -0.5,
            size = 3) +
  theme_classic(base_size = 12) +
  labs(x = "Biome", y = "Unique fungal OTUs", pattern = "Sample Type",
       title= "b)")+
  theme(plot.margin = margin(t = 5, r = 5, b = 10, l = 10),
        plot.caption = element_text(hjust = 0),
        plot.title.position = "plot",
        text = element_text(family = "sans", size = 15),
        axis.text.x = element_text(vjust = 0.5, hjust = 0.5),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold")) +
  # Turning off figure element clipping. This allows the bar chart labels to be displayed properly.
  coord_flip(clip = "off")

# Displaying the generated plot.
biomerichness2

# Combining the two plots together.
combinedbiomerichness <- biomerichness1 / biomerichness2 

# Displaying the combined plot.
combinedbiomerichness

# Uncomment to save the generated plot.
#ggsave(file = "biomeotusbar.svg", plot = combinedbiomerichness, width = 9, height = 8)
#ggsave(file = "biomeotusbar.png", plot = combinedbiomerichness, width = 9, height = 8)
#ggsave(file = "biomeotusbar.pdf", plot = combinedbiomerichness, width = 9, height = 8)

### 2.5 Overview of the dataset's taxonomic coverage

##### 2.5.0 Preparation steps
# Removing objects that will not be used in the next pipeline steps from the environment
rm(list = c("eukphyseq",
            "euktax",
            "eukotu",
            "eukotused",
            "euktaxsed",
            "eukotuwat",
            "euktaxwat",
            "combinedtax",
            "oturichnesstable",
            "oturichnesstable2",
            "oturichnesstable3",
            "oturichnesstable4",
            "fungiotulong",
            "fungitaxrenamed",
            "fungioturenamed",
            "metadatarenamed",
            "otuwithmeta"
            ))
gc()

# Using MicroViz to rename taxonomic classifications given to unknown taxa.
# Eg. if, for example, an Ascomycota class was named as ".", then the class will be renamed to "Ascomycota Class". 
# This is to ensure that unknown taxa are not lumped together between different fungal groups.
fungiphyseq <- fungiphyseq %>% 
  tax_fix(
    min_length = 2,
    unknowns = c(""),
    sep = " ", anon_unique = TRUE,
    suffix_rank = "current"
  )

# Extracting the taxonomy table with fixed names.
fungitaxnamesfixed <- data.frame(tax_table(fungiphyseq))

# Renaming the unidentified taxa for better visualization. 
fungitaxnamesfixed$Class <- gsub("_cl_incertae_sedis", " Class", 
                                 fungitaxnamesfixed$Class)
fungitaxnamesfixed$Order <- gsub("_ord_incertae_sedis", " Order", 
                                 fungitaxnamesfixed$Order)

# Subsetting the updated fungal taxonomy table to only include taxonomy data from sediment samples.
fungitaxnamesfixedsed <- fungitaxnamesfixed[c(row.names(fungiotused)),]

# Subsetting the updated fungal taxonomy table to only include taxonomy data from  water samples.
fungitaxnamesfixedwat <- fungitaxnamesfixed[c(row.names(fungiotuwat)),]

# Adding the number of sequences detected to each OTU.
fungitaxlongnamesfixed <-
  {dataframe <- fungitaxnamesfixed
  dataframe$seq_count <- rowSums(fungiotu)
  dataframe} 

# Adding the number of sequences to each OTU detected in sediments.
fungitaxlongnamesfixedsed <-
  {dataframe <- fungitaxnamesfixedsed
  dataframe$seq_count <- rowSums(fungiotused)
  dataframe} 

# Adding the number of sequences to each OTU detected in filtered water samples.
fungitaxlongnamesfixedwat <-
  {dataframe <- fungitaxnamesfixedwat
  dataframe$seq_count <- rowSums(fungiotuwat)
  dataframe} 

#### 2.5.1 Generating overview tables of the most OTU-abundant fungal group

## 1) Phylum-level tables

# First, the code generates an overview of the 10 most OTU-abundant Phyla in all samples combined.

DT::datatable(fungitaxlongnamesfixed %>%
                group_by(Phylum) %>% # Data is grouped by phyla.
                dplyr::summarise(
                  `OTU count` = n(), # Counts the number of OTUs.
                  Sequences = sum(seq_count)) %>% # Summarizes the sequence counts.
                
                # Calculates the OTU and sequence percentage for each phylum.
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10), # displays the 10 most OTU abundant.
              caption = "Most OTU abundant phyla across all samples combined") 

# Then, it creates a table of the most OTU-abundant phyla in sediments.

DT::datatable(fungitaxlongnamesfixedsed %>%
                group_by(Phylum) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant phyla across sediment samples")


# Lastly, it creates a table of the most OTU-abundant phyla in filtered water samples.
DT::datatable(fungitaxlongnamesfixedwat%>%
                group_by(Phylum) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant phyla across filtered water samples")

## 2) Class-level tables

# First, it generates a table showing the most OTU-abundant classes across all samples combined.
DT::datatable(fungitaxlongnamesfixed%>%
                group_by(Class) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant classes across all samples combined") 

# Then, it generates a table showing the most OTU-abundant classes in sediments.
DT::datatable(fungitaxlongnamesfixedsed %>%
                group_by(Class) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant classes across sediment samples")

# Lastly, it generates a table showing the most OTU-abundant classes in water.
DT::datatable(fungitaxlongnamesfixedwat %>%
                group_by(Class) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant classes across filtered water samples")

## 3) Order-level tables

# First, the code generates an overview of the 10 most OTU-abundant orders in all samples combined.
DT::datatable(fungitaxlongnamesfixed%>%
                group_by(Order) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant orders across all samples combined") 

# Then, the code generates an overview of the most OTU-abundant orders in sediment samples.
DT::datatable(fungitaxlongnamesfixedsed %>%
                group_by(Order) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant orders across sediment samples")

# Lastly, the code generates an overview of the most OTU-abundant orders in filtered samples.
DT::datatable(fungitaxlongnamesfixedwat %>%
                group_by(Order) %>%
                dplyr::summarise(
                  `OTU count` = n(), 
                  Sequences = sum(seq_count)) %>%
                mutate(`OTU percentage` = round(`OTU count` / sum(`OTU count`) * 100, 1),
                       `Sequence percentage` = round(Sequences / sum(Sequences) * 100, 1)) %>%
                slice_max(`OTU count`, n = 10),
              caption = "Most OTU abundant orders across filtered water samples")

# Deletes the previously generated objects to free up memory.

rm(list = c("fungitaxlongnamesfixedsed",
            "fungitaxlongnamesfixedwat"))

# Removes unused objects from the environment.
gc()

#### 2.5.2 Generating figures

## Preparation steps

# Adding back the OTU column to the fungal OTU table from the row names.
fungioturenamed <-  fungiotu %>% rownames_to_column("OTU")
# Adding back the OTU column to the fungal taxonomy table from the row names.
fungitaxrenamed <-  fungitaxlongnamesfixed %>% rownames_to_column("OTU")
# Adding back the sample ID column to the metadata table
metadatarenamed <- metadata %>% rownames_to_column("sample")
# Selecting only columns necessary for plotting.
metadatarenamed<- metadatarenamed[,c("sample", "plot_name", "sample_source")]

# Generating a long-format table where each row represents an OTU found in one sample.
fungiotulong<- fungioturenamed %>%
  pivot_longer(
    cols = -OTU,              
    names_to = "sample",
    values_to = "abundance"
  )

# Adding the sample metadata table to the long format table.
otuwithmeta <- fungiotulong %>%
  left_join(metadatarenamed, by = "sample") %>%
  left_join(fungitaxrenamed, by = "OTU") %>%
  group_by(sample_source)


# Creating a function to calculate relative abundance.
# Arguments:
# data - OTU metadata table combined with taxonomy and sample metadata.
# label - label indicating sample type (i.e., "combined", "sediment", "water)
# taxlevel - indicating the taxonomic level at which the data is analyzed.

calcrelabun <- function(data, label, taxlevel) {
  data %>%
    # Dataframe is grouped by a specific taxonomic level.
    dplyr::group_by(.data[[taxlevel]]) %>%
    # The number of unique OTUs is calculated for each taxa of that specific taxonomic level.
    dplyr::summarise(OTU_count = dplyr::n_distinct(OTU)) %>% 
    # The relative abundance of each taxa is calculated on that specific taxonomic level.
    dplyr::mutate(RelAbundance = (OTU_count / sum(OTU_count)) * 100,
                  # Creates a column "Group" that indicates the sample type.
                  Group = label) 
}


# Calculating a table of all of the phyla's relative abundance with all samples combined.
otuwithmetaphylumrel <- calcrelabun(otuwithmeta, "combined", "Phylum")

# Doing the same with sediment samples.
sediments <- otuwithmeta  %>%
  # Filtering out the sediment sample rows.
  dplyr::filter(sample_source == "sediment") %>% 
  # Keeping only the OTUs which have been detected in sediments.
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "sediment", "Phylum")

# Repeating the previous steps with filtered water samples.
water <- otuwithmeta %>%
  dplyr::filter(sample_source == "water") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "water", "Phylum")

# Combining all of the three dataframes together.
otuphylumrelcombined <- bind_rows(otuwithmetaphylumrel, sediments, water)


# Removing the intermediary objects to clear memory.

rm(list = c("otuwithmetaphylumrel",
            "sediments",
            "water"))

# Removing unused objects.
gc()

# Creating a dataframe for the purpose of plotting stacked bar plots

plot_data <- otuphylumrelcombined %>%
  # Grouping by sample type.
  dplyr::group_by(Group) %>%
  # Gives each phyla a rank based on their OTU abundance.
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  # Filters out the 5 most abundant phyla, others are lumped into the group "other".
  dplyr::mutate(Phylum = ifelse(rank <= 5, Phylum, "Other")) %>%
  # Groups the data by sample type and phyla.
  dplyr::group_by(Group, Phylum) %>%
  # Generates OTU count numbers.
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  # Groups the data by sample type again.
  dplyr::group_by(Group) %>%
  # Calculates relative abundance.
  dplyr::mutate(
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()


# For better visualization, unidentified taxa are renamed.
plot_data$Phylum <- replace(plot_data$Phylum, 
                          plot_data$Phylum ==".",
                          "unidentified") 

# Generating the stacked barplot.
# Phyla are reordered based on OTU count.
stackbarphylum <- ggplot(plot_data, aes(fill = reorder(Phylum, OTU_count), 
                                       y = OTU_count, x = Group)) + 
  geom_bar(position = "fill", stat = "identity", colour = "black")+
  scale_fill_brewer(palette = "Set2") + # Specifying colour palette.
  # Adding labels to the stacked barplot sections to show each taxa's relative abundance.
  geom_text(aes(label = round(RelAbundance, 1)),
            position = position_fill(vjust = 0.5),
            size = 4,
            vjust = -0.75)+
  # Changing the Y-scale to show percentages.
  scale_y_continuous(labels = scales::percent)+
  labs(x="Sample type", y ="Relative abundance of OTUs", fill ="Phylum")+
  theme_classic()+
  theme(text = element_text(family = "sans", size=15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold"))

# Displaying the figure.
stackbarphylum


# Uncomment to save the generated plot.
#ggsave(file = "stackbarphylum.svg", plot = stackbarphylum, width = 6, height = 5)
#ggsave(file = "stackbarphylum.png", plot = stackbarphylum, width = 6, height = 5)
#ggsave(file = "stackbarphylum.pdf", plot = stackbarphylum, width = 6, height = 5)


# Removing intermediary objects from the environments. 
rm(list = c("otuphylumrelcombined",
            "plot_data"))
# Removing unused objects.
gc()

# Creating a table with all of the classes' relative abundances in all samples combined.
otuwithmetaclassrel <- calcrelabun(otuwithmeta, "combined", "Class")

# Repeating that for sediment samples.
sediments <- otuwithmeta  %>%
  dplyr::filter(sample_source == "sediment") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "sediment", "Class")

# Repeating that for filtered water samples.
water <- otuwithmeta %>%
  dplyr::filter(sample_source == "water") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "water", "Class")

# Combining the tables together.
otuclassrelcombined<- bind_rows(otuwithmetaclassrel, sediments, water)
otuclassrelcombined$Class <- gsub("_cl_incertae_sedis", " Class", 
                                  otuclassrelcombined$Class)
# Removing the intermediary objects to clear memory.

rm(list = c("otuwithmetaclassrel",
            "sediments",
            "water"))

# Removing unused objects.
gc()


# Creating a dataframe for the purpose of plotting stacked bar plots

plot_data <- otuclassrelcombined %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  # Selecting the 7 most abundant classes.
  dplyr::mutate(Class = ifelse(rank <= 7, Class, "Other")) %>%
  dplyr::group_by(Group, Class) %>%
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()


plot_data$Class <- replace(plot_data$Class, 
                         plot_data$Class==".",
                         "unidentified") 


# Creating a stacked bar chart of the most OTU abundant classes. 
stackbarclass <- ggplot(plot_data, 
                        aes(fill = reorder(Class, OTU_count), 
                            y = OTU_count, x = Group)) + 
  geom_bar(position = "fill", stat = "identity", colour = "black")+
  scale_fill_brewer(palette = "Set2") + 
  geom_text(aes(label = round(RelAbundance, 1)),
            position = position_fill(vjust = 0.5),
            size = 4)+
  scale_y_continuous(labels = scales::percent)+
  labs(x="Sample type", y ="Relative abundance of OTUs", fill ="Class")+
  theme_classic()+
  theme(text = element_text(family = "sans", size=15),
        legend.title = element_text(size = 15),
        legend.text = element_text(size = 10),
        title = element_text(face = "bold"))

# Displaying the plot.
stackbarclass

# Uncomment to save the generated plot.
#ggsave(file = "stackbarclass.svg", plot = stackbarclass, width = 6, height = 5)
#ggsave(file = "stackbarclass.png", plot = stackbarclass, width = 6, height = 5)
#ggsave(file = "stackbarclass.pdf", plot = stackbarclass, width = 6, height = 5)

# Removing the intermediary objects to clear memory.
rm(list = c("otuclassrelcombined",
            "plot_data"))

# Removing unused objects.
gc()


# Creating a new function for calculating relative abundance.
# This function calculates relative abundance of orders.
# It also keeps the phylum names intact so that each class' relative abundance can be calculated in relation to all of it's phyla's OTUs.
calcrelabun2 <- function(data, label, taxlevel) {
  data %>%
    dplyr::group_by(Phylum, .data[[taxlevel]]) %>%   
    dplyr::summarise(
      OTU_count = dplyr::n_distinct(OTU),
      .groups = "drop"
    ) %>%
    dplyr::group_by(Phylum) %>%   
    dplyr::mutate(
      RelAbundance = (OTU_count / sum(OTU_count)) * 100,
      Group = label
    ) %>%
    dplyr::ungroup()
}

# Calculating the orders' relative abundance table.
otuwithmetaorderrel<- calcrelabun(otuwithmeta, "combined", "Order")

# Repeating that for sediments.
sediments <- otuwithmeta  %>%
  dplyr::filter(sample_source == "sediment") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "sediment", "Order")

# Repeating that for water.
water <- otuwithmeta %>%
  dplyr::filter(sample_source == "water") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun(data = ., "water", "Order")

# Combining the generated tables together.
otuorderrelcombined<- bind_rows(otuwithmetaorderrel, sediments, water)

# Removing the intermediary objects to clear memory.
rm(list = c("otuwithmetaorderrel",
            "sediments",
            "water"))

# Removing unused objects.
gc()


# Generating a table for a heat map depicting the relative abundance of each class when looking at all of the taxa together.
# i.e., without grouping by phylum.

plot_data <- otuorderrelcombined %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  # Selecting the 10 most abundant taxa.
  dplyr::mutate(Order = ifelse(rank <= 10, Order, "Other")) %>%
  dplyr::group_by(Group, Order) %>%
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()


plot_data$Order<-replace(plot_data$Order, 
                         plot_data$Order==".",
                         "unidentified") 
plot_data$Order<-replace(plot_data$Order, 
                         plot_data$Order=="Fungi Order",
                         "unidentified") 

# Creating the first heat map.
# This depicts each order's relative abundance when considering all fungal OTUs.

# Data is reordered by relative abundance.
orderheat <- ggplot(plot_data, aes(x = Group,
                                  y = reorder(Order, RelAbundance,
                                              FUN = function(z) max(z, na.rm = TRUE)),
                                  fill = RelAbundance)) +
  geom_tile() +
  paletteer::scale_fill_paletteer_c("viridis::plasma", # Specifying the colour palette for the plot.
                                    limits = c(0,50))+
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 13.5),
        axis.text.x = element_text(hjust = 0.5, vjust = 0.70),
        title = element_text(face = "bold")) +
  # Adding percentage labels to each tile.
  geom_text(
    aes( 
      label = round(RelAbundance, 1),
      color = RelAbundance > 20
    ), size = 4) +
  scale_color_manual(values = c("FALSE" = "white", "TRUE" = "black"), guide = "none")+
  labs(
    x = "Sample type",
    y = "Order",
    fill = "Relative abundance (%) of OTUs",
    title = "a) All phyla"
  ) 

# Displaying the first plot.
orderheat


# Now the code generates phylum-specific heat maps.

# Calculating abundances with all samples combined
otuwithmetaorderrel2 <- calcrelabun2(otuwithmeta, "combined", "Order")

# Repeating that with sediment samples.
sediments2 <- otuwithmeta  %>%
  dplyr::filter(sample_source == "sediment") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun2(data = ., "sediment", "Order")

# Repeating that for filtered water samples.
water2 <- otuwithmeta %>%
  dplyr::filter(sample_source == "water") %>%
  dplyr::filter(abundance > 0) %>%
  calcrelabun2(data = ., "water", "Order")

# Combining the tables together.
otuorderrelcombined2 <- bind_rows(otuwithmetaorderrel2, sediments2, water2)

# Updating the taxonomic labels for unidentified OTUs.
otuorderrelcombined2$Order <-replace(otuorderrelcombined2$Order, 
                                     otuorderrelcombined2$Order == ".",
                                     "unidentified") 

# Removing the intermediary objects to clear memory.
rm(list = c("otuwithmetaorderrel2",
            "sediments2",
            "water2"))

# Removing unused objects.
gc()

# Generating the dataframe used for heat map plotting.
plot_data2 <- otuorderrelcombined2 %>%
  dplyr::filter(Phylum == "Ascomycota") %>% # Selects Ascomycota phylum.
  dplyr::group_by(Group) %>%
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  dplyr::mutate(Order = ifelse(rank <= 10, Order, "Other")) %>% # Chooses the 10 most abundant Ascomycota taxa.
  dplyr::group_by(Group, Phylum, Order) %>%
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(
    # Calculates the relative abundance of the orders in relation to all Ascomycota OTUs.
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()


# Generates a heatmap depicting the relative abundance of Ascomycota orders' OTUs in relation to Ascomycota OTUs.
orderheat2 <- ggplot(plot_data2, aes(x = Group,
                                    y = reorder(Order, RelAbundance,
                                                FUN = function(z) max(z, na.rm = TRUE)),
                                    fill = RelAbundance)) +
  geom_tile(color = "white") +
  paletteer::scale_fill_paletteer_c("viridis::plasma",
                                    limits = c(0,50))+
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 13.5),
        axis.text.x = element_text(hjust = 0.5, vjust = 0.70),
        title = element_text(face = "bold"))+
  geom_text(
    aes(
      label = round(RelAbundance, 1),
      color = RelAbundance > 20
    ), size = 4) +
  scale_color_manual(values = c("FALSE" = "white", "TRUE" = "black"), guide = "none")+
  labs(
    x = "Sample type",
    y = "Order",
    fill = "Relative abundance (%) of OTUs",
    title = "b) Ascomycota"
  ) 

# Displays the plot.
orderheat2


# Generating the dataframe used for heat map plotting.
plot_data3 <- otuorderrelcombined2 %>%
  dplyr::filter(Phylum == "Basidiomycota") %>% # Selects orders form the Basidiomycota pylum.
  dplyr::group_by(Group) %>%
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  dplyr::mutate(Order = ifelse(rank <= 10, Order, "Other")) %>% # Selects the 10 most abundant orders.
  dplyr::group_by(Group, Phylum, Order) %>%
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()

# Generates the heatmap depicting the relative abundances of Basidiomycota orders' OTUs in relation to Basidiomycota OTUs.
orderheat3 <- ggplot(plot_data3, aes(x = Group,
                                    y = reorder(Order, RelAbundance,
                                                FUN = function(z) max(z, na.rm = TRUE)),
                                    fill = RelAbundance)) +
  geom_tile(color = "white") +
  paletteer::scale_fill_paletteer_c("viridis::plasma",
                                    limits = c(0,50))+
  scale_y_discrete(labels = function(y) {
    y <- gsub(" unspecified", "\nunspecified", y)
  })+
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 13.5),
        axis.text.x = element_text( hjust = 0.5, vjust = 0.70),
        title = element_text (face = "bold"))+
  geom_text(
    aes(
      label = round(RelAbundance, 1),
      color = RelAbundance > 20
    ),size = 4) +
  scale_color_manual(values = c("FALSE" = "white", "TRUE" = "black"), guide = "none")+
  labs(
    x = "Sample type",
    y = "Order",
    fill = "Relative abundance (%) of OTUs",
    title = "c) Basidiomycota"
  ) 

# Displays the plot.
orderheat3


# Generating the dataframe used for heat map plotting.
plot_data4 <- otuorderrelcombined2 %>%
  dplyr::filter(Phylum =="Chytridiomycota") %>% # Selecting orders belonging to the Chytridiomycota phylum.
  dplyr::group_by(Group) %>%
  dplyr::mutate(rank = rank(-OTU_count)) %>%
  dplyr::mutate(Order = ifelse(rank <= 8, Order, "Other")) %>% # Selecting the 8 most abundant orders.
  dplyr::group_by(Group, Phylum, Order) %>%
  dplyr::summarise(OTU_count = sum(OTU_count), .groups = "drop") %>%
  dplyr::group_by(Group) %>%
  dplyr::mutate(
    RelAbundance = OTU_count / sum(OTU_count) * 100
  ) %>%
  dplyr::ungroup()

# Generates the heatmap depicting the relative abundances of Chytridiomycota orders' OTUs in relation to Chytridiomycota OTUs.
orderheat4 <- ggplot(plot_data4, aes(x = Group,
                                    y = reorder(Order, RelAbundance,
                                                FUN = function(z) max(z, na.rm = TRUE)),
                                    fill = RelAbundance)) +
  geom_tile(color = "white") +
  paletteer::scale_fill_paletteer_c("viridis::plasma",
                                    limits = c(0,50))+
  theme_classic() +
  # Adjusting aesthetical parameters pertaining to the legend and font size.
  theme(legend.position = "right", legend.direction = "vertical",
        legend.title = element_text(size = 15), legend.key.size = unit(1,"cm"),
        legend.text = element_text(size = 10),
        text = element_text(family = "sans", size = 13.5),
        axis.text.x = element_text(hjust = 0.5, vjust = 0.70),
        title = element_text(face = "bold")) +
  geom_text(
    aes(
      label = round(RelAbundance, 1),
      color = RelAbundance > 20
    ),size = 4) +
  scale_color_manual(values = c("FALSE" = "white", "TRUE" = "black"), guide = "none")+
  labs(
    x = "Sample type",
    y = "Order",
    fill = "Relative abundance (%) of OTUs",
    title = "d) Chytridiomycota"
  ) 

# Displays the plot.
orderheat4

# Combines the plot together.
combinedorderheat <-(orderheat + orderheat2)/(orderheat3+orderheat4)+
  plot_layout(guides = "collect")&
  theme(legend.position = "bottom",
        legend.direction = "horizontal",
        legend.justification = "left",
        legend.box.just = "left")

# Displays the plot.
combinedorderheat

# Uncomment to save the generated plot.
#ggsave(file = "heatmaporder.svg", plot = combinedorderheat, width = 9.5, height = 7)
#ggsave(file = "heatmaporder.png", plot = combinedorderheat, width = 9.5, height = 7)
#ggsave(file = "heatmaporder.pdf", plot = combinedorderheat, width = 9.5, height = 7)

# Removing the intermediary objects to clear memory.
rm(list = c("otuorderrelcombined2",
            "plot_data",
            "plot_data2",
            "plot_data3",
            "plot_data4"))

# Removing unused objects.
gc()