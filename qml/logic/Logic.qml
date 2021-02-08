import QtQuick 2.0

Item {
    // actions
    signal fetchContacts()

    signal fetchContactDetails(int id)

    signal clearCache()

    signal toggleFavorite(int id, bool isFavorite)

}
