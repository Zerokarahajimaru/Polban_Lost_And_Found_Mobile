class BountyModel {
  BountyModel({
    required this.amount,
    required this.currency,
  });

  factory BountyModel.fromMap(Map<String, dynamic> map) {
    return BountyModel(
      amount: map['amount'] as double,
      currency: map['currency'] as String,
    );
  }

  final double amount;
  final String currency;

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}
