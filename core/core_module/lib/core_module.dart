library core_module;

// Widgets
export 'src/widgets/custom_header.dart';
export 'src/widgets/custom_bottom_nav.dart';
export 'src/widgets/custom_text_field.dart';
export 'src/widgets/custom_dropdown.dart';
export 'src/widgets/notification_banner.dart';
export 'src/widgets/shimmer_loading.dart';
export 'src/widgets/status_dialog.dart';
export 'src/widgets/claim_progress_stepper.dart';
export 'src/widgets/report_progress_stepper.dart';

// Theme
export 'src/theme/color_service.dart';
export 'src/theme/theme_service.dart';

// Services
export 'src/services/hive_service.dart';
export 'src/services/network_service.dart';
export 'src/services/cloudinary_service.dart';
export 'src/services/file_service.dart';
export 'src/services/pdf_service.dart';
export 'src/services/image_compress_service.dart';

// Repositories
export 'src/repositories/report_repository.dart';
export 'src/repositories/claim_repository.dart';
export 'src/repositories/notification_repository.dart';

// Controllers
export 'src/controllers/session_controller.dart';

// Models
export 'src/models/user_model.dart';
export 'src/models/report_model.dart';
export 'src/models/claim_model.dart';
export 'src/models/notification_model.dart';

// Utils
export 'src/utils/time_helper.dart';

// Enums
export 'src/enums/notifier_state.dart';

import 'package:timeago/timeago.dart' as timeago_lib;

class CoreSetup {
  static void init() {
    timeago_lib.setLocaleMessages('id', timeago_lib.IdMessages());
  }
}
