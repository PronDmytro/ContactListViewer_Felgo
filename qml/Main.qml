import Felgo 3.0
import QtQuick 2.0
import "model"
import "logic"
import "pages"



import QtQuick.Layouts 1.3


App {

    licenseKey:  "E4C85014F42886644ABD678B7B5A0FCBDF79FF02ABE0B30772DEBC728644E7DB24DEB2D31E5B89D7FC852C0A83856D806D82A96405C84136AAB523D01B7FD5A414520C72BEB0D99E4D1A8BDB4FF5EFE7ADE2D0B81A3F3296110A9C5A1DFBFE4D96BDD8C63DF88986A47E87C17BABDABA47B1BFC57E00F2196C9C4CDDC2CF02F030F34A9D5FC3F2521BDF5A43A6FBAD21B31938B55A9D46533C415FD0BD7265125AD19CA42DE4BECB615F6040726A1216D7CB2F2377B6E26EE64BB6E5226BA64DD309FB24E579C89A9864AB67EA3D2D61ABAF00AF784022DB9D420D278731797D54A767121FF7654D1826E2D353294F47B11193C98B4078B35A87B2BDDEE805C1500D8C2BFE2F8C6DB64FB49088CF298AA1C6E8CFE3C143E2C3F372EEE902CBAC0998164978D361ABDC8103B77C31000CDC929A2A6F398B75179141D7709DCC38"

    // app initialization
    Component.onCompleted: {
        // if device has network connection, clear cache at startup
        // you'll probably implement a more intelligent cache cleanup for your app
        // e.g. to only clear the items that aren't required regularly
        if(isOnline) {
            logic.clearCache()
        }

        // fetch contact list data
        logic.fetchContacts()
    }

    // business logic
    Logic {
        id: logic
    }

    // model
    DataModel {
        id: dataModel
        dispatcher: logic // data model handles actions sent by logic

        // global error handling
        onFetchContactsFailed: nativeUtils.displayMessageBox("Unable to load contacts", error, 1)
        onFetchContactDetailsFailed: nativeUtils.displayMessageBox("Unable to load contacts "+id, error, 1)
    }

    // helper functions for view
    ViewHelper {
        id: viewHelper
    }


    // view
    NavigationStack {

         FlickablePage {
            id: page
            title: qsTr("Contacts List")

            rightBarItem: NavigationBarRow {
                // network activity indicator
                ActivityIndicatorBarItem {
                    enabled: dataModel.isBusy
                    visible: enabled
                    showItem: showItemAlways // do not collapse into sub-menu on Android
                }
            }


            // JsonListModel
            // A ViewModel for JSON data that offers best integration and performance with list views
            JsonListModel {
                id: listModel
                source: dataModel.contacts // show contacts from data model
                keyField: "id"
                fields: ["id", "name", "surname", "mobilenum", "fav", "firstLetter"]
            }


            // filter settings are grouped in this item
            Item {
                id: filterSettings
                property bool favoriteFilterActive: false
                property string userFilterValue: ""
            }

            SortFilterProxyModel {
                id: filteredModel
                sourceModel: listModel

                // configure filters
                filters: [
                    ValueFilter {
                        roleName: "fav"
                        value: true
                        enabled: filterSettings.favoriteFilterActive
                    },
                    AnyOf{
                        RegExpFilter {
                            roleName: "name"
                            pattern: filterSettings.userFilterValue
                            caseSensitivity: Qt.CaseInsensitive
                        }
                    }
                ]


            }

            // show sorted/filterd contacts of data model

            ListPage {
                id: listPage
                anchors.fill: parent

                model: filteredModel
                // the delegate is the template item for each entry of the list
                delegate: SimpleRow {

                    AppImage{
                        id:contactLogo
                        source: "../assets/contact-icon.png"
                        width: parent.height
                        height: parent.height
                    }
                    AppText{
                        x: contactLogo.width
                        anchors.verticalCenter: parent.verticalCenter
                        text: viewHelper.formatTitle(model)
                    }
                    AppButton{
                        id:callButton
                        x: contactLogo.width
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 40
                        Icon{
                            id:icon
                            icon:IconType.phone
                            color: "#008000"
                            width: parent.height
                            height: parent.height
                            size: parent.height
                        }


                        backgroundColor: "#00000000"
                        backgroundColorPressed : "#00000000"
                        width: parent.height
                        height: parent.height

                        onClicked: nativeUtils.displayMessageBox("Unable to call")
                    }


                    style.showDisclosure: false
                    // push detail page when selected, pass chosen contact id
                    onSelected: page.navigationStack.popAllExceptFirstAndPush(detailPageComponent, { contactId: model.id})

                }
                //////////////////////////////////////////////////////////
                ////Don`t working - conflict with SortFilterProxyModel////
                ////I don't know how to fix this                     ////
                section.property: "firstLetter"

                // add section select
                SectionSelect {
                    id: sectionSelect
                    anchors.right: parent.right
                    target: listPage.listView
                    sectionProperty: "firstLetter"
                }
                //////////////////////////////////////////////////////////

                // add UI for filter options as list header
                listView.header: Column {
                    x: spacing
                    width: parent.width - 2 * spacing
                    spacing: dp(5)

                    // top spacer
                    Item { width: parent.width; height: px(1) }

                    // completed filter
                    AppCheckBox {
                        text: "Favorite only"
                        checked: filterSettings.favoriteFilterActive
                        updateChecked: false
                        onClicked: filterSettings.favoriteFilterActive = !filterSettings.favoriteFilterActive
                    }

                    // user id filter
                    Row {
                        spacing: parent.spacing
                        AppText {
                            text: "User name"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        AppTextField {
                            id: userFilterText
                            anchors.verticalCenter: parent.verticalCenter
                            placeholderText: "Type here.."
                            Layout.fillWidth: true
                            font.pointSize: 12
                            background: Rectangle {
                                radius: 5
                                implicitWidth: parent.width
                                implicitHeight: 30
                                border.width: 1
                            }

                            onTextChanged: {
                                filterSettings.userFilterValue = userFilterText.text
                            }
                        }
                    }
                    // bottom spacer
                    Item { width: parent.width; height: px(1) }
                }
            }

            Component {
                id: detailPageComponent
                ContactDetailPage {
                }
            }
        }
    }
}
