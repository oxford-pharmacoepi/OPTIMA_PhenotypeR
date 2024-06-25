# Manage project dependencies ------
# the following will prompt you to install the various packages used in the study
# install.packages("renv")
# renv::activate()
renv::restore()

# packages ---
library(readr)
library(RSQLite)
library(here)
library(duckdb)
library(Capr)
library(DBI)
library(CDMConnector)
library(dplyr)
library(tidyr)
library(CodelistGenerator)
library(ggplot2)

# get the local vocabs
source(here("local_vocab.R"))


# check vocab version
# getVocabVersion(cdm = cdm)

# get cohort concept vocabs
#getConceptClassId(cdm, standardConcept = "Standard")

# Broad lung cancer including cancers of trachea and bronchus and lower respiratory tract
lungcancer_codes <- getCandidateCodes(
  cdm = cdm,
  keywords = c("malignant neoplasm of lung",
               "malignant neoplasm of trachea",
               "Primary malignant neoplasm of bronchus",
               "neoplasm of lung",
               "neoplasm of trachea",
               "malignant neoplasm of bronchus",
               "Oat cell carcinoma of lung",
               "Oat cell carcinoma of trachea",
               "Oat cell carcinoma of main bronchus" ,
               "malignant neoplasm of lower respiratory tract") ,
  domains = c("Condition", "Observation"),
  standardConcept = "Standard",
  searchInSynonyms = FALSE,
  searchNonStandard = FALSE,
  includeDescendants = TRUE,
  includeAncestor = FALSE
)


write.csv(lungcancer_codes, here::here("preliminary_cohorts" ,
                                       paste0("broad_lungCancer.csv")), row.names = FALSE)



# Breast cancer
breastcancer_codes <- getCandidateCodes(
  cdm = cdm,
  keywords = c("malignant neoplasm of breast",
               "neoplasm of breast") ,
  domains = c("Condition", "Observation"),
  standardConcept = "Standard",
  searchInSynonyms = FALSE,
  searchNonStandard = FALSE,
  includeDescendants = TRUE,
  includeAncestor = FALSE
)

write.csv(breastcancer_codes, here::here("preliminary_cohorts" ,
                                       paste0("broad_breastCancer.csv")), row.names = FALSE)



# prostate
prostatecancer_codes <- getCandidateCodes(
  cdm = cdm,
  keywords = c("malignant neoplasm of prostate",
               "neoplasm of prostate") ,
  domains = c("Condition", "Observation"),
  standardConcept = "Standard",
  searchInSynonyms = FALSE,
  searchNonStandard = FALSE,
  includeDescendants = TRUE,
  includeAncestor = FALSE
)

write.csv(prostatecancer_codes, here::here("preliminary_cohorts" ,
                                         paste0("broad_prostateCancer.csv")), row.names = FALSE)




# Creating cohort files ------------
# read in list of codelists for all three cancers
breastcancer_codes <- read.csv(here::here("preliminary_cohorts"  ,
                                          paste0("broad_breastCancer.csv")))
lungcancer_codes <- read.csv(here::here("preliminary_cohorts"  ,
                                          paste0("broad_lungCancer.csv")))
prostatecancer_codes <- read.csv(here::here("preliminary_cohorts"  ,
                                          paste0("broad_prostateCancer.csv")))

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

# lung cancer plus stage ------

# smoker
smoker_obs <- reviewed_code_list_smoking %>%
  filter(Smoker == "y" &
           domain_id == "Observation" ) %>%
  pull(concept_id)

smoker_cond <- reviewed_code_list_smoking %>%
  filter(Smoker == "y" &
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
