#!/bin/bash
sed -i '' -e "s/'Item            Price   Total'/'Item            Preço   Total'/g" \
          -e "s/'TOTAL: /'TOTAL: /g" \
          lib/core/utils/printer_helper.dart
