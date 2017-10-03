###
 * Testing Routines.
 *
 * Here, I will unit test any data structures that I write to ensure some numerical sanity.
###

SEE.Test = () ->
    new SEE.Testing()

class SEE.Testing

    constructor: () ->

        @test_triangle_ray_intersection()

    test_triangle_ray_intersection: () ->

        ###
        origin = new BDS.Point(0, 0, 0)
        dir    = new BDS.Point(0, 0, 1)

        # Z perpendicular triangle that contains the ray.
        a = new BDS.Point(-5, 5,  5)
        b = new BDS.Point( 5, 5,  5)
        c = new BDS.Point( 0, -5, 5)
        triangle = new BDS.Triangle(a, b, c)

        ray      = new BDS.Ray(origin, dir)
        rayQuery = new BDS.RayQuery(ray)

        result = triangle.rayQueryTime(rayQuery)

        console.log("Should be true, .time = 5")
        console.log(result)
        console.log(rayQuery)

        result = triangle.rayQueryTimes(rayQuery)
        console.log(result)
        console.log(rayQuery)

        result = triangle.rayQueryMin(rayQuery)
        console.log(result)
        console.log(rayQuery)

        result = triangle.rayQueryAll(rayQuery)
        console.log(result)
        console.log(rayQuery)
        ###

        origin = new BDS.Point(.5, -.5, .5)
        dir    = new BDS.Point(0, 1, 0)
        ray      = new BDS.Ray(origin, dir)
        rayQuery = new BDS.RayQuery(ray)

        # Set of triangles representing a cube.
        triangle_list = BDS.Mesh_Builder.new_cube()

        # Test finding all Intersections. (2 for the diagonal on both xz faces.)
        for tri in triangle_list
            tri.rayQueryAll(rayQuery)
        console.log(rayQuery.objs.length >= 4)

        # Test finding minnimum.
        rayQuery.reset()
        for tri in triangle_list
            tri.rayQueryMin(rayQuery)
        console.log(rayQuery.min_time <= .51)

        # Test Bounding Volume Hiearchy.
        mesh = new BDS.Mesh({triangles: triangle_list, bvh:true})
        rayQuery.reset()
        mesh.rayQueryMin(rayQuery)
        console.log(rayQuery)


    ###
        #@test_AABB()

    
    test_AABB: () ->

        scene = new THREE.Scene()

        geometry = new THREE.Geometry()

        y = 0
        for x in [0 .. 10]
            mesh = @test_mesh(new THREE.Vector3(x*3 +  0, y*3 + 1, 0 ),
                              new THREE.Vector3(x*3 + -1, y*3 - 1, 0 ),
                              new THREE.Vector3(x*3 +  1, y*3 - 1, 0 ))
            scene.add( mesh )

        AABB = new TSAG.AABB(scene, {val: 'x', dim:2})

        origin    = new THREE.Vector3(0, 0, -10)
        direction = new THREE.Vector3(0, 0, 1)
        ray = new THREE.Ray(origin, direction)

        [mesh, inter] = AABB.collision_query(ray)

        console.log(mesh)
        console.log(inter)

    # Returns a test triangle mesh.
    test_mesh: (a, b, c) ->
    
        geometry = new THREE.Geometry()
        geometry.vertices.push(a, b, c)

        geometry.faces.push( new THREE.Face3( 0, 1, 2 ) )

        material = new THREE.MeshBasicMaterial( { color: 0xffff00 } )
        mesh = new THREE.Mesh( geometry, material )
    ###