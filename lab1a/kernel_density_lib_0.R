source('./normal_point_mixture_lib.R')
      

# Fill in a kernel function
# Could be Gaussian, square, cosine
Kernel <- function(x, h) {
  # A kernel function for use in nonparametric estimation.
  # Args:
  #  x: The point to evaluate the kernel
  #  h: The bandwidth of the kernel.
  # Returns:
  #  The value of a kernel with bandwidth h evaluated at x.
  
  return()
}

EstimateDensity <- function(x.data, KernelFun, h, resolution=length(eval.x), eval.x=NULL) {
  # Perform a kernel density estimate.
  # Args:
  #   x.data: The observations from the density to be estimated.
  #   KernelFun: A kernel function.
  #   h: the bandwidth.
  #   resolution: The number of points at which to evaluate the density.  Only necessary
  #               if eval.x is unspecified.
  #   eval.x: Optional, the points at which to evaluate the density.  Defaults to
  #           resolution points in [ min(x.data), max(x.data) ]
  # Returns:
  #  A data frame containing the x values and kernel density estimates with
  #  column names "x" and "f.hat" respectively.
  
  return()
}


PerformSimulations <- function(sims, n, p, means, sds, eval.x, KernelFun, h) {
  # Simulate data from a normal point mixture and perform kernel estimators.
  # Args:
  #  sims: The number of simulations to run.
  #  n: The number of points in the dataset.
  #  p: The probabilities of each mixture component.
  #  means: The means of each mixture component.
  #  sds: The standard deviations of each mixture component.
  #  eval.x: The points at which to estimate the density.
  #  KernelFun: The kernel function, which should take a point and a bandwidth as arguments.
  #  h: The bandwidth of the estimator.
  #
  # Returns:
  #  A data frame containing the following information:
  #    sim: Which simulation the data came from
  #    x: The points at which the density is estimated.
  #    f.hat: The estimated density at x for this simulation.
  #    true.pdf: The true pdf at x

  true.pdf <- NormalPointMixtureDensity(x=eval.x, p=p, mean=means, sds=sds)
  results <- list()
  for (sim in 1:sims) {
    data <- NormalPointMixtureDraws(n, p=p, means=means, sds=sds)
    f.hat <- EstimateDensity(x.data=data, KernelFun=KernelFun, h=h, eval.x=eval.x)
    results[[as.character(sim)]] <- data.frame(sim=sim, x=eval.x,
                                               f.hat=f.hat$f.hat,
                                               true.pdf=true.pdf)
  }
  return(do.call(rbind, results))
}
