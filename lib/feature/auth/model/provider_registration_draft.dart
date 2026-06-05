class ProviderRegistrationDraft {
  final String registrationToken;
  final String phone;
  final String providerType;
  final String currentStep;
  final List<String> completedSteps;
  final Map<String, dynamic> formData;
  final Map<String, dynamic> files;

  ProviderRegistrationDraft({
    required this.registrationToken,
    required this.phone,
    required this.providerType,
    required this.currentStep,
    required this.completedSteps,
    required this.formData,
    required this.files,
  });

  factory ProviderRegistrationDraft.fromJson(Map<String, dynamic> json) {
    final form = json['form_data'];
    final fileMap = json['files'];
    return ProviderRegistrationDraft(
      registrationToken: json['registration_token']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      providerType: json['provider_type']?.toString() ?? 'individual',
      currentStep: json['current_step']?.toString() ?? 'provider_type',
      completedSteps: (json['completed_steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
      formData: form is Map ? Map<String, dynamic>.from(form) : {},
      files: fileMap is Map ? Map<String, dynamic>.from(fileMap) : {},
    );
  }
}
