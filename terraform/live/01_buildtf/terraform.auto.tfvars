region           = "us-east-1"
project          = "dog"
buildprojects = {
  docker  = "buildspec.yml"
  tfsec   = "buildspec_tfsec.yml"
  tfplan  = "buildspec_tfplan.yml"
  tfapply = "buildspec_tfapply.yml"
  tfplan_ecr = "buildspec_tfplan_ecr.yml"
}