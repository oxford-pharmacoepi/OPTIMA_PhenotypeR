PhenotypeR
========================================================================================================================================================

## Introduction
This repository is checking the feasibility and phenotypes developed for OPTIMA

## Running the analysis
1) You should have downloaded the entire study repository i.e. OPTIMA_incidence_survival (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project <i>phenotypeR.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Load all the necessary libraries using renv.
renv::activate()
renv::restore()
4) Open and work though the <i>CodeToRun.R</i> file which should be the only file that you need to interact with. Run the lines in the file, adding your database specific information and so on (see comments within the file for instructions). The last line of this file will run the study <i>(source(here("RunStudy.R"))</i>.     
5) After running you should then have a zip folder with results to share in your output folder.

## Reviewing the results
If you wish to review your results locally on the shiny app. 
1) Take the .RData file produced. Navigate to 1_Diagnostics/PhenotypeRShiny and place this file in the data folder.
2) Open the project <i>shiny.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session) 
3) Load all the necessary libraries using renv.
renv::activate()
renv::restore()
y (to accept all the packages that are needed to install, this step can take several minutes)
4) Run the local shiny app
shiny::runApp() or open up the UI.R file and click "Run App"

Your local shiny app is ready!

Any problems with the repository or shiny apps contact danielle.newby@ndorms.ox.ac.uk

