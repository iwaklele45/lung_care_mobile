class PasswordResetRequestResult {
  const PasswordResetRequestResult({
    required this.requestId,
    required this.maskedDestination,
    required this.channel,
    required this.resendAvailableAt,
    this.demoCode,
  });

  final String requestId;
  final String maskedDestination;
  final String channel;
  final DateTime resendAvailableAt;
  final String? demoCode;
}

class PasswordResetVerificationResult {
  const PasswordResetVerificationResult({required this.resetToken});

  final String resetToken;
}
