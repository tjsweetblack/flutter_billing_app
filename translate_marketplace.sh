#!/bin/bash
sed -i '' -e "s/ added to cart.'/ adicionado ao carrinho.'/g" \
          -e "s/'Your cart is empty'/'Seu carrinho está vazio'/g" \
          -e "s/'Total:'/'Total:'/g" \
          -e "s/'Order placed successfully! We will process it shortly.'/'Pedido realizado com sucesso! Vamos processá-lo em breve.'/g" \
          -e "s/'Place Order'/'Colocar Pedido'/g" \
          -e "s/'Order Stock'/'Encomendar Estoque'/g" \
          -e "s/'In stock: /'Em estoque: /g" \
          -e "s/'Add'/'Adicionar'/g" \
          lib/features/marketplace/presentation/pages/marketplace_page.dart
