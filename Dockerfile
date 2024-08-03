# Use a imagem oficial do Ubuntu como base
FROM ubuntu:latest

# Mantenedor da imagem (opcional)
LABEL maintainer="Bruno Torres"

# Atualizar os pacotes do sistema e instalar dependências necessárias
RUN apt-get update && \
    apt-get install -y wget unzip curl git sudo openssh-client iputils-ping

# Definir a versão do Terraform (ajuste conforme necessário)
ENV TERRAFORM_VERSION=1.8.2

# Baixar e instalar Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

RUN az upgrade

# Criar a pasta /iac como um ponto de montagem para um volume
RUN mkdir /iac
VOLUME /iac

# Definir o comando padrão para execução quando o container for iniciado
CMD ["/bin/bash"]
