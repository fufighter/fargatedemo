region           = "us-east-1"
env_name         = "dev"
project          = "dog"
buildprojects = {
  docker  = "buildspec.yml"
  tfsec   = "buildspec_tfsec.yml"
  tfplan  = "buildspec_tfplan.yml"
  tfapply = "buildspec_tfapply.yml"
}