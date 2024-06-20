# Get data ----
# All potential outputs
result_names <- c("cohort_definitions", "cohort_count", "code_counts", "cohort_overlap", 
                  "age_distribution", "time_distribution", "prevalence", "incidence", 
                  "index_events", "lsc_sample", "lsc_matched", "lsc_difference", "log",
                  "cdm_snapshot")


  
  # Load, prepare, and merge results -----
# see what type of file it is
tryCatch({
  results <- list.files(here("data"), full.names = TRUE,
                        recursive = TRUE,
                        include.dirs = TRUE,
                        pattern = ".zip")
}, error = function(e) {
  # Handle the error here, you can print a message or take other actions
  print(paste("An error occurred:", e))
  # Assign an empty list to results or any other default value you prefer
  results <- NULL
})

if(length(results) > 0){

#unzip data
for (i in (1:length(results))) {
  utils::unzip(zipfile = results[[i]],
               exdir = here("data"))
}

#grab the results from the folders
result_files <- list.files(
  path = here("data"),
  pattern = ".csv",
  full.names = TRUE,
  recursive = TRUE,
  include.dirs = TRUE
)

data <- vector("list", length(result_names)) |> setNames(result_names)

# Read files and join equal outputs
# read in the files we need and read them into the data
# cohort definitions
# cohort_definitions_files<-result_files[stringr::str_detect(result_files, ".csv")]
# cohort_definitions_files<-result_files[stringr::str_detect(result_files, "cohort_definitions")]
# 
# cohort_definitions_estimates <- list()
# for(i in seq_along(cohort_definitions_files)){
#   cohort_definitions_estimates[[i]]<-readr::read_csv(cohort_definitions_files[[i]], 
#                                              show_col_types = FALSE)  
# }
# 
# data$cohort_definitions <- bind_rows(cohort_definitions_estimates)

cohort_set <- CDMConnector::read_cohort_set(here::here(
  "Cohorts" ))

cohort_set$markdown <- ""

for (n in  row_number(cohort_set) ) {
  
  cohort <- cohort_set$cohort_name[n]  
  json <- paste0(cohort_set$json[n]  )
  cohortExpresion <- CirceR::cohortExpressionFromJson(json)
  markdown <- CirceR::cohortPrintFriendly(cohortExpresion)
  cohort_set$markdown[n] <-  markdown
  
} 

data$cohort_definitions <- cohort_set

# cohort count
cohort_count_files<-result_files[stringr::str_detect(result_files, ".csv")]
cohort_count_files<-result_files[stringr::str_detect(result_files, "cohort_count")]

cohort_count_estimates <- list()
for(i in seq_along(cohort_count_files)){
  cohort_count_estimates[[i]]<-readr::read_csv(cohort_count_files[[i]], 
                                                     show_col_types = FALSE)  
}

data$cohort_count <- bind_rows(cohort_count_estimates)

# code counts
code_count_files<-result_files[stringr::str_detect(result_files, ".csv")]
code_count_files<-result_files[stringr::str_detect(result_files, "code_count")]

code_count_estimates <- list()
for(i in seq_along(code_count_files)){
  code_count_estimates[[i]]<-readr::read_csv(code_count_files[[i]], 
                                               show_col_types = FALSE)  
}

data$code_counts <- bind_rows(code_count_estimates)

# cohort overlap
code_overlap_files<-result_files[stringr::str_detect(result_files, ".csv")]
code_overlap_files<-result_files[stringr::str_detect(result_files, "code_overlap")]

code_overlap_estimates <- list()
for(i in seq_along(code_overlap_files)){
  code_overlap_estimates[[i]]<-readr::read_csv(code_overlap_files[[i]], 
                                             show_col_types = FALSE)  
}

data$code_overlap <- bind_rows(code_overlap_estimates)

# age distribution
age_distribution_files<-result_files[stringr::str_detect(result_files, ".csv")]
age_distribution_files<-result_files[stringr::str_detect(result_files, "age_distribution")]

age_distribution_estimates <- list()
for(i in seq_along(age_distribution_files)){
  age_distribution_estimates[[i]]<-readr::read_csv(age_distribution_files[[i]], 
                                               show_col_types = FALSE)  
}

data$age_distribution <- bind_rows(age_distribution_estimates)

# time distribution
time_distribution_files<-result_files[stringr::str_detect(result_files, ".csv")]
time_distribution_files<-result_files[stringr::str_detect(result_files, "time_distribution")]

time_distribution_estimates <- list()
for(i in seq_along(time_distribution_files)){
  time_distribution_estimates[[i]]<-readr::read_csv(time_distribution_files[[i]], 
                                                   show_col_types = FALSE)  
}

data$time_distribution <- bind_rows(time_distribution_estimates)

# cohort definitions
cohort_overlap_files<-result_files[stringr::str_detect(result_files, ".csv")]
cohort_overlap_files<-result_files[stringr::str_detect(result_files, "cohort_overlap")]

cohort_overlap_estimates <- list()
for(i in seq_along(cohort_overlap_files)){
  cohort_overlap_estimates[[i]]<-readr::read_csv(cohort_overlap_files[[i]], 
                                                     show_col_types = FALSE)  
}

data$cohort_overlap <- bind_rows(cohort_overlap_estimates)

# prevalence
prevalence_files<-result_files[stringr::str_detect(result_files, ".csv")]
prevalence_files<-result_files[stringr::str_detect(result_files, "prevalence")]

prevalence_estimates <- list()
for(i in seq_along(prevalence_files)){
  prevalence_estimates[[i]]<-readr::read_csv(prevalence_files[[i]], 
                                                    show_col_types = FALSE)  
}

data$prevalence <- bind_rows(prevalence_estimates)

# incidence
incidence_files<-result_files[stringr::str_detect(result_files, ".csv")]
incidence_files<-result_files[stringr::str_detect(result_files, "/incidence_")]

incidence_estimates <- list()
for(i in seq_along(incidence_files)){
  incidence_estimates[[i]]<-readr::read_csv(incidence_files[[i]],
                                             show_col_types = FALSE)
}

data$incidence <- bind_rows(incidence_estimates)

# index events
index_events_files<-result_files[stringr::str_detect(result_files, ".csv")]
index_events_files<-result_files[stringr::str_detect(result_files, "index_events")]

index_events_estimates <- list()
for(i in seq_along(index_events_files)){
  index_events_estimates[[i]]<-readr::read_csv(index_events_files[[i]], 
                                            show_col_types = FALSE)  
}

data$index_events <- bind_rows(index_events_estimates)

# lsc sample
lsc_sample_files<-result_files[stringr::str_detect(result_files, ".csv")]
lsc_sample_files<-result_files[stringr::str_detect(result_files, "lsc_sample")]

lsc_sample_estimates <- list()
for(i in seq_along(lsc_sample_files)){
  lsc_sample_estimates[[i]]<-readr::read_csv(lsc_sample_files[[i]], 
                                               show_col_types = FALSE)  
}

data$lsc_sample <- bind_rows(lsc_sample_estimates)

# lsc matched
lsc_matched_files<-result_files[stringr::str_detect(result_files, ".csv")]
lsc_matched_files<-result_files[stringr::str_detect(result_files, "lsc_matched")]

lsc_matched_estimates <- list()
for(i in seq_along(lsc_matched_files)){
  lsc_matched_estimates[[i]]<-readr::read_csv(lsc_matched_files[[i]], 
                                             show_col_types = FALSE)  
}

data$lsc_matched <- bind_rows(lsc_matched_estimates)

# lsc difference
lsc_difference_files<-result_files[stringr::str_detect(result_files, ".csv")]
lsc_difference_files<-result_files[stringr::str_detect(result_files, "lsc_difference")]

lsc_difference_estimates <- list()
for(i in seq_along(lsc_difference_files)){
  lsc_difference_estimates[[i]]<-readr::read_csv(lsc_difference_files[[i]], 
                                              show_col_types = FALSE)  
}

data$lsc_difference <- bind_rows(lsc_difference_estimates)

# log
log_files<-result_files[stringr::str_detect(result_files, ".csv")]
log_files<-result_files[stringr::str_detect(result_files, "log")]

log_estimates <- list()
for(i in seq_along(log_files)){
  log_estimates[[i]]<-readr::read_csv(log_files[[i]], 
                                                 show_col_types = FALSE)  
}

data$log <- bind_rows(log_estimates)

# cdm snapshot
cdm_snapshot_files<-result_files[stringr::str_detect(result_files, ".csv")]
cdm_snapshot_files<-result_files[stringr::str_detect(result_files, "cdm_snapshot")]

cdm_snapshot_estimates <- list()
for(i in seq_along(cdm_snapshot_files)){
  cdm_snapshot_estimates[[i]]<-readr::read_csv(cdm_snapshot_files[[i]], 
                                      show_col_types = FALSE)  %>% 
    mutate(cdm_version = as.character(cdm_version)) 
}

data$cdm_snapshot <- bind_rows(cdm_snapshot_estimates)




} else {

# Result files
result_files <- list.files(path = here(dataFolder), pattern = ".RData")

# Read files and join equal outputs
data <- vector("list", length(result_names)) |> setNames(result_names)
settings <- NULL
for (file in result_files) {
  x <- load(here(dataFolder, file))
  settings <- settings %>%  union_all(bind_rows(input))
  for (resName in result_names) {
    if (!is.null(output[[resName]])) {
      if (nrow(output[[resName]]) > 0) {
        eval(parse(text = paste0("data$", resName, " <- data$", resName, " %>% union_all(output$", resName, ")")))
        
      }
    }
  }
  rm(list = x)
}
rm(x)

}

# Tranform data for shiny ----
# Orphan code counts
data$orphan_counts <- data$code_counts %>% 
  filter(strata_name == "recomendation") %>% 
  ungroup()  %>% 
  distinct() %>% 
  mutate(standard_concept_name = substr(additional_level, 1,
                                        unlist(gregexpr(';', additional_level))-2)) %>% 
  pivot_wider(names_from = variable_name, values_from = estimate_value) %>% 
  select("cdm_name", "cohort", "relationship_id",
         "standard_concept_id", "standard_concept_name", "Record count", "Person count")
# Code counts
data$code_counts <- data$code_counts %>% 
  filter(strata_name == "original_codes") %>% 
  ungroup()  %>% 
  distinct() %>% 
  mutate(standard_concept_name = substr(additional_level, 1,
                                        unlist(gregexpr(';', additional_level))-2)) %>% 
  pivot_wider(names_from = variable_name, values_from = estimate_value) %>% 
  select("cdm_name", "cohort", 
         "standard_concept_id", "standard_concept_name", "Record count", "Person count")
# Index events
data$index_events <- data$index_events %>% 
  pivot_wider(names_from = variable_name, values_from = estimate) %>% 
  select(cdm_name, cohort_name, codelist_name, group_name, group_level, standard_concept_id, standard_concept_name, 
         source_concept_name, source_concept_id, domain_id,  
         cdm_name, `Record count`, `Person count`)


# Cohort overlap
data$cohort_overlap <- data$cohort_overlap %>%
  ungroup() %>%
  inner_join(data$cohort_count %>%
               select(cdm_name,
                      cohort_definition_id_x = cohort_definition_id,
                      cohort_name_x = cohort_name,
                      subject_counts_x = number_subjects),
             by = c("cdm_name", "cohort_definition_id_x")) %>%
  inner_join(data$cohort_count %>%
               select(cdm_name,
                      cohort_definition_id_y = cohort_definition_id,
                      cohort_name_y = cohort_name,
                      subject_counts_y = number_subjects),
             by = c("cdm_name", "cohort_definition_id_y")) %>%
  mutate(
    intersect_counts = as.integer(intersect_count)) %>%
  select(-intersect_count)


# # Age distribution
data$age_distribution <- data$age_distribution %>%
  ungroup() %>%
  inner_join(data$cohort_count %>% select(cdm_name, cohort_definition_id, cohort_name)) %>%
  select(-cohort_definition_id)
# Time distribution
to_pivot <- colnames(data$time_distribution)[!colnames(data$time_distribution) %in%
                                               c("sex", "cohort_name", "cdm_name", "cohort_definition_id")]
data$time_distribution <- tibble(covariate = c("age", "prior_observation", "future_observation")) %>%
  left_join(
    data$time_distribution %>%
      ungroup() %>%
      inner_join(data$cohort_count %>% select(cdm_name, cohort_definition_id, cohort_name)) %>%
      select(-cohort_definition_id) %>%
      mutate(across(tidyr::everything(), ~ as.character(.x))) %>%
      pivot_longer(cols = to_pivot, values_to = "estimate_value") %>%
      mutate(
        estimate_type = case_when(
          grepl("Min", name) ~ "min",
          grepl("Max", name) ~ "max",
          grepl("Median", name) ~ "median",
          grepl("Mean", name) ~ "mean",
          grepl("Sd", name) ~ "sd",
        ),
        covariate = gsub("_Min|_Max|_Median|_Sd|_Mean", "", name),
        estimate_value = niceNum(estimate_value, 3)
      ) %>%
      select(-name)
  ) %>%
  select(cdm_name, cohort_name, sex, covariate, estimate_type, estimate_value)



# LSC
data$lsc_table <- data$lsc_matched %>%
  mutate(
    estimate_type = paste0("matched_", estimate_type),
    estimate = as.numeric(estimate_value)
  ) %>%
  pivot_wider(id_cols = !c("estimate_name", "estimate_value"),
    names_from = estimate_type, 
              values_from = estimate) %>%
  left_join(
    data$lsc_sample %>%
      mutate(
        estimate_type = paste0("sample_", estimate_type),
        estimate = as.numeric(estimate_value)
      ) %>%
      pivot_wider(id_cols = !c("estimate_name", "estimate_value"),
        names_from = estimate_type, 
                  values_from = estimate)) %>%
  mutate(
    difference_integer = (sample_integer - matched_integer)/matched_integer,
    difference_percentage = (sample_percentage - matched_percentage)/matched_percentage
  ) %>%
  select(
    cdm_name, cohort_name = group_level, concept_name = variable_name,
    window = variable_level, matched_integer, matched_percentage, sample_integer, sample_percentage,
    difference_integer, difference_percentage
  )

cohort_set <- data$cohort_definitions

# Shiny theme ----
DUtheme <- create_theme(
  adminlte_color(
    light_blue = "#0c0e0c" 
  ),
  adminlte_sidebar(
    # width = "400px",
    dark_bg = "#78B7C5",
    dark_hover_bg = "#3B9AB2",
    dark_color = "white"
  ), 
  adminlte_global(
    content_bg = "#eaebea" 
  ),
  adminlte_vars(
    border_color = "#112446",
    active_link_hover_bg = "#FFF",
    active_link_hover_color = "#112446",
    active_link_hover_border_color = "#112446",
    link_hover_border_color = "#112446"
  )
)
