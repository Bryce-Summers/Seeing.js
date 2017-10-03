###

Written on Sept.30.2017 by Bryce Summers
Purpose: Generates a set of impressions from models and a camera.

These impression are used to genreate a 3D image.

An Impression Field discretizes and quantizes an image signal into a way of seeing the abstract.
###

class SEE.Impression

    constructor: (@x, @y, default_val) ->

        @pos = new BDS.Point(@x, @y)

    hasPt: () ->
        return @pt_right != null or @pt_down != null

    clear: () ->
        @val_front = null
        @val_back  = null

        # Cached midpoints, for line tracing.
        @pt_right = null
        @pt_down  = null

        @marked = false

        @nx = null
        @ny = null
        @nz = null

class SEE.E_Impressions

    # How many impressions in each dimension of the 2D image plane.
    constructor: (xNum, yNum, default_val, width, height) ->

        @visual_set = new Set(['outline', 'nx', 'ny', 'nz'])#, 'nz'])
        @partitions = 2
        @depth_scale = 5

        @unit_meshes = new SEE.Unit_Meshes()

        @default_val = default_val

        @xNum = xNum
        @yNum = yNum

        @impressions = []

        @col_w = width/xNum
        @row_h = height/yNum

        @width  = width
        @height = height

        @_discretize(xNum, yNum, @col_w, @row_h, default_val)

    # Discretizes the image field into individual impressions.
    _discretize: (xNum, yNum, col_w, row_h, default_val) ->

        for row in [0...yNum] by 1
            for col in[0...xNum] by 1

                # Random Sampling of space.
                x = col_w*col + Math.random()*col_w
                y = row_h*row + Math.random()*row_h
                @impressions.push(new SEE.Impression(x, y, 0, default_val))

    getImpression: (mouse_x, mouse_y) ->
        pos = new BDS.Point(mouse_x, mouse_y)
        [row, column] = @_getRowColumn(pos)
        return @_getImpression(row, column)

    _getImpression: (row, col) ->

        index = @_getIndex(row, col)

        return @impressions[index]

    _getIndex: (row, col) ->

        if row >= @yNum
            row = @yNum - 1
        if col >= @xNum
            col = @xNum - 1

        if row < 0
            row = 0
        if col < 0
            col = 0

        return row*@xNum + col

    # .x, .y vector or point.
    _getRowColumn: (pos) ->

        x = pos.x
        y = pos.y

        row = Math.floor(y / @row_h)
        col = Math.floor(x / @col_w)

        return [row, col]

    # Quanitizes the impressions, based on the given mesh and camera position.
    # THREE.Geometry, 
    quantize: (geometry, transform, camera) ->

        out_indices = []

        geometry = new THREE.Geometry().fromBufferGeometry( geometry )
        geometry.mergeVertices() # Removes duplicate vertices to 4 decimal places and indexes their faces.

        triangle_list = SEE.Math.GeometryToTriangles(geometry, transform, out_indices)

        for index in [0...triangle_list.length]
            triangle_list[index] = BDS.Triangle.from_abc_triangle(triangle_list[index])

        # Create neighbor graph.
        # FIXME: Create 3D halfedgegraph. link twins and triangle cycles first, then link vertex stars.
        neighbors = {}
        for index in [0...triangle_list.length] by 1

            triangle = triangle_list[index]

            i1 = out_indices[index*3]
            i2 = out_indices[index*3 + 1]
            i3 = out_indices[index *3+ 2]

            triangle.setIndices(i1, i2, i3)

            @addNeighbor(neighbors, i1, triangle)
            @addNeighbor(neighbors, i2, triangle)
            @addNeighbor(neighbors, i3, triangle)

            

        vertex_normals = []
        for i in [0...geometry.vertices.length]
            vertex_normal = @computeVertexNormal(i, neighbors)
            vertex_normals.push(vertex_normal)

        for triangle in triangle_list
            @_quantizeTriangle(triangle, camera, vertex_normals)

        # FIXME: Implement alternate quantization tools.

    computeVertexNormal: (index, neighbors) ->
        original_index = index
        triangles = neighbors[index]

        count = 0
        average = new THREE.Vector3(0, 0, 0)

        iter = triangles.values()
        while(v = iter.next(); !v.done)
            triangle = v.value
            normal = triangle.normal()
            a = triangle.a
            if a.dot(normal) < 0
                normal.multScalar(-1)
            average.add(normal)
            count += 1

        average.divideScalar(count)
        average.normalize()
        return average

    addNeighbor: (neighbors, key, val) ->
        list = neighbors[key]
        if list == undefined
            list = new Set()
            neighbors[key] = list

        list.add(val)

    _quantizeTriangle: (triangle, camera, vertex_normals) ->
        # Step 1: Determine on camera image coordinates.
        toCamera     = camera.matrixWorldInverse
        toProjection = camera.projectionMatrix

        # Homogeneous World Space coordinates.
        v = triangle.a
        a_w = v
        a_h = new THREE.Vector4(v.x, v.y, v.z, 1)

        v = triangle.b
        b_w = v
        b_h = new THREE.Vector4(v.x, v.y, v.z, 1)

        v = triangle.c
        c_w = v
        c_h = new THREE.Vector4(v.x, v.y, v.z, 1)

        # Flat Normal
        v = triangle.normal()
        n_w = v
        n_h = new THREE.Vector4(v.x, v.y, v.z, 0)

        i1 = triangle.a_index
        i2 = triangle.b_index
        i3 = triangle.c_index

        v = vertex_normals[i1]
        na_w = v
        na_h = new THREE.Vector4(v.x, v.y, v.z, 0)

        v = vertex_normals[i2]
        nb_w = v
        nb_h = new THREE.Vector4(v.x, v.y, v.z, 0)        

        v = vertex_normals[i3]
        nc_w = v
        nc_h = new THREE.Vector4(v.x, v.y, v.z, 0)        


        # Convert triangle coordinates to homogeneous projection space.
        a_h.applyMatrix4(toCamera)
        a_h.applyMatrix4(toProjection)

        b_h.applyMatrix4(toCamera)
        b_h.applyMatrix4(toProjection)

        c_h.applyMatrix4(toCamera)
        c_h.applyMatrix4(toProjection)


        n_h.applyMatrix4(toCamera)
        n_h.applyMatrix4(toProjection)

        # Transform vertex normals.
        na_h.applyMatrix4(toCamera)
        na_h.applyMatrix4(toProjection)

        # Transform vertex normals.
        nb_h.applyMatrix4(toCamera)
        nb_h.applyMatrix4(toProjection)

        # Transform vertex normals.
        nc_h.applyMatrix4(toCamera)
        nc_h.applyMatrix4(toProjection)


        screen_a = @projection_to_screen(a_h)
        screen_b = @projection_to_screen(b_h)
        screen_c = @projection_to_screen(c_h)

        # Find a reasonable bounding box for the triangle on the screen.
        bbox = new BDS.Box()
        bbox.expandByPoint(screen_a)
        bbox.expandByPoint(screen_b)
        bbox.expandByPoint(screen_c)

        imp_set = @lookupImpressionsInBox(bbox)

        screen_polygon = new BDS.Polyline(true, [screen_a, screen_b, screen_c], true)

        a_h.divideScalar(a_h.w)
        b_h.divideScalar(b_h.w)
        c_h.divideScalar(c_h.w)

        # Set all impressions within the hand to maximum.
        for imp in imp_set

            if n_h.z < 0 and screen_polygon.containsPoint(imp.pos)              

                [per1, per2, per3] =@baryPercentages(screen_a, screen_b, screen_c, imp.pos)

                # Interpolated z value.
                val = z_interp = a_h.z*per1 + b_h.z*per2 + c_h.z*per3

                if n_h.z < 0
                    imp.val_front = val
                else
                    imp.val_back = val

                normal = na_h.clone().multiplyScalar(per1).add(nb_h.multiplyScalar(per2)).add(nc_h.multiplyScalar(per3))
                normal.normalize()

                # FIXME: In the future, interpolate this normal.
                imp.nx = normal.x
                imp.ny = normal.y
                imp.nz = normal.z
        return

    # Uses BDS.Point's on a screen.
    baryPercentages: (screen_a, screen_b, screen_c, pt) ->

        # FIXME: Use perspective correct interpolation.
        len1 = screen_a.distanceTo(pt)
        len2 = screen_b.distanceTo(pt)
        len3 = screen_c.distanceTo(pt)

        total_len = len1 + len2 + len3

        per1 = len1 / total_len
        per2 = len2 / total_len
        per3 = len3 / total_len

        return [per1, per2, per3]

    lookupImpressionsInBox: (box) ->

        outputs = []

        min = box.min
        max = box.max

        [min_row, min_column] = @_getRowColumn(min)
        [max_row, max_column] = @_getRowColumn(max)

        for row in [min_row   ..max_row] by 1
            for col in [min_column..max_column] by 1
                impression = @_getImpression(row, col)
                outputs.push(impression)

        return outputs
                

    # THREE.Vector4 (-1 , -1), (1, 1) normalized projection volume
    #  -> BDS.Point (width, height) screen space.
    projection_to_screen: (v) ->

        x = (v.x + 1)*@width /2
        y = (v.y + 1)*@height/2

        return new BDS.Point(x, y)

    getVisual: () ->

        output = new THREE.Object3D()

        scale = new THREE.Vector3(2, 2, 1)
        
        # Display Sillhouettes.
        sillhouettesfunc = (self) ->
            (impression) ->
                if self.isDefined(impression.val_front)
                    return 1
                else
                    return 0

        if @visual_set.has('outline')
            @showValFunc(output, sillhouettesfunc(@))

        # Display NormalShape.
        NormalShapeX = (self) ->
            (impression) ->
                if impression.nx is undefined
                    return null
                # Mod 1, 4 species.
                out = Math.floor((impression.nx + 1)*self.partitions)
                return out

        if @visual_set.has('nx')
            @showValFunc(output, NormalShapeX(@))

        NormalShapeY = (self) ->
            (impression) ->
                if impression.ny is undefined
                    return null
                # Mod 1, 4 species.
                return Math.floor((impression.ny + 1)*self.partitions)

        if @visual_set.has('ny')
            @showValFunc(output, NormalShapeY(@))

        NormalShapeZ = (self) ->
            (impression) ->
                if impression.nz is undefined
                    return null
                # Mod 1, 4 species.
                return Math.floor((impression.nz + 1)*self.partitions)

        if @visual_set.has('nz')
            @showValFunc(output, NormalShapeZ(@))

        for i in @impressions
            if i.val_front != null

                output.add(@newPtVisual(i.pos, (i.val_front*@depth_scale) % 1))

        return output

    showValFunc: (output, func) ->

        # Find dividing points for silhouette.
        for row in [0...@xNum - 1]
            for col in [0...@yNum - 1]
                i = @_getImpression(row, col)
                right = @_getImpression(row, col + 1)
                down  = @_getImpression(row + 1, col)

                val_i = func(i)
                val_right = func(right)
                val_down = func(down)

                if val_i == null
                    continue
                
                # Detect Boundaries of Mesh.
                if val_right != null and val_i != val_right
                    pos = i.pos.clone().add(right.pos).divScalar(2)
                    i.pt_right = pos

                if val_down  != null and val_i != val_down
                    pos = i.pos.clone().add(down.pos).divScalar(2)
                    i.pt_down = pos

        # Find dividing points for val func.
        for row in [0...@xNum - 1]
            for col in [0...@yNum - 1]
                i = @_getImpression(row, col)

                if not i.marked and i.hasPt()
                    output.add(@traceLine(row, col))

        return


    isDefined: (val) ->
        return val != null

    traceLine: (row, col) ->

        pline = new BDS.Polyline()

        i = @_getImpression(row, col)

        right = true
        if i.pt_right
            right = true
        else
            right = false

        while i.hasPt()

            if i.pt_right and right
                pline.addPoint(i.pt_right)
                i.pt_right = null

            else if i.pt_down and not right
                pline.addPoint(i.pt_down)
                i.pt_down = null

            range = 3

            min_dist = 1000000

            # Search for the closest next point.
            for r in [row - range .. row + range]
                for c in [col - range .. col + range]
                    temp = @_getImpression(r, c)
                    if temp.hasPt()

                        if temp.pt_right
                            new_dist = temp.pt_right.distanceTo(pline.getLastPoint())
                            if new_dist < min_dist
                                row = r
                                col = c
                                i = temp
                                right = true
                                min_dist = new_dist

                        if temp.pt_down
                            new_dist = temp.pt_down.distanceTo(pline.getLastPoint())
                            if new_dist < min_dist
                                row = r
                                col = c
                                i = temp
                                right = false # Down.
                                min_dist = new_dist


        return @newPolylineVisual(pline)



    getAllDrawnPoints: () ->
        output = new THREE.Object3D()
        
        for i in @impressions
            pos   = new THREE.Vector3(i.x, i.y, 0)
            scale = new THREE.Vector3(@col_w/2, @row_h/2, 1)
            val = i.val # 0 - 1

            if val == 0
                continue

            mesh  = @unit_meshes.newCircle({color:new THREE.Color(val, val, val)
                                         ,material:SEE.style.m_flat_fill
                                         ,position:pos
                                         ,scale:scale})
            output.add(mesh)
        return output

    # Clear to the default values.
    clear: () ->

        for i in @impressions
            i.clear()

    # Converts a polyline to a THREE.Line
    newPolylineVisual: (polyline) ->

        geom = new THREE.Geometry();
        
        pts = polyline.toPoints()

        for pt in pts
            geom.vertices.push(new THREE.Vector3(pt.x, pt.y, pt.z))

        line_material = SEE.style.m_default_line.clone()

        return new THREE.Line(geom, line_material)


    newPtVisual: (pt, val) ->

        scale = new THREE.Vector3(2, 2, 1)

        pos = new THREE.Vector3(pt.x, pt.y, 1)

        material = SEE.style.m_flat_fill.clone()

        mesh  = @unit_meshes.newCircle({color:new THREE.Color(val, val, val)
                             ,material:material
                             ,position:pos
                             ,scale:scale})
        return mesh