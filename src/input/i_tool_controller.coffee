#
# Tool Controller.
#
# Written by Bryce Summers on May.5.2017
#
# Purpose:
#  - This class specifies a common interface for interacting with tools.
#  - Especially when switching between which ones are active.
#

class SEE.I_Tool_Controller
    
    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        @active = true
        
    setActive: (val) ->
        @active = val

    isActive: () ->
        return @active