# Manage project dependencies ------
# the following will prompt you to install the various packages used in the study 
# install.packages("renv")
# renv::activate()
renv::restore()

# packages #####
library(CDMConnector)
library(DBI)
library(dbplyr)
library(dplyr)
library(CodelistGenerator)
library(PatientProfiles)
library(here)
library(DrugUtilisation)
library(IncidencePrevalence)
library(tictoc)
library(readr)
library(stringr)
library(testthat)
library(SqlRender)

# database metadata and connection details -----
# The name/ acronym for the database
db_name <- "..."

# Specify databaseConnector connection details -----
user <- "..."
password <- "..."
port <- "..."
host <- "..."
server_dbi <- "..."



# Specify cdm_reference via DBI connection details -----
# In this study we also use the DBI package to connect to the database
# set up the dbConnect details below (see https://dbi.r-dbi.org/articles/dbi for more details)
# you may need to install another package for this (although RPostgres is included with renv in case you are using postgres)
db <- DBI::dbConnect("...",
                     dbname = server_dbi,
                     port = port,
                     host = host, 
                     user = user, 
                     password = password)


# Set database details -----
# The name of the schema that contains the OMOP CDM with patient-level data
#cdm_database_schema <- "public"
cdm_schema <- "..."

# The name of the schema where results tables will be created 
write_schema <- "..."

# where your Achilles scheme is located (you should have run achilles when mapping your database) 
achilles_schema <- "..."

# Table prefix -----
# any tables created in the database during the analysis will start with this prefix
study_prefix <- "optima_diagnositics_"

# Run the study ------
source(here("RunStudy.R"))

# disconnect from the database (only do this after you have run analysis)
#dbDisconnect(db)