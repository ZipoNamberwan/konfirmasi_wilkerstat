/// Configuration for the business confirmation workflow
///
/// This class allows developers to quickly switch between different workflow modes
class WorkflowConfig {
  // ========== DEVELOPER CONFIGURATION ==========
  // Change this value to switch between workflow modes:
  // - true: Two-step workflow (business confirmation + photo upload)
  // - false: One-step workflow (business confirmation only)
  static const bool enablePhotoUploadStep = true;
  // =============================================

  /// Returns whether the photo upload step is needed in the workflow
  static bool get isPhotoUploadStepNeeded => enablePhotoUploadStep;

  /// Returns the total number of required steps in the workflow
  static int get totalSteps => enablePhotoUploadStep ? 2 : 1;

  /// Returns a description of the current workflow mode
  static String get workflowDescription =>
      enablePhotoUploadStep
          ? 'Two-step workflow: Business confirmation + Photo upload'
          : 'One-step workflow: Business confirmation only';
}
