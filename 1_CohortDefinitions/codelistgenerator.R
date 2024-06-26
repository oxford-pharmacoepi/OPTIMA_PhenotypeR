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
               "Malignant neoplasm of middle lobe of lung",
               "neoplasm of lung",
               "neoplasm of trachea",
               "neoplasm of bronchus",
               "malignant neoplasm of bronchus",
               "Oat cell carcinoma of lung",
               "Oat cell carcinoma of trachea",
               "Oat cell carcinoma of main bronchus" ,
               "malignant neoplasm of lower respiratory tract") ,
  exclude = c("family history", "FH") ,
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
               "paget's disease, mammary",
               "paget's disease and intraductal carcinoma of breast",
               "lymphoedema following breast cancer",
               "neoplasm of breast") ,
  domains = c("Condition", "Observation"),
  exclude = c("family history", "FH") ,
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
  exclude = c("family history", "FH") ,
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

# create cohorts -----------
# breast cancer
breast_obs <- breastcancer_codes %>%
  filter(domain_id == "Observation" ) %>%
  pull(concept_id)

breast_cond <- breastcancer_codes %>%
  filter(domain_id == "Condition" ) %>%
  pull(concept_id)


#
breastcancer <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(breast_cond, name = "breast_cond"), db, vocabularyDatabaseSchema = "main")),
    observation(getConceptSetDetails(cs(breast_obs , name = "breast_obs"), db, vocabularyDatabaseSchema = "main")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "All"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(breastcancer, here::here("preliminary_cohorts", "breastcancer.json"))



# lung cancer
lung_obs <- lungcancer_codes %>%
  filter(domain_id == "Observation" ) %>%
  pull(concept_id)

lung_cond <- lungcancer_codes %>%
  filter(domain_id == "Condition" ) %>%
  pull(concept_id)

#adding additional concepts (if we include them in codelist generator it includes all the
#descendants which covers head and neck cancer which we dont want)

lung_cond <- c(lung_cond, 4311499, 4317685)

#
lungcancer <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(lung_cond, name = "lung_cond"), db, vocabularyDatabaseSchema = "main")),
    observation(getConceptSetDetails(cs(lung_obs , name = "lung_obs"), db, vocabularyDatabaseSchema = "main")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "All"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(lungcancer, here::here("preliminary_cohorts", "lungcancer.json"))


# prostate cancer
prostate_obs <- prostatecancer_codes %>%
  filter(domain_id == "Observation" ) %>%
  pull(concept_id)

prostate_cond <- prostatecancer_codes %>%
  filter(domain_id == "Condition" ) %>%
  pull(concept_id)


#
prostatecancer <- cohort(
  entry = entry(
    conditionOccurrence(getConceptSetDetails(cs(prostate_cond, name = "prostate_cond"), db, vocabularyDatabaseSchema = "main")),
    observation(getConceptSetDetails(cs(prostate_obs , name = "prostate_obs"), db, vocabularyDatabaseSchema = "main")),
    observationWindow = continuousObservation(0L, 0L),
    primaryCriteriaLimit = "All"
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

writeCohort(prostatecancer, here::here("preliminary_cohorts", "prostatecancer.json"))
