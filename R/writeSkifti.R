library(RNifti)
library(stringr)

#' Write Skifti data
#' 
#' @param Skifti_data Skifti data object
#' @param filename filename to write
#' @param overwrite TRUE/FALSE(default) to overwrite existing data
writeSkifti <- function(Skifti_data, filename, overwrite=FALSE, use_zip=TRUE){
  if(!(class(Skifti_data)=="Skifti")) {
    stop(paste('Skifti class expected, but', class(Skifti_data), 'was given',sep=''))    
  }
  if(file(filename) & (overwrite==FALSE)) {
    stop(paste('File ', filename, ' exists, but overwrite was not selected', sep=''))
  }
  if(is.null(Skifti_data$datatype)){
    print("Datatype was NULL, using ASCII volume-per-row-ASCII")
    Skifti_data$datatype<-"volume-per-row-ASCII"
  }
  if(Skifti_data$datatype=="volume-per-row-ASCII"){
    file.create(filename, showWarnings = FALSE)
    write(paste('#', paste(class(Skifti_data)), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$reftype), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$refdata), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$dim, collapse = ' '), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$pixdim, collapse = ' '), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$xform, collapse = ' '), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$version), sep=' '), file = filename, append = TRUE, sep = " ")
    write(paste('#', paste(Skifti_data$datatype), sep=' '), file = filename, append = TRUE, sep = " ")
    rnames<-rownames(Skifti_data$data)
    for(i in 1:dim(Skifti_data$data)[1]) {
      write(paste(rnames[i], paste(Skifti_data$data[i,], collapse = " "), collapse = " "), file = filename, append = TRUE, sep = " ")
    }
  } else if(Skifti_data$datatype=="binary") {
    saveRDS(Skifti_data, file=filename)
  } else {
    stop(paste('Unrecognised datatype:\"', Skifti_data$datatype, "\"", sep=''))
  }
  if(use_zip==TRUE) {
    R.utils::bzip2(filename, paste(filename,'.bz2',sep=''))
    filename<-paste(filename,'.bz2',sep='')
  }
  return(filename)
}
