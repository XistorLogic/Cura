// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.1 as UM

UM.PreferencesPage
{
    //: General configuration page title
    title: catalog.i18nc("@title:tab","General")

    function setDefaultLanguage(languageCode)
    {
        //loops trough the languageList and sets the language using the languageCode
        for(var i = 0; i < languageList.count; i++)
        {
            if (languageComboBox.model.get(i).code == languageCode)
            {
                languageComboBox.currentIndex = i
            }
        }
    }

    function reset()
    {
        UM.Preferences.resetPreference("general/language")
        var defaultLanguage = UM.Preferences.getValue("general/language")
        setDefaultLanguage(defaultLanguage)

        UM.Preferences.resetPreference("physics/automatic_push_free")
        pushFreeCheckbox.checked = boolCheck(UM.Preferences.getValue("physics/automatic_push_free"))
        UM.Preferences.resetPreference("mesh/scale_to_fit")
        scaleToFitCheckbox.checked = boolCheck(UM.Preferences.getValue("mesh/scale_to_fit"))
        UM.Preferences.resetPreference("mesh/scale_tiny_meshes")
        scaleTinyCheckbox.checked = boolCheck(UM.Preferences.getValue("mesh/scale_tiny_meshes"))
        UM.Preferences.resetPreference("cura/jobname_prefix")
        prefixJobNameCheckbox.checked = boolCheck(UM.Preferences.getValue("cura/jobname_prefix"))

        if (plugins.model.find("id", "SliceInfoPlugin") > -1) {
            UM.Preferences.resetPreference("info/send_slice_info")
            sendDataCheckbox.checked = boolCheck(UM.Preferences.getValue("info/send_slice_info"))
        }
        if (plugins.model.find("id", "UpdateChecker") > -1) {
            UM.Preferences.resetPreference("info/automatic_update_check")
            checkUpdatesCheckbox.checked = boolCheck(UM.Preferences.getValue("info/automatic_update_check"))
        }
    }

    ColumnLayout
    {
        //: Language selection label
        UM.I18nCatalog{id: catalog; name:"cura"}

        RowLayout
        {
            Label
            {
                id: languageLabel
                text: catalog.i18nc("@label","Language:")
            }

            ComboBox
            {
                id: languageComboBox
                model: ListModel
                {
                    id: languageList

                    Component.onCompleted: {
                        append({ text: catalog.i18nc("@item:inlistbox", "English"), code: "en" })
                        append({ text: catalog.i18nc("@item:inlistbox", "Finnish"), code: "fi" })
                        append({ text: catalog.i18nc("@item:inlistbox", "French"), code: "fr" })
                        append({ text: catalog.i18nc("@item:inlistbox", "German"), code: "de" })
                        append({ text: catalog.i18nc("@item:inlistbox", "Italian"), code: "it" })
                        append({ text: catalog.i18nc("@item:inlistbox", "Dutch"), code: "nl" })
                        append({ text: catalog.i18nc("@item:inlistbox", "Spanish"), code: "es" })
                    }
                }

                currentIndex:
                {
                    var code = UM.Preferences.getValue("general/language");
                    for(var i = 0; i < languageList.count; ++i)
                    {
                        if(model.get(i).code == code)
                        {
                            return i
                        }
                    }
                }
                onActivated: UM.Preferences.setValue("general/language", model.get(index).code)

                Component.onCompleted:
                {
                    // Because ListModel is stupid and does not allow using qsTr() for values.
                    for(var i = 0; i < languageList.count; ++i)
                    {
                        languageList.setProperty(i, "text", catalog.i18n(languageList.get(i).text));
                    }

                    // Glorious hack time. ComboBox does not update the text properly after changing the
                    // model. So change the indices around to force it to update.
                    currentIndex += 1;
                    currentIndex -= 1;
                }
            }
        }

        Label
        {
            id: languageCaption

            //: Language change warning
            text: catalog.i18nc("@label", "You will need to restart the application for language changes to have effect.")
            wrapMode: Text.WordWrap
            font.italic: true
        }

        UM.TooltipArea {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Should objects on the platform be moved so that they no longer intersect?")

            CheckBox
            {
                id: pushFreeCheckbox
                text: catalog.i18nc("@option:check", "Ensure objects are kept apart")
                checked: boolCheck(UM.Preferences.getValue("physics/automatic_push_free"))
                onCheckedChanged: UM.Preferences.setValue("physics/automatic_push_free", checked)
            }
        }

        UM.TooltipArea {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip","Should opened files be scaled to the build volume if they are too large?")

            CheckBox
            {
                id: scaleToFitCheckbox
                text: catalog.i18nc("@option:check","Scale large files")
                checked: boolCheck(UM.Preferences.getValue("mesh/scale_to_fit"))
                onCheckedChanged: UM.Preferences.setValue("mesh/scale_to_fit", checked)
            }
        }

        UM.TooltipArea {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip","Should opened files be scaled up if they are extremely small?")

            CheckBox
            {
                id: scaleTinyCheckbox
                text: catalog.i18nc("@option:check","Scale extremely small files")
                checked: boolCheck(UM.Preferences.getValue("mesh/scale_tiny_meshes"))
                onCheckedChanged: UM.Preferences.setValue("mesh/scale_tiny_meshes", checked)
            }
        }

        UM.TooltipArea {
            visible: plugins.model.find("id", "UpdateChecker") > -1
            width: childrenRect.width
            height: visible ? childrenRect.height : 0
            text: catalog.i18nc("@info:tooltip","Should Cura check for updates when the program is started?")

            CheckBox
            {
                id: checkUpdatesCheckbox
                text: catalog.i18nc("@option:check","Check for updates on start")
                checked: boolCheck(UM.Preferences.getValue("info/automatic_update_check"))
                onCheckedChanged: UM.Preferences.setValue("info/automatic_update_check", checked)
            }
        }

        UM.TooltipArea {
            visible: plugins.model.find("id", "SliceInfoPlugin") > -1
            width: childrenRect.width
            height: visible ? childrenRect.height : 0
            text: catalog.i18nc("@info:tooltip","Should anonymous data about your print be sent to Ultimaker? Note, no models, IP addresses or other personally identifiable information is sent or stored.")

            CheckBox
            {
                id: sendDataCheckbox
                text: catalog.i18nc("@option:check","Send (anonymous) print information")
                checked: boolCheck(UM.Preferences.getValue("info/send_slice_info"))
                onCheckedChanged: UM.Preferences.setValue("info/send_slice_info", checked)
            }
        }

        UM.TooltipArea {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Should a prefix based on the printer name be added to the print job name automatically?")

            CheckBox
            {
                id: prefixJobNameCheckbox
                text: catalog.i18nc("@option:check", "Add machine prefix to job name")
                checked: boolCheck(UM.Preferences.getValue("cura/jobname_prefix"))
                onCheckedChanged: UM.Preferences.setValue("cura/jobname_prefix", checked)
            }
        }

        ListView
        {
            id: plugins
            model: UM.PluginsModel { }
            visible: false
        }
    }
}
