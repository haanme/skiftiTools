
# This file is part of skiftiTools.
#
# skiftiTools is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# skiftiTools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2025 Turku Brain and Mind Center

library(RNifti)

#' Create a Nifti file from Skifti data
#' 
#' Skeleton mask and corresponding image intensity data in Nifti format.
#' The skeleton mask is used to determine the coordinates of intensity data.
#' If optional label file is given, that is used to label the voxels.
#' 
#' @param Skifti_data Intensity data in Nifti format
#' @param filename file to read'
#' @param overwrite TRUE/FALSE(default) to overwrite existing data
#' @param sep file separator to be written default ';'
#' 
#' @return CSV filename
#' @importFrom RNifti readNifti
#' @export
#' @example examples/Skifti2CSV_examples.R
#'
Skifti2CSV <- function(Skifti_data, filename, overwrite=FALSE, sep=';'){
  if(!is(Skifti_data, "Skifti")) {
    stop(paste('Skifti class expected, but', class(Skifti_data), 'was given',sep=''))    
  }
  if(file.exists(filename) & (overwrite==FALSE)) {
    stop(paste('File ', filename, ' exists, but overwrite was not selected', sep=''))
  }
  file.create(filename, showWarnings = FALSE)
  rnames<-rownames(Skifti_data$data)
  for(i in 1:dim(Skifti_data$data)[1]) {
    write(paste(c(rnames[i], paste(Skifti_data$data[i,], collapse = sep)), collapse = sep), file = filename, append = TRUE)
  }
  return(filename)  
}
