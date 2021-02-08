import QtQuick 2.0
import Felgo 3.0

Item {

    // property to configure target dispatcher / logic
    property alias dispatcher: logicConnection.target

    // whether api is busy (ongoing network requests)
    readonly property bool isBusy: api.busy


    // model data properties
    readonly property alias contacts: _.contacts
    readonly property alias contactDetails: _.contactDetails

    // action error signals
    signal fetchContactsFailed(var error)
    signal fetchContactDetailsFailed(int id, var error)
    signal toggleFavorite(int id, bool isFavorite)

    // listen to actions from dispatcher
    Connections {
        id: logicConnection

        // action 1 - fetchContacts
        onFetchContacts: {
            // check cached value first
            var cached = cache.getValue("contacts")
            if(cached)
                _.contacts = cached

            // load from api
            api.getContacts(
                        function(data) {
                            // cache data before updating model property
                            cache.setValue("contacts",data)
                            _.contacts = data
                        },
                        function(error) {
                            // action failed if no cached data
                            if(!cached)
                                fetchContactsFailed(error)
                        })

        }

        // action 2 - fetchContactDetails
        onFetchContactDetails: {
            // check cached todo details first
            var cached = cache.getValue("contact_"+id)
            if(cached) {
                _.contactDetails[id] = cached
                //contactDetailsChanged() // signal change within model to update UI
            }

            // load from api
            api.getContactById(id,
                               function(data) {
                                   // cache data first
                                   cache.setValue("contacto_"+id, data)
                                   _.contactDetails[id] = data
                                   contactDetailsChanged()
                               },
                               function(error) {
                                   // action failed if no cached data
                                   if(!cached) {
                                       fetchContactDetailsFailed(id, error)
                                   }
                               })
        }
        // action 3 - clearCache
        onClearCache: {
            cache.clearAll()
        }

        // action 4 - toggleFavorite
        onToggleFavorite: {
            ////////////////////////////////////////////
            ////Don't working                      ////
            ////I don't know why it didn't working////
            HttpRequest
            .patch("https://my-json-server.typicode.com/PronDmytro/JsonDB/contacts2/"+id)
            .timeout(3000)
            .set( {fav: isFavorite})
            .end(function(err, res) {
                if(res.ok) {
                    console.log(res.status);
                    console.log(JSON.stringify(res.header, null, 4));
                    console.log(JSON.stringify(res.body, null, 4));
                }
                else {
                    console.log(err.message)
                    console.log(err.response)
                }
            });
        }
    }


        // rest api for data access
        RestAPI {
            id: api
            maxRequestTimeout: 5000 // use max request timeout of 3 sec
        }

        // storage for caching
        Storage {
            id: cache
        }

        // private
        Item {
            id: _

            // data properties
            property var contacts: []  // Array
            property var contactDetails: ({}) // Map

        }
    }
