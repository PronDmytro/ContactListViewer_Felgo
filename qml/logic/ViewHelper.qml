import QtQuick 2.0

Item {
    // function to format the todo title for display
    // appends draft number for drafts
    function formatTitle(contactsList) {
        if(!contactsList)
            return ""

        return contactsList.name + " " + contactsList.surname
    }
}
