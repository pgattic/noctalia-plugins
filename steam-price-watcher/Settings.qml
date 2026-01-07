import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

ColumnLayout {
  id: root
  spacing: Style.marginM

  property var pluginApi: null
  
  // Configuration
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property var watchlist: cfg.watchlist || defaults.watchlist || []
  property int checkInterval: cfg.checkInterval ?? defaults.checkInterval ?? 30
  property string currency: cfg.currency || defaults.currency || "br"
  property string currencySymbol: cfg.currencySymbol || defaults.currencySymbol || "R$"

  // Search state
  property var searchResults: []
  property bool searching: false
  property string searchQuery: ""

  // Header
  NText {
    text: "Steam Price Watcher"
    pointSize: Style.fontSizeXXL
    font.weight: Style.fontWeightBold
    color: Color.mOnSurface
  }

  NText {
    text: pluginApi?.tr("steam-price-watcher.settings.description") || 
      "Configure o intervalo de verificação e adicione jogos à sua watchlist pesquisando na Steam."
    color: Color.mOnSurfaceVariant
    pointSize: Style.fontSizeM
    Layout.fillWidth: true
    wrapMode: Text.WordWrap
  }

  // Check interval setting
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: intervalContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: intervalContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.check-interval") || "Intervalo de Verificação"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.check-every") || "Verificar preços a cada"
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }

        NTextInput {
          id: intervalInput
          Layout.preferredWidth: 80 * Style.uiScaleRatio
          Layout.preferredHeight: Style.baseWidgetSize
          text: checkInterval.toString()
          
          onTextChanged: {
            var val = parseInt(text);
            if (!isNaN(val) && val >= 15 && val <= 1440) {
              if (pluginApi && pluginApi.pluginSettings) {
                pluginApi.pluginSettings.checkInterval = val;
                pluginApi.saveSettings();
              }
            }
          }
        }

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.minutes") || "minutos"
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }
      }

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.interval-warning") || 
          "⚠️ Intervalos muito curtos podem resultar em muitas requisições à API da Steam."
        color: Color.mError
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        visible: checkInterval < 30
      }
    }
  }

  // Currency settings
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: 180 * Style.uiScaleRatio
    color: Color.mSurfaceVariant

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.currency") || "Currency"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.currency-description") || "Select the currency for displaying Steam prices."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      ListModel {
        id: currencyModel
        ListElement { name: "🇦🇷 Peso Argentino (ARS)"; key: "ar" }
        ListElement { name: "🇦🇺 Dólar Australiano (AUD)"; key: "au" }
        ListElement { name: "🇧🇷 Real Brasileiro (BRL)"; key: "br" }
        ListElement { name: "🇨🇦 Dólar Canadense (CAD)"; key: "ca" }
        ListElement { name: "🇨🇭 Franco Suíço (CHF)"; key: "ch" }
        ListElement { name: "🇨🇱 Peso Chileno (CLP)"; key: "cl" }
        ListElement { name: "🇨🇳 Yuan Chinês (CNY)"; key: "cn" }
        ListElement { name: "🇨🇴 Peso Colombiano (COP)"; key: "co" }
        ListElement { name: "🇨🇷 Colón Costarricense (CRC)"; key: "cr" }
        ListElement { name: "🇪🇺 Euro (EUR)"; key: "eu" }
        ListElement { name: "🇬🇧 Libra Esterlina (GBP)"; key: "gb" }
        ListElement { name: "🇭🇰 Dólar de Hong Kong (HKD)"; key: "hk" }
        ListElement { name: "🇮🇩 Rupia Indonésia (IDR)"; key: "id" }
        ListElement { name: "🇮🇱 Novo Shekel Israelense (ILS)"; key: "il" }
        ListElement { name: "🇮🇳 Rupia Indiana (INR)"; key: "in" }
        ListElement { name: "🇯🇵 Iene Japonês (JPY)"; key: "jp" }
        ListElement { name: "🇰🇷 Won Sul-Coreano (KRW)"; key: "kr" }
        ListElement { name: "🇰🇼 Dinar Kuwaitiano (KWD)"; key: "kw" }
        ListElement { name: "🇰🇿 Tenge Cazaque (KZT)"; key: "kz" }
        ListElement { name: "🇲🇽 Peso Mexicano (MXN)"; key: "mx" }
        ListElement { name: "🇲🇾 Ringgit Malaio (MYR)"; key: "my" }
        ListElement { name: "🇳🇴 Coroa Norueguesa (NOK)"; key: "no" }
        ListElement { name: "🇳🇿 Dólar Neozelandês (NZD)"; key: "nz" }
        ListElement { name: "🇵🇪 Sol Peruano (PEN)"; key: "pe" }
        ListElement { name: "🇵🇭 Peso Filipino (PHP)"; key: "ph" }
        ListElement { name: "🇵🇱 Zloty Polonês (PLN)"; key: "pl" }
        ListElement { name: "🇶🇦 Riyal Catariano (QAR)"; key: "qa" }
        ListElement { name: "🇷🇺 Rublo Russo (RUB)"; key: "ru" }
        ListElement { name: "🇸🇦 Riyal Saudita (SAR)"; key: "sa" }
        ListElement { name: "🇸🇪 Coroa Sueca (SEK)"; key: "se" }
        ListElement { name: "🇸🇬 Dólar de Singapura (SGD)"; key: "sg" }
        ListElement { name: "🇹🇭 Baht Tailandês (THB)"; key: "th" }
        ListElement { name: "🇹🇷 Lira Turca (TRY)"; key: "tr" }
        ListElement { name: "🇹🇼 Dólar de Taiwan (TWD)"; key: "tw" }
        ListElement { name: "🇺🇦 Hryvnia Ucraniana (UAH)"; key: "ua" }
        ListElement { name: "🇺🇸 Dólar Americano (USD)"; key: "us" }
        ListElement { name: "🇺🇾 Peso Uruguaio (UYU)"; key: "uy" }
        ListElement { name: "🇻🇳 Dong Vietnamita (VND)"; key: "vn" }
        ListElement { name: "🇿🇦 Rand Sul-Africano (ZAR)"; key: "za" }
      }

      NComboBox {
        Layout.fillWidth: true
        Layout.preferredHeight: Style.baseWidgetSize
        model: currencyModel
        currentKey: cfg.currency || defaults.currency || "br"
        onSelected: key => {
          if (pluginApi && pluginApi.pluginSettings) {
            pluginApi.pluginSettings.currency = key;
            
            // Define o símbolo da moeda
            var symbols = {
              "ar": "ARS$", "au": "A$", "br": "R$", "ca": "CA$", "ch": "CHF",
              "cl": "CLP$", "cn": "¥", "co": "COL$", "cr": "₡", "eu": "€",
              "gb": "£", "hk": "HK$", "id": "Rp", "il": "₪", "in": "₹",
              "jp": "¥", "kr": "₩", "kw": "KD", "kz": "₸", "mx": "Mex$",
              "my": "RM", "no": "kr", "nz": "NZ$", "pe": "S/", "ph": "₱",
              "pl": "zł", "qa": "QR", "ru": "₽", "sa": "SR", "se": "kr",
              "sg": "S$", "th": "฿", "tr": "₺", "tw": "NT$", "ua": "₴",
              "us": "$", "uy": "$U", "vn": "₫", "za": "R"
            };
            pluginApi.pluginSettings.currencySymbol = symbols[key] || "$";
            pluginApi.saveSettings();
          }
        }
      }
    }
  }

  // Wishlist Import section
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: wishlistImportContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    property bool importing: false
    property string importStatus: ""

    ColumnLayout {
      id: wishlistImportContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.import-wishlist") || "Importar Wishlist do Steam"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.import-description") ||
          "Importe sua wishlist diretamente do Steam. Insira seu Steam ID ou nome de usuário personalizado."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NTextInput {
          id: steamIdInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          placeholderText: pluginApi?.tr("steam-price-watcher.settings.steam-id-placeholder") ||
            "Ex: 76561198012345678 ou seu_username"
        }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.settings.import") || "Importar"
          enabled: !parent.parent.parent.importing && steamIdInput.text.trim().length > 0
          onClicked: {
            if (steamIdInput.text.trim().length > 0) {
              importWishlist(steamIdInput.text.trim());
            }
          }
        }
      }

      // Status messages
      NText {
        visible: parent.parent.importing
        text: pluginApi?.tr("steam-price-watcher.settings.importing") || "Importando wishlist..."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        Layout.fillWidth: true

        NIcon {
          anchors.left: parent.left
          anchors.leftMargin: -25
          anchors.verticalCenter: parent.verticalCenter
          icon: "loader"
          pointSize: Style.fontSizeM
          color: Color.mPrimary

          RotationAnimator on rotation {
            running: wishlistImportContent.parent.importing
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
          }
        }
      }

      NText {
        visible: parent.parent.importStatus.length > 0 && !parent.parent.importing
        text: parent.parent.importStatus
        color: parent.parent.importStatus.includes("sucesso") || parent.parent.importStatus.includes("success") ?
          Color.mPrimary : Color.mError
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.wishlist-note") ||
          "⚠️ Nota: Seu perfil Steam deve estar público para que a importação funcione."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }
    }
  }

  // Search section
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: 500 * Style.uiScaleRatio
    color: Color.mSurfaceVariant

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.add-games") || "Adicionar Jogos"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.search-hint") || 
          "Pesquise jogos pelo nome. Digite o nome do jogo e clique em Pesquisar."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NTextInput {
          id: searchInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          placeholderText: pluginApi?.tr("steam-price-watcher.settings.search-placeholder") || 
            "Digite o nome do jogo (ex: Counter Strike)"
        }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.settings.search") || "Pesquisar"
          enabled: !searching && searchInput.text.trim().length > 0
          onClicked: {
            if (searchInput.text.trim().length > 0) {
              searchGame(searchInput.text.trim());
            }
          }
        }
      }

      // Loading indicator
      NText {
        visible: searching
        text: pluginApi?.tr("steam-price-watcher.settings.searching") || "Pesquisando..."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        Layout.fillWidth: true
        
        NIcon {
          id: loadingIcon
          anchors.left: parent.left
          anchors.leftMargin: -25
          anchors.verticalCenter: parent.verticalCenter
          icon: "loader"
          pointSize: Style.fontSizeM
          color: Color.mPrimary
          
          RotationAnimator on rotation {
            running: searching
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
          }
        }
      }

      // Search results
      ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: searchResults.length > 0
        clip: true

        ListView {
          model: searchResults
          spacing: Style.marginS

          delegate: NBox {
            required property var modelData
            required property int index

            width: ListView.view.width
            implicitHeight: resultContent.implicitHeight + Style.marginM * 2
            color: Color.mSurface

            RowLayout {
              id: resultContent
              anchors.fill: parent
              anchors.margins: Style.marginM
              spacing: Style.marginM

              // Game image
              Rectangle {
                Layout.preferredWidth: 184 * Style.uiScaleRatio * 0.6
                Layout.preferredHeight: 69 * Style.uiScaleRatio * 0.6
                Layout.alignment: Qt.AlignVCenter
                color: Color.mSurfaceVariant
                radius: Style.iRadiusS
                border.color: Color.mOutline
                border.width: 1
                
                Image {
                  anchors.fill: parent
                  anchors.margins: 1
                  source: `https://cdn.cloudflare.steamstatic.com/steam/apps/${modelData.appId}/capsule_184x69.jpg`
                  fillMode: Image.PreserveAspectFit
                  asynchronous: true
                  
                  Rectangle {
                    anchors.fill: parent
                    color: Color.mSurfaceVariant
                    visible: parent.status === Image.Loading || parent.status === Image.Error
                    radius: Style.iRadiusS
                    
                    NIcon {
                      anchors.centerIn: parent
                      icon: "gamepad"
                      color: Color.mOnSurfaceVariant
                      pointSize: 20
                    }
                  }
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

              RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: Style.marginXS

                  NText {
                    text: modelData.name
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeM
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                  }

                  NText {
                    text: `App ID: ${modelData.appId}`
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeS
                  }

                  NText {
                    text: modelData.price ? `${root.currencySymbol} ${modelData.price.toFixed(2)}` : 
                      (pluginApi?.tr("steam-price-watcher.settings.free") || "Gratuito")
                    color: Color.mPrimary
                    pointSize: Style.fontSizeM
                    visible: modelData.price !== undefined
                  }
                }

                NButton {
                  text: isGameInWatchlist(modelData.appId) ? 
                    (pluginApi?.tr("steam-price-watcher.settings.added") || "✓ Adicionado") :
                    (pluginApi?.tr("steam-price-watcher.settings.add") || "+ Adicionar")
                  enabled: !isGameInWatchlist(modelData.appId)
                  onClicked: {
                    if (modelData.price && modelData.price > 0) {
                      addGameDialog.open(modelData);
                    }
                  }
                }
              }
              }

              NText {
                text: pluginApi?.tr("steam-price-watcher.settings.free-game-note") || 
                  "Jogos gratuitos não podem ser adicionados à watchlist."
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeS
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                visible: !modelData.price || modelData.price === 0
              }
            }
          }
        }
      }

      // No results message
      NText {
        visible: !searching && searchResults.length === 0 && searchQuery.length > 0
        text: pluginApi?.tr("steam-price-watcher.settings.no-results") || 
          "Nenhum jogo encontrado. Verifique o App ID e tente novamente."
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
      }

      // Current watchlist
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        visible: watchlist.length > 0

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          color: Color.mOutline
        }

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.current-watchlist") || 
            `Watchlist atual (${watchlist.length} ${watchlist.length === 1 ? "jogo" : "jogos"})`
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
          font.weight: Style.fontWeightBold
        }

        ScrollView {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(200 * Style.uiScaleRatio, watchlist.length * 70 * Style.uiScaleRatio)
          clip: true

          ListView {
            id: watchlistView
            spacing: Style.marginS
            model: root.watchlist

            delegate: NBox {
              required property var modelData
              required property int index

              width: watchlistView.width
              implicitHeight: gameRow.implicitHeight + Style.marginS * 2
              color: Color.mSurface

              RowLayout {
                id: gameRow
                anchors.fill: parent
                anchors.margins: Style.marginS
                spacing: Style.marginM

                // Game image
                Rectangle {
                  Layout.preferredWidth: 184 * Style.uiScaleRatio * 0.5
                  Layout.preferredHeight: 69 * Style.uiScaleRatio * 0.5
                  Layout.alignment: Qt.AlignVCenter
                  color: Color.mSurfaceVariant
                  radius: Style.iRadiusS
                  border.color: Color.mOutline
                  border.width: 1
                  
                  Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: `https://cdn.cloudflare.steamstatic.com/steam/apps/${modelData.appId}/capsule_184x69.jpg`
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    
                    Rectangle {
                      anchors.fill: parent
                      color: Color.mSurfaceVariant
                      visible: parent.status === Image.Loading || parent.status === Image.Error
                      radius: Style.iRadiusS
                      
                      NIcon {
                        anchors.centerIn: parent
                        icon: "gamepad"
                        color: Color.mOnSurfaceVariant
                        pointSize: 16
                      }
                    }
                  }
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 2

                  NText {
                    text: modelData.name
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeS
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                  }

                  NText {
                    text: modelData.addedDate ? 
                      `${new Date(modelData.addedDate).toLocaleDateString('pt-BR')}` :
                      `App ID: ${modelData.appId}`
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeXS
                  }
                }

                NText {
                  text: `${root.currencySymbol} ${modelData.targetPrice.toFixed(2)}`
                  color: Color.mPrimary
                  pointSize: Style.fontSizeM
                  font.weight: Style.fontWeightBold
                }

                RowLayout {
                  spacing: Style.marginXS

                  NIconButton {
                    icon: "pencil"
                    tooltipText: pluginApi?.tr("steam-price-watcher.edit") || "Editar"
                    baseSize: Style.baseWidgetSize * 0.6
                    colorBg: Color.mPrimary
                    colorFg: Color.mOnPrimary
                    onClicked: editGameDialog.open(modelData, index)
                  }

                  NIconButton {
                    icon: "trash"
                    tooltipText: pluginApi?.tr("steam-price-watcher.remove") || "Remover"
                    baseSize: Style.baseWidgetSize * 0.6
                    colorBg: Color.mError
                    colorFg: Color.mOnError
                    onClicked: removeGame(index)
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Add Game Dialog
  Popup {
    id: addGameDialog
    anchors.centerIn: Overlay.overlay
    width: 400 * Style.uiScaleRatio
    height: contentItem.implicitHeight + Style.marginL * 2
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var gameData: null

    function open(game) {
      gameData = game;
      targetPriceInput.text = game.price ? (game.price * 0.8).toFixed(2) : "0.00";
      visible = true;
    }

    background: Rectangle {
      color: Color.mSurface
      radius: Style.iRadiusL
      border.color: Color.mOutline
      border.width: Style.borderM
    }

    contentItem: ColumnLayout {
      spacing: Style.marginM

      NText {
        text: pluginApi?.tr("steam-price-watcher.settings.add-to-watchlist") || "Adicionar à Watchlist"
        color: Color.mOnSurface
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
      }

      NText {
        text: addGameDialog.gameData ? addGameDialog.gameData.name : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.current-price-label") || "Preço atual:"
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
        }

        NText {
          text: addGameDialog.gameData && addGameDialog.gameData.price ? 
            `${root.currencySymbol} ${addGameDialog.gameData.price.toFixed(2)}` : ""
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
          font.weight: Style.fontWeightBold
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.target-price-label") || `Preço-alvo (${root.currencySymbol}):`
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }

        NTextInput {
          id: targetPriceInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          text: "0.00"
          
          property var numberValidator: DoubleValidator {
            bottom: 0
            decimals: 2
            notation: DoubleValidator.StandardNotation
          }
          
          Component.onCompleted: {
            if (inputItem) {
              inputItem.validator = numberValidator;
            }
          }
        }

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.target-price-hint") || 
            "💡 Sugerimos 20% abaixo do preço atual para boas ofertas."
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS
          Layout.fillWidth: true
          wrapMode: Text.WordWrap
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        Item { Layout.fillWidth: true }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.cancel") || "Cancelar"
          onClicked: addGameDialog.close()
        }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.add") || "Adicionar"
          onClicked: {
            var targetPrice = parseFloat(targetPriceInput.text);
            if (!isNaN(targetPrice) && targetPrice > 0) {
              addGameToWatchlist(addGameDialog.gameData, targetPrice);
              addGameDialog.close();
            }
          }
        }
      }
    }
  }

  // Functions
  function searchGame(query) {
    searching = true;
    searchQuery = query;
    searchResults = [];
    
    // Search by game name using Steam's search API
    searchGamesByName(query);
  }

  function searchGamesByName(gameName) {
    var process = Qt.createQmlObject(`
      import Quickshell.Io
      Process {
        running: true
        command: ["curl", "-s", "https://steamcommunity.com/actions/SearchApps/${encodeURIComponent(gameName)}"]
        stdout: StdioCollector {}
        
        onExited: (exitCode) => {
          if (exitCode === 0) {
            try {
              var results = JSON.parse(stdout.text);
              if (results && results.length > 0) {
                // Fetch prices for the top 5 results
                var topResults = results.slice(0, 5);
                root.pendingFetches = topResults.length;
                
                for (var i = 0; i < topResults.length; i++) {
                  root.fetchGamePrice(topResults[i].appid, topResults[i].name);
                }
              } else {
                root.searchResults = [];
                root.searching = false;
              }
            } catch (e) {
              console.error("Error parsing search results:", e);
              root.searchResults = [];
              root.searching = false;
            }
          } else {
            root.searchResults = [];
            root.searching = false;
          }
          
          destroy();
        }
      }
    `, root, "searchProcess");
  }

  property int pendingFetches: 0

  function fetchGamePrice(appId, gameName) {
    var process = Qt.createQmlObject(`
      import Quickshell.Io
      Process {
        running: true
        command: ["curl", "-s", "https://store.steampowered.com/api/appdetails?appids=${appId}&cc=${cfg.currency || defaults.currency || "br"}"]
        stdout: StdioCollector {}
        property int gameAppId: ${appId}
        property string gameNameStr: "${gameName.replace(/"/g, '\\"')}"
        
        onExited: (exitCode) => {
          if (exitCode === 0) {
            try {
              var response = JSON.parse(stdout.text);
              var appData = response[gameAppId.toString()];
              if (appData && appData.success && appData.data) {
                var game = {
                  appId: gameAppId,
                  name: appData.data.name || gameNameStr,
                  price: 0
                };
                
                if (appData.data.price_overview) {
                  game.price = appData.data.price_overview.final / 100;
                }
                
                // Add to results
                var temp = root.searchResults.slice();
                temp.push(game);
                root.searchResults = temp;
              }
            } catch (e) {
              console.error("Error parsing Steam API response:", e);
            }
          }
          
          root.pendingFetches--;
          if (root.pendingFetches === 0) {
            root.searching = false;
          }
          destroy();
        }
      }
    `, root, "searchProcess");
  }

  function isGameInWatchlist(appId) {
    for (var i = 0; i < watchlist.length; i++) {
      if (watchlist[i].appId === appId) {
        return true;
      }
    }
    return false;
  }

  function addGameToWatchlist(game, targetPrice) {
    if (pluginApi && pluginApi.pluginSettings) {
      var temp = watchlist.slice();
      temp.push({
        appId: game.appId,
        name: game.name,
        targetPrice: targetPrice,
        addedDate: new Date().toISOString()
      });
      
      pluginApi.pluginSettings.watchlist = temp;
      pluginApi.saveSettings();
      console.log("Steam Price Watcher: Added", game.name, "with target price", targetPrice);
      
      // Clear search
      searchInput.text = "";
      searchResults = [];
      searchQuery = "";
    }
  }

  function removeGame(index) {
    if (pluginApi && pluginApi.pluginSettings) {
      var temp = watchlist.slice();
      var removed = temp.splice(index, 1);
      
      // Remover jogo da lista de notificados
      if (removed.length > 0) {
        var appId = removed[0].appId;
        var notifiedGames = pluginApi.pluginSettings.notifiedGames || [];
        var notifiedTemp = [];
        for (var j = 0; j < notifiedGames.length; j++) {
          if (notifiedGames[j] !== appId) {
            notifiedTemp.push(notifiedGames[j]);
          }
        }
        pluginApi.pluginSettings.notifiedGames = notifiedTemp;
      }
      
      pluginApi.pluginSettings.watchlist = temp;
      pluginApi.saveSettings();
      console.log("Steam Price Watcher: Removed", removed[0].name, "and cleared from notifications");
    }
  }

  function updateGamePrice(index, newPrice) {
    if (pluginApi && pluginApi.pluginSettings) {
      var temp = watchlist.slice();
      temp[index].targetPrice = newPrice;
      pluginApi.pluginSettings.watchlist = temp;
      pluginApi.saveSettings();
      console.log("Steam Price Watcher: Updated", temp[index].name, "target price to", newPrice);
    }
  }

  // Edit Game Dialog
  Popup {
    id: editGameDialog
    anchors.centerIn: Overlay.overlay
    width: 400 * Style.uiScaleRatio
    height: contentItem.implicitHeight + Style.marginL * 2
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var gameData: null
    property int gameIndex: -1

    function open(game, index) {
      gameData = game;
      gameIndex = index;
      editPriceInput.text = game.targetPrice.toFixed(2);
      visible = true;
    }

    background: Rectangle {
      color: Color.mSurface
      radius: Style.iRadiusL
      border.color: Color.mOutline
      border.width: Style.borderM
    }

    contentItem: ColumnLayout {
      spacing: Style.marginM

      NText {
        text: pluginApi?.tr("steam-price-watcher.edit-target-price") || "Editar Preço-Alvo"
        color: Color.mOnSurface
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
      }

      NText {
        text: editGameDialog.gameData ? editGameDialog.gameData.name : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NText {
          text: pluginApi?.tr("steam-price-watcher.settings.target-price-label") || `Preço-alvo (${root.currencySymbol}):`
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }

        NTextInput {
          id: editPriceInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          placeholderText: "0.00"
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        Item { Layout.fillWidth: true }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.cancel") || "Cancelar"
          onClicked: editGameDialog.close()
        }

        NButton {
          text: pluginApi?.tr("steam-price-watcher.save") || "Salvar"
          onClicked: {
            var newPrice = parseFloat(editPriceInput.text);
            if (!isNaN(newPrice) && newPrice > 0) {
              updateGamePrice(editGameDialog.gameIndex, newPrice);
              editGameDialog.close();
            }
          }
        }
      }
    }
  }

  // Import wishlist from Steam
  property var wishlistImportBox: null

  Component.onCompleted: {
    // Find the wishlist import box to update its properties
    for (var i = 0; i < root.children.length; i++) {
      if (root.children[i].toString().indexOf("wishlistImportContent") !== -1) {
        wishlistImportBox = root.children[i];
        break;
      }
    }
  }

  function importWishlist(steamId) {
    // Find the wishlist import NBox
    var importBox = null;
    for (var i = 0; i < root.children.length; i++) {
      if (root.children[i].importing !== undefined) {
        importBox = root.children[i];
        break;
      }
    }

    if (!importBox) {
      console.error("Could not find import box");
      return;
    }

    importBox.importing = true;
    importBox.importStatus = "";

    console.log("Steam Price Watcher: Starting wishlist import for", steamId);

    // Try different URL formats
    var urls = [
      "https://store.steampowered.com/wishlist/id/" + steamId + "/wishlistdata/",
      "https://store.steampowered.com/wishlist/profiles/" + steamId + "/wishlistdata/"
    ];

    tryImportFromUrl(urls, 0, importBox);
  }

  function tryImportFromUrl(urls, urlIndex, importBox) {
    if (urlIndex >= urls.length) {
      importBox.importing = false;
      importBox.importStatus = pluginApi?.tr("steam-price-watcher.settings.import-failed") ||
        "❌ Falha ao importar. Verifique se o Steam ID está correto e o perfil está público.";
      console.log("Steam Price Watcher: All URL attempts failed");
      return;
    }

    var url = urls[urlIndex];
    console.log("Steam Price Watcher: Trying URL", url);

    var process = Qt.createQmlObject(`
      import Quickshell.Io
      Process {
        running: true
        command: ["curl", "-s", "${url}"]
        stdout: StdioCollector {}

        onExited: (exitCode) => {
          if (exitCode === 0 && stdout.text.length > 10) {
            try {
              var wishlistData = JSON.parse(stdout.text);
              var gameIds = Object.keys(wishlistData);

              if (gameIds.length === 0) {
                console.log("Steam Price Watcher: Empty wishlist, trying next URL");
                root.tryImportFromUrl(urls, urlIndex + 1, importBox);
              } else {
                console.log("Steam Price Watcher: Found", gameIds.length, "games in wishlist");
                root.processWishlistGames(gameIds, wishlistData, importBox);
              }
            } catch (e) {
              console.error("Steam Price Watcher: Error parsing wishlist:", e);
              root.tryImportFromUrl(urls, urlIndex + 1, importBox);
            }
          } else {
            console.log("Steam Price Watcher: Failed to fetch, trying next URL");
            root.tryImportFromUrl(urls, urlIndex + 1, importBox);
          }
          destroy();
        }
      }
    `, root, "wishlistProcess");
  }

  property int wishlistGamesAdded: 0
  property int wishlistGamesTotal: 0

  function processWishlistGames(gameIds, wishlistData, importBox) {
    wishlistGamesAdded = 0;
    wishlistGamesTotal = gameIds.length;

    var added = 0;
    var skipped = 0;

    for (var i = 0; i < gameIds.length; i++) {
      var appId = parseInt(gameIds[i]);
      var gameInfo = wishlistData[gameIds[i]];

      // Check if game is already in watchlist
      if (isGameInWatchlist(appId)) {
        skipped++;
        console.log("Steam Price Watcher: Skipping", gameInfo.name, "- already in watchlist");
        continue;
      }

      // Fetch price and add to watchlist
      fetchWishlistGamePrice(appId, gameInfo.name, importBox);
    }

    // Update status immediately for skipped games
    if (skipped === gameIds.length) {
      importBox.importing = false;
      importBox.importStatus = pluginApi?.tr("steam-price-watcher.settings.import-all-exist") ||
        "ℹ️ Todos os jogos da wishlist já estão na sua lista.";
    }
  }

  property int pendingWishlistFetches: 0

  function fetchWishlistGamePrice(appId, gameName, importBox) {
    pendingWishlistFetches++;

    var process = Qt.createQmlObject(`
      import Quickshell.Io
      Process {
        running: true
        command: ["curl", "-s", "https://store.steampowered.com/api/appdetails?appids=${appId}&cc=${root.currency}"]
        stdout: StdioCollector {}
        property int gameAppId: ${appId}
        property string gameNameStr: "${gameName.replace(/"/g, '\\"').replace(/\n/g, ' ')}"

        onExited: (exitCode) => {
          if (exitCode === 0) {
            try {
              var response = JSON.parse(stdout.text);
              var appData = response[gameAppId.toString()];

              if (appData && appData.success && appData.data && appData.data.price_overview) {
                var currentPrice = appData.data.price_overview.final / 100;
                var targetPrice = currentPrice * 0.8; // 20% discount

                var game = {
                  appId: gameAppId,
                  name: appData.data.name || gameNameStr,
                  targetPrice: targetPrice,
                  addedDate: new Date().toISOString()
                };

                // Add to watchlist
                var temp = root.watchlist.slice();
                temp.push(game);
                root.pluginApi.pluginSettings.watchlist = temp;
                root.pluginApi.saveSettings();
                root.wishlistGamesAdded++;

                console.log("Steam Price Watcher: Added from wishlist:", game.name, "target:", targetPrice);
              } else {
                console.log("Steam Price Watcher: Skipping", gameNameStr, "- no price available");
              }
            } catch (e) {
              console.error("Steam Price Watcher: Error processing game:", e);
            }
          }

          root.pendingWishlistFetches--;
          if (root.pendingWishlistFetches === 0) {
            importBox.importing = false;
            if (root.wishlistGamesAdded > 0) {
              importBox.importStatus = (root.pluginApi?.tr("steam-price-watcher.settings.import-success") || "✅ Importação concluída! {count} jogos adicionados.").replace("{count}", root.wishlistGamesAdded.toString());
            } else {
              importBox.importStatus = root.pluginApi?.tr("steam-price-watcher.settings.import-no-games") || "ℹ️ Nenhum jogo com preço foi encontrado na wishlist.";
            }
          }

          destroy();
        }
      }
    `, root, "wishlistGameProcess");
  }

  // Called when user clicks Apply in settings dialog
  function saveSettings() {
    console.log("SteamPriceWatcher: saveSettings() called");
    
    if (!pluginApi) {
      Logger.e("SteamPriceWatcher", "Cannot save settings: pluginApi is null");
      return;
    }

    // Save settings to disk
    pluginApi.saveSettings();
    
    // Show notification
    var message = pluginApi?.tr("steam-price-watcher.settings.settings-saved") || "Plugin settings saved.";
    console.log("SteamPriceWatcher: Showing toast with message:", message);
    ToastService.showNotice(message);
    
    Logger.i("SteamPriceWatcher", "Settings saved successfully");
  }
}
