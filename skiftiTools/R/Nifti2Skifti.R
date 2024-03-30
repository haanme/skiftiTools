library(RNifti)
library(stringr)

#' Create a SKIFTI file from fsl TBSS skeleton data
#' 
#' Skeleton mask and corresponding image intensity data must be in Nifti format.
#' The skeleton mask is used to determine the coordinates of intensity data.
#' If optional label file is given, that is used to label the voxels.
#' 
#' @inheritSection labels_Description Label Levels
#' 
#' @param Nifti_data Intensity data in Nifti format
#' @param Nifti_skeleton Skeleton at same imaging space as the data, in Nifti format
#' @param start_volume starting volume
#' @param end_volume ending volume
#' 
#' @export
#'
Nifti2Skifti <- function(Nifti_data=NULL, Nifti_skeleton=NULL, start_volume=NULL, end_volume=NULL) {

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
      error(paste('Dimensions of data and skeleton mask do not match ', img_hdr$dim[i], img_hdr$dim[i], sep=' '))
      return(NULL)
    }
    if(img_hdr$pixdim[i] != img_hdr$pixdim[i]){
      error(paste('Dimensions of data and skeleton mask do not match ', img_hdr$pixdim[i], img_hdr$pixdim[i], sep=' '))
      return(NULL)
    }
  }

  names<-list()
  data<-NULL
  if (is.null(start_volume)) {
      start_volume=1
  }
  if (is.null(end_volume)) {
      end_volume<-img_hdr$dim[5]
  }
  total_volumes_to_read<-end_volume-start_volume+1
  for(i in start_volume:end_volume) {
    names[[length(names)+1]]<-c(paste("vol",i,sep=''))
    img<-RNifti::readNifti(Nifti_data, internal = FALSE, volumes = c(i))
    rowdata<-img[mask>0]
    cat(paste("\r Reading FA data ", i-start_volume+1, "/", total_volumes_to_read, " ", names[[length(names)]], sep=""))
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
