import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:universal_platform/universal_platform.dart';

@lazySingleton
class HomeWidgetService {
  static const String _androidWidgetName = 'SoruTrackWidget';
  static const String _iosWidgetName = 'SoruTrackWidget';

  Future<void> updateWidget({
    required double caloriesConsumed,
    required double calorieTarget,
    required int streak,
  }) async {
    try {
      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
        await HomeWidget.saveWidgetData<double>('caloriesConsumed', caloriesConsumed);
        await HomeWidget.saveWidgetData<double>('calorieTarget', calorieTarget);
        await HomeWidget.saveWidgetData<int>('streak', streak);

        await HomeWidget.updateWidget(
          name: _androidWidgetName,
          iOSName: _iosWidgetName,
          androidName: _androidWidgetName,
        );
      }
    } catch (_) {}
  }
}
