variable "package" {
  type        = "string"
  description = "The NPM package to be bundled for use as a Lambda function."
}

variable "version" {
  type        = "string"
  default     = "*"
  description = "The package version."
}

variable "environment" {
  type        = "list"
  value       = []
  description = "Environment variables to inject into the Lambda function."
}

resource "null_resource" "runner" {
  triggers {
    filepath = "${path.cwd}/tmp/${md5("${var.package}${var.version}${jsonencode(sort(var.environment))}")}.zip"
  }

  provisioner "local-exec" {
    command = <<COMMAND
mkdir -p ${path.cwd}/tmp
${path.module}/bin/package ${join(" ", formatlist("-e \"%s\"", var.environment))} -o ${null_resource.runner.triggers.filepath} ${var.package}@${var.version}
COMMAND
  }
}

output "filepath" {
  value = "${null_resource.runner.triggers.filepath}"
}
