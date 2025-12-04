
<h1 style="text-align:center;">
  FunAqua: a global dataset of fungal biodiversity in aquatic ecosystems
</h1>

## Introduction

[mapikene]

 It is known that fungi have an impact on aquatic food webs as decomposers, regulate toxic algal blooms via parasitism, and can be mutualists in lichens and on the roots of hydrophytes. However, research on them has previously been limited in comparison to terrestrial fungi and other aquatic microorganisms.

Established in 2018 as a collaborative project between the University of Tartu and the Estonian University of Life Sciences, the FunAqua project aims to:
1. Build a global dataset of fungal distribution in aquatic ecosystems;
2. Describe the factors which shape the community composition of fungi in aquatic ecosystems.

In its current state, the FunAqua dataset contains eukaryotic long-read metabarcoding data from 1,076 sediment and 1,299 filtered water samples collected across 1,452 sampling sites in 87 countries. We targeted the internal transcribed spacer (ITS) region. In total, 50,152 fungal OTUs were recorded. The sequencing data is accompanied by comprehensive sample metadata, including physicochemical data of water and sediments. The FunAqua dataset provides a new resource for analysing and better understanding the biodiversity of fungi in different types of aquatic habitats across biogeographical regions. 

## Pipeline overview

The pipeline deposited in this GitHub repository includes majority of the steps included in the technical validation section of the manuscript describing the FunAqua dataset.

The pipeline is shared as two different files: an .R script (filename), and an RMarkdown script (filename).  The outputs of the two pipelines are mostly the same, however there are some differences. Namely, the markdown output includes more interactive visualizations, for example, it includes an interactive map. There are a few additional graphs included in the markdown document which where not included in the final manuscript, but can be used to explore the data further. The .R script includes only the data and graphs which were used in the manuscript. 

The repository includes two .html files "blahblah/blahblah", and "blahblah/blahblah2", which are example outputs of the pipeline. "blahblah/blahblah" shows the output of the pipeline when its ran on the entire dataset.  "blahblah/blahblah2" shows the output of the pipeline based on the smaller example datasets provided in the repository.

The pipeline is divided into the following sections:

** 1.  File preparation steps **
   
   1.1 Package importing
   
   1.2 File validation
   
   1.3 OTU and sequence count addition to the metadata table
   
   1.4 Phyloseq object construction
   
   1.5 Subsetting the dataset into sediment and water data

** 2. General data overview **
   
   2.1  Short overview of the number of samples in the dataset
   
   2.2 Geographic overview
     2.2.1 Overview of represented countries

   		2.2.2 Overview of sampled continents
	
	1. Biome overview
		
		1. Overview of sampled biomes
		
		1. Overview of biome sampling distribution across continents
	
	1. Sequencing data overview
		
		1. General overview of the fungal and non-fungal sequence numbers and OTUs
		
		1. Comparison of the fungal and non-fungal OTU and sequence abundance in sediment and filtered water samples
		
		1. General sequencing depth overview
		
		1. Overview of continent-specific sequencing depth
		
		1. Overview of biome-specific sequencing depth


The pipeline also included commented lines for the purpose of saving generated plots. To save the plots that you are generating, uncomment those lines.

The versions of the software and packages used in the pipeline is included in the file (blahblahblah2/blahblahblah3)


### Running the pipeline(s)
#### Pipeline dependencies

The following packages are required for the .R script:

1. tiyverse/dplyr (Required for basic data manipulation, included in CRAN)

2. tidyverse/tidyverse (Required for basic data manipulation and graph generation, included in CRAN)

3. trevorld/ggpattern (Required for producing side-by-side bar charts with a patterned aesthetic)

4. rstudio/DT (Required for producing interactive tables)

5. joey711/phyloseq (Required for easier community data manipulation)

6. vegandevs/vegan (Required for generating rarefaction curves)

7. r-spatial/sf (Required for drawing the map depicting sampling plots, included in CRAN)

8. andysouth/rworldmap (Required for drawing the map depicting sampling plots, included in CRAN)

9. ropensci/rnaturalearth (Required for drawing the map depicting sampling plots)

10. kassambara/ggpubr (Required for combining the heatmap plots together, included in CRAN)

To run the markdown script, you additionally need:

11. rstudio/rmarkdown (Required to execute and write markdown scripts in R, included in CRAN)

12. haozhu233/kableExtra (Required for customizing interactive tables)

13. rstudio/leaflet (Required for generating interactive maps, included in CRAN)

To install the required packages, execute this code:
```
install.packages("tidyverse")
install.packages("ggpattern")
install.packages("DT")
install.packages("phyloseq")
install.packages("vegan")
install.packages("sf")
install.packages("rworldmap")
install.packages("rnaturalearth")
install.packages("ggpubr")
install.packages("rmarkdown")
install.packages("kableExtra")
install.packages("leaflet")
```
#### Hardware recommendations
It is recommended that the code is executed on an RStudio server due to the high computational requirements in the sequencing depth section, namely the rarefaction curve generation. The minimal recommended RAM for the pipeline is 32GB, as during the rarefaction curve generation, the RAM usage can rise up to 25GB. In idle, the pipeline uses up around 18-20 GB of RAM. 

The pipeline is largely constructed in a way where the amount of data stored in the R environment is as minimal as possible. This means that data manipulation is done in the data's calling function wherever feasible (for example, contingency tables are generated inside a ggplot() function instead of generating and saving it for use beforehand).

The RMarkdown document does not save any files into the R environment. 

#### The example files
When running the pipeline with the smaller example files provided in the repository, please change the file names in the file import section to their correct names.
#### Usage notes
Before starting the pipeline, confirm the following:
1. ✅The required packages are installed
2. ✅All of the files are present in your working directory
3. ✅The file names are correct

## Example data
## Data availability

## Citation

##
