#!/bin/bash
# Variaveis
resourceGroup=Lab-Terasaka
resourceLocation=eastus
vnetAddress=10.0.0.0/16
subnetAddress=10.0.0.0/24
vnetName=Vnet-Lab-Terasaka
subnetName=Subnet-Lab-Terasaka
nsgSubnetName=NSG-Subnet-Lab-Terasaka
vmImage=UbuntuLTS
vmSize=Standard_B1ls

# Criando Resouce Group
az group create --name $resourceGroup --location $resourceLocation

# Criando VNet
az network vnet create \
  --resource-group $resourceGroup \
  --location $resourceLocation \
  --address-prefix $vnetAddress \
  --name $vnetName

# Criando NSG para a Subnet
az network nsg create \
  --resource-group $resourceGroup \
  --name $nsgSubnetName

# Criando Subnet e adicionando a NSG
az network vnet subnet create \
  --resource-group $resourceGroup \
  --vnet-name $vnetName \
  --name $subnetName \
  --address-prefixes $subnetAddress \
  --network-security-group $nsgSubnetName

# Atribuindo o ID da subnet para utilizar na criação das VMs 
subnetId=$(az network vnet subnet show \
  --resource-group $resourceGroup --name $subnetName \
  --vnet-name $vnetName --query id -o tsv)  

# Criando 2 VMs
for i in `seq 1 2`; do
az vm create \
  --resource-group $resourceGroup \
  --name VM$i \
  --image $vmImage \
  --size $vmSize \
  --generate-ssh-keys \
  --subnet $subnetId \
  --no-wait
done

# Pegando o IP de origem para criar NSG de entrada para as VMs
sourceIp=$(curl ifconfig.me)

# Criando regra de entrada na subnet para SSH com IP de origem
az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name $nsgSubnetName \
  --name Allow-Source-Home \
  --priority 300 \
  --source-address-prefixes $sourceIp/32 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
  --protocol Tcp --description "Allow SSH from my home"

# Criando regra na NSG das VMs para SSH com IP de origem
for i in `seq 1 2`; do
  while [ ! $(az network nsg rule list -g $resourceGroup --nsg-name VM${i}NSG) ]; do 
    echo 'Aguardando NSG ser criada...'
  done
az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name VM${i}NSG \
  --name Allow-Source-Home \
  --priority 300 \
  --source-address-prefixes $sourceIp/32 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
  --protocol Tcp --description "Allow SSH from my home"

# Deletando regra default de entrada para SSH com origem ANY
az network nsg rule delete \
  --resource-group $resourceGroup \
  --nsg-name VM${i}NSG \
  --name default-allow-ssh
done
