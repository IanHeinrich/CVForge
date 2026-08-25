import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/ui/common/app_colors.dart';

/// The one severity→colour/icon mapping [AtsXrayPainter] and
/// [AtsFindingCard] both draw from — a finding's icon here and its
/// evidence box on the page read as the same colour, not two different
/// severity languages for one thing.
extension AtsFindingSeverityStyle on AtsFindingSeverity {
  Color get color => switch (this) {
    AtsFindingSeverity.critical => kcErrorColor,
    AtsFindingSeverity.warning => kcWarningColor,
    AtsFindingSeverity.info => kcLightGrey,
  };

  IconData get icon => switch (this) {
    AtsFindingSeverity.critical => RemixIcons.error_warning_fill,
    AtsFindingSeverity.warning => RemixIcons.alert_fill,
    AtsFindingSeverity.info => RemixIcons.information_fill,
  };
}
