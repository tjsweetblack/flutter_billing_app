import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final payload = {
    'amount': 2000,
    'external_id': 'ORD-1234',
    'customer_email': 'cliente@email.com',
    'customer_name': 'Cliente',
    'description': 'Pedido Teste',
  };

  try {
    final response = await http.post(
      Uri.parse('https://app.dizanpay.com/api/v1/payments.php'),
      headers: {
        'Authorization': 'Bearer pk_live_4c1c22b27d8b5e00da0b5af826a67eff67b97722874e5eb3',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({...payload, 'method': 'REF'}),
    );
    print(response.body);
  } catch(e) {
    print(e);
  }
}
