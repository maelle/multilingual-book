common_config <- list(
  new_session = FALSE,
  before_chapter_script = "_common.R",
  delete_merged_file = TRUE
)

english_chapters <- fs::dir_ls("chapters-en")
english_rmd_files <- c("index.Rmd", english_chapters)
english_specific_config <- list(
  book_filename = "multilingual-book",
  language = list(ui = list(chapter_name = "Chapter ")),
  rmd_files = english_rmd_files,
  output_dir = "docs/multilingual-book"
)
english_config <- c(common_config, english_specific_config)

english_config_file <- withr::local_tempfile(fileext = ".yml")
yaml::write_yaml(english_config, english_config_file)
bookdown::render_book(config_file = english_config_file)

french_chapters <- fs::dir_ls("chapters-fr")
french_rmd_files <- c("index.Rmd", french_chapters)
french_specific_config <- list(
  book_filename = "livre-multilangues",
  language = list(ui = list(chapter_name = "Chapitre ")),
  rmd_files = french_rmd_files,
  output_dir = "docs/livre-multilangues"
)
french_config <- c(common_config, french_specific_config)
french_config_file <- withr::local_tempfile(fileext = ".yml")
yaml::write_yaml(french_config, french_config_file)
bookdown::render_book(config_file = french_config_file)




