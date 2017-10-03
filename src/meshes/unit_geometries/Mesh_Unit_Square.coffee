###
    Square Mesh.

    Initializes as a unit square at the origin.

    Written by Bryce Summers on 11/22/2016.
    
    Purpose:
     - Provides a unit square that can then be scaled, positioned, and rotated.
###

class SEE.Mesh_Unit_Square extends SEE.Mesh_Basic

    constructor: () ->

        # Creat a plane that is perpendicular facing to the z axis.
        #geometry = new THREE.PlaneBufferGeometry( 1, 1);
        geometry = new THREE.PlaneGeometry( 1, 1);
        
        outline = new THREE.Geometry();
        outline.vertices.push(
            new THREE.Vector3( -.5, -.5, 0 ),
            new THREE.Vector3(  .5, -.5, 0 ),
            new THREE.Vector3(  .5,  .5, 0 ),
            new THREE.Vector3( -.5,  .5, 0 ),
            new THREE.Vector3( -.5, -.5, 0 ) # Closed.
        );

        super(geometry, outline)

    ###
    setup_texture_coordinates: () ->
        @geometry.faceVertexUvs.push(uv_coords)

        s = 1

        v1 = new THREE.Vector2(0, 0)
        v2 = new THREE.Vector2(s, 0)
        v3 = new THREE.Vector2(s, s)
        v4 = new THREE.Vector2(0, s)

        uv_coords.push([v1, v2, v3])
        uv_coords.push([v1, v3, v4])

        @geometry.uvsNeedUpdate = true

        @geometry.computeBoundingSphere()

        @geometry.computeFaceNormals()
        @geometry.computeVertexNormals()
        
        @geometry.verticesNeedUpdate = true
                
        # Changes to Vertex normals.
        @geometry.normalsNeedUpdate = true
        @geometry.colorsNeedUpdate = true
    ###
    