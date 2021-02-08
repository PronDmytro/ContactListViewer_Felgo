import Felgo 3.0
import QtQuick 2.0
import "model"
import "logic"
import "pages"



import QtQuick.Layouts 1.3


App {
    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    // app initialization
    Component.onCompleted: {
        // if device has network connection, clear cache at startup
        // you'll probably implement a more intelligent cache cleanup for your app
        // e.g. to only clear the items that aren't required regularly
        if(isOnline) {
            logic.clearCache()
        }

        // fetch todo list data
        logic.fetchContacts()
        logic.fetchDraftContacts()
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

        Page {
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


                    style.showDisclosure: false
                    // push detail page when selected, pass chosen contact id
                    onSelected: page.navigationStack.popAllExceptFirstAndPush(detailPageComponent, { contactId: model.id, contactData:model })

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
                ContactDetailPage { }
            }
        }
    }
}
