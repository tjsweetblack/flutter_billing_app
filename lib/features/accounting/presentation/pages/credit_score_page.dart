import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/accounting_transaction.dart';
import '../bloc/accounting_bloc.dart';
import '../bloc/accounting_event.dart';
import '../bloc/accounting_state.dart';

class CreditScorePage extends StatefulWidget {
  const CreditScorePage({super.key});

  @override
  State<CreditScorePage> createState() => _CreditScorePageState();
}

class _CreditScorePageState extends State<CreditScorePage> {
  int _selectedAmount = 0;
  String _loanStatus = 'none';
  String _selectedBank = '';

  final List<Map<String, dynamic>> _banks = [
    {'name': 'BFA', 'color': Colors.blue},
    {'name': 'BAI', 'color': Colors.green},
    {'name': 'BIC', 'color': Colors.orange},
    {'name': 'Atlantico', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    context.read<AccountingBloc>().add(LoadMonthTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pontuação de Crédito e Empréstimo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AccountingBloc, AccountingState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(state),
                const SizedBox(height: 24),
                _buildFraudDetectionSection(state),
                const SizedBox(height: 24),
                _buildVelocityChart(state),
                const SizedBox(height: 24),
                _buildMetricsGrid(state),
                const SizedBox(height: 24),
                _buildDetailedBreakdown(state),
                const SizedBox(height: 24),
                _buildLoanSection(state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========== FRAUD DETECTION METHODS ==========

  double _calculateFraudScore(AccountingState state) {
    final transactions = state.transactions;
    if (transactions.isEmpty) return 100;

    double fraudScore = 100;

    fraudScore -= _detectVelocityAnomaly(transactions) * 0.3;
    fraudScore -= _detectCustomerDiversity(transactions) * 0.2;
    fraudScore -= _detectInventoryAnomaly(transactions) * 0.2;
    fraudScore -= _detectTimeAnomaly(transactions) * 0.15;
    fraudScore -= _detectLocationAnomaly(state) * 0.15;

    return fraudScore.clamp(0, 100);
  }

  double _detectVelocityAnomaly(List<AccountingTransaction> transactions) {
    final cashSales = transactions.where((t) => t.type == TransactionType.sale).toList();
    if (cashSales.length < 5) return 0;

    cashSales.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    int burstCount = 0;
    int windowSize = 10;

    for (int i = 0; i < cashSales.length - windowSize + 1; i++) {
      final window = cashSales.sublist(i, i + windowSize);
      final duration = window.last.dateTime.difference(window.first.dateTime).inSeconds;

      if (duration < 60 && window.every((t) => t.amount > 10000)) {
        burstCount++;
      }
    }

    if (burstCount > 5) return 50;
    if (burstCount > 2) return 25;
    if (burstCount > 0) return 10;
    return 0;
  }

  double _detectCustomerDiversity(List<AccountingTransaction> transactions) {
    if (transactions.isEmpty) return 0;

    final Map<String, int> customerCounts = {};

    for (final t in transactions) {
      if (t.paymentMethod != null) {
        final hashedId = t.paymentMethod.hashCode.abs().toString();
        customerCounts[hashedId] = (customerCounts[hashedId] ?? 0) + 1;
      }
    }

    final uniqueCustomers = customerCounts.length;
    final totalTransactions = transactions.length;

    final diversityRatio = uniqueCustomers / totalTransactions;

    if (diversityRatio < 0.1) return 40;
    if (diversityRatio < 0.3) return 20;
    if (diversityRatio < 0.5) return 10;
    return 0;
  }

  double _detectInventoryAnomaly(List<AccountingTransaction> transactions) {
    if (transactions.isEmpty) return 0;

    final sales = transactions.where((t) => t.type == TransactionType.sale).length;
    final purchases = transactions.where((t) => t.type == TransactionType.purchase).length;

    if (sales == 0 || purchases == 0) return 5;

    final ratio = sales / purchases;

    if (ratio > 100) return 50;
    if (ratio > 50) return 30;
    if (ratio > 20) return 15;
    return 0;
  }

  double _detectTimeAnomaly(List<AccountingTransaction> transactions) {
    int lateNightSales = 0;
    int totalSales = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.sale) {
        totalSales++;
        final hour = t.dateTime.hour;
        if (hour >= 0 && hour < 5) {
          lateNightSales++;
        }
      }
    }

    if (totalSales == 0) return 0;

    final lateNightRatio = lateNightSales / totalSales;

    if (lateNightRatio > 0.5) return 40;
    if (lateNightRatio > 0.3) return 25;
    if (lateNightRatio > 0.1) return 10;
    return 0;
  }

  double _detectLocationAnomaly(AccountingState state) {
    return 5;
  }

  Widget _buildFraudDetectionSection(AccountingState state) {
    final fraudScore = _calculateFraudScore(state);
    final fraudColor = _getFraudScoreColor(fraudScore);
    final fraudLabel = _getFraudScoreLabel(fraudScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fraudScore < 50 ? Colors.red.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: fraudColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'RISCO DE FRAUDE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: fraudColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fraudLabel,
                  style: TextStyle(
                    color: fraudColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fraudScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: fraudColor,
                      ),
                    ),
                    const Text(
                      'Pontuação de Confiança',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: fraudScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(fraudColor),
                    ),
                  ),
                  Icon(Icons.verified_user, color: fraudColor, size: 30),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _buildFraudCheckRow(
            'Verificação de Velocidade',
            'Detecção de picos de vendas',
            _detectVelocityAnomaly(state.transactions) > 0 ? Icons.warning : Icons.check_circle,
            _detectVelocityAnomaly(state.transactions) > 0 ? Colors.orange : Colors.green,
          ),
          _buildFraudCheckRow(
            'Diversidade de Clientes',
            'Proporção de clientes únicos',
            _detectCustomerDiversity(state.transactions) > 0 ? Icons.warning : Icons.check_circle,
            _detectCustomerDiversity(state.transactions) > 0 ? Colors.orange : Colors.green,
          ),
          _buildFraudCheckRow(
            'Fluxo de Inventário',
            'Taxa de rotação de estoque',
            _detectInventoryAnomaly(state.transactions) > 0 ? Icons.warning : Icons.check_circle,
            _detectInventoryAnomaly(state.transactions) > 0 ? Colors.orange : Colors.green,
          ),
          _buildFraudCheckRow(
            'Padrão de Tempo',
            'Vendas noturnas',
            _detectTimeAnomaly(state.transactions) > 0 ? Icons.warning : Icons.check_circle,
            _detectTimeAnomaly(state.transactions) > 0 ? Colors.orange : Colors.green,
          ),
          _buildFraudCheckRow(
            'Verificação de Localização',
            'Verificação de GPS',
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFraudCheckRow(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFraudScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getFraudScoreLabel(double score) {
    if (score >= 80) return 'VERIFICADO';
    if (score >= 60) return 'BAIXO RISCO';
    if (score >= 40) return 'MÉDIO RISCO';
    return 'ALTO RISCO';
  }

  Widget _buildVelocityChart(AccountingState state) {
    final transactions = state.transactions;
    final hourlyData = _getHourlyData(transactions);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'VELOCIDADE DE VENDAS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fluxo Natural vs Picos Anômalos',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: VelocityChartPainter(hourlyData),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Crescimento Orgânico', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Anomalia', Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '10+ high-value sales in 60s = Anomaly flagged',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getHourlyData(List<AccountingTransaction> transactions) {
    final hourlyTotals = List<double>.filled(24, 0);
    final hourlyCounts = List<int>.filled(24, 0);

    for (final t in transactions) {
      if (t.type == TransactionType.sale) {
        final hour = t.dateTime.hour;
        hourlyTotals[hour] += t.amount;
        hourlyCounts[hour]++;
      }
    }

    final avg = hourlyTotals.reduce((a, b) => a + b) / 24;
    final threshold = avg * 3;

    return hourlyTotals.map((v) {
      if (v > threshold) return -v;
      return v;
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildScoreCard(AccountingState state) {
    final score = _calculateHealthScore(state);
    final scoreColor = _getScoreColor(score);
    final scoreLabel = _getScoreLabel(score);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'PONTUAÇÃO DE SAÚDE DO NEGÓCIO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    scoreLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We aren\'t just a POS; we are a portable credit bureau for the informal sector.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateHealthScore(AccountingState state) {
    int score = 50;

    final transactions = state.transactions;
    if (transactions.isEmpty) return 40;

    final now = DateTime.now();
    final thisMonth = transactions.where((t) =>
        t.dateTime.month == now.month && t.dateTime.year == now.year).toList();
    final lastMonth = transactions.where((t) =>
        t.dateTime.month == now.month - 1 && t.dateTime.year == now.year).toList();

    double consistency = 0;
    if (thisMonth.isNotEmpty) {
      final days = thisMonth.map((t) => t.dateTime.day).toSet().length;
      consistency = (days / 30) * 100;
      score += (consistency * 0.2).toInt();
    }

    double growth = 0;
    if (lastMonth.isNotEmpty && thisMonth.isNotEmpty) {
      final thisMonthTotal = thisMonth.fold<double>(0, (sum, t) => sum + t.amount);
      final lastMonthTotal = lastMonth.fold<double>(0, (sum, t) => sum + t.amount);
      if (lastMonthTotal > 0) {
        growth = ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
        score += (growth.clamp(-20, 30) * 0.5).toInt();
      }
    }

    final salesCount = state.salesCount;
    final retention = salesCount > 0 ? (salesCount / 10).clamp(0, 20) : 0;
    score += retention.toInt();

    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bom';
    if (score >= 40) return 'Regular';
    return 'Baixo';
  }

  Widget _buildMetricsGrid(AccountingState state) {
    final consistency = _calculateConsistency(state);
    final growth = _calculateGrowth(state);
    final retention = _calculateRetention(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FATORES DA PONTUAÇÃO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Consistência',
              '${consistency.toStringAsFixed(0)}%',
              _getMetricIcon(consistency, 70),
              _getMetricColor(consistency, 70),
              'Dias que a loja está ativa',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Crescimento',
              '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
              Icons.trending_up,
              growth >= 0 ? Colors.green : Colors.red,
              'Month-over-month',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Retenção',
              '${retention.toStringAsFixed(0)}%',
              Icons.people,
              _getMetricColor(retention, 50),
              'Clientes recorrentes',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Transações',
              '${state.totalTransactions}',
              Icons.receipt_long,
              Colors.blue,
              'Total este mês',
            )),
          ],
        ),
      ],
    );
  }

  double _calculateConsistency(AccountingState state) {
    final transactions = state.transactions;
    if (transactions.isEmpty) return 0;
    final now = DateTime.now();
    final thisMonth = transactions.where((t) =>
        t.dateTime.month == now.month && t.dateTime.year == now.year).toList();
    if (thisMonth.isEmpty) return 0;
    final days = thisMonth.map((t) => t.dateTime.day).toSet().length;
    return (days / 30) * 100;
  }

  double _calculateGrowth(AccountingState state) {
    final transactions = state.transactions;
    if (transactions.isEmpty) return 0;
    final now = DateTime.now();
    final thisMonth = transactions.where((t) =>
        t.dateTime.month == now.month && t.dateTime.year == now.year).toList();
    final lastMonth = transactions.where((t) =>
        t.dateTime.month == now.month - 1 || (now.month == 1 && t.dateTime.month == 12)).toList();

    if (lastMonth.isEmpty || thisMonth.isEmpty) return 0;

    final thisTotal = thisMonth.fold<double>(0, (sum, t) => sum + t.amount);
    final lastTotal = lastMonth.fold<double>(0, (sum, t) => sum + t.amount);

    if (lastTotal == 0) return 100;
    return ((thisTotal - lastTotal) / lastTotal) * 100;
  }

  double _calculateRetention(AccountingState state) {
    return (state.salesCount / 10).clamp(0, 100);
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMetricIcon(double value, double threshold) {
    return value >= threshold ? Icons.check_circle : Icons.warning;
  }

  Color _getMetricColor(double value, double threshold) {
    if (value >= threshold) return Colors.green;
    if (value >= threshold * 0.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDetailedBreakdown(AccountingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO FINANCEIRO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Vendas Totais', state.totalSales, Colors.green),
          _buildSummaryRow('Despesas Totais', state.totalExpenses, Colors.red),
          _buildSummaryRow('Compras Totais', state.totalPurchases, Colors.orange),
          const Divider(height: 24),
          _buildSummaryRow('Lucro Líquido', state.netProfit,
              state.netProfit >= 0 ? Colors.green : Colors.red, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Kz ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSection(AccountingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'MICRO-CRÉDITO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Solicite um micro-crédito dos nossos parceiros bancários.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (_loanStatus == 'pending') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aguardando Aprovação',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kz ${NumberFormat('#,###').format(_selectedAmount)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_loanStatus == 'approved') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Aprovado!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Montante: Kz ${NumberFormat('#,###').format(_selectedAmount)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWithdrawDialog(),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Levantar Montante'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildLoanAmountChip(50000),
            const SizedBox(height: 8),
            _buildLoanAmountChip(100000),
            const SizedBox(height: 8),
            _buildLoanAmountChip(250000),
            const SizedBox(height: 8),
            _buildLoanAmountChip(500000),
            const SizedBox(height: 16),
            if (_selectedAmount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Montante selecionado: Kz ${NumberFormat('#,###').format(_selectedAmount)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAmount > 0 ? () => _showBankSelectionDialog() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedAmount > 0 ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Solicitar Micro-crédito'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Powered by LISPA - Financial Inclusion for Angola',
            style: TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanAmountChip(int amount) {
    final isSelected = _selectedAmount == amount;
    return InkWell(
      onTap: () => setState(() => _selectedAmount = amount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withValues(alpha: 0.3) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 20)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              'Kz ${NumberFormat('#,###').format(amount)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  void _showBankSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.account_balance, size: 40, color: Colors.blue),
            const SizedBox(height: 12),
            const Text(
              'Escolher Banco',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Montante: Kz ${NumberFormat('#,###').format(_selectedAmount)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _banks.map((bank) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _submitLoanRequest(bank['name']);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (bank['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: bank['color'] as Color),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: bank['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                bank['name'][0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              bank['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Levantar Fundos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Kz ${NumberFormat('#,###').format(_selectedAmount)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            const Text(
              'O montante será transferido para a sua conta bancária em 24-48 horas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _loanStatus = 'none');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transferência iniciada!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Confirmar Levantamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _submitLoanRequest(String bankName) async {
    setState(() {
      _selectedBank = bankName;
      _loanStatus = 'pending';
    });

    final accountingState = context.read<AccountingBloc>().state;
    final healthScore = _calculateHealthScore(accountingState);
    final fraudScore = _calculateFraudScore(accountingState);
    final velocityAnomaly = _detectVelocityAnomaly(accountingState.transactions).toInt();
    final customerDiversity = _detectCustomerDiversity(accountingState.transactions).toInt();
    final inventoryAnomaly = _detectInventoryAnomaly(accountingState.transactions).toInt();
    final timeAnomaly = _detectTimeAnomaly(accountingState.transactions).toInt();
    final consistency = _calculateConsistency(accountingState);
    final growth = _calculateGrowth(accountingState);
    final retention = _calculateRetention(accountingState);

    final loanData = {
      'shopName': 'Kandonga Business',
      'ownerName': 'Merchant',
      'amount': _selectedAmount,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'pending',
      'bank': bankName,
      'healthScore': healthScore,
      'fraudScore': fraudScore.toInt(),
      'riskLabel': _getFraudScoreLabel(fraudScore),
      'riskClass': _getScoreLabel(healthScore),
      'metrics': {
        'consistency': consistency.toInt(),
        'growth': growth.toStringAsFixed(1),
        'retention': retention.toInt(),
        'totalTransactions': accountingState.totalTransactions,
        'totalSales': accountingState.totalSales,
        'totalExpenses': accountingState.totalExpenses,
        'totalPurchases': accountingState.totalPurchases,
        'netProfit': accountingState.netProfit,
        'salesCount': accountingState.salesCount,
      },
      'fraudDetails': {
        'velocityAnomaly': velocityAnomaly,
        'customerDiversity': customerDiversity,
        'inventoryAnomaly': inventoryAnomaly,
        'timeAnomaly': timeAnomaly,
        'locationAnomaly': 5,
        'lateNightSales': accountingState.transactions.where((t) => t.dateTime.hour >= 0 && t.dateTime.hour < 5 && t.type == TransactionType.sale).length,
      },
      'speedOfSales': _getHourlyData(accountingState.transactions),
      'createdAt': DateTime.now().toIso8601String(),
      'transactionsList': accountingState.transactions.take(50).map((t) => {
        'date': t.dateTime.toIso8601String().split('T')[0],
        'time': DateFormat('HH:mm').format(t.dateTime),
        'type': t.type.toString().split('.').last,
        'amount': t.amount,
        'method': t.paymentMethod ?? 'N/A',
        'description': t.description,
      }).toList(),
    };

    final firebaseService = sl<FirebaseService>();
    final success = await firebaseService.submitLoanRequest(loanData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitação enviada para $bankName! A aguardar aprovação...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
        ),
      );

      _startPollingForLoanStatus(bankName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao enviar solicitação. Verifique a ligação à internet.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _loanStatus = 'none');
    }
  }

  void _startPollingForLoanStatus(String bankName) {
    int pollCount = 0;
    const maxPolls = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      pollCount++;

      if (!mounted) return false;

      final loans = await sl<FirebaseService>().getPendingLoansByBank(bankName);
      
      if (mounted && loans.isNotEmpty) {
        final myLoan = loans.firstWhere(
          (l) => l['amount'] == _selectedAmount && l['status'] == 'pending',
          orElse: () => {},
        );

        if (myLoan.isNotEmpty) {
          if (myLoan['status'] == 'approved') {
            setState(() => _loanStatus = 'approved');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Parabéns! O seu micro-crédito foi aprovado pelo banco!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
            return false;
          } else if (myLoan['status'] == 'rejected') {
            setState(() => _loanStatus = 'none');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('A sua solicitação foi rejeitada. Tente um montante menor.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
            return false;
          }
        }
      }

      if (pollCount >= maxPolls) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Timeout aguardando resposta. Verifique no portal.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }

      return _loanStatus == 'pending';
    });
  }
}

class VelocityChartPainter extends CustomPainter {
  final List<double> data;

  VelocityChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final barWidth = size.width / 24 - 2;
    final zeroY = size.height / 2;

    final organicPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final anomalyPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final axisPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / 24) + 1;
      final value = data[i];
      final height = (value.abs() / maxVal) * (size.height / 2 - 10);

      final paint = value < 0 ? anomalyPaint : organicPaint;

      if (value >= 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, zeroY - height, barWidth, height),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, zeroY, barWidth, height),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }

    final labelStyle = TextStyle(color: Colors.grey[400], fontSize: 8);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < 24; i += 6) {
      final x = i * (size.width / 24) + 1;
      textPainter.text = TextSpan(text: '${i}h', style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, size.height - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}