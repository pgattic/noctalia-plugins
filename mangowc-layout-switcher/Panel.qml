import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property ShellScreen currentScreen
  
  readonly property var geometryPlaceholder: panelContainer

  // ===== DATA BINDING =====

  // Determine monitor
  readonly property string panelMonitor: {
    if (currentScreen && currentScreen.name) return currentScreen.name
    if (pluginApi && pluginApi.currentScreen && pluginApi.currentScreen.name) return pluginApi.currentScreen.name
    
    // Fallback to first available monitor
    if (pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.availableMonitors.length > 0) {
      return pluginApi.mainInstance.availableMonitors[0]
    }
    return ""
  }
  
  readonly property var layouts: pluginApi?.mainInstance?.availableLayouts || []
  readonly property string activeLayout: pluginApi?.mainInstance?.getMonitorLayout(panelMonitor) || ""

  // ===== SETTINGS =====

  property bool applyToAll: false
  
  // Increased size to accommodate Symbol + Text comfortably
  property real contentPreferredWidth: 460 * Style.uiScaleRatio 
  property real contentPreferredHeight: 360 * Style.uiScaleRatio

  Component.onCompleted: {
    if (pluginApi?.mainInstance) {
      pluginApi.mainInstance.refresh()
    }
  }

  // ===== UI CONTENT =====

  MouseArea {
    anchors.fill: parent
    onClicked: pluginApi.closePanel()

    Rectangle {
      id: panelContainer
      anchors.centerIn: parent
      width: root.contentPreferredWidth
      height: root.contentPreferredHeight
      
      color: Color.mSurface
      radius: Style.radiusL
      border.width: 1
      border.color: Color.mOutline
      
      MouseArea { anchors.fill: parent; onClicked: {} }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginL
        spacing: Style.marginM

        // Header
        NText {
          text: "Switch Layout"
          pointSize: Style.fontSizeL
          font.weight: Font.Medium
          color: Color.mOnSurface
        }

        // Options Row
        RowLayout {
          Layout.fillWidth: true
          
          NText {
            text: "Apply to all monitors"
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeS
          }
 
          Item { Layout.fillWidth: true }
          
          NToggle {
            checked: root.applyToAll
            onToggled: (checked) => { root.applyToAll = checked }
          }
        }

        NDivider { Layout.fillWidth: true }

        // Layout Grid
        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          rowSpacing: Style.marginS
          columnSpacing: Style.marginS

          Repeater {
            model: root.layouts
            
            delegate: Rectangle {
              id: layoutBtn
              Layout.fillWidth: true
              Layout.preferredHeight: 60 * Style.uiScaleRatio
              
              property bool isActive: modelData.code === root.activeLayout
              property bool isHovered: false

              // Background: Active = Primary, Inactive = SurfaceVariant
              color: isActive ? Color.mPrimary : Color.mSurfaceVariant
              radius: Style.radiusM
              
              // Border Highlight on Hover (only for inactive items)
              border.width: 2
              border.color: !isActive && isHovered ? Color.mPrimary : Color.transparent
              
              // Smooth transitions
              Behavior on border.color { ColorAnimation { duration: 150 } }
              Behavior on color { ColorAnimation { duration: 150 } }

              ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                width: parent.width - (Style.marginS * 2)

                // 1. Symbol / Letter (Large, Bold)
                NText {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.code
                  color: layoutBtn.isActive ? Color.mOnPrimary : Color.mOnSurface
                  font.weight: Font.Black
                  pointSize: Style.fontSizeL
                }

                // 2. Full Name (Small, Regular)
                NText {
                  Layout.alignment: Qt.AlignHCenter
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  
                  text: modelData.name
                  color: layoutBtn.isActive ? Color.mOnPrimary : Color.mOnSurface
                  opacity: layoutBtn.isActive ? 1.0 : 0.7 // Visual hierarchy
                  
                  font.weight: Font.Medium
                  pointSize: Style.fontSizeXS
                  elide: Text.ElideRight
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onEntered: layoutBtn.isHovered = true
                onExited: layoutBtn.isHovered = false
                
                onClicked: {
                  if (root.applyToAll) {
                    pluginApi.mainInstance.setLayoutGlobally(modelData.code)
                  } else {
                    pluginApi.mainInstance.setLayout(root.panelMonitor, modelData.code)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
