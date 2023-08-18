require("devtools")
require("roxygen2")
require("r2readthedocs")

devtools::create("skiftiTools")
devtools::build("skiftiTools")

rtd_dummy_pkg('skiftiTools')
rtd_dummy_pkg('skiftiTools', pkg_name = "skiftiTools")
