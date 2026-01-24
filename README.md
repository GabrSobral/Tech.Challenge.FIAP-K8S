# Infraestrutura Kubernetes (EKS) - Tech Challenge

Este repositório contém o código Terraform responsável pelo provisionamento da infraestrutura em nuvem na AWS para o projeto **Tech Challenge**. O foco principal é a orquestração de containers utilizando Amazon EKS (Elastic Kubernetes Service).

## 🎯 Objetivo

O objetivo deste projeto é automatizar a criação de um ambiente robusto, seguro e escalável para hospedar microsserviços. A infraestrutura provisiona:
* Um cluster Kubernetes gerenciado (EKS).
* Repositórios de imagens seguros (ECR).
* Configurações de rede e permissões (IAM/VPC).
* Camada de observabilidade e controladores de tráfego.

## 🛠 Tecnologias e Requisitos Técnicos

As seguintes tecnologias e providers foram utilizados na definição da infraestrutura:

* **IaC:** [Terraform](https://www.terraform.io/) (versão >= 1.6.0)
* **Cloud Provider:** AWS (Amazon Web Services)
* **Orquestração:** Amazon EKS (Kubernetes v1.34)
* **Gerenciamento de Pacotes K8s:** Helm Provider (versão >= 2.9)
* **Observabilidade:** New Relic (via Helm Chart `nri-bundle`)
* **Ingress Controller:** AWS Load Balancer Controller

## 🚀 Getting Started

### Pré-requisitos
Para executar este projeto, você precisará ter instalado e configurado em sua máquina:

1.  **AWS CLI**: Configurado com credenciais que possuam permissão de *Administrator* ou equivalente.
2.  **Terraform**: Versão 1.6.0 ou superior.
3.  **Kubectl**: Para interagir com o cluster após a criação.

### Variáveis Necessárias
O projeto utiliza variáveis sensíveis (como a chave de licença do New Relic). Recomenda-se criar um arquivo `terraform.tfvars` ou passar via linha de comando:

* `new_relic_license_key`: Sua chave de licença de ingestão do New Relic.
* `project_name`: Nome base para os recursos (ex: `tech-challenge`).
* `instance_type`: Tipo de instância EC2 para os nós (ex: `t3.medium`).

## 📦 Recursos Criados pelo Terraform

O código está modularizado para criar os seguintes componentes:

### 1. Computação e Cluster (EKS)
* **Cluster EKS:** Versão 1.34 com autenticação via API.
* **Node Group:** Gerenciado via **Launch Template** customizado, forçando o uso de **IMDSv2** (tokens HTTP obrigatórios) para maior segurança.
* **Escalabilidade:** Configuração de Auto Scaling (Min: 1, Desejado: 2, Max: 3).

### 2. Armazenamento de Imagens (ECR)
* **Repositório:** `tech-challenge-repo` configurado como **IMUTÁVEL** (tags não podem ser sobrescritas).
* **Scan:** *Scan on push* ativado para detectar vulnerabilidades.
* **Lifecycle Policy:** Regra automática para remover imagens sem tag (*untagged*) após **14 dias**, otimizando custos.

### 3. Add-ons e Controladores (Helm)
* **AWS Load Balancer Controller:** Instalado no namespace `kube-system`, permitindo a criação de ALBs/NLBs nativos da AWS via manifestos Kubernetes. Utiliza *IAM Roles for Service Accounts* (IRSA).
* **New Relic Bundle:** Instalado no namespace `newrelic`, com coleta de Logs e Eventos do Kubernetes habilitada.

### 4. IAM e Segurança
* **OIDC Provider:** Configurado para permitir que *Service Accounts* do Kubernetes assumam roles da AWS.
* **Access Entries:** Configuração moderna de acesso ao EKS (`aws_eks_access_entry`) substituindo o antigo `aws-auth` ConfigMap.

## ▶️ Como Rodar

1.  **Inicialize o Terraform:**
    Baixe os providers e configure o backend S3 (certifique-se de ter acesso ao bucket `tech-challenge-fiap-s3-bucket`).
    ```bash
    terraform init
    ```

2.  **Planeje a Infraestrutura:**
    Verifique os recursos que serão criados.
    ```bash
    terraform plan -var="new_relic_license_key=SUA_CHAVE_AQUI"
    ```

3.  **Aplique as Mudanças:**
    Provisione a infraestrutura na AWS.
    ```bash
    terraform apply -var="new_relic_license_key=SUA_CHAVE_AQUI" --auto-approve
    ```

4.  **Configurar Kubectl (Pós-instalação):**
    Após o término, configure seu contexto local para acessar o cluster:
    ```bash
    aws eks update-kubeconfig --region us-east-1 --name tech-challenge-eks-cluster
    ```