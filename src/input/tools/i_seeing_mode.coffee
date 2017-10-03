###

Camera Rotation Controller

Written by Bryce Summmers on 6 - 6 - 2017.

 - A mouse controller that allows a user to rotate the view in the xz plane

###

class SEE.I_Seeing_Mode extends BDS.Interface_Controller_All

    constructor: (@scene, @camera) ->

        super()
        @_key_down = false

        @NORMAL = 0
        @SEEING = 1
        @mode = @NORMAL

        dim = {x:0, y:0, w:window.innerWidth, h:innerHeight, padding:10}
        zoom = 1

        @seeing_camera = new THREE.OrthographicCamera( dim.w / - 2/ zoom, dim.w / 2/ zoom, dim.h / 2/ zoom, dim.h / - 2/zoom, 1, 600)
        @normal_camera = @camera

        # Seeing Camera positioning.
        @seeing_camera.position.copy(new THREE.Vector3(dim.w/2, dim.h/2, 2))
        @seeing_camera.lookAt(new THREE.Vector3(dim.w/2, dim.h/2, 0))

    key_down: (event) ->
        @_key_down = true
        

    key_up: (event) ->
        @_key_down = false

        if event.key == " "

            if @mode == @NORMAL
                
                @scene.generate_impressions(@normal_camera)
                @scene.enable_seeing_mode()
                window.root_camera = @seeing_camera
                @mode = @SEEING
                
            else if @mode == @SEEING
                window.root_camera = @normal_camera
                @mode = @NORMAL
                @scene.enable_normal_mode()

        return

    # Update the camera.
    time: (dt) ->