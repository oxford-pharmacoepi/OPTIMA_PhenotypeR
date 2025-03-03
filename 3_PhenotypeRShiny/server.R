server <- function(input, output, session) { 
  # Markdown ----
  output$markdown <- renderUI({
    
    table <- cohort_set %>% 
      filter(cohort_name %in% input$cohort_set_input) %>% 
      distinct(cohort, .keep_all = TRUE) %>% 
      pull(markdown) %>% 
      formatMarkdown()
  })

  output$downloadBreastCancerjson <- downloadHandler(
    filename = function() {
      "breastcancer.json"
    },
    content = function(file) {
      file.copy("www/Cohorts/breastcancer.json", file)
    }
  )
  
  output$downloadLungCancerjson <- downloadHandler(
    filename = function() {
      "lungcancer.json"
    },
    content = function(file) {
      file.copy("www/Cohorts/lungcancer.json", file)
    }
  )
  
  output$downloadProstateCancerjson <- downloadHandler(
    filename = function() {
      "prostatecancer.json"
    },
    content = function(file) {
      file.copy("www/Cohorts/prostatecancer.json", file)
    }
  )
  
  
  
  output$downloadBreastCancer <- downloadHandler(
    filename = function() {
      "breast_cancer.docx"
    },
    content = function(file) {
      file.copy("www/breast_cancer.docx", file)
    }
  )
  
  output$downloadLungCancer <- downloadHandler(
    filename = function() {
      "lung_cancer.docx"
    },
    content = function(file) {
      file.copy("www/lung_cancer.docx", file)
    }
  )
  
  output$downloadProstateCancer <- downloadHandler(
    filename = function() {
      "prostate_cancer.docx"
    },
    content = function(file) {
      file.copy("www/prostate_cancer.docx", file)
    }
  )

  
  # Cohort counts ----
  output$tidy_counts <- renderDataTable({
    datatable(
      filterData(data$cohort_count, "counts", input) %>% 
        select(cdm_name, cohort_name, number_records, number_subjects) %>% 
        niceColumnNames(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  })
  # Code counts ----
  getCodeCount <- reactive({
    filterData(data$code_counts, "code_counts", input) %>% 
      niceColumnNames() %>% 
      mutate(`Record count` = as.integer(`Record count`),
             `Person count` = as.integer(`Person count`)) %>% 
      arrange(desc(`Person count`)) %>% 
      select(input$select_code_count_columns)
  })
  output$tidy_code_counts <- renderDataTable({
    datatable(
      getCodeCount(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  })
  
  #concepts_sets ----
  get_concepts_sets <- reactive({
    
    validate(
      need(input$cohort_set_input != "", "Please select a cohort")
    )
    
    table <- concept_sets_final %>% 
      filter(name %in% input$cohort_set_input) 
    
    table
    
  })
  
  
  output$tbl_concept_sets <- DT::renderDataTable({
    DT::datatable(get_concepts_sets(), 
                  options = list(scrollX = TRUE))
  })
  

  output$dt_concept_sets_word <- downloadHandler(
    filename = function() {
      "concept_sets.docx"
    },
    content = function(file) {
      x <- gt(get_concepts_sets())
      gtsave(x, file)
    }
  )
  
  # snapshot
  output$cdm_snapshot_tidy <- renderDataTable({
    datatable(data$cdm_snapshot,
              rownames= FALSE,
              extensions = 'Buttons',
              options = list(lengthChange = FALSE,
                             dom = 'tB',
                             pageLength = 100000000,
                             buttons = list(list(extend = "csv", 
                                                 text = "Download results as csv",
                                                 filename = "cdm_snapshot"))
              ))
  })
  
  
  # Orphan counts ----
  getOrphanCount <- reactive({
    filterData(data$orphan_counts, "orphan", input) %>% 
      niceColumnNames() %>% 
      # mutate(`Record count` = as.integer(`Record count`),
      #        `Person count` = as.integer(`Person count`)) %>% 
      arrange(desc(as.integer(`Person count`))) %>% 
      select(input$select_orphan_count_columns)
  })
  output$tidy_orphan_counts <- renderDataTable({
    datatable(
      getOrphanCount(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  })
  
  # Index date ----
  getIndexDate <- reactive({
    filterData(data$index_events, "index", input) %>% 
      mutate(`Record count` = as.integer(`Record count`),
             `Person count` = as.integer(`Person count`)) %>% 
      arrange(desc(`Person count`)) %>% 
      niceColumnNames() %>% 
      select(input$select_index_columns)
  })
  output$index_date_tidy <- renderDataTable({
    datatable(
      getIndexDate(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  })
  
  # Overlap ----

  getOverlapTable <- reactive({
    
    validate(
      need(data$cohort_overlap, "No cohort overlap carried out", "No cohort overlap carried out")
    )
    
    
    filterData(data$cohort_overlap, "overlap", input) %>% 
      mutate(
        total_counts = subject_counts_x + subject_counts_y,
        intersect_percentage = intersect_counts*2/total_counts * 100,
        subject_percentage_x = (subject_counts_x-intersect_counts)/total_counts * 100,
        subject_percentage_y = (subject_counts_y-intersect_counts)/total_counts * 100,
        subject_counts_only_in_x = paste0(niceNum(subject_counts_x-intersect_counts), " (", niceNum(subject_percentage_x), "%)"),
        subject_counts_only_in_y = paste0(niceNum(subject_counts_y-intersect_counts), " (", niceNum(subject_percentage_y), "%)"),
        intersect_counts = paste0(niceNum(intersect_counts), " (", niceNum(intersect_percentage), "%)")
      ) %>% 
      select(cdm_name, cohort_name_x, cohort_name_y, subject_counts_only_in_x, subject_counts_only_in_y, intersect_counts) %>% 
      niceColumnNames() %>% 
     distinct(`Intersect counts`, .keep_all = TRUE)
    
  })


  output$overlap_tidy <- renderDataTable({
    
    datatable(
      getOverlapTable(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  
  })
  

  
  getOverlapPlot <- reactive({
      
    filterData(data$cohort_overlap, "overlap", input) %>% 
      mutate(
        total_counts = subject_counts_x + subject_counts_y - intersect_counts,
        intersect_percentage = intersect_counts/total_counts * 100,
        subject_percentage_x = subject_counts_x/total_counts * 100,
        subject_percentage_y = subject_counts_y/total_counts * 100,
        total_percentage = 100,
        comparison_name = paste0(cohort_name_x, "; ", cohort_name_y)
      ) %>% 
    distinct(intersect_percentage, .keep_all = TRUE)
  })
  
  output$overlap_plot <- renderPlotly({
    table <- getOverlapPlot() 
    table$y_pos <- seq(0, nrow(table)-1, 1) 
    type <- tolower(input$plot_overlap_type)
    if (type == "percentage") {
      x_breaks <- c(0, 25, 50, 75, 100)
      x_labels <- c("0%", "25%", "50%", "75%", "100%")
    } else {
      x_breaks <- round(c(0, max(table$total_counts)/4, max(table$total_counts)/2,
                          max(table$total_counts)*3/4, max(table$total_counts)))
      x_labels <- x_breaks
    }
    table %>% 
      ggplot() + 
      # x
      geom_rect(aes_string(xmin = 0, xmax = paste0("subject_", type, "_x"), 
                           ymin = "y_pos-0.35", ymax = "y_pos+0.35"),
                fill = "#669bbc", alpha = 0.5) +
      # y
      geom_rect(aes_string(xmin = paste0("total_", type, "-subject_", type, "_y"), 
                           xmax = paste0("total_", type), 
                           ymin = "y_pos-0.35", ymax = "y_pos+0.35"),
                fill = "#cd5d67", alpha = 0.4) +
      scale_y_continuous(breaks = table$y_pos, labels = table$comparison_name) +
      scale_x_continuous(breaks = x_breaks, labels = x_labels, limits = c(0, NA)) +
      theme_bw() +
      theme(axis.text.y = element_text(size = 12),
            axis.text.x = element_text(size = 11)) +
      facet_wrap(vars(cdm_name)) +
      geom_col(data = tibble("CohortX" = 0, "CohortY" = 0, to_fill = c("Cohort X", "Cohort Y", "Overlap")),
                 aes_string(x = "CohortX", y = "CohortY", fill = "to_fill")) +
      scale_fill_manual(
        "Legend",
        # breaks = c("Cohort X", "Cohort Y"),
        values=c('#B6CDDE', '#E7BEC2', "#BBA0AE"),
        labels = c('Cohort X', 'Cohort Y', "Overlap") 
      ) +
      guides(fill = guide_legend(order = 3, override.aes = list(fill = c('#B6CDDE', '#E7BEC2', "#BBA0AE")))) +
      ylab("") + xlab("")
  
  })
  
  
  # Age ----
  getAgeDistribution <- reactive({
    filterData(data$age_distribution, "age", input) %>% 
      select(age_group, sex, cdm_name, cohort_name, n) %>% 
      niceColumnNames() %>% 
      arrange(Sex) 
  })
  output$age_tidy_table <- renderDataTable({
    datatable(
      getAgeDistribution(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    ) 
  })
  # Time ----
  getTimeDistribution <- reactive({
    filterData(data$time_distribution, "time", input) %>% 
      niceColumnNames()
  })
  output$time_tidy_table <- renderDataTable({
    datatable(
      getTimeDistribution(),
      rownames = FALSE,
      extensions = "Buttons",
      options = list(scrollX = TRUE, scrollCollapse = TRUE)
    )
  })
  # Prevalence ----
  output$prevalence_table <- renderDataTable({
    datatable(
      filterData(data$prevalence, "prevalence", input) %>% 
        niceColumnNames() %>% 
        select(input$select_prevalence_columns),
    options = list(
      scrollX = TRUE, 
      scrollCollapse = TRUE,
      lengthChange = FALSE, 
      searching = FALSE, 
      ordering = FALSE, 
      paging = FALSE
    )
  )
  })
  output$prevalence_plot <- renderPlotly({
    table <- filterData(data$prevalence, "prevalence", input) 
    
    validate(need(ncol(table)>1, 
                  "No results for selected inputs"))
    
    if(is.null(input$plot_prevalence_color)){
      if(!is.null(input$plot_prevalence_facet_by)){
        p<-table %>% 
          unite("facet_var", 
                c(all_of(input$plot_prevalence_facet_by)), remove = FALSE, sep = "; ") %>% 
          ggplot(aes_string(x= "prevalence_start_date", y="prevalence")) +
          geom_point(position=position_dodge(width=1))+
          facet_wrap(vars(facet_var),nrow = 2)+
          scale_y_continuous(
            limits = c(0, NA)
          ) +
          theme_bw()
      } else{
        p<-table %>% 
          ggplot(aes_string(x= "prevalence_start_date", y="prevalence")) +
          geom_point(position=position_dodge(width=1))+
          scale_y_continuous(
            limits = c(0, NA)
          ) +
          theme_bw()        
      }
    } 
    
    if(!is.null(input$plot_prevalence_color) ){ 
      
      if(is.null(input$plot_prevalence_facet_by) ){ 
        p<-table %>% 
          unite("Group", 
                c(all_of(input$plot_prevalence_color)), remove = FALSE, sep = "; ") %>% 
          ggplot(aes_string(x= "prevalence_start_date", y="prevalence",
                            group="Group",
                            colour="Group")) +
          geom_point(position=position_dodge(width=1))+
          theme_bw()
      }
      
      if(!is.null(input$plot_prevalence_facet_by) ){
        if(!is.null(input$plot_prevalence_color) ){ 
          p<-table %>% 
            unite("Group", 
                  c(all_of(input$plot_prevalence_color)), remove = FALSE, sep = "; ") %>% 
            unite("facet_var", 
                  c(all_of(input$plot_prevalence_facet_by)), remove = FALSE, sep = "; ") %>% 
            ggplot(aes_string(x= "prevalence_start_date", y="prevalence",
                              group="Group",
                              colour="Group")) +
            geom_point(position=position_dodge(width=1))+
            facet_wrap(vars(facet_var),ncol = 2)+  
            scale_y_continuous(
              limits = c(0, NA)
            )  +
            theme_bw()
        }
      }
      
    }
    
    p
    
  })  
  # Incidence ----
  output$incidence_table <- renderDataTable({
    datatable(
      filterData(data$incidence, "incidence", input) %>% 
        niceColumnNames() %>% 
        select(input$select_incident_columns),
      options = list(
        scrollX = TRUE, 
        scrollCollapse = TRUE,
        lengthChange = FALSE, 
        searching = FALSE, 
        ordering = FALSE, 
        paging = FALSE
      )
    )
  })
  output$incidence_plot <- renderPlotly({
    
    table <-  filterData(data$incidence, "incidence", input)
    
    validate(need(ncol(table)>1, 
                  "No results for selected inputs"))
    
    if(is.null(input$plot_incidence_color)){
      if(!is.null(input$plot_incidence_facet_by)){
        p<-table %>% 
          unite("facet_var", 
                c(all_of(input$plot_incidence_facet_by)), remove = FALSE, sep = "; ") %>% 
          ggplot(aes_string(x= "incidence_start_date", y="incidence_100000_pys")) +
          geom_point(position=position_dodge(width=1))+
          facet_wrap(vars(facet_var),nrow = 2)+
          scale_y_continuous(
            limits = c(0, NA)
          ) +
          theme_bw()
      } else{
        p<-table %>% 
          ggplot(aes_string(x= "incidence_start_date", y="incidence_100000_pys")) +
          geom_point(position=position_dodge(width=1))+
          scale_y_continuous(
            limits = c(0, NA)
          ) +
          theme_bw()        
      }
    } 
    
    
    if(!is.null(input$plot_incidence_color) ){ 
      
      if(is.null(input$plot_incidence_facet_by) ){ 
        p<-table %>% 
          unite("Group", 
                c(all_of(input$plot_incidence_color)), remove = FALSE, sep = "; ") %>% 
          ggplot(aes_string(x= "incidence_start_date", y="incidence_100000_pys",
                            group="Group",
                            colour="Group")) +
          geom_point(position=position_dodge(width=1))+
          theme_bw()
      }
      
      if(!is.null(input$plot_incidence_facet_by) ){
        if(!is.null(input$plot_incidence_color) ){ 
          p<-table %>% 
            unite("Group", 
                  c(all_of(input$plot_incidence_color)), remove = FALSE, sep = "; ") %>% 
            unite("facet_var", 
                  c(all_of(input$plot_incidence_facet_by)), remove = FALSE, sep = "; ") %>% 
            ggplot(aes_string(x= "incidence_start_date", y="incidence_100000_pys",
                              group="Group",
                              colour="Group")) +
            geom_point(position=position_dodge(width=1))+
            facet_wrap(vars(facet_var),ncol = 2)+  
            scale_y_continuous(
              limits = c(0, NA)
            )  +
            theme_bw()
        }
      }
      
    }
    
    p
  })
  # LSC  ----

  output$lsc_table <- renderDataTable({
    
    DT::datatable(
      
      filterData(data$lsc_table, "lsc", input) %>% 
        #niceColumnNames() %>%
        arrange(cohort_name, cdm_name, desc(difference_percentage)) %>% 
        #arrange(`Cohort name`, `Cdm name`, desc(`Difference percentage`)) %>%
        select(input$select_lsc_columns) ,
      
      options = list(scrollX = TRUE),
      rownames = FALSE  
      
    )
    
  })
  
  
    
    output$lsc_plot <- renderPlotly({
      
      table <-     filterData(data$lsc_table, "lsc", input) %>% 
      arrange(cohort_name, cdm_name, desc(difference_percentage)) %>%
        mutate(label = paste0(concept_name, "; ", window)) %>%
        drop_na()

    
    if(!is.null(input$plot_lsc_facet_by)){
      p <- table %>%
        unite("facet_var", 
              c(all_of(input$plot_lsc_facet_by)), remove = FALSE, sep = "; ") %>% 
        ggplot(aes_string(x = "sample_percentage", y = "matched_percentage",
                          group= "label",
                          fill = "label",
                          color = "label"
        )) +
        geom_point() +
        geom_abline(intercept = 0, slope = 1) +
        facet_wrap(vars(facet_var),nrow = 2) +
        theme_bw() +
        theme(legend.position = "none")
      
    } else{
      p <- table %>%
        ggplot(aes_string(x = "sample_percentage", y = "matched_percentage",
                          group= "label",
                          fill = "label",
                          color = "label")) +
        geom_point() +
        geom_abline(intercept = 0, slope = 1) +
        theme_bw() +
        theme(legend.position = "none")
    }
    
    p + xlab("Sample") + ylab("Matched") +
      scale_x_continuous(limits = c(0, 100)) +
      scale_y_continuous(limits = c(0, 100))
    
    p
    
  })
    
  # log ----
  output$log <- renderUI({
    filterData(data$log, "log", input) %>% 
      pull(log) %>% 
      formatLog()
  })
}