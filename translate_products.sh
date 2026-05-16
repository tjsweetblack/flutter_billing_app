#!/bin/bash
sed -i '' -e "s/'Product Management'/'Gestão de Produtos'/g" \
          -e "s/'Scan or enter barcode'/'Escanear ou inserir código de barras'/g" \
          -e "s/'Tap the icon to open camera scanner'/'Toque no ícone para abrir a câmera'/g" \
          -e "s/'Error: /'Erro: /g" \
          -e "s/'No products found. Add some!'/'Nenhum produto encontrado. Adicione alguns!'/g" \
          -e "s/'No products match your search.'/'Nenhum produto corresponde à sua pesquisa.'/g" \
          -e "s/'Delete Product'/'Apagar Produto'/g" \
          -e "s/'Are you sure you want to delete /'Tem a certeza de que pretende apagar /g" \
          -e "s/'Cancel'/'Cancelar'/g" \
          -e "s/'Delete'/'Apagar'/g" \
          -e "s/'Add New Product'/'Adicionar Novo Produto'/g" \
          -e "s/'Edit Product'/'Editar Produto'/g" \
          -e "s/'Save Updates'/'Salvar Alterações'/g" \
          -e "s/'Update Product'/'Atualizar Produto'/g" \
          -e "s/'Name'/'Nome'/g" \
          -e "s/'Price'/'Preço'/g" \
          -e "s/'Stock'/'Estoque'/g" \
          -e "s/'Barcode'/'Código de Barras'/g" \
          -e "s/'Please enter a name'/'Por favor, indira um nome'/g" \
          -e "s/'Please enter a price'/'Por favor, insira um preço'/g" \
          -e "s/'Please enter a valid barcode'/'Por favor, insira um código de barras válido'/g" \
          lib/features/product/presentation/pages/product_list_page.dart \
          lib/features/product/presentation/pages/edit_product_page.dart \
          lib/features/product/presentation/pages/add_product_page.dart
