
# This file is part of skiftiTools.
#
# skiftiTools is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# skiftiTools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2024 Harri Merisaari

library(RNifti)
library(stringr)

#' Get subset of Skifti data
#' 
#' @param Skifti_data Skifti data object
#' @param volumes selected volumes in [1..dim(Skifti_data$data)[1]]
subset <- function(Skifti_data, volumes){
  if(!(class(Skifti_data)=="Skifti")) {
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
#' @param Skifti_data Skifti data object1
#' @param Skifti_data Skifti data object2
concat <- function(Skifti_data1, Skifti_data2){
  if(!(class(Skifti_data1)=="Skifti")) {
    stop(paste('Skifti class expected for parameter 1, but', class(Skifti_data1), 'was given',sep=''))    
  }
  if(!(class(Skifti_data2)=="Skifti")) {
    stop(paste('Skifti class expected for parameter 2, but', class(Skifti_data2), 'was given',sep=''))    
  }
  if(!(dim(Skifti_data1$data)[2] == dim(Skifti_data2$data)[2])){
    stop(paste('Parameter 1 mask size ', dim(Skifti_data1$data)[2], ' and parameter 2 mask size ', dim(Skifti_data2$data)[2], ' do not match', sep=''))
  }  
  Skifti_data1$data<-rbind(Skifti_data1$data, Skifti_data2$data)
  return(Skifti_data1)
}
