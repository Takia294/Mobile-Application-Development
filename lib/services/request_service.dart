/// ============================================================
/// REQUEST SERVICE
/// This file intentionally just re-exports RequestDatabase, which
/// already implements all request read/write logic (streamMyRequests,
/// submitRequest, updateStatus, streamAllRequests, etc.) and is used
/// throughout the app (EmergencyRequestScreen, MyRequestScreen,
/// AdminDashboardScreen). Kept as a re-export so `import
/// '../services/request_service.dart';` also works if referenced
/// elsewhere, without maintaining two parallel implementations.
/// ============================================================
export 'request_database.dart';
