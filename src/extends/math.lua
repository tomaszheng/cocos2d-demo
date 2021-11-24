function math.newRandomseed()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

function math.round(value, digit)
    digit = digit or 0
    digit = 10 ^ digit
    value = (tonumber(value) or 0) * digit
    return math.floor(value + 0.5) * 1.0 / digit
end

local pi_div_180 = math.pi / 180
function math.angle2radian(angle)
    return angle * pi_div_180
end

local pi_div_180_r = 1 / pi_div_180
function math.radian2angle(radian)
    return radian * pi_div_180_r
end

function math.floatEqual(a, b)
    return math.abs(a - b) < 0.000001
end

function math.sum(t)
    local sum = 0
    for i, v in pairs(t or {}) do
        sum = sum + v
    end
    return sum
end

function math.average(t)
    t = t or {}
    if table.size(t) < 1 then
        return 0
    end
    return math.sum(t) / table.size(t)
end

--方差
function math.variance(t)
    local avg = math.average(t)
    local sub = 0
    for i, v in pairs(t or {}) do
        sub = sub + (v - avg) ^ 2
    end
    return sub / table.size(t)
end

--标准差
function math.stdDev(t)
    return math.sqrt(math.variance(t))
end