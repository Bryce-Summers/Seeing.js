###

Camera Rotation Controller

Written by Bryce Summmers on 6 - 6 - 2017.

 - A mouse controller that allows a user to rotate the view in the xz plane

###

class SEE.I_Camera_Rotation extends BDS.Interface_Controller_All

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()
        
        @_mouse_pressed = false
        @_mouse_press_x = null # The location that the mouse was pressed, which is used as the reference for how much to rotate the camera.
        @_mouse_press_y = null

        @_camera_angle = Math.PI/4 # The current angle of the camera.
        @_start_angle  = @_camera_angle # the angle of the camera when the mouse was presses, which is used as an absolute reference for relative targets.
        @_target_angle = @_camera_angle # The angle that the camera aims to rotate to through a smooth interpolation.

        @_camera_height = 300
        @_start_height  = @_camera_height
        @_target_height = @_camera_height

        @_zoom = 2

    mouse_down: (event) ->
        @_mouse_pressed = true

        @_start_angle  = @_camera_angle
        @_start_height = @_camera_height

        @_mouse_press_x = event.x
        @_mouse_press_y = event.y

    mouse_up:   (event) ->
        @_mouse_pressed = false

    # Update the target angle for the camera.
    mouse_move: (event) ->

        #console.log(@scene.image.getImpression(event.x, event.y).nz)

        # Don't do anything if the mouse is unpressed.
        if not @_mouse_pressed
            return

        dx = event.x - @_mouse_press_x
        dy = event.y - @_mouse_press_y

        # Ideally, the user will be able to rotate the camera the entire 360 degrees as mapped to the x coordinates on their screen.
        @_target_angle  = @_start_angle + Math.PI*2*dx/dim.w
        @_target_height = @_start_height + dy

    mouse_wheel: (event) ->
        @_cameraZoom(-event.deltaY / 1000.0)
        return

    # Update the camera.
    time: (dt) ->
        per   = .9 # percentage.
        per_c = 1.0 - per # complement of percentage.
        @_camera_angle  = per*@_camera_angle  + per_c*@_target_angle
        @_camera_height = per*@_camera_height + per_c*@_target_height

        dist = 200

        x = dist*Math.cos(@_camera_angle)
        y = @_camera_height
        z = dist*Math.sin(@_camera_angle)

        @camera.position.copy(new THREE.Vector3(x, y, z))
        @camera.lookAt(new THREE.Vector3(0, 0, 0))

    # ASSUMES: THREE.OrthogrSEEhic Camera.
    # zooms the camera in if amount is positive and out if amount is negative.
    # |amount| should be between 0 and .1
    _cameraZoom: (amount) ->

        @_zoom += amount

        @camera.left   = dim.w / -2/@_zoom
        @camera.right  = dim.w /  2/@_zoom
        @camera.top    = dim.h /  2/@_zoom
        @camera.bottom = dim.h / -2/@_zoom

        # After formal dimensions have been changed, the camera needs to be told to use those values.
        @camera.updateProjectionMatrix()

        return        

        # = new THREE.OrthogrSEEhicCamera( dim.w / - 2/zoom, dim.w / 2/zoom, dim.h / 2/zoom, dim.h / - 2/zoom, 1, 600)
        #root_camera = new THREE.OrthogrSEEhicCamera( dim.w / - 2/zoom, dim.w / 2/zoom, dim.h / 2/zoom, dim.h / - 2/zoom, 1, 600)