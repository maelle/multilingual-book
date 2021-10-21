# Multilingual bs4_book

[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)


* Chapters are in two folders, one folder by language. They hold the same number of chapters!
* The content of index.Rmd is in each language folder, without any frontmatter, as `index.Rmd.pre`.
* The mapping between English and French filenames is in [`dic.yaml`](dic.yaml). YAML seemed natural, but it could be included in another YAML config file. 
* The script [`make-books.R`](make-books.R)
    * builds the books after merging the general and language specific configurations, 
    * copies their content to the docs/ folder, 
    * then performs xml2 surgery to get the mapping between Rmd and HTML filenames, and to add a link to each HTML to the HTML in the other language.

This is a **prototype**.
For instance it'd be good to have more generic code, with not only two languages.

Instead of having to merge configuration in the R code it'd be nice to merge configuration like with Hugo (including, for frontmatter, something like [cascades](https://gohugo.io/news/0.86.0-relnotes/)).
