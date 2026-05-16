import 'dart:io';

void main() {
  final file = File('lib/features/settings/presentation/pages/menu_page.dart');
  var content = file.readAsStringSync();

  // Translate section headers
  content = content.replaceAll("'Management'", "'Gestão'");
  content = content.replaceAll("'Financial Services'", "'Serviços Financeiros'");
  content = content.replaceAll("'Hardware'", "'Equipamento'");

  // Remove Tax & Reports section completely
  // The section is from `_buildSectionHeader('Tax & Reports'),` to the `const SizedBox(height: 24),` before Financial Services.
  final taxSectionRegex = RegExp(r"_buildSectionHeader\('Tax & Reports'\),[\s\S]*?const SizedBox\(height: 24\),");
  content = content.replaceFirst(taxSectionRegex, "");

  // Update Pontuação de Crédito and remove Pedir Empréstimo
  content = content.replaceAll("'Pontuação de Crédito'", "'Pontuação de Crédito e Empréstimo'");
  
  // Remove Pedir Empréstimo List Item
  final loanRegex = RegExp(r"_buildDivider\(\),\s*_buildListItem\(\s*icon: Icons.account_balance,\s*title: 'Pedir Empréstimo',[\s\S]*?onTap: \(\) => context\.push\('/credit-score'\),\s*\),");
  content = content.replaceFirst(loanRegex, "");

  file.writeAsStringSync(content);
}
