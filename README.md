# OPTIMA Phenotyping
<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started">

- **Study title**: OPTIMA Phenotyping
- **Study start date**: 28/06/2024
- **Study leads**: Danielle Newby and Cheryl Tan
- **Study end date**:
- **ShinyApp**: https://dpa-pde-oxford.shinyapps.io/OPTIMA_phenotypeR/
- **Report**:

---

This repo is organized as follows:
- [1 Cohort Definitions](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/1_CohortDefinitions): This contains the code on how the codelists were obtained using codelist generator. Broad definitions were defined to obtain a overview of each data partner.
- [2_PhenotypeR](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/2_PhenotypeR): please find there the relevant code to obtain the study results (see below for how to run this part).
- [3_PhenotypeRShiny](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/3_PhenotypeRShiny): please find there the code to visualise the results with the shiny app and generate the report with the plots and tables (see below for how to run this part).
- [4_DataQualityDashboard](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/4_DataQualityDashboard): please find there the code to carry out data quality assessment of the outcome cohorts in your database (under developement).

---

## First steps
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 

## Running the cohort diagnostics using PhenotypeR
1) Navigate to [2_PhenotypeR](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/2_PhenotypeR). Open the project <i>PhenotypeR.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session).
2) Open and work though the <i>CodeToRun.R</i> file which should be the only file that you need to interact with. Run the lines in the file, adding your database specific information and so on (see comments within the file for instructions). The last line of this file will run the study <i>(source(here("RunStudy.R"))</i>.     
3) After running you should then have a zip folder with results to share in your results folder OR you can use the RData file to review your results locally.

## Reviewing results from cohort diagnostics using PhenotypeR
1) Take the RData file from your results folder and move it to the data file 
2) Navigate to [3_PhenotypeRShiny](https://github.com/oxford-pharmacoepi/OPTIMA_PhenotypeR/tree/main/3_PhenotypeRShiny). Open the project <i>Shiny.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session).
3) Either write shiny::runApp() in the console or open up the UI.R file and click "Run App".
4) Your results are ready to review locally in the shiny
