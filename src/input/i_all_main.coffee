#
# All input Controller.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
# Purpose: This class is the root of my input system, it collects simple input events and passes them to the relevant controllers by type.
#

class SEE.I_All_Main extends BDS.Controller_Group
    
    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        # Thus far, the only thing that we do is initialize the mouse input pipeline.
        @_mouse_input = new SEE.I_Mouse_Main(@scene, @camera)
        @add_mouse_input_controller(@_mouse_input)
        @add_time_input_controller(@_mouse_input) # We use a universal one so that time events will be passed.


        # Keyboard Controllers.
        @_keyboard_input = new SEE.I_Keyboard_Main(@scene, @camera)
        @add_keyboard_input_controller(@_keyboard_input)

        # Time
        @_time_input = new SEE.I_Time_Main(@scene, @camera)
        @add_time_input_controller(@_time_input)
        
    getMouseController: () ->
        return @_mouse_input