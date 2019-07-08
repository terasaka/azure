# Azure

Scritps e dicas para estudos em Azure

## Requisitos

- [Subscription Azure](https://azure.microsoft.com/pt-br/free/)
- [Az CLI instalado](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli?view=azure-cli-latest)

Obs. Scripts validados utilizando Ubuntu 18.04

## Criando Lab

- [Criando Lab](https://github.com/terasaka/azure/blob/master/createLab.sh)

Para utilizar o script de criação do Lab, apenas altere as variaveis de acordo a sua necessidade.  
  
Esse script cria os seguinte recursos:

- Vnet.
- Subnet.
- NSG para a subnet.
- Adicionado regra de inbound na NSG da subnet na porta 22 com origem do seu ip de saida.
- 2 VMs UbuntuLTS - Standard_B1ls com IPs públicos.
- NSG com regras de inbound para as portas 22 com a origem do seu ip de saida.
- Deleta as regras de inbound para as portas 22 com origem any.

![Lab](https://github.com/terasaka/azure/blob/master/img/infra.svg)