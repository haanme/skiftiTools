
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

#' Create a Nifti file from Skifti data
#' 
#' Skeleton mask and corresponding image intensity data in Nifti format.
#' The skeleton mask is used to determine the coordinates of intensity data.
#' If optional label file is given, that is used to label the voxels.
#' 
#' @inheritSection labels_Description Label Levels
#' 
#' @param Skifti_data Intensity data in Nifti format
#' 
#' @importFrom RNifti niftiHeader
#' @export
#'
Skifti2Nifti <- function(Skifti_data){
  
  if (is.null(Skifti_data)) {
    warning("`Nifti_data`, was NULL: Nothing to read!\n")
    return(NULL)
  }
  
  if(Skifti_data$reftype=="filename"){
    Nifti_skeleton<-Skifti_data$refdata
    if (is.null(Nifti_skeleton)) {
      warning("`Nifti_skeleton`, was NULL: Cannot reconstruct Nifti!\n")
      return(NULL)
    }
    mask<-RNifti::readNifti(Nifti_skeleton, internal = FALSE, volumes = NULL)    
    
    m<-array(mask)
    a<-m
    ret<-list()
    for(i in 1:dim(Skifti_data$data)[1]) {
      # Re-create Nifti
      a[m>0]<-Skifti_data$data[i,]
      dim(a)<-Skifti_data$dim[2:4]
      hdr<-niftiHeader()
      hdr$dim<-Skifti_data$dim
      hdr$pixdim<-Skifti_data$pixdim
      hdr$srow_x<-Skifti_data$xform[1,]
      hdr$srow_y<-Skifti_data$xform[2,]
      hdr$srow_z<-Skifti_data$xform[3,]
      hdr$sform_code<-2
      img<-asNifti(a, reference=hdr)
      ret[[length(ret)+1]]<-img
    }
    return(ret)
  } else {
    warning(paste("Non supported skeleton reference type:", Skifti_data$reftype, sep=''))
    return(NULL)
  }
}
