import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/accounting_transaction.dart';
import '../bloc/accounting_bloc.dart';
import '../bloc/accounting_event.dart';
import '../bloc/accounting_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/export_helper.dart';
import '../../../../core/theme/app_theme.dart';


class AccountingPage extends StatefulWidget {
  const AccountingPage({super.key});

  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AccountingBloc>().add(LoadTodayTransactions());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Kz ', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.purchase:
        return Colors.red;
      case TransactionType.expense:
        return Colors.orange;
      case TransactionType.income:
        return Colors.blue;
      case TransactionType.refund:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.shopping_cart;
      case TransactionType.purchase:
        return Icons.shopping_bag;
      case TransactionType.expense:
        return Icons.receipt_long;
      case TransactionType.income:
        return Icons.attach_money;
      case TransactionType.refund:
        return Icons.undo;
    }
  }

  String _getTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return 'Venda';
      case TransactionType.purchase:
        return 'Compra';
      case TransactionType.expense:
        return 'Despesa';
      case TransactionType.income:
        return 'Receita';
      case TransactionType.refund:
        return 'Reembolso';
    }
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      context.read<AccountingBloc>().add(
            LoadCustomDateRange(picked.start, picked.end.add(const Duration(days: 1))),
          );
    }
  }

  void _showAddTransactionDialog() {
    TransactionType selectedType = TransactionType.expense;
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final paymentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adicionar Transação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TransactionType.values.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(_getTypeName(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() => selectedType = type);
                      },
                      selectedColor: _getTypeColor(type).withValues(alpha: 0.3),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Montante (Kz)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: paymentController,
                  decoration: InputDecoration(
                    labelText: 'Método Pagamento (opcional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.payment),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () {
                      if (amountController.text.isEmpty) return;
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      final transaction = AccountingTransaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        dateTime: DateTime.now(),
                        type: selectedType,
                        amount: amount,
                        description: descController.text.isEmpty
                            ? _getTypeName(selectedType)
                            : descController.text,
                        paymentMethod: paymentController.text.isEmpty
                            ? null
                            : paymentController.text,
                      );

                      context
                          .read<AccountingBloc>()
                          .add(AddTransaction(transaction));
                      Navigator.pop(context);
                    },
                    label: 'Adicionar',
                    icon: Icons.add,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Contabilidade',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.go('/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _showAddTransactionDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearDialog();
                  break;
                case 'export_agt':
                  _exportAGTReport();
                  break;
                case 'export_csv':
                  _exportCSV();
                  break;
                case 'scan_receipt':
                  _showScanReceiptDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'scan_receipt',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, size: 20),
                    SizedBox(width: 8),
                    Text('Escanear Recibo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_agt',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, size: 20),
                    SizedBox(width: 8),
                    Text('Exportação AGT'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Exportar CSV'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpar Tudo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Entradas'),
            Tab(text: 'Saídas'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDateFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildTransactionsList(
                    filter: (t) => t.isEntry),
                _buildTransactionsList(
                    filter: (t) => t.isExit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Tudo'),
        content: const Text(
            'Tem a certeza que deseja apagar todas as transações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountingBloc>().add(ClearAllTransactions());
              Navigator.pop(ctx);
            },
            child: const Text('Apagar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showScanReceiptDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 20),
            const Icon(Icons.receipt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Escanear Recibo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use camera to scan receipts for expense entry\n(OCR powered by ML Kit)',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Câmera OCR em breve!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddTransactionDialog();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Manual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _exportAGTReport() {
    final state = context.read<AccountingBloc>().state;
    final totalSales = state.totalSales;
    final totalExpenses = state.totalExpenses;
    final totalPurchases = state.totalPurchases;
    final netProfit = state.netProfit;
    final ivaRate = 0.14;
    final ivaCollected = totalSales * ivaRate;
    final ivaPaid = (totalExpenses + totalPurchases) * ivaRate;
    final ivaNet = ivaCollected - ivaPaid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 20),
            const Icon(Icons.summarize, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'AGT Tax Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDateRange != null
                  ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                  : 'This Month',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildReportRow('Total Sales (Vendas)', totalSales),
                  _buildReportRow('Total Expenses (Despesas)', totalExpenses),
                  _buildReportRow('Total Purchases (Compras)', totalPurchases),
                  const Divider(),
                  _buildReportRow('IVA Collected (14%)', ivaCollected, isBold: true),
                  _buildReportRow('IVA Paid (14%)', ivaPaid, isBold: true),
                  const Divider(),
                  _buildReportRow(
                    'Net IVA (Payable/Refundable)',
                    ivaNet,
                    color: ivaNet >= 0 ? Colors.green : Colors.red,
                    isBold: true,
                  ),
                  const Divider(),
                  _buildReportRow('Net Profit (Lucro)', netProfit,
                      color: netProfit >= 0 ? Colors.green : Colors.red,
                      isBold: true,
                      fontSize: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final transactions = state.transactions.map((t) => {
                          'date': t.dateTime,
                          'type': _getTypeName(t.type),
                          'description': t.description,
                          'amount': t.amount,
                          'paymentMethod': t.paymentMethod,
                        }).toList();
                        
                        await ExportHelper.createCSVExport(
                          transactions: transactions,
                          type: 'AGT_Report',
                        );
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('CSV exportado e compartilhando...'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Falha na exportação: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Exportar CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final period = _selectedDateRange != null
                            ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                            : 'This Month';
                        
                        final reportData = {
                          'totalSales': totalSales,
                          'totalExpenses': totalExpenses,
                          'totalPurchases': totalPurchases,
                          'netProfit': netProfit,
                          'ivaDetails': {
                            'ivaCollected': ivaCollected,
                            'ivaPaid': ivaPaid,
                            'ivaNet': ivaNet,
                          },
                          'transactions': state.transactions.map((t) => {
                            'date': t.dateTime,
                            'type': _getTypeName(t.type),
                            'description': t.description,
                            'amount': t.amount,
                          }).toList(),
                        };
                        
                        await ExportHelper.createAGTReport(
                          data: reportData,
                          period: period,
                        );
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF exportado e compartilhando...'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Falha na exportação: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, double amount,
      {Color? color, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Kz ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _exportCSV() async {
    final state = context.read<AccountingBloc>().state;
    final transactions = state.filteredTransactions;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem transações para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final data = transactions.map((t) => {
        'date': t.dateTime,
        'type': _getTypeName(t.type),
        'description': t.description,
        'amount': t.amount,
        'paymentMethod': t.paymentMethod,
      }).toList();

      await ExportHelper.createCSVExport(
        transactions: data,
        type: 'Transactions',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportou ${transactions.length} transações e compartilhando...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha na exportação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDateFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDateChip('Hoje', () {
              context.read<AccountingBloc>().add(LoadTodayTransactions());
            }),
            const SizedBox(width: 8),
            _buildDateChip('Esta Semana', () {
              context.read<AccountingBloc>().add(LoadWeekTransactions());
            }),
            const SizedBox(width: 8),
            _buildDateChip('Este Mês', () {
              context.read<AccountingBloc>().add(LoadMonthTransactions());
            }),
            const SizedBox(width: 8),
            _buildDateChip('Personalizado', _selectDateRange),
            if (_selectedDateRange != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _selectedDateRange = null);
                  context.read<AccountingBloc>().add(LoadTransactions());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return BlocBuilder<AccountingBloc, AccountingState>(
      builder: (context, state) {
        if (state.status == AccountingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(state),
              const SizedBox(height: 16),
              _buildTypeBreakdown(state),
              const SizedBox(height: 16),
              _buildQuickStats(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(AccountingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BALANÇA TOTAL',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.totalTransactions} transações',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(state.balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                'Kz',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Entradas',
                  state.totalEntries,
                  Icons.arrow_downward,
                  Colors.green[100]!,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceItem(
                  'Saídas',
                  state.totalExits,
                  Icons.arrow_upward,
                  Colors.red[100]!,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(color: iconColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
                color: iconColor,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdown(AccountingState state) {
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
            'DETALHES POR TIPO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildTypeRow(
            'Vendas',
            state.totalSales,
            state.salesCount,
            TransactionType.sale,
            Colors.green,
          ),
          _buildTypeRow(
            'Compras',
            state.totalPurchases,
            state.purchasesCount,
            TransactionType.purchase,
            Colors.red,
          ),
          _buildTypeRow(
            'Despesas',
            state.totalExpenses,
            null,
            TransactionType.expense,
            Colors.orange,
          ),
          _buildTypeRow(
            'Receitas',
            state.totalIncome,
            null,
            TransactionType.income,
            Colors.blue,
          ),
          _buildTypeRow(
            'Reembolsos',
            state.totalRefunds,
            null,
            TransactionType.refund,
            AppTheme.primaryColor,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lucro Líquido',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                _formatCurrency(state.netProfit),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: state.netProfit >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String label, double amount, int? count,
      TransactionType type, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getTypeIcon(type), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AccountingState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Ticket Médio',
            state.salesCount > 0
                ? _formatCurrency(state.totalSales / state.salesCount)
                : 'Kz 0.00',
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Vendas/Dia',
            state.salesCount > 0
                ? '${(state.salesCount / (_selectedDateRange != null ? _selectedDateRange!.duration.inDays + 1 : 1)).toStringAsFixed(1)}'
                : '0',
            Icons.trending_up,
            AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
      {required bool Function(AccountingTransaction) filter}) {
    return BlocBuilder<AccountingBloc, AccountingState>(
      builder: (context, state) {
        if (state.status == AccountingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions =
            state.filteredTransactions.where(filter).toList();

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma transação encontrada',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final grouped = _groupByDate(transactions);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final date = grouped.keys.elementAt(index);
            final dayTransactions = grouped[date]!;
            final dayTotal = dayTransactions.fold<double>(
                0, (sum, t) => sum + (filter(t) ? t.amount : 0));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMM yyyy', 'pt_PT')
                            .format(date),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        _formatCurrency(dayTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: filter(dayTransactions.first)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...dayTransactions.map((t) => _buildTransactionCard(t)),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Map<DateTime, List<AccountingTransaction>> _groupByDate(
      List<AccountingTransaction> transactions) {
    final grouped = <DateTime, List<AccountingTransaction>>{};
    for (final t in transactions) {
      final dateOnly = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      grouped.putIfAbsent(dateOnly, () => []).add(t);
    }
    return grouped;
  }

  Widget _buildTransactionCard(AccountingTransaction transaction) {
    final color = _getTypeColor(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getTypeIcon(transaction.type),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatDate(transaction.dateTime),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (transaction.paymentMethod != null) ...[
                            const Text(' • ', style: TextStyle(fontSize: 12)),
                            Text(
                              transaction.paymentMethod!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isEntry ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.isEntry ? Colors.green : Colors.red,
                      ),
                    ),
                    if (transaction.profit != null)
                      Text(
                        'Lucro: ${_formatCurrency(transaction.profit!)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(AccountingTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor(transaction.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(transaction.type),
                    color: _getTypeColor(transaction.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeName(transaction.type),
                        style: TextStyle(
                          color: _getTypeColor(transaction.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(transaction.dateTime),
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(transaction.type),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Descrição', transaction.description),
            _buildDetailRow(
                'Tipo', _getTypeName(transaction.type)),
            if (transaction.paymentMethod != null)
              _buildDetailRow(
                  'Método Pagamento', transaction.paymentMethod!),
            if (transaction.reference != null)
              _buildDetailRow('Referência', transaction.reference!),
            _buildDetailRow('ID', transaction.id),
            if (transaction.profit != null)
              _buildDetailRow(
                  'Lucro', _formatCurrency(transaction.profit!)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar Transação'),
                      content: const Text(
                          'Tem a certeza que deseja eliminar esta transação?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<AccountingBloc>()
                                .add(DeleteTransaction(transaction.id));
                            Navigator.pop(ctx);
                          },
                          child: const Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Eliminar',
                    style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
