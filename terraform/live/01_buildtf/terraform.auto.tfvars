region           = "us-east-1"
project          = "dog"
buildprojects = {
  docker  = "buildspec.yml"
  tfsec   = "buildspec_tfsec.yml"
  tfplan  = "buildspec_tfplan.yml"
  tfapply = "buildspec_tfapply.yml"
}