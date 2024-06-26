# label your output folder ---------------------------
outputFolder <- "output"

# which DQ check levels to run -------------------------------------------------------------------
checkLevels <- c("TABLE", "FIELD", "CONCEPT")

# which DQ checks to run? ------------------------------------
# Names can be found in inst/csv/OMOP_CDM_v5.3.1_Check_Desciptions.csv
checkNames <- c()

# which CDM tables to exclude? ------------------------------------
tablesToExclude <- c()

if (!file.exists(outputFolder)){
  dir.create(outputFolder, recursive = TRUE)}

# DQD for ATLAS cohort
DataQualityDashboard::executeDqChecks(connectionDetails = connectionDetails, 
                                      cdmDatabaseSchema = cdm_database_schema, 
                                      resultsDatabaseSchema = results_database_schema,
                                      cdmSourceName = cdmSourceName,
                                      cohortDefinitionId = ATLASID,
                                      cohortDatabaseSchema = cohort_database_schema ,
                                      numThreads = numThreads,
                                      sqlOnly = FALSE, 
                                      outputFolder = "output", 
                                      verboseMode = TRUE,
                                      writeToTable = FALSE,
                                      checkLevels = checkLevels,
                                      checkNames = checkNames)
