write_df_to_csv <- function(deaths_pre_pandemic, filename) {
  readr::write_csv(deaths_pre_pandemic,
                   filename,
                   append = FALSE)
  
  filename
}

read_df_from_csv <- function(filename) {
  readr::read_csv(filename)
}