# Get cohort details -----
cohortJsonFiles <- list.files(here("1_InstantiateCohorts"))
cohortJsonFiles <- cohortJsonFiles[str_detect(cohortJsonFiles,".json")]

cohortDefinitionSet <- list()
for(i in 1:length(cohortJsonFiles)){
  working.json<-here("1_InstantiateCohorts",
                     cohortJsonFiles[i])
  cohortJson <- readChar(working.json, file.info(working.json)$size)
  cohortExpression <- cohortExpressionFromJson(cohortJson) # generates the sql
  sql <- buildCohortQuery(cohortExpression, 
                          options = CirceR::createGenerateOptions(generateStats = TRUE))
  
  cohortDefinitionSet[[i]]<-tibble(atlasId = i,
                                   cohortId = i,
                                   cohortName = str_replace(cohortJsonFiles[i],".json",""),
                                   json=cohortJson,
                                   sql=sql,
                                   logicDescription = NA,
                                   generateStats=TRUE)
}
cohortDefinitionSet<-bind_rows(cohortDefinitionSet)

# Names of tables to be created during study run ----- 
cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTableStem)

# Create the tables in the database -----
CohortGenerator::createCohortTables(connectionDetails = connectionDetails,
                                    cohortTableNames = cohortTableNames,
                                    cohortDatabaseSchema = results_database_schema)
