#!/bin/bash
sed -i '' -e "s/'Cash'/'Dinheiro'/g" \
          -e "s/'Change: /'Troco: /g" \
          -e "s/'Change Given: /'Troco Entregue: /g" \
          -e "s/'Imprimir Recibo (Opcional)'/'Imprimir Recibo'/g" \
          lib/features/billing/presentation/pages/checkout_page.dart
