# Copyright (c) 2015 Ultimaker B.V.
# Uranium is released under the terms of the AGPLv3 or higher.

from UM.Tool import Tool
from UM.Scene.Selection import Selection
from UM.Application import Application
from UM.Preferences import Preferences


##  This tool allows the user to add & change settings per node in the scene.
#   The settings per object are kept in a ContainerStack, which is linked to a node by decorator.
class PerObjectSettingsTool(Tool):
    def __init__(self):
        super().__init__()
        self._model = None

        self.setExposedProperties("SelectedObjectId", "ContainerID")

        Preferences.getInstance().preferenceChanged.connect(self._onPreferenceChanged)
        Selection.selectionChanged.connect(self.propertyChanged)
        self._onPreferenceChanged("cura/active_mode")

    def event(self, event):
        return False

    def getSelectedObjectId(self):
        try:
            selected_object = Selection.getSelectedObject(0)
            if selected_object.getParent().callDecoration("isGroup"):
                selected_object = selected_object.getParent()
        except:
            selected_object = None
        selected_object_id = id(selected_object)
        return selected_object_id

    def getContainerID(self):
        selected_object = Selection.getSelectedObject(0)
        if selected_object.getParent().callDecoration("isGroup"):
            selected_object = selected_object.getParent()
        try:
            return selected_object.callDecoration("getStack").getId()
        except AttributeError:
            return ""

    def _onPreferenceChanged(self, preference):
        if preference == "cura/active_mode":
            enabled = Preferences.getInstance().getValue(preference)==1
            Application.getInstance().getController().toolEnabledChanged.emit(self._plugin_id, enabled)