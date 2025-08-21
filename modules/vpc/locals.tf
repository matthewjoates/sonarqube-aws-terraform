locals {
  primary_az   = "${ data.aws_region.current.name }a"
  secondary_az = "${ data.aws_region.current.name }b"
}