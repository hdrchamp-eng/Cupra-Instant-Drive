abstract interface class IdentityVerificationAdapter {
  Future<bool> verifySyntheticIdentity();
}

abstract interface class KeylessAdapter {
  Future<bool> locateVehicle(String vehicleId);
  Future<bool> unlockVehicle(String vehicleId);
  Future<bool> lockVehicle(String vehicleId);
}

abstract interface class PaymentAdapter {
  Future<String> authorize(int amountRappen);
}

abstract interface class EmailAdapter {
  Future<String> createLocalPreview(String subject);
}

abstract interface class InsuranceAdapter {
  Future<int> quoteMonthlyRappen(String vehicleId);
}

abstract interface class MapAdapter {
  String directionsLabel(double latitude, double longitude);
}

class SandboxIdentityAdapter implements IdentityVerificationAdapter {
  @override
  Future<bool> verifySyntheticIdentity() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return true;
  }
}

class SandboxKeylessAdapter implements KeylessAdapter {
  @override
  Future<bool> locateVehicle(String vehicleId) async => vehicleId.isNotEmpty;
  @override
  Future<bool> unlockVehicle(String vehicleId) async => vehicleId.isNotEmpty;
  @override
  Future<bool> lockVehicle(String vehicleId) async => vehicleId.isNotEmpty;
}

class SandboxPaymentAdapter implements PaymentAdapter {
  @override
  Future<String> authorize(int amountRappen) async =>
      'PAY-DEMO-${amountRappen.toString().padLeft(4, '0')}';
}

class LocalEmailPreviewAdapter implements EmailAdapter {
  @override
  Future<String> createLocalPreview(String subject) async =>
      'Lokale Vorschau: $subject';
}

class SandboxInsuranceAdapter implements InsuranceAdapter {
  @override
  Future<int> quoteMonthlyRappen(String vehicleId) async => 11800;
}

class DemoMapAdapter implements MapAdapter {
  @override
  String directionsLabel(double latitude, double longitude) =>
      'Demo-Route ($latitude, $longitude)';
}
