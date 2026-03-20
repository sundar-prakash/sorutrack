part of 'barcode_scanner_bloc.dart';

abstract class BarcodeScannerEvent extends Equatable {
  const BarcodeScannerEvent();

  @override
  List<Object?> get props => [];
}

class BarcodeScanned extends BarcodeScannerEvent {
  final String barcode;
  const BarcodeScanned(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ManualBarcodeEntry extends BarcodeScannerEvent {
  final String barcode;
  const ManualBarcodeEntry(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ResetScanner extends BarcodeScannerEvent {}
