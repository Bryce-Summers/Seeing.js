###

Written on Sept.30.2017 by Bryce Summers
Purpose: Initializes and glues everything together.

###

class SEE.E_Scene

    constructor: () ->

        # Local Variables.

        # Root of THREE.JS visualization.
        @scene = new THREE.Scene()
        
        @input_root = null

        # The list of objects that will be quantized.
        @_objects   = []

        # A Scene that displays the pt to pt pipe finding algorithm interactively.
        @init_scene()

        @init_geometries()

        @seeing_mode = false

        @image = new SEE.E_Impressions(200, 200, 0, window.innerWidth, window.innerHeight)

    init_scene: () ->
        #@init_ground_plane()
        @init_label("Algo Pipe")
        @init_lighting()

    init_geometries: () ->

        loader = new THREE.OBJLoader2()

        # Bunny Rabbit on Load function.

        # this, world length of longest side, position.
        intergrateIntoScene = (self, size, position) ->
            (object) ->

                mesh = object.children[0]
                geometry = mesh.geometry
                geometry.computeBoundingBox()

                bbox = geometry.boundingBox

                min = bbox.min
                max = bbox.max

                translate = min.clone().multiplyScalar(-1)
                mesh.position.copy(translate)


                # Compute the scaling factor to bring the mesh to size 1 in the longest direction.
                rangex = max.x - min.x
                rangey = max.y - min.y
                rangez = max.z - min.z

                max_range = Math.max(rangex, Math.max(rangey, rangez))
                scaleToNormal = 1.0 / max_range
                scale = scaleToNormal * size#120 # Scale object to size 20.

                mesh.scale.copy(new THREE.Vector3(scale, scale, scale))

                # Align the rabbit within our voxel bounds.
                mesh.rotation.copy(new THREE.Euler( 0, 1, 0, 'XYZ' ))
                #mesh.position.copy(new THREE.Vector3(10, -50, -30))# Original buggy mesh.
                #mesh.scale.copy(new THREE.Vector3(1288.98456, 1288.98456, 1288.98456))
                mesh.position.copy(position)

                mesh.material = SEE.params.preview_material

                # visualize shape.
                self.scene.add( object )
                self._objects.push(object)

                return

        # load a resource from provided URL
        # load Stanford Bunny (A clean, manifold version)
        #loader.load( 'data/bunny.obj', intergrateIntoScene(@, 200, new THREE.Vector3(-60, 0, -50)) )
        #loader.load( 'data/hand.obj', intergrateIntoScene(@, 200, new THREE.Vector3(0, 0, 0)) )
        #loader.load( 'data/sphere.obj', intergrateIntoScene(@, 200, new THREE.Vector3(0, 0, 0)) )
        loader.load( 'data/torus.obj', intergrateIntoScene(@, 200, new THREE.Vector3(70, -40, 0)) )


    # Returns objects that can be rotated.
    getObjects: () ->
        return @_objects

    ###

    External API.

    ###

    # Provides a link to the root of the input controller tree.
    setInputRoot: (input) ->
        input_root = input

    getObjects: () ->
        return @_objects

    getVisual: () ->
        if @seeing_mode
            return @seeing_scene
        else
            return @scene

    # Returns a ground plane textured with a grid cooresponding to the research scene.
    new_ground_plane: () ->
        size = 200 # Total size.
        divisions = 10

        gridHelper = new THREE.GridHelper( size, divisions )
 
        return gridHelper

    init_ground_plane: () ->
        ground_plane = @new_ground_plane()
        @scene.add( ground_plane )
        return

    # str is the message spelled in the label.
    new_label: (str) ->

        # params: {font: (FontLoader), message: String, height:, out:,
        #           fill_color:0xrrggbb, outline_color:0xff}
        obj = new THREE.Object3D()
        params = {font: SEE.style.fontLoader, message: str, height:20, out: obj, fill_color:0x000000, outline_color:0x111111}
        SEE.style.newText(params)

        obj.position.copy(new THREE.Vector3(-50, 20, -100))
        obj.scale.copy(new THREE.Vector3(1, -1, 1))
        obj.rotation.copy(new THREE.Vector3(0, 0, Math.PI/2))

        return obj

    init_label: (str) ->
        label = @new_label(str)
        @scene.add(label)
        return

    init_lighting: () ->
        ambient = new THREE.AmbientLight( 0x404040 )
        @scene.add( ambient )

        directionalLight = new THREE.DirectionalLight( 0xffffff, 0.5 )
        # SET, do not copy. Copy does not work.
        directionalLight.position.set( 0, 1, 1 )
        @scene.add( directionalLight )

    enable_normal_mode: () ->
        @seeing_mode = false

    enable_seeing_mode: () ->
        @seeing_mode = true

    generate_impressions: (camera) ->

        @image.clear()

        for group in @_objects
            
            mesh = group.children[0]

            geometry = mesh.geometry

            mesh.updateMatrixWorld(true)
            geometryToWorldTransform = mesh.matrixWorld.clone()

            @image.quantize(geometry, geometryToWorldTransform, camera)

        @seeing_scene = new THREE.Scene()
        @seeing_scene.add(@image.getVisual())