import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/data_management/data/services/export_service.dart';
import 'package:sorutrack_pro/features/data_management/data/services/import_service.dart';
import 'package:sorutrack_pro/features/data_management/data/services/backup_service.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';

// Events
abstract class DataManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExportDataRequested extends DataManagementEvent {
  final String userId;
  final String format; // json, csv, excel, pdf
  ExportDataRequested(this.userId, this.format);
}

class CreateBackupRequested extends DataManagementEvent {
  final String? password; // If null, raw backup
  CreateBackupRequested({this.password});
}

class RestoreBackupRequested extends DataManagementEvent {
  final File file;
  final String? password;
  RestoreBackupRequested(this.file, {this.password});
}

class ImportDataRequested extends DataManagementEvent {
  final String userId;
  final File file;
  final String type; // healthifyme, mfp, generic
  final Map<String, String>? mapping;
  ImportDataRequested(this.userId, this.file, this.type, {this.mapping});
}

class ClearAllDataRequested extends DataManagementEvent {}

// State
abstract class DataManagementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DataManagementInitial extends DataManagementState {}
class DataManagementLoading extends DataManagementState {
  final String message;
  DataManagementLoading(this.message);
}
class DataManagementSuccess extends DataManagementState {
  final String message;
  final String? filePath;
  DataManagementSuccess(this.message, {this.filePath});
}
class DataManagementFailure extends DataManagementState {
  final String error;
  DataManagementFailure(this.error);
}

@injectable
class DataManagementBloc extends Bloc<DataManagementEvent, DataManagementState> {
  final ExportService _exportService;
  final ImportService _importService;
  final BackupService _backupService;

  DataManagementBloc(
    this._exportService,
    this._importService,
    this._backupService,
  ) : super(DataManagementInitial()) {
    on<ExportDataRequested>(_onExportRequested);
    on<CreateBackupRequested>(_onCreateBackupRequested);
    on<RestoreBackupRequested>(_onRestoreBackupRequested);
    on<ImportDataRequested>(_onImportRequested);
    on<ClearAllDataRequested>(_onClearAllDataRequested);
  }

  Future<void> _onExportRequested(ExportDataRequested event, Emitter<DataManagementState> emit) async {
    emit(DataManagementLoading('Exporting ${event.format.toUpperCase()}...'));
    try {
      String path;
      switch (event.format) {
        case 'json': path = await _exportService.exportToJson(event.userId); break;
        case 'csv': path = await _exportService.exportToCsv(event.userId); break;
        case 'excel': path = await _exportService.exportToExcel(event.userId); break;
        case 'pdf': path = await _exportService.generatePdfReport(event.userId); break;
        default: throw Exception('Unsupported format');
      }
      emit(DataManagementSuccess('Export completed successfully', filePath: path));
    } catch (e) {
      emit(DataManagementFailure(e.toString()));
    }
  }

  Future<void> _onCreateBackupRequested(CreateBackupRequested event, Emitter<DataManagementState> emit) async {
    emit(DataManagementLoading('Creating backup...'));
    try {
      File backup;
      if (event.password != null && event.password!.isNotEmpty) {
        backup = await _backupService.createEncryptedBackup(event.password!);
      } else {
        backup = await _backupService.createFullBackup();
      }
      emit(DataManagementSuccess('Backup created: ${backup.path.split('/').last}'));
    } catch (e) {
      emit(DataManagementFailure(e.toString()));
    }
  }

  Future<void> _onRestoreBackupRequested(RestoreBackupRequested event, Emitter<DataManagementState> emit) async {
    emit(DataManagementLoading('Restoring from backup...'));
    try {
      if (event.password != null) {
        await _backupService.restoreFromEncryptedBackup(event.file, event.password!);
      } else {
        // Raw restore (copying over .db)
        // Note: For simplicity, assuming caller handles file swap or we handle it here
        final dbPath = await _backupService.createFullBackup(); // Just to get the path
        await event.file.copy(dbPath.path.replaceAll(RegExp(r'backup_.*\.db'), 'sorutrack_pro.db'));
      }
      emit(DataManagementSuccess('Restore successful. Please restart the app.'));
    } catch (e) {
      emit(DataManagementFailure(e.toString()));
    }
  }

  Future<void> _onImportRequested(ImportDataRequested event, Emitter<DataManagementState> emit) async {
    emit(DataManagementLoading('Importing data...'));
    try {
      List<Map<String, dynamic>> data;
      if (event.type == 'healthifyme') {
        data = await _importService.parseHealthifyMe(event.file);
      } else if (event.type == 'mfp') {
        data = await _importService.parseMyFitnessPal(event.file);
      } else {
        data = await _importService.parseGenericCsv(event.file, event.mapping!);
      }
      
      final result = await _importService.importData(event.userId, data);
      emit(DataManagementSuccess('Imported ${result.imported} logs. Errors: ${result.errors}'));
    } catch (e) {
      emit(DataManagementFailure(e.toString()));
    }
  }

  Future<void> _onClearAllDataRequested(ClearAllDataRequested event, Emitter<DataManagementState> emit) async {
    emit(DataManagementLoading('Clearing all data...'));
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.clearAllData();
      emit(DataManagementSuccess('All data cleared successfully. Please restart the app.'));
    } catch (e) {
      emit(DataManagementFailure(e.toString()));
    }
  }
}
