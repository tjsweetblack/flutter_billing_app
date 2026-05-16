#!/bin/bash
sed -i '' -e "s/'Product with barcode \"\$_barcode\" already exists!'/'O produto com o código de barras \"\$_barcode\" já existe!'/g" \
          -e "s/'Add Product'/'Adicionar Produto'/g" \
          -e "s/'Product Name'/'Nome do Produto'/g" \
          -e "s/'e.g. Basmati Rice'/'ex. Arroz Agulha'/g" \
          -e "s/'Initial Stock'/'Estoque Inicial'/g" \
          -e "s/'e.g. 10'/'ex. 10'/g" \
          lib/features/product/presentation/pages/add_product_page.dart \
          lib/features/product/presentation/pages/edit_product_page.dart
