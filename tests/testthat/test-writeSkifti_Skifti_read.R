test_that("multiplication works", {
  source('../../R/Nifti2Skifti.R')
  source('../../R/Skifti_read.R')
  source('../../R/writeSkifti.R')
  library(RNifti)
  data<-array(0,dim=list(10,10,10,10))
  for(t in 1:10) {
    for(x in 1:10) {
      for(y in 1:10) {
        for(z in 1:10) {
          data[x,y,z,t]<-t+x
        }
      }
    }
  }
  data_Nifti<-RNifti::retrieveNifti(data)
  RNifti::writeNifti(data_Nifti, "data_Nifti.nii.gz", template = NULL, datatype = "auto")
  
  data_skeleton<-array(0,dim=list(10,10,10))
  data_skeleton[5,5,5]<-1
  data_skeleton[6,6,6]<-1
  data_skeleton[7,7,7]<-1
  data_skeleton_Nifti<-RNifti::retrieveNifti(data_skeleton)
  RNifti::writeNifti(data_skeleton_Nifti, "data_skeleton_Nifti.nii.gz", template = NULL, datatype = "auto")
  
  data_Skifti<-Nifti2Skifti(Nifti_data="data_Nifti.nii.gz", Nifti_skeleton="data_skeleton_Nifti.nii.gz", selected_volumes=c(1), Nifti_labels=NULL, write_coordinates=TRUE, verbose=FALSE)
  
  filename<-writeSkifti(data_Skifti, "data_Skifti", overwrite=TRUE, compress="bz2", verbose=FALSE)
  expect_equal(filename, "data_Skifti.bz2")
  Skifti_data<-readSkifti("data_Skifti.bz2", verbose=FALSE)
  
  expect_equal(Skifti_data$reftype, "filename")
  expect_equal(Skifti_data$refdata, "data_skeleton_Nifti.nii.gz")
  expect_equal(Skifti_data$dim, c(3,10,10,10,1,1,1,1))
  expect_equal(Skifti_data$pixdim, c(0,1,1,1,0,0,0,0))
  expect_equal(Skifti_data$datatype, "volume-per-row-ASCII")
  expect_equal(Skifti_data$version, "0.1")
  expect_equal(Skifti_data$data, matrix(c(6,7,8), nrow=1, ncol=3, byrow = TRUE, dimnames = list("vol1")))  
})
