import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Rectangle {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  
  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: ({})

  // Reactive binding to Main.qml data
  property string rawLayout: pluginApi?.mainInstance?.getMonitorLayout(screen?.name) || "?"
  
  property string displayLetter: {
    if (rawLayout && rawLayout.length > 0 && rawLayout !== "?") {
      return rawLayout.substring(0, 1).toUpperCase()
    }
    return "?"
  }

  implicitWidth: layoutText.implicitWidth + Style.marginM * 2
  implicitHeight: Style.barHeight

  color: Style.capsuleColor
  radius: Style.radiusM

  NText {
    id: layoutText
    anchors.centerIn: parent
    text: root.displayLetter
    color: Color.mOnSurface
    pointSize: Style.fontSizeS
    font.weight: Font.Bold
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    
    onEntered: {
      root.color = Qt.lighter(Style.capsuleColor, 1.2)
      TooltipService.show(root, "Layout: " + root.rawLayout, BarService.getTooltipDirection())
    }
    
    onExited: {
      root.color = Style.capsuleColor
      TooltipService.hide()
    }
    
    onClicked: {
      if (pluginApi) pluginApi.openPanel(root.screen)
    }
  }
}
