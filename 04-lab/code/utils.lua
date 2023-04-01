local utils = {}

-- Utility function to obtain the max value, angle and index from an array of sensors.
-- N.B. Each sensor must have a value and an angle entry in the table.
function utils.maxOfSensors(sensors)
    max_value = -1
    max_angle = -1
    max_index = -1

    for i=1,#sensors do
        if max_value < sensors[i].value then
            max_index = i
            max_value = sensors[i].value
            max_angle = sensors[i].angle
        end
    end
    
    return max_index, max_value, max_angle
end

-- Utility function to limit the velocity
function utils.limitVelocity(max, v)
    if v > max then
      return max
    elseif v < -max then
      return -max
    else
      return v
    end
  end

-- Utility function to concat arrays
function utils.concatArray(a, b)
    local result = {table.unpack(a)}
    table.move(b, 1, #b, #result + 1, result)
    return result
end

return utils