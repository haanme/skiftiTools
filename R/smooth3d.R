#!/usr/bin/env Rscript

# This file is part of skiftiTools.
#
# skiftiTools is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# skiftiTools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with skiftiTools. If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2026 Turku Brain and Mind Center

library(RNifti)

#' Creates smoothing kernel
#' 
#' @param sigma smoothing amount in data sample units
#' 
#' @return smoothing kernel
#'
gaussian_kernel <- function(sigma) {
  if (sigma <= 0)
    return(1)
  radius <- ceiling(4 * sigma)
  x <- -radius:radius
  k <- exp(-(x^2) / (2 * sigma^2))
  k / sum(k)
}

#' Smooth data, 1-dimension
#' 
#' @param x data array
#' @param kernel smoothing kernel
#' 
#' @return smoothed data
#'
smooth_1d <- function(x, kernel) {
  stats::filter(x, kernel, sides = 2, method = "convolution")
}

#' Smooth 3D image data along single axis
#' 
#' @param img 3D data matrix
#' @param sigma smoothing amount in voxel units, of selected axis
#' @param axis selected for smoothing
#' 
#' @return smoothed data
#' @importFrom RNifti
#' @example man/examples/smooth3d_examples.R
#'
smooth_along_axis <- function(img, sigma, axis)
{
  kernel <- gaussian_kernel(sigma)
  if (length(kernel) == 1)
    return(img)
  perm <- c(axis, setdiff(seq_along(dim(img)), axis))
  tmp <- aperm(img, perm)
  dims <- dim(tmp)
  mat <- matrix(tmp, nrow = dims[1], ncol = prod(dims[-1]))
  for (i in seq_len(ncol(mat)))
  {
    v <- as.numeric(mat[, i])
    sv <- smooth_1d(v, kernel)
    na.idx <- is.na(sv)
    sv[na.idx] <- v[na.idx]
    mat[, i] <- sv
  }
  tmp <- array(mat, dim = dims)
  aperm(tmp, order(perm))
}

#' Smooth 3D image data, with isotropic kernel
#' 
#' @param data 3D or 4D data matrix
#' @param voxel_sizes data voxel dimensions x, y, z in mm
#' @param fwhm_mm Full Width at Half Maximum (FWHM) in mm of smoothing
#' 
#' @return smoothed data
#' @importFrom RNifti niftiHeader readNifti
#' @export
#' @example man/examples/smooth3d_examples.R
#'
smooth_3d_mm <- function(data, voxel_sizes, fwhm_mm)
{
  sigma_mm <- fwhm_mm / 2.354820045
  sigma_vox <- sigma_mm / voxel_sizes
  smooth_volume <- function(vol)
  {
    vol <- smooth_along_axis(vol, sigma_vox[1], 1)
    vol <- smooth_along_axis(vol, sigma_vox[2], 2)
    vol <- smooth_along_axis(vol, sigma_vox[3], 3)
    
    vol
  }
  
  if (length(dim(data)) == 3)
  {
    smooth_volume(data)
  } else if (length(dim(data)) == 4)
  {
    result <- data
    for (t in seq_len(dim(data)[4]))
    {
      cat("Smoothing volume", t, "of", dim(data)[4], "\n")
      result[,,,t] <- smooth_volume(data[,,,t])
    }
    result
  } else
  {
    stop(
      sprintf(
        "Unsupported image dimensionality: %d",
        length(dim(data))
      )
    )
  }
}

# Command line interface function
main <- function()
{
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 3)
  {
    stop(
      paste(
        "Usage:",
        "Rscript smooth_nifti.R",
        "input.nii.gz",
        "output.nii.gz",
        "fwhm_mm"
      )
    )
  }
  # Read parameters
  input_file  <- args[1]
  output_file <- args[2]
  fwhm_mm     <- as.numeric(args[3])
  
  img <- readNifti(input_file)
  data <- as.array(img)
  voxel_sizes <- pixdim(img)[1:3]
  cat("Voxel size:", paste(voxel_sizes, collapse = " x "), "mm\n")
  cat("FWHM:", fwhm_mm, "mm\n")
  smoothed_data <- smooth_3d_mm(data, voxel_sizes, fwhm_mm)
  out_img <- updateNifti(smoothed_data, template = img)
  writeNifti(out_img, output_file)
  cat("Saved:", output_file, "\n")
}

# run command line interface
main()