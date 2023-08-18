require(RNifti)
require(stringr)

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
