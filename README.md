# Voting App - Proyecto DevOps

Este repositorio contiene una aplicación de votación compuesta por múltiples servicios (`vote`, `result`, `worker`), una infraestructura definida con Terraform para su despliegue en Amazon Web Services (AWS), y pipelines de CI/CD automatizados con GitHub Actions.

## Estructura del Proyecto

```
.
├── .app/                  # Código de los microservicios (vote, result, worker)
├── .infra/
│   ├── terraform/         # Infraestructura como código (EKS, VPC, etc.)
│   │   ├── dev.tfvars     # Variables para entorno Dev
│   │   ├── test.tfvars    # Variables para entorno Test
│   │   ├── prod.tfvars    # Variables para entorno Prod
│   ├── k8s-specifications/ # Archivos YAML de despliegue para K8s
│   └── healthcheck-lambda/ # Lambda opcional de monitoreo
├── .github/workflows/     # Pipelines de CI/CD
├── scripts/               # Scripts de utilidad (espera, test, etc.)
└── tests/                 # Tests funcionales (colecciones Postman)
```

## Despliegue

### Requisitos previos

- AWS CLI configurado
- Terraform ≥ 1.5.0
- kubectl
- Docker
- Cuenta en SonarCloud
- Repositorio en GitHub con Secrets configurados

### Secrets requeridos

En GitHub Actions (`Settings > Secrets`):

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`
- `SONAR_TOKEN`

### Despliegue automático (vía GitHub Actions)

1. Hacer push a la rama correspondiente:
   - `dev` → Despliega en entorno de desarrollo.
   - `test` → Corre quality gates y tests funcionales.
   - `main` → Requiere aprobación manual y despliega a producción.

2. El pipeline:
   - Crea/actualiza infraestructura con Terraform.
   - Ejecuta análisis de código (SonarCloud).
   - Escanea imágenes Docker (Trivy).
   - Construye y sube imágenes a Amazon ECR.
   - Aplica los manifiestos Kubernetes en EKS.
   - Corre tests funcionales con Newman.

### Despliegue manual (infraestructura)

```bash
cd .infra/terraform
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -auto-approve -var-file=dev.tfvars
```

### Aplicación en Kubernetes

```bash
# Cargar configuración de cluster
aws eks update-kubeconfig --name <nombre_cluster> --region <region>

# Aplicar manifiestos
kubectl apply -f .infra/k8s-specifications/
```

##  Observabilidad

- **Dashboard Grafana**: Visualiza uso de CPU, memoria y estado de pods por namespace.
- **Alertas configuradas**:
  - Alto uso de CPU.
  - Uso de memoria mayor al 90%.

## Testing

- **Funcional**: Automatizado con Newman y Postman.
- **Estático**: Análisis con SonarCloud.
- **Seguridad**: Escaneo de imágenes con Trivy.

## Tecnologías utilizadas

- AWS (EKS, ECR, Lambda)
- Terraform
- Kubernetes
- Docker
- GitHub Actions
- Prometheus + Grafana
- SonarCloud
- Trivy
- Postman / Newman

##  Autor

Santiago Rafael Paris Della Valle  
Proyecto Obligatorio DevOps 2025  
Universidad ORT
---

## 📄 Licencia

Este proyecto fue desarrollado con fines educativos y académicos.
