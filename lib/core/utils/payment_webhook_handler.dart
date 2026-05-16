import 'dart:convert';
import 'dart:io';

class WebhookPayload {
  final String id;
  final String event;
  final DateTime createdAt;
  final String transactionId;
  final String externalId;
  final String status;
  final int amount;
  final DateTime? paidAt;
  final String? customerEmail;

  WebhookPayload({
    required this.id,
    required this.event,
    required this.createdAt,
    required this.transactionId,
    required this.externalId,
    required this.status,
    required this.amount,
    this.paidAt,
    this.customerEmail,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return WebhookPayload(
      id: json['id'] ?? '',
      event: json['event'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      transactionId: data['transaction_id'] ?? '',
      externalId: data['external_id'] ?? '',
      status: data['status'] ?? '',
      amount: data['amount'] ?? 0,
      paidAt: data['paid_at'] != null ? DateTime.tryParse(data['paid_at']) : null,
      customerEmail: data['customer_email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event': event,
        'created_at': createdAt.toIso8601String(),
        'data': {
          'transaction_id': transactionId,
          'external_id': externalId,
          'status': status,
          'amount': amount,
          'paid_at': paidAt?.toIso8601String(),
          'customer_email': customerEmail,
        },
      };
}

class PaymentWebhookHandler {
  static Future<void> handleWebhook(
      String payload, String? signature) async {
    print('==========================================');
    print('=== WEBHOOK RECEIVED ===');
    print('Signature: $signature');
    print('Payload: $payload');
    print('==========================================');

    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final webhook = WebhookPayload.fromJson(json);

      print('Webhook Event: ${webhook.event}');
      print('External ID: ${webhook.externalId}');
      print('Status: ${webhook.status}');
      print('Amount: ${webhook.amount}');

      if (webhook.event == 'payment.paid') {
        print('!!! PAYMENT CONFIRMED !!!');
      }
    } catch (e) {
      print('Error processing webhook: $e');
    }
  }
}

class PaymentStatusChecker {
  static const String _apiKey = 'pk_live_4c1c22b27d8b5e00da0b5af826a67eff67b97722874e5eb3';

  static Future<Map<String, dynamic>?> checkPaymentStatus(String externalId) async {
    try {
      print('==========================================');
      print('=== CHECKING PAYMENT STATUS ===');
      print('External ID: $externalId');
      print('==========================================');

      final request = await HttpClient().getUrl(
        Uri.parse('https://app.dizanpay.com/api/v1/payments.php?external_id=$externalId'),
      );
      request.headers.set('Authorization', 'Bearer $_apiKey');

      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        print('Payment Status: ${data['status']}');
        return data;
      } else {
        print('Status check failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error checking payment: $e');
      return null;
    }
  }
}