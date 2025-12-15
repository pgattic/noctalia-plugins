import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  // ===== REQUIRED PROPERTIES =====
  // These MUST be defined for the shell loader to inject location data correctly.
  
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // ===== DATA BINDING =====

  // Safe access to main instance to prevent startup errors
  readonly property string layoutCode: pluginApi?.mainInstance?.getMonitorLayout(screen?.name) || "?"
  readonly property string layoutName: pluginApi?.mainInstance?.getLayoutName(layoutCode) || layoutCode

  // ===== SIZING =====

  // Bind the size to the pill so it reserves correct space in the bar
  implicitWidth: pill.width
  implicitHeight: pill.height

  // ===== COMPONENT =====

  // Uses the native Noctalia component for perfect consistency
  BarPill {
    id: pill

    // Pass the shell/screen properties
    screen: root.screen
    density: Settings.data.bar.density
    
    // Automatically calculate direction based on the 'section' property
    oppositeDirection: BarService.getPillDirection(root)

    // Content: Static Icon + Dynamic Text (Layout Name)
    icon: "layout-dashboard"
    text: root.layoutName
    
    // Tooltip for accessibility
    tooltipText: "Layout: " + root.layoutName

    // Interaction: Open panel on click
    onClicked: {
      if (pluginApi) pluginApi.openPanel(root.screen)
    }
  }
}
