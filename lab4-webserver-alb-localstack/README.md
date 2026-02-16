# Lab 4 - Webserver na AWS (LocalStack)
Este tem como objetivo implementar uma infraestrutura de webserver com Nginx e banco de dadaos na AWS, utilizando o LocalStack para simular os serviços da AWS localmente.

Os recursos provisionados incluem:
- 1 VPC com 4 subnets (2 públicas e 2 privadas) distribuídas em diferentes AZs para Alta Disponibilidade;
- Internet Gateway para acesso público e 2 NAT Gateways para saída de internet das subnets privadas;
- Security Groups organizados de forma a garantir que o banco de dados e instâncias privadas não fiquem expostos à internet
- 2 Instâncias EC2 (Dev em subnet pública e Prod em subnet privada)
- 2 Application Load Balancers (ALB, 1 prod e 1 dev) gerenciando o tráfego de entrada
- 2 instâncias RDS PostgreSQL privadas (prod e dev)
- buckets S3 para armazenamento de logs de acesso e errors dos ALBs, além do bucket para o remote state do Terraform.

## Estrutura do Repositório
O projeto utiliza módulos locais para organizar a lógica da infraestrutura:

- `modules/vpc`: Módulo de rede (VPC, subnets, internet gateway, nat gateways, route tables);;
- `modules/ec2`: Módulo para provisionamento das instâncias com Nginx via user data;
- `modules/security`: Centralização das regras dos security groups.

## Como utilizar

Pré-requisitos:

- [Docker](https://docs.docker.com/get-started/get-docker/)
- [LocalStack CLI](https://docs.localstack.cloud/aws/getting-started/installation/) (utilizada a versão for Students)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Faça um clone deste repositório e navegue até ao diretório do projeto:

`git clone https://github.com/ludsilva/Terraform-Labs.git && cd Terraform-Labs/lab4-webserver-alb-localstack`

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
aws --endpoint-url=http://localhost:4566 s3 mb s3://lab4-tf-state
```

**4. Inicializar o Terraform, rodar plan e apply**
```bash
terraform init
terraform plan
terraform apply --auto-approve
```

**5. Validar**
Execute os comandos para validar:
```bash
## EC2
aws --endpoint-url=http://localhost:4566 ec2 describe-instances

## ALB
aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers

## RDS
aws --endpoint-url=http://localhost:4566 rds describe-db-instances

## Buckets
aws --endpoint-url=http://localhost:4566 s3 ls
```

**6. Destruir os recursos**
```bash
terraform destroy
```

**7. Destruir o bucket S3**
Como boa prática, lembre-se de destruir o bucket S3 criado para o remote state, caso contrário, ele permanecerá no LocalStack:
```bash
aws --endpoint-url=http://localhost:4566 s3 rb s3://lab4-tf-state --force
```

## Desafios e aprendizados
**Dificuldades e Limitações**
- Devido a instabilidades na versão do módulo oficial do ALB na versão 9.0 para definição de target groups no LocalStack, optou-se pela utilização da versão 8.0;
- a dependência entre Security Groups exigiu um planejamento maior para evitar dependências cíclicas entre instâncias e firewalls;

**Decisões Técnicas**
- Optou-se por módulos locais para os recursos de VPC, EC2 e Security Groups, visando uma melhor organização e reutilização de código;
- Separação da camada de SGs em um módulo específico, abandonando a lógica de dynamic ingress pensada inicialmente dentro da EC2 para permitir um gerenciamento centralizado e mais granular;
- Uso da função merge para combinar tags globais do projeto com tags específicas de cada recurso (como o Tier e Name).

## Melhorias futuras
- Implementar a execução em ambiente AWS real;
- Reduzir repetições na chamada de módulos (for_each e outras formas de otimização);
- Implementar, caso necessário e se aplique, blocos de lifecycle para evitar destruição acidental de recursos críticos.

## Referências

- [How to Build AWS VPC Using Terraform - Step By Step](https://dev.to/aws-builders/how-to-build-aws-vpc-using-terraform-step-by-step-3k7f)
- [Creating a Custom Module for an EC2 Instance with Terraform](https://helenccampbell.medium.com/creating-a-custom-module-for-an-ec2-instance-with-terraform-eb624776f3c9)
- [Terraform Doc: templatefile Function](https://developer.hashicorp.com/terraform/language/functions/templatefile)
- [Terraform Registry: Resource aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
- [AWS Terraform ALB Module](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)
- [AWS Terraform RDS Module](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest)
- [How to Use Terraform Merge Function](https://spacelift.io/blog/terraform-merge-function)
- [Video: How to use Terraform merge tags?](https://www.youtube.com/watch?v=87Vt5todeD8)