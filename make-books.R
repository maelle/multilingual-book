# Folder, file names etc.
english_name <- "english"
french_name <- "french"

# Common configuration for "index.Rmd"
common_index <- list(
  date = as.character(Sys.Date()),
  site = "bookdown::bookdown_site",
  documentclass = "book",
  bibliography  = c("book.bib", "packages.bib"),
  author = "Some Person",
  `biblio-style` = "apalike",
  csl = "chicago-fullnote-bibliography.csl"
)

# Common _output.yml configuration
common_config <- list(
  new_session = FALSE,
  before_chapter_script = "_common.R",
  delete_merged_file = TRUE
)

# Build English book
english_specific_index <- list(
  title = "Book Example",
  description = "Minimal example, blablabla"
)
english_index_file <- "index.Rmd"
writeLines(
  c(
    "---",
    paste0(yaml::as.yaml(c(common_index, english_specific_index, omap = TRUE)), "---"),
    "",
    readLines("chapters-en/index-content.Rmd.pre")),
  english_index_file
)
english_chapters <- fs::dir_ls("chapters-en", glob = "*.Rmd")
english_rmd_files <- c("index.Rmd", english_chapters)
english_specific_config <- list(
  language = list(ui = list(chapter_name = "Chapter ")),
  rmd_files = english_rmd_files,
  output_dir = english_name
)
english_config <- c(common_config, english_specific_config)

english_config_file <- withr::local_tempfile(fileext = ".yml")
yaml::write_yaml(english_config, english_config_file)
bookdown::render_book(config_file = english_config_file)
fs::file_delete(english_index_file)


# Build French book
french_specific_index <- list(
  title = "Exemple de livre",
  description = "Exemple minimal, blablabla"
)
french_index_file <- "index.Rmd"
writeLines(
  c(
    "---",
    paste0(yaml::as.yaml(c(common_index, french_specific_index, omap = TRUE)), "---"),
    "",
    readLines("chapters-fr/index-content.Rmd.pre")),
  french_index_file
)
french_chapters <- fs::dir_ls("chapters-fr", glob = "*.Rmd")
french_rmd_files <- c("index.Rmd", french_chapters)
french_specific_config <- list(
  language = list(ui = list(chapter_name = "Chapitre ")),
  rmd_files = french_rmd_files,
  output_dir = french_name
)
french_config <- c(common_config, french_specific_config)

french_config_file <- withr::local_tempfile(fileext = ".yml")
yaml::write_yaml(french_config, french_config_file)
bookdown::render_book(config_file = french_config_file)
fs::file_delete(french_index_file)

# Copy
if (fs::dir_exists("docs")) fs::dir_delete("docs")
fs::dir_create("docs")
fs::dir_copy(english_name, "docs")
fs::dir_delete(english_name)
fs::dir_copy(french_name, "docs")
fs::dir_delete(french_name)

# Surgery

# Correspondance between English and French Rmd filenames
dic <- yaml::read_yaml("dic.yaml")

# We need the correspondance between Rmd and HTML filenames.
# We get it thanks to bs4_book storing the source filename!
map_source <- function(filename, lang) {
  html <- xml2::read_html(filename)
  source <- xml2::xml_find_first(html, ".//li/a[@id='book-source']")
  rmd_filename <- basename(xml2::xml_attr(source, "href"))
  tibble::tibble(
    html = as.character(filename),
    rmd = rmd_filename,
    lang = lang
  )
}

english_html <- fs::dir_ls(file.path("docs", english_name), glob = "*.html")
french_html <- fs::dir_ls(file.path("docs", french_name), glob = "*.html")

english_map <- purrr::map_df(english_html, map_source, lang = "en")
french_map <- purrr::map_df(french_html, map_source, lang = "fr")
all_map <- rbind(english_map, french_map)
all_map$rmd[all_map$rmd == "#"] <- "index.Rmd"
all_map <- all_map[!is.na(all_map$rmd),]

modify_one <- function(filename, all_map, dic) {
  english <- names(dic)
  french <- dic
  is_english <- grepl("docs/english", filename)

  lang <- if (is_english) {
    "en"
  } else {
    "fr"
  }

  if (basename(filename) == "404.html") {
    return()
  }

  rmd_filename <- all_map$rmd[all_map$html == filename & all_map$lang == lang]
  new_rmd <- if (is_english) {
    french[english == fs::path_ext_remove(rmd_filename)]
  } else {
    english[french == fs::path_ext_remove(rmd_filename)]
  }

  new_name <- all_map$html[fs::path_ext_remove(all_map$rmd) == new_rmd & all_map$lang != lang]

  html <- xml2::read_html(filename)
  source <- xml2::xml_find_first(html, ".//li/a[@id='book-source']")
  xml2::xml_add_sibling(
    xml2::xml_parent(source),
    "li"
  )

  new_dir <- if(is_english) {
    french_name
  } else {
    english_name
  }

  other_language <- if (is_english) {
    "Version française 👋"
  } else {
    "English version 👋"
  }

  xml2::xml_add_child(
    xml2::xml_siblings(xml2::xml_parent(source))[[1]],
    "a", href = sprintf("../%s/%s", new_dir, basename(new_name)), other_language
  )

  xml2::write_html(html, filename)
}

purrr::walk(all_map$html, modify_one, dic = dic, all_map = all_map)
