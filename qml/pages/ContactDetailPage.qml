import Felgo 3.0
import QtQuick 2.0

Page {
    id: contactDeteilPage
    title: viewHelper.formatTitle(contactData)

    property bool isFavorite: contactData.fav
    property bool isFavChanged: false
    // target id
    property int contactId: 0

    // data property for page
    property var contactData: dataModel.contactDetails[contactId]

    // load data initially or when id changes
    rightBarItem:IconButtonBarItem {
        icon: isFavorite ? IconType.heart : IconType.hearto
        onClicked: {
            isFavChanged = true
            if(isFavorite)
            {
                isFavorite = false
                logic.toggleFavorite(contactId,isFavorite)
            }
            else{
                isFavorite = true
                logic.toggleFavorite(contactId,isFavorite)
            }

        }
    }

    // load data initially or when id changes
    onContactIdChanged: {

        logic.fetchContactDetails(contactId)
    }

    // column to show all todo object properties, if data is available
    Column {
        y: spacing
        width: parent.width - 2 * spacing
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(Theme.navigationBar.defaultBarItemPadding)
        visible: !noDataMessage.visible

        AppText {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: implicitHeight

            text: "<strong>Name:</strong> " + contactData.name + " " + contactData.surname
            wrapMode: AppText.WrapAtWordBoundaryOrAnywhere
        }
        AppText {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: implicitHeight

            text: "<strong>Mobile Number:</strong> " + contactData.mobilenum
            wrapMode: AppText.WrapAtWordBoundaryOrAnywhere
        }
    }

    // show message if data not available
    AppText {
        id: noDataMessage
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Contact data not available. Please check your internet connection.")
        width: parent.width
        horizontalAlignment: Qt.AlignHCenter
        visible: !contactData && !dataModel.isBusy
    }
}
