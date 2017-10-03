# Written on July 10.2017 by Bryce Summers
# Stores and records timing statistics.
class SEE.Profiler

    constructor: (name) ->

        @name_string = name

        @overall_time = 0 # Sum of all logs in the histogram.
        @num_logs = 0 # The total size of the histogram.

        # average time is overall time / num_logs.

        # Minnimum and maxium time values.
        @min_time = Number.MAX_VALUE
        @max_time = Number.MIN_VALUE

    # Milliseconds time.
    logTime: (time) ->
        @num_logs += 1
        @overall_time += time
        @min_time = Math.min(@min_time, time)
        @max_time = Math.max(@max_time, time)

    toString: () ->
        return @name_string + "time log: (average: " + @overall_time/@num_logs + ", min: " + @min_time + ", max: " + @max_time + ") milliseconds."