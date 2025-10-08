test_that("Skifti2Nifti and Nifti2Skifti works", {
  library(skiftiTools)
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
    
  # Create Nifti
  expect_equal(data_Skifti$refdata, "data_skeleton_Nifti.nii.gz")
  expect_equal(data_Skifti$dim, c(3,10,10,10,1,1,1,1))
  expect_equal(data_Skifti$pixdim, c(0,1,1,1,0,0,0,0))
  expect_equal(data_Skifti$mask_coordinates, matrix(c(5,6,7,5,6,7,5,6,7), nrow=3, ncol=3))
  expect_equal(data_Skifti$datatype, NULL)
  expect_equal(data_Skifti$version, "0.1")
  expect_equal(data_Skifti$data, matrix(c(6,7,8), nrow=1, ncol=3, byrow = TRUE, dimnames = list("vol1")))

  # Create Skifti
  data_Nifti2<-Skifti2Nifti(data_Skifti)
  RNifti::writeNifti(data_Nifti2[[1]], "data_Nifti.nii.gz", template = NULL, datatype = "auto")
  data_Nifti2<-RNifti::readNifti("data_Nifti.nii.gz", internal = TRUE, volumes = NULL)
  expect_equal(array(data_Nifti), array(data_Nifti2))
  
})
