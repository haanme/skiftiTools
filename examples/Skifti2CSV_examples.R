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
RNifti::writeNifti(data_skeleton_Nifti, "data_skeleton_Nifti.nii.gz", datatype = "auto")

data_Skifti<-Nifti2Skifti(Nifti_data="data_Nifti.nii.gz", 
                          Nifti_skeleton="data_skeleton_Nifti.nii.gz", 
                          selected_volumes=1:10, 
                          Nifti_labels=NULL, 
                          write_coordinates=TRUE, 
                          verbose=FALSE)

Skifti2CSV(data_Skifti, "data_Skifti.csv", overwrite=TRUE, sep=';')
data_csv<-read.csv2("data_Skifti.csv", ';', header = FALSE, row.names = NULL)
