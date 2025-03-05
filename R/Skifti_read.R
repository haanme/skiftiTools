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
library(stringr)

#' Read Skifti data
#' 
#' @param filename file to read
readSkifti <- function(filename){
  if(!file(filename)) {
    stop(paste('File ', filename, ' does not exist', sep=''))
  }
  if(str_detect(filename,'.bz2')){
    R.utils::bunzip2(filename, str_replace(filename,'.bz2',''))
    filename<-str_replace(filename,'.bz2','')
  }  
  
  datatype<-"volume-per-row-ASCII"
  flines<-readLines(filename)
  if(!(flines[1]=="# Skifti")) {
    print(paste('# Skifti not found at 1st line of ', filename, sep=''))
    datatype="binary"
  }
  
  if(datatype=="volume-per-row-ASCII") {
    Skifti_data<-list()
    if(flines[2]=="# filename") {
      Skifti_data$reftype<-"filename"
      Skifti_data$refdata<-sub('# ', '', flines[3])
    } else {
      stop(paste('Unrecognized skeleton reference type:', flines[2], sep=''))
    }
    Skifti_data$dim<-as.numeric(strsplit(sub('# ', '', flines[4]), split=' ')[[1]])
    Skifti_data$pixdim<-as.numeric(strsplit(sub('# ', '', flines[5]), split=' ')[[1]])
    Skifti_data$xform<-as.numeric(strsplit(sub('# ', '', flines[6]), split=' ')[[1]])
    dim(Skifti_data$xform)<-c(3,4)
    Skifti_data$version<-sub('# ', '', flines[7])
    Skifti_data$datatype<-sub('# ', '', flines[8])
    rnames<-c()
    Skifti_data$data<-c()
    for(i in 9:length(flines)) {
      rowdata<-strsplit(flines[i]," ")[[1]]
      rnames<-c(rnames, rowdata[1])
      rowdata<-as.double(rowdata[2:length(rowdata)])
      if(i==9) {
        data<-data.frame(rowdata)
      } else {
        data<-cbind(data, rowdata)
      }
    }
    Skifti_data$data<-t(data)
    rownames(Skifti_data$data)<-rnames
  } else if(datatype=="binary") {
    Skifti_data<-readRDS(filename)
  } else {
    stop(paste('Unrecognised datatype:', Skifti_data$datatype, sep=''))
  } 
  return(Skifti_data)
}
