library(rmarchingcubes)
library(RNifti)
options(rgl.useNULL=TRUE)
library(rgl)
library(fields)
library(abind)
library(png)
library(Rvcg)
library(oce)

# Function to rotate view
get_rot_matrix <- function(axis, angle) {
  r<-diag(4)
  if (axis == 1) {
    r[2,2]<-cos(angle)
    r[2,3]<--sin(angle)
    r[3,2]<-sin(angle)
    r[3,3]<-cos(angle)   
    return(r)
  }
  if (axis == 2) {
    r[1,1]<-cos(angle)
    r[1,3]<-sin(angle)
    r[3,1]<--sin(angle)
    r[3,3]<-cos(angle)   
    return(r)
  }
  if (axis == 3) {
    r[1,1]<-cos(angle)
    r[1,2]<--sin(angle)
    r[2,1]<-sin(angle)
    r[2,2]<-cos(angle)   
    return(r)
  }
}

#' Create png from mask and data in Nifti format
#' 
#' Skeleton mask and corresponding image intensity data must be in Nifti format.
#' The skeleton mask is used to determine the coordinates of intensity data.
#' 
#' @param mask Intensity data in Nifti object format
#' @param data Skeleton at same imaging space as the data, in Nifti format
#' @param img_hdr Nifti header object
#' @param output Output PNG filename
#' @param legend_title Title to be shown
#' @param scale scaling for intensity values, tune for better color depth
#'
#' @export
#'
save_skeleton <- function(mask, data, img_hdr, output, legend_title, scale) {
  
  data<-data*scale
  print(c(min(data),max(data)))
  
  x <- seq(-img_hdr$dim[2]/2*img_hdr$pixdim[2],img_hdr$dim[2]/2*img_hdr$pixdim[2],len = img_hdr$dim[2])
  y <- seq(-img_hdr$dim[3]/2*img_hdr$pixdim[3],img_hdr$dim[3]/2*img_hdr$pixdim[3],len = img_hdr$dim[3])
  z <- seq(-img_hdr$dim[4]/2*img_hdr$pixdim[4],img_hdr$dim[4]/2*img_hdr$pixdim[4],len = img_hdr$dim[4])
  grid_coords <- expand.grid(x, y, z)
  
  # Run marching cubes to the mask image
  mask_th<-mean(c(min(mask),max(mask)))
  contour_shape <- rmarchingcubes::contour3d(griddata = mask, level = mask_th, x = x, y = y, z = z)
  
  # Interpolate surface on the intensity data
  mesh_i <- approx3d(x, y, z, data, contour_shape$vertices[,1], contour_shape$vertices[,2], contour_shape$vertices[,3])
  mesh_i_lim <- range(mesh_i)
  print(mesh_i_lim)
  mesh_i_len <- mesh_i_lim[2] - mesh_i_lim[1] + 1
  colorlut <- hcl.colors(mesh_i_len, palette = "viridis", alpha = NULL, rev = FALSE, fixup = TRUE)
  #colorlut <- hcl.colors(mesh_i_len, palette = "YlOrRd", alpha = NULL, rev = FALSE, fixup = TRUE)
  col <- colorlut[ mesh_i - mesh_i_lim[1] + 1 ]

  vertices_h <- t(cbind(contour_shape$vertices, rep(1, nrow(contour_shape$vertices))))
  faces_h <- t(contour_shape$triangles)
  
  # Create mesh
  #options(rgl.useNULL = FALSE)
  rgl::open3d()
  rgl::par3d("antialias")
  rgl::par3d(windowRect = c(0,0,500,500))
  mesh <- rgl::tmesh3d(vertices_h, faces_h, material=list(color = col))
  # Smooth for better visualization
  mesh <- Rvcg::vcgSmooth(mesh, type = "taubin", iteration = 10, lambda = 0.5, mu = -0.53, delta = 0.1)
  
  # Draw the mesh.
  mesh_col <- rgl::shade3d(mesh, meshColor = "vertices", specular="black")
  Min<-mesh_i_lim[1]/scale
  Max<-mesh_i_lim[2]/scale
  Tick_step<-(Max-Min)/9
  Ticks<-seq(Min,Max,Tick_step)
  Ticks_str<-c()
  for (i in 1:length(Ticks)) {
    Ticks_str<-c(Ticks_str, sprintf("%.1f", Ticks[i]))
  }
  
  # Create views
  options(rgl.useNULL = FALSE)
  um<-list()
  um[[length(um)+1]]<-diag(4)
  um[[length(um)+1]]<-get_rot_matrix(2, pi)
  um[[length(um)+1]]<-get_rot_matrix(1, -pi/2)
  um[[length(um)+1]]<-get_rot_matrix(3, pi)%*%get_rot_matrix(1, pi/2)
  um[[length(um)+1]]<-get_rot_matrix(2, -pi/2)%*%get_rot_matrix(3, pi)%*%get_rot_matrix(1, pi/2)
  um[[length(um)+1]]<-get_rot_matrix(2, pi/2)%*%get_rot_matrix(3, pi)%*%get_rot_matrix(1, pi/2)
  for (i in 1:6) {
    rgl::view3d(userMatrix=um[[i]], fov = 60, zoom = 1.0, interactive = FALSE, type = "modelviewpoint")
    rgl.snapshot(paste('3dplot_', i, '.png',sep=''), fmt = 'png')
    #rgl.postscript(paste('3dplot_', i, '.svg',sep=''), fmt = 'svg')
  }
  rgl::clear3d() 
  rgl::bgplot3d(suppressWarnings(fields::image.plot(legend.only=TRUE, legend.args=list(text=legend_title,cex = 4, side = 2, line = 0.1), zlim=(c(Min,Max)),col=colorlut,axis.args = list(at = 0:(length(Ticks_str)-1), labels=Ticks_str)))) 
  rgl.snapshot(paste('3dplot_', 7, '.png',sep=''), fmt = 'png')
  #rgl.postscript(paste('3dplot_', 7, '.svg',sep=''), fmt = 'svg')
  rgl::close3d()
  
  # Concatenate the images
  pngdata <- readPNG(paste('3dplot_', 1, '.png',sep=''))
  file.remove(paste('3dplot_', 1, '.png',sep=''))
  d<-dim(pngdata)
  d1<-c(d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1)
  d2<-c(d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9)
  d3<-c(d[2]*0.2,d[2]*0.2,d[2]*0.2,d[2]*0.2,d[2]*0.15,d[2]*0.15,d[2]*0.75)
  d4<-c(d[2]*0.8,d[2]*0.8,d[2]*0.8,d[2]*0.8,d[2]*0.85,d[2]*0.85,d[2]*1.0)
  pngdata<-pngdata[d1[1]:d2[1], d3[1]:d4[1], ]
  for (i in 2:6) {
    pngadd <- readPNG(paste('3dplot_', i, '.png',sep=''))
    file.remove(paste('3dplot_', i, '.png',sep=''))
    pngdata <- abind(pngdata, pngadd[d1[i]:d2[i], d3[i]:d4[i], ], along=2)
  }
  pngadd <- readPNG(paste('3dplot_', 7, '.png',sep=''))
  file.remove(paste('3dplot_', 7, '.png',sep=''))
  pngdata <- abind(pngdata, pngadd[d1[7]:d2[7], d3[7]:d4[7],], along=2)
  writePNG(pngdata, target=paste(output), metadata=sessionInfo())
}
