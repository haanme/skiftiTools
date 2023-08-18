require(RNifti)
require(stringr)

#' Write Skifti data to Comma Separated Values (CSV) file. No header is written, for 
#' header write Skifti to ASCII format using writeSkifti.
#' 
#' @param Skifti_data Skifti data object
#' @param filename filename to write
#' @param overwrite TRUE/FALSE(default) to overwrite existing data
#' @param sep separator to be used between values, default=','
writeCSV <- function(Skifti_data, filename, overwrite=FALSE, sep=','){
  if(!(class(Skifti_data)=="Skifti")) {
    stop(paste('Skifti class expected, but', class(Skifti_data), 'was given',sep=''))    
  }
  if(file(filename) & (overwrite==FALSE)) {
    stop(paste('File ', filename, ' exists, but overwrite was not selected', sep=''))
  }
  file.create(filename, showWarnings = FALSE)
  rnames<-rownames(Skifti_data$data)
  for(i in 1:dim(Skifti_data$data)[1]) {
    write(paste(rnames[i], paste(Skifti_data$data[i,], collapse = " "), collapse = " "), file = filename, append = TRUE, sep = " ")
  }
  return(filename)
}
