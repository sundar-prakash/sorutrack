part of 'barcode_scanner_bloc.dart';

abstract class BarcodeScannerState extends Equatable {
  const BarcodeScannerState();

  @override
  List<Object?> get props => [];
}

class BarcodeScannerInitial extends BarcodeScannerState {}

class BarcodeScannerScanning extends BarcodeScannerState {}

class BarcodeScannerLoading extends BarcodeScannerState {
  final String barcode;
  const BarcodeScannerLoading(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class BarcodeScannerSuccess extends BarcodeScannerState {
  final FoodItem foodItem;
  const BarcodeScannerSuccess(this.foodItem);

  @override
  List<Object?> get props => [foodItem];
}

class BarcodeScannerNotFound extends BarcodeScannerState {
  final String barcode;
  const BarcodeScannerNotFound(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class BarcodeScannerError extends BarcodeScannerState {
  final String message;
  const BarcodeScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
