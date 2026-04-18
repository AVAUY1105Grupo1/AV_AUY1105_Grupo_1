# AV_AUY1105_Grupo_1 - Evaluación Parcial N°1

**Estudiante:** Bryan Painemilla  
**Curso:** Infraestructura como Código II 001V
**Institución:** Duoc UC  
**Semestre:** 1 - 2026

## 1. Descripción del Proyecto
Este repositorio gestiona la infraestructura en la nube para el proyecto **duocapp**. Utiliza Terraform para desplegar un entorno web seguro en AWS (us-east-1), integrando herramientas de auditoría y políticas para garantizar un despliegue de alto rendimiento y bajo costo.

## 2. Arquitectura de Infraestructura (AWS)
La infraestructura desplegada incluye los siguientes componentes core:
- **Redes:** VPC con bloque CIDR 10.1.0.0/16, subredes públicas en múltiples zonas de disponibilidad y Gateway de Internet.
- **Seguridad:** Security Group configurado exclusivamente para acceso administrativo vía SSH (puerto 22).
- **Cómputo:** Instancia EC2 Ubuntu 24.04 LTS (t2.micro).
- **Gestión de Identidad:** Generación dinámica de llaves SSH (RSA 4096) integradas en el flujo de Terraform.

## 3. Calidad y Gobernanza (Quality Gate)
Para cumplir con la rúbrica de la evaluación, se han implementado las siguientes herramientas de análisis:

### 3.1. TFLint
Se realiza un análisis estático para asegurar que el código cumpla con las mejores prácticas de AWS.
- **Configuración:** `.tflint.hcl` con el plugin de AWS habilitado.
- **Uso:** `tflint --init` seguido de `tflint`.

### 3.2. Open Policy Agent (OPA)
Se aplica **Políticas como Código** para validar el cumplimiento de las restricciones de presupuesto.
- **Política:** `policy/check.rego`.
- **Regla:** Solo se permite el despliegue de instancias tipo `t2.micro`. Cualquier otro tipo de instancia será rechazado en la fase de auditoría.

### 3.3. terraform-docs
Generación automática de documentación técnica para mantener el `README.md` siempre actualizado con el estado real del código.

## 4. Guía de Ejecución Local
Siga estos pasos para validar sus cambios antes de enviarlos a la rama principal:

1. **Sincronizar proveedores:** `terraform init`
2. **Validar Políticas (OPA):** `terraform plan -out=tfplan.binary`  
   `terraform show -json tfplan.binary > tfplan.json`  
   `opa eval -i tfplan.json -d policy/check.rego "data.terraform.analysis.allow"`
3. **Generar Documentación:** `terraform-docs .`

---

## 5. Documentación de Recursos (Auto-generada)
*(Esta sección se actualiza automáticamente al ejecutar terraform-docs)*

### Ejemplo de la documentación con terraform-docs:

# Documentación de Infraestructura


<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.41.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.8.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.deployer_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.rsa_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | n/a |
<!-- END_TF_DOCS -->
