###

Cube Rotation Controller.

Written by Bryce Summmers on 6 - 6 - 2017.

 - A Test time controller that takes every cube in the scene and rotates it by a fixed amount.

###

class SEE.I_Rotate_Cubes extends BDS.Interface_Controller_Time

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        @time_count = 0.0
        @time_step  = 2000.0

    time: (dt) ->

        cubes = @scene.getObjects()

        for cube in cubes
            cube.rotation.x += dt*.001
            cube.rotation.y += dt*.001

        return