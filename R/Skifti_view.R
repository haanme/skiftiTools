#!/usr/bin/env Rscript
# This file is part of skiftiTools.
#
# skiftiTools is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# skiftiTools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2025 Turku Brain and Mind Center

library(rmarchingcubes)
library(RNifti)
# running rgl in system without graphics support
#options(rgl.useNULL = TRUE)
library(rgl)
library(fields)
library(abind)
library(png)
library(Rvcg)
#library(oce)
#library(s2dverification)

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
#' @param keep_temp TRUE/FALSE(default) to keep temporary png images
#' @param palette 
#'
#' @export
#'
save_skeleton <- function(mask, data, img_hdr, output, legend_title, scale, keep_temp=FALSE, palette="lajolla") {
  
  data<-data*scale
  print(paste("Data extreme values for visualization min:", min(data), " max:", max(data), sep=""))
  
  x <- seq(-img_hdr$dim[2]/2*img_hdr$pixdim[2],img_hdr$dim[2]/2*img_hdr$pixdim[2],len = img_hdr$dim[2])
  y <- seq(-img_hdr$dim[3]/2*img_hdr$pixdim[3],img_hdr$dim[3]/2*img_hdr$pixdim[3],len = img_hdr$dim[3])
  z <- seq(-img_hdr$dim[4]/2*img_hdr$pixdim[4],img_hdr$dim[4]/2*img_hdr$pixdim[4],len = img_hdr$dim[4])
  grid_coords <- expand.grid(x, y, z)
  
  # Run marching cubes to the mask image
  mask_th<-mean(c(min(mask),max(mask)))
  contour_shape <- rmarchingcubes::contour3d(griddata = mask, level = mask_th, x = x, y = y, z = z)
  
  # Interpolate surface on the intensity data
  #f <- array(rep(rep(1:length(z),length(y)),length(x)), dim = c(length(x), length(y), length(z)))
  print(min(x))
  print(max(x))
  print(length(x))
  print(min(y))
  print(max(y))
  print(length(y))
  print(min(z))
  print(max(z))
  print(length(z))
  print(min(contour_shape$vertices[,1]))
  print(max(contour_shape$vertices[,1]))
  print(length(contour_shape$vertices[,1]))
  print(min(contour_shape$vertices[,2]))
  print(max(contour_shape$vertices[,2]))
  print(length(contour_shape$vertices[,2]))
  print(min(contour_shape$vertices[,3]))
  print(max(contour_shape$vertices[,3]))
  print(length(contour_shape$vertices[,3]))
  mesh_i <- approx3d(x, y, z, data, contour_shape$vertices[,1], contour_shape$vertices[,2], contour_shape$vertices[,3])
  mesh_i <- round(mesh_i)+1
  print(unique(round(mesh_i)))  
  #mesh_i <- approx3d(x, y, z, data, contour_shape$vertices[,1], contour_shape$vertices[,2], contour_shape$vertices[,3])
  mesh_i_lim <- range(mesh_i)
  Ticks<-seq(mesh_i_lim[1]*0.99,mesh_i_lim[2]*1.01,length.out = 39)
  print(paste("Extreme values at surface mesh for visualization min:", mesh_i_lim[1], " max:", mesh_i_lim[2], sep=""))
  mesh_i_len <- mesh_i_lim[2] - mesh_i_lim[1] + 1
  print(mesh_i_len)
  colorlut <- hcl.colors(mesh_i_len, palette = palette, alpha = NULL, rev = FALSE, fixup = TRUE)
  #colorlut <- hcl.colors(mesh_i_len, palette = "YlOrRd", alpha = NULL, rev = FALSE, fixup = TRUE)
  print(colorlut)
  col<-colorlut[mesh_i]
#  col<-c()
#  for(mi in 1:length(mesh_i)) {
#    col <- c(col, colorlut[mesh_i[mi]])
#  }
#  col <- colorlut[ mesh_i - mesh_i_lim[1] ]
  print(length(col))
  Tickscol <- seq(0.0, mesh_i_lim[2]-mesh_i_lim[1],length.out = 39)
  Tickscol <- colorlut[ Tickscol ]

  vertices_h <- t(cbind(contour_shape$vertices, rep(1, nrow(contour_shape$vertices))))
  faces_h <- t(contour_shape$triangles)
  print(dim(vertices_h))
  
  # Create mesh
  #options(rgl.useNULL = FALSE)
  rgl::open3d()
  rgl::par3d("antialias")
  rgl::par3d(windowRect = c(0,0,500,500))
  mesh <- rgl::tmesh3d(vertices=vertices_h, indices=faces_h, material=list(color = col))
  #mesh <- rgl::tmesh3d(vertices=vertices_h, triangles=faces_h, material=list(color = col))
  # Smooth for better visualization
  mesh <- Rvcg::vcgSmooth(mesh, type = "taubin", iteration = 10, lambda = 0.5, mu = -0.53, delta = 0.1)
  
  # Draw the mesh.
  mesh_col <- rgl::shade3d(mesh, meshColor = "vertices", specular="black")

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
  }

  rgl::clear3d()
  rgl::bgplot3d(ColorBar(brks=Ticks/scale, cols=Tickscol, 
                         title=legend_title, title_scale = 4.0, 
                         tick_scale = 0.0, label_digits=3, label_scale=4.0, lwd=8.0))
  rgl.snapshot(paste('3dplot_', 7, '.png',sep=''), fmt = 'png')
  #rgl.postscript(paste('3dplot_', 7, '.svg',sep=''), fmt = 'svg')
  rgl::close3d()
  
  # Concatenate the images
  pngdata <- readPNG(paste('3dplot_', 1, '.png',sep=''))
  if(keep_temp==FALSE) {
    file.remove(paste('3dplot_', 1, '.png',sep=''))
  }
  d<-dim(pngdata)
  d1<-c(d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1,d[1]*0.1)
  d2<-c(d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9,d[1]*0.9)
  d3<-c(d[2]*0.2,d[2]*0.2,d[2]*0.2,d[2]*0.2,d[2]*0.15,d[2]*0.15,d[2]*0.1)
  d4<-c(d[2]*0.8,d[2]*0.8,d[2]*0.8,d[2]*0.8,d[2]*0.85,d[2]*0.85,d[2]*1.0)
  pngdata<-pngdata[d1[1]:d2[1], d3[1]:d4[1], ]
  for (i in 2:6) {
    pngadd <- readPNG(paste('3dplot_', i, '.png',sep=''))
    if(keep_temp==FALSE) {
      file.remove(paste('3dplot_', i, '.png',sep=''))
    }
    pngdata <- abind(pngdata, pngadd[d1[i]:d2[i], d3[i]:d4[i], ], along=2)
  }
  pngadd <- readPNG(paste('3dplot_', 7, '.png',sep=''))
  # pad 3D shape images to match color bar size
  yoffset<-dim(pngadd)[1]-dim(pngdata)[1]
  yoffset_modulo<-(yoffset %% 2)
  ypad_lo<-(yoffset-yoffset_modulo)/2+yoffset_modulo
  ypad_hi<-(yoffset-yoffset_modulo)/2
  ypad_lo<-array(1, c(ypad_lo, dim(pngdata)[2], 3))
  ypad_hi<-array(1, c(ypad_hi, dim(pngdata)[2], 3))
  pngdata<-abind(ypad_lo, pngdata, ypad_hi, along=1)
  pngdata <- abind(pngdata, pngadd[,d3[7]:(d[2]*0.3),], pngadd[,(d[2]*0.6):d4[7],], along=2)
  if(keep_temp==FALSE) {
    file.remove(paste('3dplot_', 7, '.png',sep=''))
  }
  writePNG(pngdata, target=paste(output), metadata=sessionInfo())
}
