#!/usr/bin/env python3
from pathlib import Path
import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle


def main():
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("StarRain")
    app.setApplicationName("ProjectBlackbox")
    QQuickStyle.setStyle("Basic")
    engine = QQmlApplicationEngine()
    entry = Path(__file__).resolve().parents[1] / "Preview.qml"
    engine.load(QUrl.fromLocalFile(str(entry)))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
