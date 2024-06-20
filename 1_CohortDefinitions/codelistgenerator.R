# Manage project dependencies ------
# the following will prompt you to install the various packages used in the study
# install.packages("renv")
# renv::activate()
renv::restore()

# packages ---
library(Capr)
library(here)
library(DBI)
library(CDMConnector)
library(dplyr)
library(tidyr)
library(CodelistGenerator)
library(ggplot2)

# db with vocab ----
server_dbi <- Sys.getenv("DB_SERVER_cdm_thin_fr_202308_dbi")
user       <- Sys.getenv("DB_USER")
password   <- Sys.getenv("DB_PASSWORD")
port       <- Sys.getenv("DB_PORT")
host       <- Sys.getenv("DB_HOST")

# connect
db <- DBI::dbConnect(RPostgres::Postgres(),
                     dbname = server_dbi,
                     port = port,
                     host = host,
                     user = user,
                     password = password)

# Set database details -----
# The name of the schema that contains the OMOP CDM with patient-level data
cdm_database_schema <- "public"

# The name of the schema that contains the vocabularies
# (often this will be the same as cdm_database_schema)
vocabulary_database_schema <- cdm_database_schema

# The name of the schema where results tables will be created
results_database_schema <- "results"

# database metadata and connection details -----
# The name/ acronym for the database
db_name<-"THIN_fr"

# Name of outcome table in the result table where the outcome cohorts will be stored
# Note, if there is an existing table in your results schema with the same names
# it will be overwritten
table_stem <- "dnclgenoptima"

# create cdm reference ----
cdm <- CDMConnector::cdm_from_con(con = db,
                                  cdm_schema = cdm_database_schema,
                                  write_schema = c("schema" = results_database_schema,
                                                   "prefix" = table_stem),
                                  cdm_name = db_name,
                                  achilles_schema = results_database_schema )


# check patient numbers
cdm$person %>%
  tally()

# check vocab version
# getVocabVersion(cdm = cdm)

getConceptClassId(cdm,
                  standardConcept = "Standard")

# [1] "Clinical Finding"  "Context-dependent" "HCPCS Modifier"    "ICDO Condition"
# [5] "Procedure"

# Broad lung cancer including cancers of trachea and bronchus and lower respiratory tract
lungcancer_codes <- getCandidateCodes(
  cdm = cdm,
  keywords = c("malignant neoplasm of lung",
               "malignant neoplasm of trachea",
               "Primary malignant neoplasm of bronchus",
               "Oat cell carcinoma of lung",
               "Oat cell carcinoma of trachea",
               "Oat cell carcinoma of main bronchus" ,
               "malignant neoplasm of lower respiratory tract") ,
  exclude = c("melanoma",
              "lymphoma",
              "sarcoma",
              "secondary",
              "metastasis",
              "lymphocytic",
              "benign",
              "hodgkin",
              "neuroendocrine",
              "rhabdomyosarcoma",
              "angiomyosarcoma",
              "fibrosarcoma",
              "leiomyosarcoma",
              "hemangiosarcoma",
              "pseudosarcomatous",
              "carcinosarcoma",
              "leukemia",
              "blastoma",
              "T-cell",
              "atelectasis",
              "plasmacytoma",
              "mesenchymoma",
              "heavy chain disease" ,
              "ectomesenchymoma",
              "myeloproliferative",
              "sezary",
              "lymphoid",
              "epithelioid hemangioendothelioma"

  ) ,
  domains = c("Condition", "Observation")
)

write.csv(lungcancer_codes, here::here("preliminary_cohorts" ,
                                       paste0(cdmName(cdm), "_lungCancerBroad.csv")), row.names = FALSE)

#trying out orphan codes for lung cancer BROAD
lungcancer_orphan_codes <- findOrphanCodes(x = list("lung_cancer" = lungcancer_codes$concept_id),
                                cdm = cdm,
                                domains = c("Condition", "Observation"),
                                standardConcept = "Standard",
                                searchInSynonyms = FALSE,
                                searchNonStandard = FALSE,
                                includeDescendants = TRUE,
                                includeAncestor = TRUE)


lungcancer_orphan_codes <- lungcancer_orphan_codes %>%
  separate(additional_level, into = c("Description", "Concept ID"), sep = " ; ")

write.csv(lungcancer_orphan_codes, here::here("preliminary_cohorts" ,
                                       paste0(cdmName(cdm), "_lungCancerBroad_orphan.csv")), row.names = FALSE)


# get codes for staging/grade

# #Stage 1
# stage1_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("TNM stage 1",
#                "Stage 1"
#                ) ,
#   exclude = c("stage 2",
#               "Ann Arbor Stage",
#               "Eye fundus" ,
#               "Newborn",
#               "ISS Stage",
#               "ENSAT",
#               "Evans" ,
#               "Enneking",
#               "Lugano",
#               "FIGO", #
#               "Rai Stage" ,
#               "RISS Stage",
#               "Antibody detection",
#               "Node stage",
#               "retinoblastoma" ,
#               "WR stage",
#               "Stage M1" ,
#               "Stage D1" ,
#               "Durie/Salmon Stage 1" ,
#               "SEER Summary Stage",
#               "PRETEXT Stage" ,
#               "INRG Stage" ,
#               "COG Stage" ,
#               "Clotting",
#               "INSS" ,
#               "Masaoka_Koga Stage 1" ,
#               "Antibody identification" ,
#               "stage 3",
#               "stage 4") ,
#   domains = "Measurement")
#
# write.csv(stage1_codes, here::here("preliminary_cohorts" ,
#                                               paste0(cdmName(cdm), "_stage1_codes.csv")), row.names = FALSE)
#
#
# #Stage 2
# stage2_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("TNM stage 2",
#                "Stage 2"
#   ) ,
#   exclude = c("stage 1",
#               "Ann Arbor Stage",
#               "Masaoka_Koga Stage 2a",
#               "Masaoka_Koga Stage 2",
#               "Durie/Salmon Stage 2",
#               "Masaoka_Koga Stage 2b",
#               "Coagulation factor VIII",
#               "Antibody identification",
#               "Eye fundus" ,
#               "Newborn",
#               "ISS Stage",
#               "ENSAT",
#               "Evans" ,
#               "Enneking",
#               "Lugano",
#               "FIGO", #
#               "Rai Stage" ,
#               "RISS Stage",
#               "Antibody detection",
#               "Node stage",
#               "retinoblastoma" ,
#               "WR stage",
#               "Stage M1" ,
#               "Stage D1" ,
#               "Durie/Salmon" ,
#               "SEER Summary Stage",
#               "PRETEXT Stage" ,
#               "INRG Stage" ,
#               "COG Stage" ,
#               "Clotting",
#               "INSS" ,
#               "Masaoka_Koga" ,
#               "stage 3",
#               "stage 4") ,
#   domains = "Measurement")
#
# write.csv(stage2_codes, here::here("preliminary_cohorts" ,
#                                               paste0(cdmName(cdm), "_stage2_codes.csv")), row.names = FALSE)
#
# #Stage 3
# stage3_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("TNM stage 3",
#                "Stage 3"
#   ) ,
#   exclude = c("stage 2",
#               "stage 1",
#               "Ann Arbor Stage",
#               "Eye fundus" ,
#               "Newborn",
#               "ISS Stage",
#               "ENSAT",
#               "Evans" ,
#               "Enneking",
#               "Lugano",
#               "FIGO",
#               "Rai Stage" ,
#               "RISS Stage",
#               "Antibody detection",
#               "Node stage",
#               "retinoblastoma" ,
#               "WR stage",
#               "Stage M1" ,
#               "Stage D1" ,
#               "Durie/Salmon" ,
#               "SEER Summary Stage",
#               "PRETEXT Stage" ,
#               "INRG Stage" ,
#               "COG Stage" ,
#               "Clotting",
#               "INSS" ,
#               "Durie/Salmon Stage 3",
#               "Masaoka_Koga Stage 3",
#               "stage 4") ,
#   domains = "Measurement")
#
# write.csv(stage3_codes, here::here("preliminary_cohorts" ,
#                                               paste0(cdmName(cdm), "_stage3_codes.csv")), row.names = FALSE)
#
# #Stage 4
# stage4_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("TNM stage 4",
#                "Stage 4",
#                "Stage M1" ,
#                "Stage D1",
#                "Metastasis"
#   ) ,
#   exclude = c("stage 2",
#               "stage 1",
#               "Ann Arbor Stage",
#               "Eye fundus" ,
#               "Newborn",
#               "ISS Stage",
#               "ENSAT",
#               "Evans" ,
#               "Enneking",
#               "Lugano",
#               "FIGO", #
#               "Rai Stage" ,
#               "RISS Stage",
#               "Antibody detection",
#               "Node stage",
#               "retinoblastoma" ,
#               "WR stage",
#               "SEER Summary Stage",
#               "PRETEXT Stage" ,
#               "INRG Stage" ,
#               "COG Stage" ,
#               "Clotting",
#               "INSS" ,
#               "Masaoka_Koga Stage 4" ,
#               "Masaoka_Koga Stage 4a",
#               "Site of distant metastasis in Breast tumor",
#               "Collaborative staging metastasis evaluation Cancer",
#               "Tumor size, largest metastasis, additional dimension",
#               "Circulating tumor cell test",
#               "Circulating tumor cells",
#               "Malignant pleural effusion",
#               "Malignant ascites" ,
#               "KISS1",
#               "MTA1 ",
#               "MTA3",
#               "stage 3") ,
#   domains = "Measurement")
#
# write.csv(stage4_codes, here::here("preliminary_cohorts" ,
#                                               paste0(cdmName(cdm), "_stage4_codes.csv")), row.names = FALSE)
#

# #staging codes 1 NSCLC
# stage1_nsclungcancer_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("Non-small cell carcinoma of lung, TNM stage 1",
#                "Large cell carcinoma of lung, TNM stage 1",
#                "Squamous cell carcinoma of lung, TNM stage 1",
#                "Adenocarcinoma of lung, stage I"
#                ),
#   exclude = c("melanoma",
#               "lymphoma",
#               "secondary",
#               "small cell carcinoma",
#               "metastasis",
#               "secondary",
#               "benign",
#               "hodgkin",
#               "sarcoma",
#               "small cell malignant neoplasm",
#               "rhabdomyosarcoma",
#               "angiomyosarcoma",
#               "fibrosarcoma",
#               "leiomyosarcoma",
#               "hemangiosarcoma",
#               "pseudosarcomatous",
#               "carcinosarcoma",
#               "leukemia",
#               "blastoma",
#               "T-cell",
#               "atelectasis",
#               "plasmacytoma",
#               "mesenchymoma",
#               "heavy chain disease" ,
#               "ectomesenchymoma",
#               "myeloproliferative",
#               "sezary",
#               "lymphoid",
#               "epithelioid hemangioendothelioma") ,
#   domains = "Condition"
# )
#
#
# nsclc_stage1_orphan_codes <- findOrphanCodes(x = list("lung_cancer" = stage1_nsclungcancer_codes$concept_id),
#                                                               cdm = cdm,
#                                                               domains = "Condition",
#                                                               standardConcept = "Standard",
#                                                               searchInSynonyms = FALSE,
#                                                               searchNonStandard = FALSE,
#                                                               includeDescendants = TRUE,
#                                                               includeAncestor = TRUE)
#
#
# #staging codes 2 NSCLC
# stage2_nsclungcancer_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("Non-small cell carcinoma of lung, TNM stage 2",
#                "Large cell carcinoma of lung, TNM stage 2",
#                "Squamous cell carcinoma of lung, TNM stage 2",
#                "Adenocarcinoma of lung, stage II"
#   ),
#   exclude = c("melanoma",
#               "lymphoma",
#               "secondary",
#               "small cell carcinoma",
#               "metastasis",
#               "secondary",
#               "benign",
#               "hodgkin",
#               "sarcoma",
#               "small cell malignant neoplasm",
#               "rhabdomyosarcoma",
#               "angiomyosarcoma",
#               "fibrosarcoma",
#               "leiomyosarcoma",
#               "hemangiosarcoma",
#               "pseudosarcomatous",
#               "carcinosarcoma",
#               "leukemia",
#               "blastoma",
#               "T-cell",
#               "atelectasis",
#               "plasmacytoma",
#               "mesenchymoma",
#               "heavy chain disease" ,
#               "ectomesenchymoma",
#               "myeloproliferative",
#               "sezary",
#               "lymphoid",
#               "epithelioid hemangioendothelioma") ,
#   domains = "Condition"
# )
#
# nsclc_stage2_orphan_codes <- findOrphanCodes(x = list("lung_cancer" = stage2_nsclungcancer_codes$concept_id),
#                                              cdm = cdm,
#                                              domains = "Condition",
#                                              standardConcept = "Standard",
#                                              searchInSynonyms = FALSE,
#                                              searchNonStandard = FALSE,
#                                              includeDescendants = TRUE,
#                                              includeAncestor = TRUE)
#
#
#
# #staging codes 3 NSCLC
# stage3_nsclungcancer_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("Non-small cell carcinoma of lung, TNM stage 3",
#                "Large cell carcinoma of lung, TNM stage 3",
#                "Squamous cell carcinoma of lung, TNM stage 3",
#                "Adenocarcinoma of lung, stage III"
#   ),
#   exclude = c("melanoma",
#               "lymphoma",
#               "secondary",
#               "small cell carcinoma",
#               "metastasis",
#               "secondary",
#               "benign",
#               "hodgkin",
#               "sarcoma",
#               "small cell malignant neoplasm",
#               "rhabdomyosarcoma",
#               "angiomyosarcoma",
#               "fibrosarcoma",
#               "leiomyosarcoma",
#               "hemangiosarcoma",
#               "pseudosarcomatous",
#               "carcinosarcoma",
#               "leukemia",
#               "blastoma",
#               "T-cell",
#               "atelectasis",
#               "plasmacytoma",
#               "mesenchymoma",
#               "heavy chain disease" ,
#               "ectomesenchymoma",
#               "myeloproliferative",
#               "sezary",
#               "lymphoid",
#               "epithelioid hemangioendothelioma") ,
#   domains = "Condition"
# )
#
# nsclc_stage3_orphan_codes <- findOrphanCodes(x = list("lung_cancer" = stage3_nsclungcancer_codes$concept_id),
#                                              cdm = cdm,
#                                              domains = "Condition",
#                                              standardConcept = "Standard",
#                                              searchInSynonyms = FALSE,
#                                              searchNonStandard = FALSE,
#                                              includeDescendants = TRUE,
#                                              includeAncestor = TRUE)
#
#
#
#
# #staging codes 4 NSCLC
# stage4_nsclungcancer_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("Non-small cell carcinoma of lung, TNM stage 4",
#                "Large cell carcinoma of lung, TNM stage 4",
#                "Squamous cell carcinoma of lung, TNM stage 4",
#                "Adenocarcinoma of lung, stage IV"
#   ),
#   exclude = c("melanoma",
#               "lymphoma",
#               "secondary",
#               "small cell carcinoma",
#               "metastasis",
#               "secondary",
#               "benign",
#               "hodgkin",
#               "sarcoma",
#               "small cell malignant neoplasm",
#               "rhabdomyosarcoma",
#               "angiomyosarcoma",
#               "fibrosarcoma",
#               "leiomyosarcoma",
#               "hemangiosarcoma",
#               "pseudosarcomatous",
#               "carcinosarcoma",
#               "leukemia",
#               "blastoma",
#               "T-cell",
#               "atelectasis",
#               "plasmacytoma",
#               "mesenchymoma",
#               "heavy chain disease" ,
#               "ectomesenchymoma",
#               "myeloproliferative",
#               "sezary",
#               "lymphoid",
#               "epithelioid hemangioendothelioma") ,
#   domains = "Condition"
# )
#
# nsclc_stage4_orphan_codes <- findOrphanCodes(x = list("lung_cancer" = stage4_nsclungcancer_codes$concept_id),
#                                              cdm = cdm,
#                                              domains = "Condition",
#                                              standardConcept = "Standard",
#                                              searchInSynonyms = FALSE,
#                                              searchNonStandard = FALSE,
#                                              includeDescendants = TRUE,
#                                              includeAncestor = TRUE)


# smoking related phenotypes

# smoking_codes <- getCandidateCodes(
#   cdm = cdm,
#   keywords = c("smoking",
#                "smoker",
#                "tobacco",
#                "pipe",
#                "cigar"
#   ) ,
#   #exclude = c("non smoker") ,
#   domains = c("condition", "observation", "measurement")
# )
#
# write.csv(smoking_codes, here::here("preliminary_cohorts" , "other_cancers",
#                                     paste0(cdmName(cdm), "_smokingBroad.csv")), row.names = FALSE)
#
#
#

# Creating cohort files ------------

# read in reviewed list of codelists
reviewed_code_list <- read.csv(here::here("preliminary_cohorts" , "reviewed" ,
                                   paste0(cdmName(cdm), "_lungCancerBroad_reviewed.csv")))


# Broad lung cancer incidence
broad_inc <- reviewed_code_list %>%
  filter(broad_inc == "y") %>%
  pull(concept_id)

# narrow lung cancer incidence
narrow_inc <- reviewed_code_list %>%
  filter(narrow_inc == "y") %>%
  pull(concept_id)

# Broad lung cancer prevalence
broad_prev <- reviewed_code_list %>%
  filter(Broad_prev == "y") %>%
  pull(concept_id)

# narrow lung cancer prevalence
narrow_prev <- reviewed_code_list %>%
  filter(narrow_prev == "y") %>%
  pull(concept_id)

# small cell lung cancer
sclc <- reviewed_code_list %>%
  filter(SCLC == "y") %>%
  pull(concept_id)

# create cohorts
# 1 broad incidence
lung_cancer_incident_broad <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(broad_inc, name = "lung_cancer_broad_inc"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(lung_cancer_incident_broad, here::here("preliminary_cohorts",
                                                     "lung_cancer_incident_broad.json"))

# 2 narrow incidence
lung_cancer_incident_narrow <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(narrow_inc, name = "lung_cancer_narrow_inc"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(lung_cancer_incident_narrow, here::here("preliminary_cohorts",
                                                   "lung_cancer_incident_narrow.json"))


# 3 sclc incidence
small_cell_lung_cancer <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(sclc, name = "small_cell_lung_cancer"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(small_cell_lung_cancer, here::here("preliminary_cohorts",
                                                    "small_cell_lung_cancer.json"))


# 4 broad prev end
total_prev_lung_cancer_broad <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(broad_prev, name = "broad_lung_cancer_end"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(total_prev_lung_cancer_broad, here::here("preliminary_cohorts",
                                                     "broad_lung_cancer_end.json"))


# 5 broad prev 2 year
partial_prev2y_lung_cancer_broad <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(broad_prev, name = "broad_lung_cancer_2y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 720L)
  )
)

writeCohort(partial_prev2y_lung_cancer_broad, here::here("preliminary_cohorts",
                                                         "broad_lung_cancer_2y.json"))

# 6 broad prev 5 year
partial_prev5y_lung_cancer_broad <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(broad_prev, name = "broad_lung_cancer_5y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 1825L)
  )
)

writeCohort(partial_prev5y_lung_cancer_broad, here::here("preliminary_cohorts",
                                                         "broad_lung_cancer_5y.json"))

# 7 narrow prev end
total_prev_lung_cancer_narrow <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(narrow_prev, name = "narrow_lung_cancer_end"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(total_prev_lung_cancer_narrow, here::here("preliminary_cohorts",
                                                     "narrow_lung_cancer_end.json"))


# 8 narrow prev 2 year
partial_prev2y_lung_cancer_narrow <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(narrow_prev, name = "narrow_lung_cancer_2y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 720L)
  )
)

writeCohort(partial_prev2y_lung_cancer_narrow, here::here("preliminary_cohorts",
                                                         "narrow_lung_cancer_2y.json"))

# 9 narrow prev 5 year
partial_prev5y_lung_cancer_narrow <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(narrow_prev, name = "narrow_lung_cancer_5y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 1825L)
  )
)

writeCohort(partial_prev5y_lung_cancer_narrow, here::here("preliminary_cohorts",
                                                         "narrow_lung_cancer_5y.json"))

# 10 sclc prev 2 year
partial_prev2y_sclc <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(sclc, name = "sclc_2y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 720L)
  )
)

writeCohort(partial_prev2y_sclc, here::here("preliminary_cohorts",
                                                          "small_cell_lung_cancer_2y.json"))


# 11 sclc prev 5 year
partial_prev5y_sclc <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(sclc, name = "sclc_5y"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(fixedExit("startDate", 1825L)
  )
)

writeCohort(partial_prev5y_sclc, here::here("preliminary_cohorts",
                                                          "small_cell_lung_cancer_5y.json"))



# lung cancer plus stage ------
# lung cancer condition OR measurement - unable to get nested to work so will take the codes below and create in ATLAS

# broad stage 1
# lung_cancer_incident_broad_stage1 <- cohort(
#   entry = entry(
#     conditionOccurrence(getConceptSetDetails(cs(broad_inc, name = "lung_cancer_broad_stage_1"), db, vocabularyDatabaseSchema = "public")),
#
#     measurement(getConceptSetDetails(cs(stage1_codes$concept_id , name = "stage1"), db, vocabularyDatabaseSchema = "public")),
#     observationWindow = continuousObservation(0L, 0L),
#     primaryCriteriaLimit = "First"
#   ),
#   exit = exit(
#     endStrategy = observationExit()
#   )
# )
#
# writeCohort(lung_cancer_incident_broad_stage1, here::here("preliminary_cohorts",
#                                                    "lung_cancer_incident_broad_s1.json"))
#
#
# # broad stage 2
# lung_cancer_incident_broad_stage2 <- cohort(
#   entry = entry(
#     conditionOccurrence(getConceptSetDetails(cs(broad_inc, name = "lung_cancer_broad_stage_2"), db, vocabularyDatabaseSchema = "public")),
#     measurement(getConceptSetDetails(cs(stage2_codes$concept_id , name = "stage2"), db, vocabularyDatabaseSchema = "public")),
#     observationWindow = continuousObservation(0L, 0L),
#     primaryCriteriaLimit = "First"
#   ),
#   exit = exit(
#     endStrategy = observationExit()
#   )
# )
#
# writeCohort(lung_cancer_incident_broad_stage2, here::here("preliminary_cohorts",
#                                                           "lung_cancer_incident_broad_s2.json"))
#
#
#
# # broad stage 3
# lung_cancer_incident_broad_stage3 <- cohort(
#   entry = entry(
#     conditionOccurrence(getConceptSetDetails(cs(broad_inc, name = "lung_cancer_broad_stage_3"), db, vocabularyDatabaseSchema = "public")),
#     measurement(getConceptSetDetails(cs(stage3_codes$concept_id , name = "stage3"), db, vocabularyDatabaseSchema = "public")),
#     observationWindow = continuousObservation(0L, 0L),
#     primaryCriteriaLimit = "First"
#   ),
#   exit = exit(
#     endStrategy = observationExit()
#   )
# )
#
# writeCohort(lung_cancer_incident_broad_stage3, here::here("preliminary_cohorts",
#                                                           "lung_cancer_incident_broad_s3.json"))
#
#
#
# # broad stage 4
# lung_cancer_incident_broad_stage4 <- cohort(
#   entry = entry(
#     conditionOccurrence(getConceptSetDetails(cs(broad_inc, name = "lung_cancer_broad_stage_4"), db, vocabularyDatabaseSchema = "public")),
#     measurement(getConceptSetDetails(cs(stage4_codes$concept_id , name = "stage4"), db, vocabularyDatabaseSchema = "public")),
#     observationWindow = continuousObservation(0L, 0L),
#     primaryCriteriaLimit = "First"
#   ),
#   exit = exit(
#     endStrategy = observationExit()
#   )
# )
#
# writeCohort(lung_cancer_incident_broad_stage4, here::here("preliminary_cohorts",
#                                                           "lung_cancer_incident_broad_s4.json"))
#

# smoking status
reviewed_code_list_smoking <- read.csv(here::here("preliminary_cohorts" , "reviewed" ,
                                          paste0(cdmName(cdm), "_smokingBroad_reviewed.csv")))


# smoker
smoker_obs <- reviewed_code_list_smoking %>%
  filter(Smoker == "y" &
           domain_id == "Observation" ) %>%
  pull(concept_id)

smoker_cond <- reviewed_code_list_smoking %>%
  filter(Smoker == "y" &
           domain_id == "Condition" ) %>%
  pull(concept_id)

# previous smoker
pre_smoker_obs <- reviewed_code_list_smoking %>%
  filter(Previous.smoker == "y" &
           domain_id == "Observation" ) %>%
  pull(concept_id)

pre_smoker_cond <- reviewed_code_list_smoking %>%
  filter(Previous.smoker == "y" &
           domain_id == "Condition" ) %>%
  pull(concept_id)

#non smoker
non_smoker_obs <- reviewed_code_list_smoking %>%
  filter(non.smoker == "y" &
           domain_id == "Observation" ) %>%
  pull(concept_id)

non_smoker_cond <- reviewed_code_list_smoking %>%
  filter(non.smoker == "y" &
           domain_id == "Condition" ) %>%
  pull(concept_id)


# smoker
smoker <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(smoker_cond, name = "smoker_cond"), db, vocabularyDatabaseSchema = "public")),
    observation(getConceptSetDetails(cs(smoker_obs , name = "smoker_obs"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(smoker, here::here("preliminary_cohorts", "smoker.json"))


# former smoker
prev_smoker <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(pre_smoker_cond, name = "prev_smoker_cond"), db, vocabularyDatabaseSchema = "public")),
    observation(getConceptSetDetails(cs(pre_smoker_obs , name = "prev_smoker_obs"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(prev_smoker, here::here("preliminary_cohorts", "prev_smoker.json"))

# non smoker
non_smoker <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(non_smoker_cond, name = "non_smoker_cond"), db, vocabularyDatabaseSchema = "public")),
    observation(getConceptSetDetails(cs(non_smoker_obs , name = "non_smoker_obs"), db, vocabularyDatabaseSchema = "public")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(non_smoker, here::here("preliminary_cohorts", "non_smoker.json"))
