# Infraestrutura Kubernetes (EKS) - Tech Challenge

Este repositório contém o código Terraform responsável pelo provisionamento da infraestrutura em nuvem na AWS para o projeto **Tech Challenge**. O foco principal é a orquestração de containers utilizando Amazon EKS (Elastic Kubernetes Service).

## 📑 Sumário

- [Objetivo](#-objetivo)
- [Tecnologias e Requisitos Técnicos](#-tecnologias-e-requisitos-técnicos)
- [Getting Started](#-getting-started)
- [Recursos Criados pelo Terraform](#-recursos-criados-pelo-terraform)
  - [Computação e Cluster (EKS)](#1-computação-e-cluster-eks)
  - [Armazenamento de Imagens (ECR)](#2-armazenamento-de-imagens-ecr)
  - [Add-ons e Controladores (Helm)](#3-add-ons-e-controladores-helm)
  - [IAM e Segurança](#4-iam-e-segurança)
- [Como Rodar](#️-como-rodar)

---

## Outros repositórios

- [Database](https://github.com/GabrSobral/Tech.Challenge.FIAP-Database)
- [API](https://github.com/GabrSobral/Tech.Challenge.FIAP)
- [Lambda Function](https://github.com/GabrSobral/Tech.Challenge.FIAP---Lambda-Functions)


## 🎯 Objetivo

O objetivo deste projeto é automatizar a criação de um ambiente robusto, seguro e escalável para hospedar microsserviços. A infraestrutura provisiona:
* Um cluster Kubernetes gerenciado (EKS).
* Repositórios de imagens seguros (ECR).
* Configurações de rede e permissões (IAM/VPC).
* Camada de observabilidade e controladores de tráfego.

## 🛠 Tecnologias e Requisitos Técnicos

As seguintes tecnologias e providers foram utilizados na definição da infraestrutura:

* [cite_start]**IaC:** [Terraform](https://www.terraform.io/) (versão >= 1.6.0)[cite: 16].
* **Cloud Provider:** AWS (Amazon Web Services).
* [cite_start]**Orquestração:** Amazon EKS (Kubernetes v1.34)[cite: 21].
* [cite_start]**Gerenciamento de Pacotes K8s:** Helm Provider (versão >= 2.9)[cite: 16].
* [cite_start]**Observabilidade:** New Relic (via Helm Chart `nri-bundle`)[cite: 5].
* [cite_start]**Ingress Controller:** AWS Load Balancer Controller[cite: 3].

## 🚀 Getting Started

### Pré-requisitos
Para executar este projeto, você precisará ter instalado e configurado em sua máquina:

1.  **AWS CLI**: Configurado com credenciais que possuam permissão de *Administrator* ou equivalente.
2.  [cite_start]**Terraform**: Versão 1.6.0 ou superior[cite: 16].
3.  **Kubectl**: Para interagir com o cluster após a criação.

### Variáveis Necessárias
O projeto utiliza variáveis sensíveis (como a chave de licença do New Relic). Recomenda-se criar um arquivo `terraform.tfvars` ou passar via linha de comando:

* [cite_start]`new_relic_license_key`: Sua chave de licença de ingestão do New Relic[cite: 5].
* [cite_start]`project_name`: Nome base para os recursos (ex: `tech-challenge`)[cite: 21].
* [cite_start]`instance_type`: Tipo de instância EC2 para os nós (ex: `t3.medium`)[cite: 23].

## 📦 Recursos Criados pelo Terraform

O código está modularizado para criar os seguintes componentes:

### 1. Computação e Cluster (EKS)
* [cite_start]**Cluster EKS:** Versão 1.34 com autenticação via API[cite: 21].
* [cite_start]**Node Group:** Gerenciado via **Launch Template** customizado[cite: 23].
* [cite_start]**Segurança de Instância:** Força o uso de **IMDSv2** (tokens HTTP obrigatórios) para proteger os metadados dos nós[cite: 24].
* [cite_start]**Escalabilidade:** Configuração de Auto Scaling (Min: 1, Desejado: 2, Max: 3)[cite: 27].

### 2. Armazenamento de Imagens (ECR)
* [cite_start]**Repositório:** `tech-challenge-repo` configurado como **IMUTÁVEL** (tags não podem ser sobrescritas)[cite: 18].
* [cite_start]**Scan:** *Scan on push* ativado para detectar vulnerabilidades[cite: 18].
* [cite_start]**Lifecycle Policy:** Regra automática para remover imagens sem tag (*untagged*) que tenham mais de **14 dias**, otimizando custos[cite: 19].

### 3. Add-ons e Controladores (Helm)
* [cite_start]**AWS Load Balancer Controller:** Instalado no namespace `kube-system`[cite: 3], permitindo a criação de ALBs/NLBs nativos da AWS via manifestos Kubernetes. [cite_start]Utiliza políticas IAM específicas baixadas dinamicamente[cite: 30].
* [cite_start]**New Relic Bundle:** Instalado no namespace `newrelic`, com coleta de Logs e Eventos do Kubernetes habilitada[cite: 5, 6].

### 4. IAM e Segurança
* [cite_start]**OIDC Provider:** Configurado para permitir que *Service Accounts* do Kubernetes assumam roles da AWS (IRSA)[cite: 31].
* [cite_start]**Access Entries:** Configuração de acesso moderna (`STANDARD`) para o principal usuário IAM e grupos Kubernetes[cite: 1].
* [cite_start]**Policies:** Uso de políticas gerenciadas como `AmazonEKSClusterAdminPolicy` para controle de acesso granular[cite: 1].

## ▶️ Como Rodar

1.  **Inicialize o Terraform:**
    [cite_start]Baixe os providers e configure o backend S3 (certifique-se de ter acesso ao bucket `tech-challenge-fiap-s3-bucket` [cite: 16]).
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