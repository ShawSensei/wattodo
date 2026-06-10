// Wraps async results so the controller can react to loading/success/error
// in one stream without managing separate boolean flags
enum Status { loading, success, error }

class Resource<T> {
  final Status status;
  final T? data;
  final String? errorMessage;
  final int? errorCode;

  Resource._({
    required this.status,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  factory Resource.loading() => Resource._(status: Status.loading);

  factory Resource.success(T data) =>
      Resource._(status: Status.success, data: data);

  factory Resource.error(String errorMessage, int? errorCode) => Resource._(
        status: Status.error,
        errorMessage: errorMessage,
        errorCode: errorCode,
      );
}
