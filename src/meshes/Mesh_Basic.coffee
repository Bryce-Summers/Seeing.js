###
    Super class to mesh construction classes.

    Written by Bryce Summers on 11/22/2016.
    
    Purpose:
        Deals with all of the common problems such as adding a material and changing its color.
###

class SEE.Mesh_Basic extends THREE.Mesh

    constructor: (area_geometry, @outline_geometry) ->

        # Affix the geometry with a material.
        @fill_material = SEE.style.m_default_fill.clone()
        super(area_geometry, @fill_material);

        # Black Line color.
        @line_material = SEE.style.m_default_line.clone()

    # color: THREE.Color fill color.
    # material: material
    # position: THREE.Vector, sets position.
    # scale: THREE.Vector. sets scale.
    #roation: THREE.Euler, sets orientation.
    clone: (params) ->
        output  = new THREE.Object3D()
        mesh    = new SEE.Mesh_Basic(@geometry)
        outline = new THREE.Line(@outline_geometry, @line_material)
        outline.renderOrder = 1
        output.add(mesh)
        output.add(outline)

        # Act on params.

        if params.material
            mesh.material = params.material

        if params.color
            if not (params.color instanceof THREE.Color)
                debugger

            mesh.material.color = params.color;

        if params.position
            output.position.copy(params.position)
        if params.scale
            output.scale.copy(params.scale)
        if params.rotation
            output.rotation.copy(params.rotation)

        output.setFillColor = (c) ->
            @children[0].material.color = c

        output.revertFillColor = () ->
            @children[0].material.color = SEE.style.m_default_fill.color.clone()

        return output;