import 'dart:io';

void main() {
  final file = File('lib/features/accounting/presentation/pages/credit_score_page.dart');
  var content = file.readAsStringSync();

  final map = {
    "'BUSINESS HEALTH SCORE'": "'PONTUAÇÃO DE SAÚDE DO NEGÓCIO'",
    "'FRAUD RISK SCORE'": "'PONTUAÇÃO DE RISCO DE FRAUDE'",
    "'FINANCIAL SUMMARY'": "'RESUMO FINANCEIRO'",
    "'SALES VELOCITY'": "'VELOCIDADE DE VENDAS'",
    "'SCORE FACTORS'": "'FATORES DA PONTUAÇÃO'",
    "'We aren\\'t ready yet for the micro-loan request, please try again next month.'": "'Ainda não estamos prontos para a solicitação de micro-crédito, por favor, tente novamente no próximo mês.'",
    "'Status: SENT TO LISPA BANK'": "'Estado: ENVIADO AO BANCO LISPA'",
    "'Total Revenue'": "'Receita Total'",
    "'Total Sales'": "'Vendas Totais'",
    "'Total Expenses'": "'Despesas Totais'",
    "'Total Purchases'": "'Compras Totais'",
    "'Total Transactions'": "'Transações Totais'",
    "'Total this month'": "'Total este mês'",
    "'Net Profit'": "'Lucro Líquido'",
    "'Transactions'": "'Transações'",
    "'Trust Score'": "'Pontuação de Confiança'",
    "'Health Score'": "'Pontuação de Saúde'",
    "'Velocity Check'": "'Verificação de Velocidade'",
    "'Burst sales detection'": "'Detecção de picos de vendas'",
    "'Customer Diversity'": "'Diversidade de Clientes'",
    "'Unique customers ratio'": "'Proporção de clientes únicos'",
    "'Location Check'": "'Verificação de Localização'",
    "'GPS verification'": "'Verificação de GPS'",
    "'Time Pattern'": "'Padrão de Tempo'",
    "'Late night sales'": "'Vendas noturnas'",
    "'Shop Consistency'": "'Consistência da Loja'",
    "'Days shop is active'": "'Dias que a loja está ativa'",
    "'Inventory Flow'": "'Fluxo de Inventário'",
    "'Stock turnover rate'": "'Taxa de rotação de estoque'",
    "'Retention'": "'Retenção'",
    "'Repeat customers'": "'Clientes recorrentes'",
    "'Monthly Growth'": "'Crescimento Mensal'",
    "'Organic Growth'": "'Crescimento Orgânico'",
    "'Consistency'": "'Consistência'",
    "'Growth'": "'Crescimento'",
    "'Natural Flow vs Anomalous Spikes'": "'Fluxo Natural vs Picos Anômalos'",
    "'HIGH RISK'": "'ALTO RISCO'",
    "'MEDIUM RISK'": "'MÉDIO RISCO'",
    "'LOW RISK'": "'BAIXO RISCO'",
    "'VERIFIED'": "'VERIFICADO'",
    "'Excellent'": "'Excelente'",
    "'Good'": "'Bom'",
    "'Fair'": "'Regular'",
    "'Poor'": "'Baixo'",
    "'Anomaly'": "'Anomalia'",
  };

  map.forEach((k, v) {
    content = content.replaceAll(k, v);
  });

  file.writeAsStringSync(content);
}
