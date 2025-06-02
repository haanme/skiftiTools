
# This file is part of skiftiTools.
#
# skiftiTools is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# skiftiTools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2025 Turku Brain and Mind Center

library(methods)

#' Write Skifti data to Comma Separated Values (CSV) file. No header is written, for 
#' header write Skifti to ASCII format using writeSkifti.
#' 
#' @param Skifti_data Skifti data object
#' @param filename filename to write
#' @param overwrite TRUE/FALSE(default) to overwrite existing data
#' @param sep separator to be used between vales, default=','
#' 
#' @return csv filename where output was written
#' @importFrom methods is
#' @export
#' @example examples/writeCSV_examples.R
writeCSV <- function(Skifti_data, filename, overwrite=FALSE, sep=','){
  if(!is(Skifti_data, "Skifti")) {
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
