#!/bin/bash
sed -i '' -e "s/'Products'/'Produtos'/g" \
          -e "s/'Manage stock and barcodes'/'Gerir estoque e códigos de barras'/g" \
          -e "s/'Shop Details'/'Detalhes da Loja'/g" \
          -e "s/'Edit business info & address'/'Editar informações da loja'/g" \
          -e "s/'Accounting'/'Contabilidade'/g" \
          -e "s/'Entries, exits, P&L, tax reports'/'Entradas, saídas, receitas, impostos'/g" \
          -e "s/'OCR scan for expense entry'/'Escanear para adicionar despesa'/g" \
          -e "s/'P&L Statement'/'Demonstração de Resultados'/g" \
          -e "s/'Profit & Loss statement'/'Declaração de lucros e perdas'/g" \
          -e "s/'Export for Tax Authority (AGT)'/'Exportar para AGT'/g" \
          -e "s/'Credit Score'/'Pontuação de Crédito'/g" \
          -e "s/'Business Health Score & micro-credit'/'Saúde do negócio e micro-crédito'/g" \
          -e "s/'Request Loan'/'Pedir Empréstimo'/g" \
          -e "s/'LISPA micro-credit for merchants'/'Micro-crédito LISPA'/g" \
          -e "s/'Order Stock from Supplier'/'Encomendar Estoque do Fornecedor'/g" \
          -e "s/'Buy stock directly from us'/'Comprar estoque diretamente'/g" \
          -e "s/'Connected to printer'/'Conectado à impressora'/g" \
          -e "s/'Print Device'/'Dispositivo de Impressão'/g" \
          -e "s/'Amount (Kz)'/'Montante (Kz)'/g" \
          -e "s/'Description'/'Descrição'/g" \
          -e "s/'Add Expense'/'Adicionar Despesa'/g" \
          -e "s/'Generate PDF Report'/'Gerar Relatório PDF'/g" \
          -e "s/'Sell Excess Stock'/'Vender Estoque em Excesso'/g" \
          -e "s/'Bulk Pricing'/'Preços em Lote'/g" \
          -e "s/'Connect with Buyers'/'Conectar com Compradores'/g" \
          -e "s/'Marketplace feature coming soon!'/'Função Mercado em breve!'/g" \
          -e "s/'Coming Soon'/'Em Breve'/g" \
          lib/features/settings/presentation/pages/menu_page.dart
