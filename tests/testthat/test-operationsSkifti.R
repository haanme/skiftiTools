test_that("multiplication works", {
  source('../../R/Nifti2Skifti.R')
  source('../../R/operationsSkifti.R')
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
  
  data_Skifti<-Nifti2Skifti(Nifti_data="data_Nifti.nii.gz", Nifti_skeleton="data_skeleton_Nifti.nii.gz", selected_volumes=1:10, Nifti_labels=NULL, write_coordinates=TRUE, verbose=FALSE)
  
  data_Skifti_subset<-subset(data_Skifti, c(1,5,10))
  m<-matrix(c(6,10,15,7,11,16,8,12,17), nrow=3, ncol=3)
  rownames(m)<-c("vol1", "vol5", "vol10")
  expect_equal(data_Skifti_subset$data, m)
  
  data_Skifti_subset1<-subset(data_Skifti, c(1,5))
  data_Skifti_subset2<-subset(data_Skifti, c(10))  
  data_Skifti_concat<-concat(data_Skifti_subset1, data_Skifti_subset2)
  m<-matrix(c(6,10,15,7,11,16,8,12,17), nrow=3, ncol=3)
  rownames(m)<-c("vol1", "vol5", "")
  expect_equal(data_Skifti_concat$data, m)
})
