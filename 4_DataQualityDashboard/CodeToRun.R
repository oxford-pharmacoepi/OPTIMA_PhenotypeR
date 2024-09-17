renv::activate() #activate the renv
renv::restore() #restore the environment

# Load packages ------
# load r packages

library(SqlRender)
library(DatabaseConnector)
library(here)
library(lubridate)
library(stringr)
library(ggplot2)
library(DBI)
library(dbplyr)
library(dplyr)
library(tidyr)
library(kableExtra)
library(RSQLite) 
library(rmarkdown)
library(tableone) 
library(scales)
library(forcats) 
library(RPostgres)
library(broom) 
library(rms)
library(glue) 
library(remotes)
library(readr)
library(tictoc)
library(purrr)
library(CirceR)
library(log4r)
library(readr)
library(devtools)
library(DataQualityDashboard)

# database connection details
server     <- "..."
user       <- "..."
password   <- "..."
port       <- "..." 
host       <- "..."


# Specify OHDSI DatabaseConnector connection details  ------
# set up the createConnectionDetails to connect to the database
# see http://ohdsi.github.io/DatabaseConnector for more details

downloadJdbcDrivers("...", here()) # if you already have this you can omit and change pathToDriver below
connectionDetails <- createConnectionDetails(dbms = "...",
                                             server =server,
                                             user = user,
                                             password = password,
                                             port = port ,
                                             pathToDriver = here())


# Set database details -----
# your sql dialect used with the OHDSI SqlRender package
# eg postgresql, redshift etc
# see https://ohdsi.github.io/SqlRender/articles/UsingSqlRender.html for more details
targetDialect <- "..." 

# The name of the schema that contains the OMOP CDM with patient-level data
cdm_database_schema <-"..."

# The name of the schema that contains the vocabularies 
# (often this will be the same as cdm_database_schema)
vocabulary_database_schema <-"..."

# The name of the schema where results tables will be created 
results_database_schema <-"..."

# The name of the schema where cohort table is 
cohort_database_schema <-"..."

# CDM source
cdmSourceName <- "..." # a human readable name for your CDM source e.g. SIDIAP, CPRD_GOLD

# stem name - short name in lower case
cohortTableStem <- "..."

# determine how many threads (concurrent SQL sessions) to use ----------------------------------------
numThreads <- 1 # we tried 3 but crashed so set to 1

# Run the study ------
source(here("RunStudy.R"))

# to launch DQD shiny app -----
DataQualityDashboard::viewDqDashboard(dqd_files)
