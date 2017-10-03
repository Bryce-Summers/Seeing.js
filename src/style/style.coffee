###
#
# Global Style objects, including materials for roads, lines, etc.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
###

SEE.init_style = () ->
    SEE.style = 
    {
        renderer_clear_color: 0x000000,

        discretization_length: 10,
        pipe_radius: 10,

        # Materials.
        m_default_fill: new THREE.MeshLambertMaterial( {color: 0xdddddd, side: THREE.DoubleSide} ),
        m_flat_fill: new THREE.MeshBasicMaterial( {color: 0xdddddd, side: THREE.DoubleSide} ),
        m_default_line: new THREE.LineBasicMaterial( {color: 0x000000, linewidth:5}),
        m_transparent:  new THREE.MeshBasicMaterial( {color: 0xdddddd, side: THREE.DoubleSide, transparent:true, opacity:.1} ),
        m_translucent:  new THREE.MeshLambertMaterial( {color: 0xdddddd, side: THREE.DoubleSide, transparent:true, opacity:.5} )

        highlight: new THREE.Color(0x0000ff),
        error:     new THREE.Color(0xff0000),
        action:    new THREE.Color(0x72E261),
        c_normal:  new THREE.Color(0xdddddd),
    }

    # All of the important parameters for debugging in one place.
    SEE.params = 
    {
        preview_material: SEE.style.m_default_fill,
    }

    SEE.style.loader = new THREE.TextureLoader()

    # dim {x:, y: w:, h:}
    SEE.style.newSprite = (url, dim) ->
        
        texture = SEE.style.loader.load(url)
        geom = new THREE.PlaneBufferGeometry( dim.w, dim.h, 32 )
        mat  = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide, map:texture, transparent: true} )
        mesh = new THREE.Mesh( geom, mat )

        mesh.position.x = dim.w/2
        mesh.position.y = dim.h/2

        mesh.rotation.z = Math.PI

        mesh.scale.x = -1

        # We use a container, so the sprite is now aligned with a position at its top left corner on the screen.
        container = new THREE.Object3D()
        container.add(mesh)

        container.position.x = dim.x
        container.position.y = dim.y

        return container


    SEE.style.fontLoader = new THREE.FontLoader();
    SEE.style.textMeshQueue = []

    # FIXME: Uncomment this out when we need fonts again.

    # Asynchronously load the font into the font loader.
    ###
    SEE.style.fontLoader.load('fonts/Raleway_Regular.typeface.json',
                               (font) ->

                                    SEE.style.font = font

                                    for params in SEE.style.textMeshQueue
                                        SEE.style.newText(params)
                               )
    ###
    

    

    # params: {font: (FontLoader), message: String, height:, out:THREE.Object3D (text will be children of the given object),
    #           fill_color:0xrrggbb, outline_color:0xff}
    # FIXME: Text is assumed to be left aligned, but I may allow for center alignment eventually.
    # It is expected that the user will position the containing object externally,
    # so that the internal text shapes may be replaced.
    # Creates a new object that contins an outline form and a fill form.
    # adds the object to the out: threejs Object, which will be the container.
    # filled objects are created if a fill is provide.
    # outlined objects are created if an outline is provided.
    SEE.style.newText = (params) ->

        # If the font is not loaded yet,
        # then we put the request in a queue for processing later,
        # once the font has loaded.
        if not SEE.style.font
            SEE.style.textMeshQueue.push(params)
            return

        # Compute shared variables once.
        if params.fill_color or params.outline_color
            message = params.message

            # 2 is the level of subdivision for the paths that are created.
            shapes  = SEE.style.font.generateShapes( message, params.height, 2 )

            geometry = new THREE.ShapeGeometry( shapes )
            geometry.computeBoundingBox()

        if params.fill_color
            SEE.style.newFillText(params, shapes, geometry)

        if params.outline_color
            SEE.style.newOutlineText(params, shapes, geometry)

    SEE.style.newFillText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        textShape = new THREE.BufferGeometry()
        
        color_fill = params.fill_color

        material_fill = new THREE.LineBasicMaterial( {
            color: color_fill,
            side: THREE.DoubleSide
        } )

        # Perform Translations.
        xMid = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )
        geometry.scale(1, -1, 1)
        tx = 0
        if params.align_center
            tx = xMid
        geometry.translate( tx, params.height, 0)

        # make shape
        textShape.fromGeometry( geometry )
        text = new THREE.Mesh(textShape, material_fill)
        output.add( text )

    SEE.style.newOutlineText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        color_outline = params.outline_color

        material_outline = new THREE.MeshBasicMaterial( {
            color: color_outline,
            ###
            transparent: true,
            opacity: 1.0,
            FIXME: Specify Opacity settings.
            ###
            side: THREE.DoubleSide
        } )

        # -- Outlines.

        # Make the letters with holes.
        holeShapes = []
        for i in [0...shapes.length] by 1
            shape = shapes[i]
            if shape.holes and shape.holes.length > 0
                for j in [0...shape.holes.length] by 1 #( var j = 0; j < shape.holes.length; j ++ ) {
                    hole = shape.holes[j]
                    holeShapes.push(hole)

        shapes.push.apply( shapes, holeShapes )
        lineText = new THREE.Object3D()
        
        
        # translation amount.
        tx = 0
        if params.align_center
            tx = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )

        #lineText.scale.y = -1
        for i in [0...shapes.length] by 1 #( var i = 0; i < shapes.length; i ++ ) {
            shape = shapes[i]
            lineGeometry = shape.createPointsGeometry()
            lineGeometry.scale(1, -1, 1)
            lineGeometry.translate(tx, params.height, 0 )
            lineMesh = new THREE.Line( lineGeometry, material_outline )
            lineText.add( lineMesh )
        
        output.add( lineText )

        return

# Init Style.
SEE.init_style()