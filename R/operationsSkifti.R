
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

#' Get subset of Skifti data
#' 
#' @param Skifti_data Skifti data object
#' @param volumes selection
#'
#' @return Skifti data object of subset
#' @importFrom methods is
#' @export
#' @example examples/operationsSkifti_examples.R
subset <- function(Skifti_data, volumes){
  if(!is(Skifti_data, "Skifti")) {
    stop(paste('Skifti class expected, but', class(Skifti_data), 'was given',sep=''))    
  }
  if(is.null(volumes)){
    stop(paste('Volumes were null for Skifti subset'))    
  }
  if(min(volumes) < 1){
    stop(paste('Volumes minimun ', min(volumes), ' out of lower bound 1', sep=''))    
  }
  if(max(volumes) > dim(Skifti_data$data)[1]){
    stop(paste('Volumes maximum ', max(volumes), ' out of high bound ', dim(Skifti_data$data)[1], sep=''))
  }
  Skifti_data$data<-Skifti_data$data[volumes,]
  return(Skifti_data)
}

#' Concatenate Skifti data
#' 
#' @param Skifti_data1 Skifti data object1
#' @param Skifti_data2 Skifti data object2
#' 
#' @return concatenated Skifti data object
#' @export
#' @example examples/operationsSkifti_examples.R
concat <- function(Skifti_data1, Skifti_data2){
  if(!is(Skifti_data1, "Skifti")) {
    stop(paste('Skifti class expected for parameter 1, but', class(Skifti_data1), 'was given',sep=''))    
  }
  if(!is(Skifti_data2, "Skifti")) {
    stop(paste('Skifti class expected for parameter 2, but', class(Skifti_data2), 'was given',sep=''))    
  }
  if(is.null(dim(Skifti_data1$data))) {
    dim1<-length(Skifti_data1$data)
  } else {
    dim1<-dim(Skifti_data1$data)[2]
  }
  if(is.null(dim(Skifti_data2$data))) {
    dim2<-length(Skifti_data2$data)
  } else {
    dim2<-dim(Skifti_data2$data)[2]
  }
  if(!(dim1 == dim2)){
    stop(paste('Parameter 1 mask size ', dim1, ' and parameter 2 mask size ', dim2, ' do not match', sep=''))
  }
  Skifti_data1$data<-rbind(Skifti_data1$data, Skifti_data2$data)
  return(Skifti_data1)
}
