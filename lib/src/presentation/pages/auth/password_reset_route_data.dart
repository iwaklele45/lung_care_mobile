import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';

class VerifyCodeRouteData {
  const VerifyCodeRouteData({
    required this.requestId,
    required this.maskedDestination,
    required this.channel,
    required this.resendAvailableAt,
    this.demoCode,
  });

  factory VerifyCodeRouteData.fromResult(PasswordResetRequestResult result) {
    return VerifyCodeRouteData(
      requestId: result.requestId,
      maskedDestination: result.maskedDestination,
      channel: result.channel,
      resendAvailableAt: result.resendAvailableAt,
      demoCode: result.demoCode,
    );
  }

  final String requestId;
  final String maskedDestination;
  final String channel;
  final DateTime resendAvailableAt;
  final String? demoCode;
}

class ResetPasswordRouteData {
  const ResetPasswordRouteData({required this.resetToken});

  final String resetToken;
}
