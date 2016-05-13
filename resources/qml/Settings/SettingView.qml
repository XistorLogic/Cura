// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM

import ".."

ScrollView
{
    id: base;

    style: UM.Theme.styles.scrollview;
    flickableItem.flickableDirection: Flickable.VerticalFlick;

    property Action configureSettings;
    signal showTooltip(Item item, point location, string text);
    signal hideTooltip();

    ListView
    {
        id: contents
        spacing: UM.Theme.getSize("default_lining").height;

        model: UM.SettingDefinitionsModel { id: definitionsModel; containerId: "fdmprinter" }

        delegate: Loader
        {
            id: delegate

            width: UM.Theme.getSize("sidebar").width;
            height: UM.Theme.getSize("section").height;

            property var definition: model
            property var settingDefinitionsModel: definitionsModel

            asynchronous: true

            source:
            {
                switch(model.type)
                {
                    case "int":
                        return "SettingTextField.qml"
                    case "float":
                        return "SettingTextField.qml"
                    case "enum":
                        return "SettingComboBox.qml"
                    case "bool":
                        return "SettingCheckBox.qml"
                    case "str":
                        return "SettingTextField.qml"
                    case "category":
                        return "SettingCategory.qml"
                    default:
                        return "SettingUnknown.qml"
                }
            }

            Connections
            {
                target: item
                onContextMenuRequested: { contextMenu.key = model.key; contextMenu.popup() }
                onShowTooltip: base.showTooltip(delegate, { x: 0, y: delegate.height / 2 }, text)
                onHideTooltip: base.hideTooltip()
            }
        }

        UM.I18nCatalog { id: catalog; name: "uranium"; }

        add: Transition {
            SequentialAnimation {
                NumberAnimation { properties: "height"; from: 0; duration: 100 }
                NumberAnimation { properties: "opacity"; from: 0; duration: 100 }
            }
        }
        remove: Transition {
            SequentialAnimation {
                NumberAnimation { properties: "opacity"; to: 0; duration: 100 }
                NumberAnimation { properties: "height"; to: 0; duration: 100 }
            }
        }
        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 100 }
        }
        removeDisplaced: Transition {
            SequentialAnimation {
                PauseAnimation { duration: 100; }
                NumberAnimation { properties: "x,y"; duration: 100 }
            }
        }

        Menu
        {
            id: contextMenu;

            property string key;

            MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Hide this setting");
                onTriggered: definitionsModel.hide(contextMenu.key);
            }
            MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Configure setting visiblity...");

                onTriggered: Actions.configureSettingVisibility.trigger(contextMenu);
            }
        }
    }
}