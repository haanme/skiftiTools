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

data_Skifti<-smooth_3d_mm(data_skeleton, c(1,2,3), 6)
