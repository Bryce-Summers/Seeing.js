#
# Bryce Summers' Spline Class.
#
# Rewritten on 2 - 23 - 2017, Direct implementation of curves containing straight lines and arcs.
#
# Purpose: Provides representation and discretization capabilities for a path in space, such as a road.
#          INPUT/OUTPUT: THREE.Vector, Face, etc objects.
#
# Planned:
# 1. Offset Curves.
# 2. Inset Curves.
# 3. Maximum-length interval discretizations for producing renderable line segments.
#
# Currently we are implementing this as a reduction to THREE.CatmullRomCurve3, but we may remove the dependancy if we have time and go sufficiently beyond it.
# FIXME: Standardize the curve class and instantiate it from interfacial curves.
class SEE.S_Curve

    constructor: () ->

        # A spline that dynamically parameterizes itself to between 0 and 1.
        #@_spline = new THREE.CatmullRomCurve3()

        @_spline = new BDS.Polyline(false)

        # A list of points in the discretization.
        @_point_discretization = []

        @_cumulative_lengths = []

        @_unit_tangents = []
        @_total_length = 0

    # p : THREE.Vector3.
    addPoint: (p) ->
        @_spline.addPoint(@vec_to_point(p))

        # Update utility structures.
        @_total_length += @_spline.getLastSegmentDistance()
        @_cumulative_lengths.push(@_total_length)

        # Populate the unit tangent array.
        if @numPoints() > 1
            @_unit_tangents.push(@_spline.getLastSegmentDirection())

        return

    numPoints: () ->
        return @_spline.size()

    getPointAtIndex: (i) ->
        return @point_to_vec(@_spline.getPoint(i))

    getLastPoint: () ->
        return @point_to_vec(@_spline.getLastPoint())

    removeLastPoint: () ->

        @_total_length -= @_spline.getLastSegmentDistance()
        @_cumulative_lengths.pop()

        # This will return undefined if we call it on an empty array.
        @_unit_tangents.pop()

        return @_spline.removeLastPoint()


    # ASSUMES t in [0, 1]
    # Returns the position along the center of the curve at the given time.
    # (float) -> THREE.Vector
    position: (t) ->

        i1 = @_get_segment_start_index(t)

        if i1 >= @numPoints() - 1
            return @getLastPoint()

        i2 = i1 + 1

        # Conversion from unit time domain to [0, @_total_length] distance codomain.
        distance = t*@_total_length
        start_distance = @_cumulative_lengths[i1]
        distance_to_go = distance - start_distance

        p1 = @_spline.getPoint(i1)
        p2 = @_spline.getPoint(i2)

        dir = p1.directionTo(p2)

        return @point_to_vec(p1.add(dir.multScalar(distance_to_go)))


    # Returns the unit direction tangent THREE.Vector to the center of the curve at the given time.
    # (float) -> THREE.Vector
    # NOTE: Currently we are handling tangents by simply discretizing the curve enough that the normal discrete tangents are suffciently smooth.
    # FIXME: Implement arc length curves.
    tangent: (t) ->

        index = @_get_segment_start_index(t)

        # Use the last tangent if we are past the second to last index.
        if index >= @_unit_tangents.length
            index--

        return @point_to_vec(@_unit_tangents[index])


    # Returns the THREE.Vector offset from the curve by the normal at the given [0, 1] time parameter.
    # (float) -> THREE.Vector
    offset: (t, amount) ->

        # THREE.Vector3
        tan = @tangent(t)
        tan.setLength(amount)
        
        # Perpendicularlize the vector.
        x = tan.x
        y = tan.y
        tan.x =  y
        tan.y = -x
        
        return @position(t).add(tan)


    # Convert from [0, 1] time to the index of the start of the segment that contains that time.
    # (float) -> THREE.Vector
    _get_segment_start_index: (t) ->
        distance = t*@_total_length
        return BDS.Arrays.binarySearch(@_cumulative_lengths, distance)


    # Returns a list of points representing this spline.
    # They will be no more than max_length apart.
    # They will be as sparse as is practical. # FIXME: Do some studying of this.
    # See: https://github.com/Bryce-Summers/Bryce-Summers.github.io/blob/master/p5/Physics/Visuals/visual_conservation_of_energy.js
    # This is more efficient than the built in THREE.js version, because it does the binary searches for all of the points at the same time.
    # It may produce up to 2 times as many points though...
    # FIXME: Do an analysis of differnt spline discretization techniques.
    # I believe I will compensate for this algorithms problems, 
    # by designing my user interactions such that when they click near the original spline, 
    # that is a signal to go back.
    getDiscretization: (max_length) ->
        return @_discretization


    # FIXME: At the moment, we are using the simplest smapling scheme known to man.

    updateDiscretization: (max_length) ->


        @_discretization = []

        len = @numPoints()

        for index in [0...len]
            vec = @getPointAtIndex(index)
            @_discretization.push(vec)

        return @_discretization
        
    getOffsets: (max_length, amount, times_output) ->

        out = []

        len = 0

        for distance in @_cumulative_lengths
            time = distance / @_total_length
            times_output.push(time)
            out.push(@offset(time, amount))

        return out


    # here are the uniform distance continuous spline sampling functions.

    ###
    updateDiscretization: (max_length) ->
        output = []
        p0 = @position(0)
        output.push(p0)

        S = [] # Stack.
        S.push(1.0)
        
        low   = 0
        p_low = @position(low)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval
        # every time an interval is less than the max_length, subdivision is terminated.

        # Left to right subdivision loop. Performs a binary search across all intervals.
        while S.length != 0
        
            high   = S.pop()
            p_high = @position(high)
        
            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high   = (low + high)/2.0
                p_high = @position(high)
        
            output.push(p_high)
            low   = high
            p_low = p_high
            continue

        @_discretization = output

    # max_length:float, maximum length out output segment.
    # amount: the distance the offset curve is away from the main curve. positive or negative is fine.
    # time_output (optional) will be populated with the times for the output points.
    # ASSUMPTION: this function assumes that it is sampling from continuously defined offsets.
    getOffsets: (max_length, amount, times_output) ->

        o0 = @offset(0, amount)
        output = []
        output.push(o0)
        times_output.push(0) if times_output

        S = []; # Stack.
        S.push(1.0)
        low = 0
        p_low = @offset(low, amount)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval.
        # every time an interval is terminated after subdivision is sufficient.

        # Left to right subdivision loop.
        while S.length != 0
        
            high   = S.pop()
            p_high = @offset(high, amount)

            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length
            
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high = (low + high)/2.0
                p_high = @offset(high, amount)
            

            output.push(p_high)
            times_output.push(high) if times_output
            low = high
            p_low = p_high
            continue
        
        return output
    ###

    # Translation functions.
    # THREE.Vector3[] -> BDS.Point[]
    threeVectorsToBDSPolyline: (vecs) ->

        polyline = new BDS.Polyline(false)

        for vec in vecs
            polyline.addPoint(new BDS.Point(vec.x, vec.y))

        return polyline

    # THREE.Vector3 -> BDS.Point
    vec_to_point: (vec) ->
        return new BDS.Point(vec.x, vec.y)

    # BDS.Point -> THREE.Vector3
    point_to_vec: (pt) ->
        return new THREE.Vector3(pt.x, pt.y)

    # Returns the total length of this curve.
    length: () ->
        return @_total_length