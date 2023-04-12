#' Writes a data frame ot a CSV file, returning the file path it was written to
#' to comply with targets convention.
#' 
#' This function will always overwrite a previously existing file! 
#' 
#' @param input_df data.frame to be written to a CSV file
#' @param file_path Path where the CSV is written to
write_df_to_csv <- function(input_df, file_path) {
  readr::write_csv(input_df,
                   file_path,
                   append = FALSE)
  
  file_path
}

read_df_from_csv <- function(filename) {
  readr::read_csv(filename)
}