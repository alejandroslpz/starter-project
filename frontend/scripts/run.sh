#!/bin/sh
# Run the app with the required dart-define flags.
# Usage: NEWS_API_KEY=<your-key> sh scripts/run.sh [flutter run args]
#
# Prerequisites:
#   - frontend/lib/firebase_options.dart must exist (run flutterfire configure)
#   - frontend/android/app/google-services.json must exist
#   - frontend/ios/Runner/GoogleService-Info.plist must exist (iOS builds)
set -e

if [ -z "$NEWS_API_KEY" ]; then
  echo "ERROR: NEWS_API_KEY environment variable is not set."
  echo "Usage: NEWS_API_KEY=<your-key> sh scripts/run.sh [flutter run args]"
  exit 1
fi

flutter run --dart-define=NEWS_API_KEY="$NEWS_API_KEY" "$@"
