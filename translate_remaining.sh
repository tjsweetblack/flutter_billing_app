#!/bin/bash
sed -i '' -e "s/'Scan Barcode'/'Escanear Código'/g" lib/features/billing/presentation/pages/scanner_page.dart
sed -i '' -e "s/'Camera OCR coming soon!'/'Câmera OCR em breve!'/g" lib/features/accounting/presentation/pages/accounting_page.dart
