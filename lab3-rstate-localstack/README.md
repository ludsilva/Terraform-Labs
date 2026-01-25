# Lab 3 - VPC Multi-AZ com Load Balancer e Remote state (S3)
Com objetivo de evoluir os labs anteriores, foi implementada uma VPC Multi-AZ com Load Balancer (ALB), instâncias privadas e Remote state S3 utilizando o Terraform e LocalStack.

### Objetivos
Esse laboratório objetiva criar:

- 1 VPC
- Subnets públicas e privadas, em multi-AZ (preparação para o próximo laboratório)
- Internet Gateway
- NAT Gateway (único, por enquanto)
- Route Tables públicas e privadas
- Application Load Balancer (ALB)
- Target Group
- EC2 privadas atrás do ALB
- Security Groups para comunicação do ALB para EC2
- Remote State com bucket S3

## Estrutura

```text
├── terraform.tf
├── main.tf
├── vpc.tf
├── security_groups.tf
├── ec2.tf 
├── variables.tf
├── outputs.tf
└── README.md
```
## Como executar

É necessário ter instalado:

- [Docker](https://docs.docker.com/get-started/get-docker/)
- [LocalStack CLI](https://docs.localstack.cloud/aws/getting-started/installation/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)


Faça um clone deste repositório e navegue até ao diretório do projeto:

`git clone https://github.com/ludsilva/Terraform-Labs.git && cd Terraform-Labs/lab3-rstate-localstack`

Abra o terminal e siga os passos a seguir:

**1. Subir o LocalStack**

`localstack start -d`


**2. Definir variáveis de ambiente AWS (falsas)**
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

**3. Criar bucket S3 para remote state**
Crie um bucket S3 para armazenar o remote state do Terraform:
```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf-state
```

**4. Inicializar o Terraform, rodar plan e apply**
```bash
terraform init
terraform plan
terraform apply --auto-approve
```

**5. Validar**
Valide a saída do comando:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

**6. Destruir os recursos**
```bash
terraform destroy
```

**7. Destruir o bucket S3**
Como boa prática, lembre-se de destruir o bucket S3 criado para o remote state, caso contrário, ele permanecerá no LocalStack:
```bash
aws --endpoint-url=http://localhost:4566 s3 rb s3://tf-state --force
```

#### Observações
O estado do Terraform é armazenado remotamente em um bucket S3 simulado pelo LocalStack, e para garantir compatibilidade entre LocalStack + backend S3, foi mantida a versão 5.0 do provider AWS.

Além disso, em cenários reais é recomendado criar um NAT Gateway para cada AZ em cenários de alta disponibilidade (VPC Multi-AZ), mas para simplificação deste laboratório, foi criado apenas um NAT Gateway.

## Documentação de referência
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Remote State with S3](https://developer.hashicorp.com/terraform/language/backend/s3)
- [AWS - Gateways NAT](https://docs.aws.amazon.com/pt_br/vpc/latest/userguide/vpc-nat-gateway.html)