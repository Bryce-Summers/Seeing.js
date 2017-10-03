###

Time Input Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

###

class SEE.I_Time_Main extends BDS.Controller_Group

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        
        #@add_time_input_controller(new SEE.I_Rotate_Cubes(@scene, @camera))