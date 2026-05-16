#!/bin/bash
sed -i '' -e "s/'Review Order'/'Rever Pedido'/g" \
          -e "s/'Turn on Camera'/'Ligar Câmera'/g" \
          -e "s/'Scanned Items'/'Itens Escaneados'/g" \
          -e "s/ items total'/ itens no total'/g" \
          -e "s/'TOTAL PRICE'/'PREÇO TOTAL'/g" \
          -e "s/'List is empty'/'Lista está vazia'/g" \
          lib/features/billing/presentation/pages/home_page.dart
