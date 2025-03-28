import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/material.dart'; // For GlobalKey

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final Web3Client _ethClient = Web3Client(
    'https://eth-sepolia.g.alchemy.com/v2/s7KY5JL822Kp6Ta5Hht1VMTB7cQ1NA7Q',
    http.Client(),
  );
  final String _contractAddress = '0xF454b96925DF3E8f41FB45c0869D90001D2B8062';
  final String _appPrivateKey = '483f27263eb36b8b4e2385dd5c5bda1f1d7aba6fb377ef04ae309a16721e0088';
  String? _currentCollectorAddress; // Store dynamically passed address

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initiatePayment(double amount, String email, String collectorAddress) {
    var options = {
      'key': 'rzp_test_XQ8HsL39q0OVQu',
      'amount': (amount * 100).toInt(),
      'name': 'Bhujriwala',
      'description': 'Scrap Payment',
      'prefill': {'email': email},
    };
    _currentCollectorAddress = collectorAddress; // Store for minting
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    // Use bid amount directly (passed via initiatePayment), not derived from paymentId
    // Assuming amount was passed correctly, mint equivalent WST (1 INR = 100 WST)
    final tokenAmount = (double.parse(response.paymentId!.substring(4)) / 100) * 100; // Adjust if needed
    _mintTokens(tokenAmount, _currentCollectorAddress!);
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.message}');
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> _mintTokens(double amount, String collectorAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(
        '[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"mint","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
        'WasteToken',
      ),
      EthereumAddress.fromHex(_contractAddress),
    );
    final credentials = EthPrivateKey.fromHex(_appPrivateKey);
    final tx = await _ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('mint'),
        parameters: [
          EthereumAddress.fromHex(collectorAddress), // Dynamic address
          BigInt.from(amount * pow(10, 18)),
        ],
      ),
      chainId: 11155111,
    );
    print('Minted $amount WST to $collectorAddress - Tx: $tx');
  }

  Future<double> getTokenBalance(String address) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(
        '[{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"}]',
        'WasteToken',
      ),
      EthereumAddress.fromHex(_contractAddress),
    );
    final balanceResult = await _ethClient.call(
      contract: contract,
      function: contract.function('balanceOf'),
      params: [EthereumAddress.fromHex(address)],
    );
    final decimalsResult = await _ethClient.call(
      contract: contract,
      function: contract.function('decimals'),
      params: [],
    );
    final balance = balanceResult[0] as BigInt;
    final decimals = decimalsResult[0] as int;
    return (balance / BigInt.from(pow(10, decimals))).toDouble();
  }

  void dispose() {
    _razorpay.clear();
  }
}

// Define navigatorKey globally (move to main.dart if not already there)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();