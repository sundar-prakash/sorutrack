import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';
import 'package:sorutrack_pro/features/food/domain/repositories/food_repository.dart';

part 'barcode_scanner_event.dart';
part 'barcode_scanner_state.dart';

@injectable
class BarcodeScannerBloc extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  final FoodRepository _foodRepository;

  BarcodeScannerBloc(this._foodRepository) : super(BarcodeScannerInitial()) {
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ManualBarcodeEntry>(_onManualBarcodeEntry);
    on<ResetScanner>(_onResetScanner);
  }

  Future<void> _onBarcodeScanned(BarcodeScanned event, Emitter<BarcodeScannerState> emit) async {
    if (state is BarcodeScannerLoading) return;
    
    emit(BarcodeScannerLoading(event.barcode));
    
    final result = await _foodRepository.getFoodByBarcode(event.barcode);
    
    result.fold(
      (failure) => emit(BarcodeScannerError(failure.message)),
      (foodItem) {
        if (foodItem != null) {
          emit(BarcodeScannerSuccess(foodItem));
        } else {
          emit(BarcodeScannerNotFound(event.barcode));
        }
      },
    );
  }

  Future<void> _onManualBarcodeEntry(ManualBarcodeEntry event, Emitter<BarcodeScannerState> emit) async {
    add(BarcodeScanned(event.barcode));
  }

  void _onResetScanner(ResetScanner event, Emitter<BarcodeScannerState> emit) {
    emit(BarcodeScannerInitial());
  }
}
