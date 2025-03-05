
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

#' Create a SKIFTI file from fsl TBSS skeleton data
#' 
#' Skeleton mask and corresponding image intensity data must be in Nifti format.
#' The skeleton mask is used to determine the coordinates of intensity data.
#' If optional label file is given, that is used to label the voxels.
#' 
#' @param Nifti_data Intensity data in Nifti format
#' @param Nifti_skeleton Skeleton at same imaging space as the data, in Nifti format
#' @param selected_volumes Selected volume indexes starting from 1
#' 
#' @return skifti object with default rownames as vol1, vol2 .... volN as indexes from the nifti data
#' @importFrom RNifti niftiHeader readNifti
#' @export
#'
Nifti2Skifti <- function(Nifti_data=NULL, Nifti_skeleton=NULL, selected_volumes=NULL) {

  if (is.null(Nifti_data)) {
    warning("`Nifti_data`, was NULL: Nothing to read!\n")
    return(NULL)
  }
  if (is.null(Nifti_skeleton)) {
    warning("`Nifti_skeleton`, was NULL: Nothing to read!\n")
    return(NULL)
  }
  
  if (!file.exists(Nifti_data)) {
    warning(paste("`Nifti_data`, does not exist:", Nifti_data, "\n", sep=''))
    return(NULL)
  }
  if (!file.exists(Nifti_skeleton)) {
    warning(paste("`Nifti_skeleton`, does not exist:", Nifti_skeleton, "\n", sep=''))
    return(NULL)
  }
  print(paste("Reading " , Nifti_data, sep=""))
  mask<-RNifti::readNifti(Nifti_skeleton, internal = FALSE, volumes = NULL)
  img_hdr<-RNifti::niftiHeader(Nifti_data)
  mask_hdr<-niftiHeader(mask)
  for(i in 1:3) {
    if(img_hdr$dim[i] != img_hdr$dim[i]){
      print(paste('Dimensions of data and skeleton mask do not match ', img_hdr$dim[i], img_hdr$dim[i], sep=' '))
      return(NULL)
    }
    if(img_hdr$pixdim[i] != img_hdr$pixdim[i]){
      print(paste('Dimensions of data and skeleton mask do not match ', img_hdr$pixdim[i], img_hdr$pixdim[i], sep=' '))
      return(NULL)
    }
  }

  names<-list()
  data<-NULL
  if(is.null(selected_volumes)) {
    total_volumes_to_read<-img_hdr$dim[5]
  } else {
    total_volumes_to_read<-length(selected_volumes)
  }
  for(i in 1:total_volumes_to_read) {
    if(is.null(selected_volumes)) {
      ii<-i
    } else {
      ii<-selected_volumes[i]
      if(ii < 1 | ii > img_hdr$dim[5]) {
        print(paste('Selected volume index ', ii, ' out of bounds [1..', img_hdr$dim[5], ']', sep=' '))
        return(NULL)
      }
    }
    names[[length(names)+1]]<-c(paste("vol", ii, sep=''))
    img<-RNifti::readNifti(Nifti_data, internal = FALSE, volumes = c(ii))
    rowdata<-img[mask>0]
    cat(paste("\r Reading Nifti data ", i, "/", total_volumes_to_read, " ", names[[length(names)]], sep=""))
    if(i==1) {
      data<-data.frame(rowdata)
    } else {
      data<-cbind(data, rowdata)
    }
  }
  print("")
  data<-t(data)
  rownames(data)<-names
  skifti<-list(reftype="filename", refdata=Nifti_skeleton, dim=mask_hdr$dim, pixdim=mask_hdr$pixdim, xform=rbind(mask_hdr$srow_x,mask_hdr$srow_y,mask_hdr$srow_z), datatype=NULL, version='0.1', data=data)
  class(skifti)<-"Skifti"
  return(skifti)
}
