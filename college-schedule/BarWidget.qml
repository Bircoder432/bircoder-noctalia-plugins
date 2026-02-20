import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // Settings with null-safe checks
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
  readonly property string displayMode: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.displayMode) {
      return pluginApi.pluginSettings.displayMode
    }
    return "timeRange"
  }
  readonly property int refreshInterval: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.refreshInterval) {
      return pluginApi.pluginSettings.refreshInterval
    }
    return 300
  }
  readonly property string iconColor: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.iconColor) {
      return pluginApi.pluginSettings.iconColor
    }
    return "primary"
  }

  property var scheduleData: null
  property bool isLoading: false
  property string errorMessage: ""
  property int todayLessonsCount: 0
  property string timeRangeText: ""

  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  // Get color based on iconColor setting
  function getIconColor() {
    switch (root.iconColor) {
      case "secondary": return Color.mSecondary
      case "tertiary": return Color.mTertiary
      case "error": return Color.mError
      case "primary":
      default: return Color.mPrimary
    }
  }

  function getHoverColor() {
    return Color.mSurface
  }

  Timer {
    id: refreshTimer
    interval: root.refreshInterval * 1000
    running: true
    repeat: true
    onTriggered: fetchSchedule()
  }

  Timer {
    id: initTimer
    interval: 300
    running: true
    repeat: false
    onTriggered: fetchSchedule()
  }

  Connections {
    target: pluginApi
    function onPluginSettingsChanged() {
      fetchSchedule()
    }
  }

  function fetchSchedule() {
    if (root.isLoading) return
    if (!root.baseUrl || root.groupId <= 0) return

    root.isLoading = true
    root.errorMessage = ""

    var date = new Date()
    var day = date.getDate().toString().padStart(2, '0')
    var month = (date.getMonth() + 1).toString().padStart(2, '0')
    var year = date.getFullYear()
    var dateStr = day + "-" + month + "-" + year

    var xhr = new XMLHttpRequest()
    var url = root.baseUrl + "/groups/" + root.groupId + "/schedules?date=" + dateStr

    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        root.isLoading = false

        if (xhr.status === 200) {
          try {
            var data = JSON.parse(xhr.responseText)
            root.scheduleData = data
            processScheduleData(data)
          } catch (e) {
            root.errorMessage = "Parse error"
            Logger.e("CollegeSchedule", "Failed to parse response:", e)
          }
        } else if (xhr.status === 404) {
          root.errorMessage = "No schedule"
          root.todayLessonsCount = 0
          root.timeRangeText = "No classes"
        } else {
          root.errorMessage = "Error " + xhr.status
          Logger.e("CollegeSchedule", "HTTP error:", xhr.status, xhr.responseText)
        }
      }
    }

    xhr.onerror = function() {
      root.isLoading = false
      root.errorMessage = "Network error"
      Logger.e("CollegeSchedule", "Network request failed")
    }

    xhr.open("GET", url)
    xhr.setRequestHeader("Accept", "application/json")
    xhr.send()
  }

  function processScheduleData(data) {
    if (!Array.isArray(data) || data.length === 0) {
      root.todayLessonsCount = 0
      root.timeRangeText = "No classes"
      return
    }

    var schedule = data[0]
    var lessons = schedule.lessons || []
    root.todayLessonsCount = lessons.length

    if (lessons.length === 0) {
      root.timeRangeText = "No classes"
      return
    }

    var firstLesson = lessons[0]
    var lastLesson = lessons[lessons.length - 1]

    root.timeRangeText = formatTime(firstLesson.startTime) + "-" + formatTime(lastLesson.endTime)
  }

  function formatTime(timeStr) {
    if (!timeStr || timeStr === "") return "--:--"
    var parts = timeStr.split(":")
    if (parts.length >= 2) {
      return parts[0] + ":" + parts[1]
    }
    return timeStr
  }

  function getDisplayText() {
    if (root.errorMessage && root.todayLessonsCount === 0) {
      return root.errorMessage
    }

    switch (root.displayMode) {
      case "count":
        return root.todayLessonsCount.toString() + " пар"
      case "timeRange":
      default:
        return root.timeRangeText
    }
  }

  function getTooltipText() {
    if (root.errorMessage) {
      return "Schedule Error: " + root.errorMessage
    }
    if (root.todayLessonsCount === 0) {
      return "No classes today"
    }
    return root.todayLessonsCount + " lessons today • Click for details"
  }

  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: mouseArea.containsMouse ? Color.mPrimary : Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      NIcon {
        icon: "school"
        color: mouseArea.containsMouse ? Color.mSurface : root.getIconColor()
        visible: !root.isLoading
      }

      NIcon {
        icon: "loader-2"
        color: mouseArea.containsMouse ? Color.mSurface : root.getIconColor()
        visible: root.isLoading
        RotationAnimation on rotation {
          loops: Animation.Infinite
          from: 0
          to: 360
          duration: 1000
        }
      }

      NText {
        text: root.getDisplayText()
        color: mouseArea.containsMouse ? Color.mSurface : (root.errorMessage ? Color.mError : Color.mOnSurface)
        pointSize: root.barFontSize
        font.weight: Font.Medium
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      if (pluginApi) {
        pluginApi.openPanel(root.screen, root)
      }
    }

    onEntered: {
      TooltipService.show(root, getTooltipText(), BarService.getTooltipDirection())
    }

    onExited: {
      TooltipService.hide()
    }
  }
}
