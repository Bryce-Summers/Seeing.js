#
# Useful Mathematics.
#

SEE.Math = {}

SEE.Math.distance = (x1, y1, x2, y2, z1, z2) ->
    return Math.sqrt(SEE.Math.distance_sqr(x1, y1, x2, y2, z1, z2))
    
SEE.Math.distance_sqr = (x1, y1, x2, y2, z1, z2) ->

    if z1 is undefined
        dz = 0
    else
        dz = z1 - z2

    dx = x1 - x2
    dy = y1 - y2
    return dx*dx + dy*dy + dz*dz

# INPUT: THREE.Geometry or THREE.BufferGeometry, THREE.Matrix3 (default is identity), int[] (optional)
# OUTPUT: THREE.Triangle, (Optional)pushes the list of incides to the out_indices array.
SEE.Math.GeometryToTriangles = (geometry, vertexTransform, out_indices) ->

    if vertexTransform is undefined
        vertexTransform = new Matrix3() # Identity.

    # Simple, easy to work with THREE.Geometry
    if geometry instanceof THREE.Geometry
        console.log(geometry)

        faces = geometry.faces
        verts = geometry.vertices

        output = []

        for face in faces
            # INT
            index_a = face.a
            index_b = face.b
            index_c = face.c

            # THREE.Vector3
            vert_a = verts[index_a].clone().applyMatrix4(vertexTransform)
            vert_b = verts[index_b].clone().applyMatrix4(vertexTransform)
            vert_c = verts[index_c].clone().applyMatrix4(vertexTransform)

            triangle = new THREE.Triangle(vert_a, vert_b, vert_c)
            output.push(triangle)

            if out_indices
                out_indices.push(index_a)
                out_indices.push(index_b)
                out_indices.push(index_c)

        return output

    # Geometry packed efficiently into buffers.
    if geometry instanceof THREE.BufferGeometry

        verts = geometry.getAttribute('position')
        faces = geometry.getAttribute('index')

        # If indexes are not defined,
        # it is assumed that the positions are contiguous sets of 9 floats = 3 vectors.
        if not faces
            len = verts.count
            faces = []
            for i in [0...len] by 3
                faces.push(i)
                faces.push(i + 1)
                faces.push(i + 2)
        else
            faces = faces.array

        # ASSUMPTION: faces is a list of indices 0, 3, 6, 9, (at multiples of 3) specifiying triangle triplets.
        output = []
        len = faces.length
        for i in [0...len] by 3
            a = faces[i]
            b = faces[i + 1]
            c = faces[i + 2]

            # Extract x, y, z floats from position attribute array.
            v1 = new THREE.Vector3(verts.getX(a), verts.getY(a), verts.getZ(a))
            v2 = new THREE.Vector3(verts.getX(b), verts.getY(b), verts.getZ(b))
            v3 = new THREE.Vector3(verts.getX(c), verts.getY(c), verts.getZ(c))

            v1.applyMatrix4(vertexTransform)
            v2.applyMatrix4(vertexTransform)
            v3.applyMatrix4(vertexTransform)

            triangle = new THREE.Triangle(v1, v2, v3)
            output.push(triangle)

            if out_indices
                out_indices.push(a)
                out_indices.push(b)
                out_indices.push(c)

        return output

    debugger
    console.error("ERROR: SEE.Math.GeometryToTriangles, Geometry Input Type not supported:" + geometry)
    return
