package terraform.analysis

default allow = false

# Regla: Permitir solo si el tipo de instancia es t2.micro
allow {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    resource.change.after.instance_type == "t2.micro"
}