import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(
      Uri.parse('https://app.dizanpay.com/api/v1/payments.php?id=pay_efcfd2633580066206d26e460ee0d096'),
      headers: {
        'Authorization': 'Bearer pk_live_4c1c22b27d8b5e00da0b5af826a67eff67b97722874e5eb3',
      },
    );
    print(response.statusCode);
    print(response.body);
  } catch(e) {
    print(e);
  }
}
