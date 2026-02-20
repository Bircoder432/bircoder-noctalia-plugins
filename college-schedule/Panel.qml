import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  property var pluginApi: null

  readonly property var geometryPlaceholder: mainContainer
  readonly property bool allowAttach: false

  property real contentPreferredWidth: 600 * Style.uiScaleRatio
  property real contentPreferredHeight: 500 * Style.uiScaleRatio

  property bool panelAnchorBottom: true
  property bool panelAnchorTop: false
  property bool panelAnchorLeft: false
  property bool panelAnchorRight: true
  property bool panelAnchorHorizontalCenter: false
  property bool panelAnchorVerticalCenter: false

  // Settings - use null-safe checks
  readonly property string baseUrl: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.baseUrl) {
      return pluginApi.pluginSettings.baseUrl
    }
    return "https://api.thisishyum.ru/schedule_api/tyumen"
  }
  readonly property int groupId: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.groupId) {
      return pluginApi.pluginSettings.groupId
    }
    return 1
  }

  property var scheduleData: null
  property var currentDate: new Date()
  property bool isLoading: false
  property string errorMessage: ""

  anchors.fill: parent

  Timer {
    id: initTimer
    interval: 200
    running: true
    repeat: false
    onTriggered: {
      fetchScheduleForDate(root.currentDate)
    }
  }

  function formatDateForApi(date) {
    var day = date.getDate().toString().padStart(2, '0')
    var month = (date.getMonth() + 1).toString().padStart(2, '0')
    var year = date.getFullYear()
    return day + "-" + month + "-" + year
  }

  function formatDateForDisplay(date) {
    var day = date.getDate().toString().padStart(2, '0')
    var month = (date.getMonth() + 1).toString().padStart(2, '0')
    var year = date.getFullYear()
    return day + "." + month + "." + year
  }

  function fetchScheduleForDate(date) {
    root.currentDate = date
    root.isLoading = true
    root.errorMessage = ""

    var dateStr = formatDateForApi(date)
    var xhr = new XMLHttpRequest()
    var url = root.baseUrl + "/groups/" + root.groupId + "/schedules?date=" + dateStr

    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        root.isLoading = false

        if (xhr.status === 200) {
          try {
            root.scheduleData = JSON.parse(xhr.responseText)
          } catch (e) {
            root.errorMessage = "Failed to parse schedule data"
          }
        } else if (xhr.status === 404) {
          root.scheduleData = []
        } else {
          root.errorMessage = "Failed to load schedule (HTTP " + xhr.status + ")"
        }
      }
    }

    xhr.onerror = function() {
      root.isLoading = false
      root.errorMessage = "Network error"
    }

    xhr.open("GET", url)
    xhr.setRequestHeader("Accept", "application/json")
    xhr.send()
  }

  function goToPreviousDay() {
    var prev = new Date(root.currentDate)
    prev.setDate(prev.getDate() - 1)
    fetchScheduleForDate(prev)
  }

  function goToNextDay() {
    var next = new Date(root.currentDate)
    next.setDate(next.getDate() + 1)
    fetchScheduleForDate(next)
  }

  function formatTime(timeStr) {
    if (!timeStr || timeStr === "") return "--:--"
    var parts = timeStr.split(":")
    if (parts.length >= 2) {
      return parts[0] + ":" + parts[1]
    }
    return timeStr
  }

  Rectangle {
    id: mainContainer
    anchors.fill: parent
    color: Color.mSurface
    radius: Style.radiusL

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginL

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NIcon {
          icon: "school"
          color: Color.mPrimary
          pointSize: Style.fontSizeXL
        }

        NText {
          text: "College Schedule"
          pointSize: Style.fontSizeL
          font.weight: Font.Bold
          color: Color.mOnSurface
        }

        Item { Layout.fillWidth: true }

        NIconButton {
          icon: "refresh"
          tooltipText: "Refresh"
          onClicked: fetchScheduleForDate(root.currentDate)
          visible: !root.isLoading
        }

        NIcon {
          icon: "loader-2"
          color: Color.mPrimary
          visible: root.isLoading
          RotationAnimation on rotation {
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1000
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        Layout.alignment: Qt.AlignHCenter

        NIconButton {
          icon: "chevron-left"
          tooltipText: "Previous day"
          onClicked: goToPreviousDay()
        }

        Rectangle {
          Layout.preferredWidth: dateText.implicitWidth + Style.marginL * 2
          Layout.preferredHeight: 40
          color: Color.mSurfaceVariant
          radius: Style.radiusM

          NText {
            id: dateText
            anchors.centerIn: parent
            text: formatDateForDisplay(root.currentDate)
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
            font.weight: Font.Medium
          }
        }

        NIconButton {
          icon: "chevron-right"
          tooltipText: "Next day"
          onClicked: goToNextDay()
        }
      }

      NDivider {
        Layout.fillWidth: true
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.mSurfaceVariant
        radius: Style.radiusL

        NText {
          anchors.centerIn: parent
          text: "Loading..."
          color: Color.mOnSurfaceVariant
          visible: root.isLoading
        }

        ColumnLayout {
          anchors.centerIn: parent
          spacing: Style.marginM
          visible: root.errorMessage !== "" && !root.isLoading

          NIcon {
            icon: "alert-circle"
            color: Color.mError
            pointSize: Style.fontSizeXXL
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: root.errorMessage
            color: Color.mError
            Layout.alignment: Qt.AlignHCenter
          }

          NButton {
            text: "Retry"
            Layout.alignment: Qt.AlignHCenter
            onClicked: fetchScheduleForDate(root.currentDate)
          }
        }

        ColumnLayout {
          anchors.centerIn: parent
          spacing: Style.marginM
          visible: !root.isLoading && root.errorMessage === "" &&
                   (!root.scheduleData || root.scheduleData.length === 0 ||
                    (root.scheduleData[0] && root.scheduleData[0].lessons && root.scheduleData[0].lessons.length === 0))

          NIcon {
            icon: "calendar-off"
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeXXL
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "No lessons scheduled"
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }
        }

        NScrollView {
          anchors {
            fill: parent
            margins: Style.marginM
          }
          visible: !root.isLoading && root.errorMessage === "" &&
                   root.scheduleData && root.scheduleData.length > 0 &&
                   root.scheduleData[0] && root.scheduleData[0].lessons && root.scheduleData[0].lessons.length > 0

          ColumnLayout {
            width: parent.width
            spacing: Style.marginM

            Repeater {
              model: root.scheduleData && root.scheduleData[0] && root.scheduleData[0].lessons ?
                     root.scheduleData[0].lessons : []

              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: Color.mSurface
                radius: Style.radiusM

                RowLayout {
                  anchors {
                    fill: parent
                    margins: Style.marginM
                  }
                  spacing: Style.marginM

                  ColumnLayout {
                    spacing: Style.marginXS
                    Layout.preferredWidth: 80

                    NText {
                      text: formatTime(modelData.startTime)
                      font.weight: Font.Bold
                      color: Color.mPrimary
                    }

                    NText {
                      text: formatTime(modelData.endTime)
                      color: Color.mOnSurfaceVariant
                      pointSize: Style.fontSizeS
                    }
                  }

                  Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 50
                    color: Color.mOutlineVariant
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginXS

                    NText {
                      text: modelData.title || "Unknown Subject"
                      font.weight: Font.Bold
                      color: Color.mOnSurface
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                    }

                    RowLayout {
                      spacing: Style.marginS
                      visible: modelData.teacher && modelData.teacher !== ""

                      NIcon {
                        icon: "user"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                      }

                      NText {
                        text: modelData.teacher
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                      }
                    }

                    RowLayout {
                      spacing: Style.marginS
                      visible: modelData.cabinet && modelData.cabinet !== ""

                      NIcon {
                        icon: "map-pin"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                      }

                      NText {
                        text: modelData.cabinet
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                      }
                    }
                  }


                  Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    color: Color.mPrimary
                    radius: Style.radiusS

                    NText {
                      anchors.centerIn: parent
                      text: (modelData.order || 0).toString()
                      color: Color.mSurface
                      font.weight: Font.Bold
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
}
