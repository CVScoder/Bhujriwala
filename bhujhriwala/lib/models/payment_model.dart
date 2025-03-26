class PaymentModel {
  final String orderId;
  final int amount;
  final String userAddress;

  PaymentModel({required this.orderId, required this.amount, required this.userAddress});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      orderId: json['orderId'],
      amount: json['amount'],
      userAddress: json['userAddress'],
    );
  }
}