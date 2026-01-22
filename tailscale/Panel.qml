import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  readonly property var mainInstance: pluginApi?.mainInstance

  function copyToClipboard(text) {
    var escaped = text.replace(/'/g, "'\\''")
    Quickshell.execDetached(["sh", "-c", "printf '%s' '" + escaped + "' | wl-copy"])
  }

  // Shared state for context menu
  property var selectedPeer: null
  property var selectedPeerDelegate: null

  function openPeerContextMenu(peer, delegate, mouseX, mouseY) {
    selectedPeer = peer
    selectedPeerDelegate = delegate
    peerContextMenu.openAtItem(delegate, mouseX, mouseY)
  }

  function copySelectedPeerIp() {
    if (selectedPeer) {
      var ips = selectedPeer.TailscaleIPs?.filter(ip => ip.startsWith("100.")) || []
      if (ips.length > 0) {
        copyToClipboard(ips[0])
        ToastService.showNotice(
          pluginApi?.tr("toast.ip-copied.title") || "IP Copied",
          ips[0],
          "clipboard"
        )
      }
    }
  }

  function sshToSelectedPeer() {
    if (selectedPeer) {
      var ips = selectedPeer.TailscaleIPs?.filter(ip => ip.startsWith("100.")) || []
      if (ips.length > 0) {
        Quickshell.execDetached(["ghostty", "-e", "ssh", ips[0]])
      }
    }
  }

  function pingSelectedPeer() {
    if (selectedPeer) {
      var ips = selectedPeer.TailscaleIPs?.filter(ip => ip.startsWith("100.")) || []
      if (ips.length > 0) {
        Quickshell.execDetached(["ghostty", "-e", "ping", "-c", "5", ips[0]])
      }
    }
  }

  NContextMenu {
    id: peerContextMenu
    model: [
      { 
        label: pluginApi?.tr("context.copy-ip") || "Copy IP", 
        action: "copy-ip", 
        icon: "clipboard" 
      },
      { 
        label: pluginApi?.tr("context.ssh") || "SSH to host", 
        action: "ssh", 
        icon: "terminal",
        enabled: root.selectedPeer?.Online || false
      },
      { 
        label: pluginApi?.tr("context.ping") || "Ping host", 
        action: "ping", 
        icon: "activity"
      }
    ]
    onTriggered: function(action) {
      switch (action) {
        case "copy-ip":
          root.copySelectedPeerIp()
          break
        case "ssh":
          root.sshToSelectedPeer()
          break
        case "ping":
          root.pingSelectedPeer()
          break
      }
    }
  }

  onPluginApiChanged: {
    if (pluginApi && pluginApi.mainInstance) {
      mainInstanceChanged()
    }
  }

  readonly property bool panelReady: pluginApi !== null && mainInstance !== null && mainInstance !== undefined

  readonly property var sortedPeerList: {
    if (!mainInstance?.peerList) return []
    var peers = mainInstance.peerList.slice()
    peers.sort(function(a, b) {
      // Online peers first
      if (a.Online && !b.Online) return -1
      if (!a.Online && b.Online) return 1
      // Then alphabetically by hostname
      var nameA = (a.HostName || a.DNSName || "").toLowerCase()
      var nameB = (b.HostName || b.DNSName || "").toLowerCase()
      return nameA.localeCompare(nameB)
    })
    return peers
  }

  property real contentPreferredWidth: panelReady ? 400 * Style.uiScaleRatio : 0
  property real contentPreferredHeight: panelReady ? Math.min(500, 100 + (mainInstance?.peerList?.length || 0) * 60) * Style.uiScaleRatio : 0

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"
    visible: panelReady

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginM
      }
      spacing: Style.marginL

      NBox {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM
          clip: true

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
              icon: "network"
              pointSize: Style.fontSizeL
              color: Color.mPrimary
            }

            NText {
              text: pluginApi?.tr("panel.title") || "Tailscale Network"
              pointSize: Style.fontSizeL
              font.weight: Style.fontWeightBold
              color: Color.mOnSurface
              Layout.fillWidth: true
            }

            NText {
              text: (mainInstance?.peerList?.length || 0) + " " + (pluginApi?.tr("panel.peers") || "peers")
              pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
            }
          }

          NText {
            Layout.fillWidth: true
            text: mainInstance?.tailscaleIp || ""
            visible: mainInstance?.tailscaleRunning && mainInstance?.tailscaleIp
            pointSize: Style.fontSizeS
            color: mainIpMouseArea.containsMouse ? Color.mPrimary : Color.mOnSurfaceVariant
            font.family: Settings.data.ui.fontFixed
            
            MouseArea {
              id: mainIpMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: function() {
                if (mainInstance?.tailscaleIp) {
                  root.copyToClipboard(mainInstance.tailscaleIp)
                  ToastService.showNotice(
                    pluginApi?.tr("toast.ip-copied.title") || "IP Copied",
                    mainInstance.tailscaleIp,
                    "clipboard"
                  )
                }
              }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.alpha(Color.mOnSurface, 0.1)
            visible: mainInstance?.tailscaleRunning && mainInstance?.peerList && mainInstance.peerList.length > 0
          }

          Flickable {
            id: peerFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: peerListColumn.height
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            pressDelay: 0

              ColumnLayout {
              id: peerListColumn
              width: peerFlickable.width
              spacing: Style.marginS

              Repeater {
                model: sortedPeerList

                delegate: ItemDelegate {
                  id: peerDelegate
                  Layout.fillWidth: true
                  Layout.preferredWidth: peerFlickable.width
                  implicitWidth: peerFlickable.width
                  height: 48
                  topPadding: Style.marginS
                  bottomPadding: Style.marginS
                  leftPadding: Style.marginL
                  rightPadding: Style.marginL

                  readonly property var peerData: modelData
                  readonly property string peerIp: {
                    var ips = []
                    if (peerData.TailscaleIPs && peerData.TailscaleIPs.length > 0) {
                      ips = peerData.TailscaleIPs.filter(ip => ip.startsWith("100."))
                    }
                    return ips.length > 0 ? ips[0] : ""
                  }
                  readonly property string peerHostname: peerData.HostName || peerData.DNSName || "Unknown"
                  readonly property bool peerOnline: peerData.Online || false

                  background: Rectangle {
                    anchors.fill: parent
                    color: peerDelegate.hovered ? Qt.alpha(Color.mPrimary, 0.1) : "transparent"
                    radius: Style.radiusM
                    border.width: peerDelegate.hovered ? 1 : 0
                    border.color: Qt.alpha(Color.mPrimary, 0.3)
                  }

                  contentItem: RowLayout {
                    spacing: Style.marginM

                    NIcon {
                      icon: peerDelegate.peerOnline ? "circle-check" : "circle-x"
                      pointSize: Style.fontSizeM
                      color: peerDelegate.peerOnline ? Color.mPrimary : Color.mOnSurfaceVariant
                    }

                    NText {
                      text: peerDelegate.peerHostname
                      color: Color.mOnSurface
                      font.weight: Style.fontWeightMedium
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }

                    NText {
                      text: peerDelegate.peerIp
                      pointSize: Style.fontSizeS
                      color: Color.mOnSurfaceVariant
                      font.family: Settings.data.ui.fontFixed
                      visible: peerDelegate.peerIp !== ""
                      Layout.alignment: Qt.AlignRight
                    }
                  }

                  onClicked: {
                    if (peerDelegate.peerIp) {
                      root.copyToClipboard(peerDelegate.peerIp)
                      ToastService.showNotice(
                        pluginApi?.tr("toast.ip-copied.title") || "IP Copied",
                        peerDelegate.peerIp,
                        "clipboard"
                      )
                    }
                  }

                  TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: root.openPeerContextMenu(peerDelegate.peerData, peerDelegate, point.position.x, point.position.y)
                  }
                }
              }

              NText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.marginL
                text: pluginApi?.tr("panel.no-peers") || "No connected peers"
                visible: !mainInstance?.tailscaleRunning || !mainInstance?.peerList || mainInstance.peerList.length === 0
                pointSize: Style.fontSizeM
                color: Color.mOnSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
              }
            }
          }
        }
      }

      NButton {
        Layout.fillWidth: true
        visible: mainInstance?.tailscaleRunning
        text: pluginApi?.tr("panel.admin-console") || "Admin Console"
        icon: "external-link"
        onClicked: {
          Qt.openUrlExternally("https://login.tailscale.com/admin")
        }
      }

      NButton {
        Layout.fillWidth: true
        text: mainInstance?.tailscaleRunning 
          ? (pluginApi?.tr("context.disconnect") || "Disconnect")
          : (pluginApi?.tr("context.connect") || "Connect")
        icon: mainInstance?.tailscaleRunning ? "plug-x" : "plug"
        backgroundColor: mainInstance?.tailscaleRunning ? Color.mError : Color.mPrimary
        textColor: mainInstance?.tailscaleRunning ? Color.mOnError : Color.mOnPrimary
        enabled: mainInstance?.tailscaleInstalled
        onClicked: {
          if (mainInstance) {
            mainInstance.toggleTailscale()
          }
        }
      }
    }
  }
}
