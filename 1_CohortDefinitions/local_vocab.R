# Build local vocabulary database
library(readr)
library(DBI)
library(RSQLite)
library(here)

vocab.folder <- Sys.getenv("VOCAB_PATH") # path to directory of unzipped files
concept <- read_delim(paste0(vocab.folder, "/CONCEPT.csv"),
                      "\t",
                      escape_double = FALSE, trim_ws = TRUE
)
concept_relationship <- read_delim(paste0(vocab.folder, "/CONCEPT_RELATIONSHIP.csv"),
                                   "\t",
                                   escape_double = FALSE, trim_ws = TRUE
)
concept_ancestor <- read_delim(paste0(vocab.folder, "/CONCEPT_ANCESTOR.csv"),
                               "\t",
                               escape_double = FALSE, trim_ws = TRUE
)
concept_synonym <- read_delim(paste0(vocab.folder, "/CONCEPT_SYNONYM.csv"),
                              "\t",
                              escape_double = FALSE, trim_ws = TRUE
)
vocabulary <- read_delim(paste0(vocab.folder, "/VOCABULARY.csv"), "\t",
                         escape_double = FALSE, trim_ws = TRUE
)
db <- dbConnect(duckdb::duckdb(paste0(vocab.folder,"/vocab.duckdb")))
dbWriteTable(db, "concept", concept, overwrite = TRUE)
dbWriteTable(db, "concept_relationship", concept_relationship, overwrite = TRUE)
dbWriteTable(db, "concept_ancestor", concept_ancestor, overwrite = TRUE)
dbWriteTable(db, "concept_synonym", concept_synonym, overwrite = TRUE)
dbWriteTable(db, "vocabulary", vocabulary)
dbExecute(db, "CREATE UNIQUE INDEX idx_concept_concept_id ON concept (concept_id)")
dbExecute(db, "CREATE INDEX idx_concept_relationship_id_1 ON concept_relationship (concept_id_1, concept_id_2)")
dbExecute(db, "CREATE INDEX idx_concept_ancestor_id_1 ON concept_ancestor (ancestor_concept_id)")
dbExecute(db, "CREATE INDEX idx_concept_ancestor_id_2 ON concept_ancestor (descendant_concept_id)")
dbExecute(db, "CREATE INDEX idx_concept_synonym_id ON concept_synonym (concept_id)")
rm(concept, concept_relationship, concept_ancestor, concept_synonym)

# so that we can create a cdm
person_cols <- omopgenerics::omopColumns("person")
person <- data.frame(matrix(ncol = length(person_cols), nrow = 0))
colnames(person) <- person_cols

observation_period_cols <- omopgenerics::omopColumns("observation_period")
observation_period <- data.frame(matrix(ncol = length(observation_period_cols), nrow = 0))
colnames(observation_period) <- observation_period_cols

DBI::dbWithTransaction(db, {
  DBI::dbWriteTable(db, "person",
                    person,
                    overwrite = TRUE
  )
})

DBI::dbWithTransaction(db, {
  DBI::dbWriteTable(db, "observation_period",
                    observation_period,
                    overwrite = TRUE
  )
})

rm(person, observation_period)

# create cdm reference ----
cdm <- CDMConnector::cdm_from_con(con = db, cdm_schema = "main", write_schema="main")

