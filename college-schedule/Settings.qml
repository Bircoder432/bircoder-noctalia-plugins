import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null
  
  property string editBaseUrl: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.baseUrl) {
      return pluginApi.pluginSettings.baseUrl
    }
    return "https://api.thisishyum.ru/schedule_api/tyumen"
  }
  property int editGroupId: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.groupId) {
      return pluginApi.pluginSettings.groupId
    }
    return 1
  }
  property string editDisplayMode: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.displayMode) {
      return pluginApi.pluginSettings.displayMode
    }
    return "timeRange"
  }
  property int editRefreshInterval: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.refreshInterval) {
      return pluginApi.pluginSettings.refreshInterval
    }
    return 300
  }
  property string editIconColor: {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.iconColor) {
      return pluginApi.pluginSettings.iconColor
    }
    return "primary"
  }
  
  spacing: Style.marginM
  
  Component.onCompleted: {
    Logger.i("CollegeSchedule", "Settings UI loaded")
  }
  
  NTextInput {
    Layout.fillWidth: true
    label: "API Base URL"
    description: "The base URL of your Open Schedule API instance"
    placeholderText: "https://api.example.com/schedule_api"
    text: root.editBaseUrl
    onTextChanged: root.editBaseUrl = text
  }
  
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS
    
    NLabel {
      label: "Group ID"
      description: "Your student group identifier"
    }
    
    NSpinBox {
      Layout.fillWidth: true
      from: 1
      to: 999999
      value: root.editGroupId
      onValueChanged: root.editGroupId = value
    }
  }
  
  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginS
    Layout.bottomMargin: Style.marginS
  }
  
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS
    
    NLabel {
      label: "Widget Display Mode"
      description: "How to show schedule info in the bar"
    }
    
    RowLayout {
      spacing: Style.marginS
      
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        color: root.editDisplayMode === "timeRange" ? Color.mPrimary : Color.mSurfaceVariant
        radius: Style.radiusM
        
        NText {
          anchors.centerIn: parent
          text: "Time Range"
          color: root.editDisplayMode === "timeRange" ? "white" : Color.mOnSurface
          pointSize: Style.fontSizeS
          font.weight: Font.Medium
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editDisplayMode = "timeRange"
        }
      }
      
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        color: root.editDisplayMode === "count" ? Color.mPrimary : Color.mSurfaceVariant
        radius: Style.radiusM
        
        NText {
          anchors.centerIn: parent
          text: "Lesson Count"
          color: root.editDisplayMode === "count" ? "white" : Color.mOnSurface
          pointSize: Style.fontSizeS
          font.weight: Font.Medium
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editDisplayMode = "count"
        }
      }
    }
  }
  
  // Icon Color Selection
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS
    
    NLabel {
      label: "Icon Color"
      description: "Choose the color for the school icon"
    }
    
    RowLayout {
      spacing: Style.marginS
      
      // Primary
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        color: root.editIconColor === "primary" ? Color.mPrimary : Color.mSurfaceVariant
        radius: Style.radiusM
        border.color: root.editIconColor === "primary" ? Color.mPrimary : "transparent"
        border.width: 2
        
        Rectangle {
          anchors.centerIn: parent
          width: 24
          height: 24
          color: Color.mPrimary
          radius: Style.radiusS
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editIconColor = "primary"
        }
      }
      
      // Secondary
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        color: root.editIconColor === "secondary" ? Color.mSecondary : Color.mSurfaceVariant
        radius: Style.radiusM
        border.color: root.editIconColor === "secondary" ? Color.mSecondary : "transparent"
        border.width: 2
        
        Rectangle {
          anchors.centerIn: parent
          width: 24
          height: 24
          color: Color.mSecondary
          radius: Style.radiusS
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editIconColor = "secondary"
        }
      }
      
      // Tertiary
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        color: root.editIconColor === "tertiary" ? Color.mTertiary : Color.mSurfaceVariant
        radius: Style.radiusM
        border.color: root.editIconColor === "tertiary" ? Color.mTertiary : "transparent"
        border.width: 2
        
        Rectangle {
          anchors.centerIn: parent
          width: 24
          height: 24
          color: Color.mTertiary
          radius: Style.radiusS
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editIconColor = "tertiary"
        }
      }
      
      // Error
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        color: root.editIconColor === "error" ? Color.mError : Color.mSurfaceVariant
        radius: Style.radiusM
        border.color: root.editIconColor === "error" ? Color.mError : "transparent"
        border.width: 2
        
        Rectangle {
          anchors.centerIn: parent
          width: 24
          height: 24
          color: Color.mError
          radius: Style.radiusS
        }
        
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.editIconColor = "error"
        }
      }
    }
  }
  
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS
    
    NLabel {
      label: "Refresh Interval"
      description: "How often to update schedule (in seconds): " + root.editRefreshInterval + "s"
    }
    
    NSlider {
      Layout.fillWidth: true
      from: 60
      to: 1800
      stepSize: 60
      value: root.editRefreshInterval
      onValueChanged: root.editRefreshInterval = value
    }
  }
  
  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginS
    Layout.bottomMargin: Style.marginS
  }
  
  NLabel {
    label: "Preview"
  }
  
  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 60
    color: Style.capsuleColor
    radius: Style.radiusM
    
    RowLayout {
      anchors.centerIn: parent
      spacing: Style.marginS
      
      NIcon {
        icon: "school"
        color: {
          if (root.editIconColor === "primary") return Color.mPrimary
          if (root.editIconColor === "secondary") return Color.mSecondary
          if (root.editIconColor === "tertiary") return Color.mTertiary
          if (root.editIconColor === "error") return Color.mError
          return Color.mPrimary
        }
      }
      
      NText {
        text: root.editDisplayMode === "count" ? "5 пар" : "08:30-15:50"
        color: Color.mOnSurface
        pointSize: Style.fontSizeM
        font.weight: Font.Medium
      }
    }
  }
  
  function saveSettings() {
    if (!pluginApi) {
      Logger.e("CollegeSchedule", "Cannot save: pluginApi is null")
      return
    }
    
    pluginApi.pluginSettings.baseUrl = root.editBaseUrl
    pluginApi.pluginSettings.groupId = root.editGroupId
    pluginApi.pluginSettings.displayMode = root.editDisplayMode
    pluginApi.pluginSettings.refreshInterval = root.editRefreshInterval
    pluginApi.pluginSettings.iconColor = root.editIconColor
    
    pluginApi.saveSettings()
    Logger.i("CollegeSchedule", "Settings saved successfully")
  }
}
