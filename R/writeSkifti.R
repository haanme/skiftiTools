library(RNifti)
library(stringr)

#' Write Skifti data
#' 
#' @param Skifti_data Skifti data object
#' @param basename basename to write without suffix
#' @param overwrite TRUE/FALSE(default) to overwrite existing data
#' @param compress bz2/zip/none(default) to select compression method
writeSkifti <- function(Skifti_data, basename, overwrite=FALSE, compress="none"){
  if(!(class(Skifti_data)=="Skifti")) {
    stop(paste('Skifti class expected, but', class(Skifti_data), 'was given',sep=''))    
  }
  if(is.null(Skifti_data$datatype)){
    print("Datatype was NULL, using ASCII volume-per-row-ASCII")
    Skifti_data$datatype<-"volume-per-row-ASCII"
  }
  if(Skifti_data$datatype=="volume-per-row-ASCII"){
    filename<-paste(basename, '.txt', sep='')
    if(file(filename) & (overwrite==FALSE)) {
      stop(paste('File ', filename, ' exists, but overwrite was not selected', sep=''))
    }
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
    filename<-paste(basename, '.rDs', sep='')
    if(file(filename) & (overwrite==FALSE)) {
      stop(paste('File ', filename, ' exists, but overwrite was not selected', sep=''))
    }
    saveRDS(Skifti_data, file=filename)
  } else {
    stop(paste('Unrecognised datatype in skifti object:', Skifti_data$datatype, sep=''))
  }
  if(str_detect(compress, "none")) {
      # no action
  } else if(str_detect(compress, "bz2")) {
    R.utils::bzip2(filename, paste(basename,'.bz2',sep=''))
    file.remove(filename)
    filename<-paste(basename,'.bz2',sep='')
  } else if(str_detect(compress, "zip")) {
    zip(zipfile = paste(basename,'.zip',sep=''), files = filename, flags="-j")
    file.remove(filename)
    filename<-paste(basename,'.zip',sep='')
  } else {
    stop(paste('Unrecognised compress method:', compress, sep=''))
  }
  return(filename)
}
