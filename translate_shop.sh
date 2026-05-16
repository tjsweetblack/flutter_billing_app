#!/bin/bash
sed -i '' -e "s/'Shop Details'/'Detalhes da Loja'/g" \
          -e "s/'Shop details saved!'/'Detalhes da loja salvos!'/g" \
          -e "s/'General Information'/'Informações Gerais'/g" \
          -e "s/'Shop Name'/'Nome da Loja'/g" \
          -e "s/'Address Line 1'/'Endereço Linha 1'/g" \
          -e "s/'Address Line 2 (Optional)'/'Endereço Linha 2 (Opcional)'/g" \
          -e "s/'Phone Number'/'Número de Telefone'/g" \
          -e "s/'UPI ID'/'ID UPI'/g" \
          -e "s/'Receipt Footer Text'/'Texto de Rodapé do Recibo'/g" \
          -e "s/'Max 150 chars'/'Máx. 150 caracteres'/g" \
          -e "s/'Save Details'/'Salvar Detalhes'/g" \
          lib/features/shop/presentation/pages/shop_details_page.dart
