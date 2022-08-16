local NAIVE_PAIR = {
    [CFrame.fromEulerAnglesYXZ(0, 0, 0)] = "\2",
    [CFrame.fromEulerAnglesYXZ(math.pi/2, 0, 0)] = "\3",
    [CFrame.fromEulerAnglesYXZ(0, math.pi, math.pi)] = "\5",
    [CFrame.fromEulerAnglesYXZ(-math.pi/2, 0, 0)] = "\6",
    [CFrame.fromEulerAnglesYXZ(0, math.pi, math.pi/2)] = "\7",
    [CFrame.fromEulerAnglesYXZ(0, math.pi/2, math.pi/2)] = "\9",
    [CFrame.fromEulerAnglesYXZ(0, 0, math.pi/2)] = "\10",
    [CFrame.fromEulerAnglesYXZ(0, -math.pi/2, math.pi/2)] = "\12",
    [CFrame.fromEulerAnglesYXZ(-math.pi/2, -math.pi/2, 0)] = "\13",
    [CFrame.fromEulerAnglesYXZ(0, -math.pi/2, 0)] = "\14",
    [CFrame.fromEulerAnglesYXZ(math.pi/2, -math.pi/2, 0)] = "\16",
    [CFrame.fromEulerAnglesYXZ(0, math.pi/2, math.pi)] = "\17",
    [CFrame.fromEulerAnglesYXZ(0, math.pi, 0)] = "\20",
    [CFrame.fromEulerAnglesYXZ(-math.pi/2, -math.pi, 0)] = "\21",
    [CFrame.fromEulerAnglesYXZ(0, 0, math.pi)] = "\23",
    [CFrame.fromEulerAnglesYXZ(math.pi/2, math.pi, 0)] = "\24",
    [CFrame.fromEulerAnglesYXZ(0, 0, -math.pi/2)] = "\25",
    [CFrame.fromEulerAnglesYXZ(0, -math.pi/2, -math.pi/2)] = "\27",
    [CFrame.fromEulerAnglesYXZ(0, -math.pi, -math.pi/2)] = "\28",
    [CFrame.fromEulerAnglesYXZ(0, math.pi/2, -math.pi/2)] = "\30",
    [CFrame.fromEulerAnglesYXZ(math.pi/2, math.pi/2, 0)] = "\31",
    [CFrame.fromEulerAnglesYXZ(0, math.pi/2, 0)] = "\32",
    [CFrame.fromEulerAnglesYXZ(-math.pi/2, math.pi/2, 0)] = "\34",
    [CFrame.fromEulerAnglesYXZ(0, -math.pi/2, math.pi)] = "\35"
}
local CFRAME_PAIR = {}

--God this is such a ducktape solution
for i,v in next, NAIVE_PAIR do
    local curComp = {i:GetComponents()}
    local bytes = ""
    for j = 4, #curComp do
        curComp[j] = math.floor(curComp[j])
        bytes = bytes .. string.pack("<f", curComp[j])
    end
    CFRAME_PAIR[bytes] = v
end


local function write_String(str)
    return string.pack("<I4", #str) .. str
end
local function write_Array_String(strs)
    local n = #strs
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_String(strs[i])
    end

    return table.concat(result)
end

local function write_Boolean(bool)
    return bool and "\1" or "\0"
end
local function write_Array_Boolean(bools)
    local n = #bools
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_Boolean(bools[i])
    end

    return table.concat(result)
end

local function write_Int32(int)
    return string.pack(">I4", int < 0 and -2*int-1 or 2*int)
end
local function write_Array_Int32(ints)
    local n = #ints
    local result = table.create(n*4)

    for i = 1, n do
        local int = write_Int32(ints[i])
        for j = 1, 4 do
            result[i + n*(j - 1)] = string.sub(int, j, j)
        end
    end

    return table.concat(result)
end

local function write_Float32(float)
    return string.pack(">I4", bit32.lrotate(string.unpack(">I4", string.pack(">f", float)), 1))
end
local function write_Array_Float32(floats)
    local n = #floats
    local result = table.create(n*4)

    for i = 1, n do
        local float = write_Float32(floats[i])
        for j = 1, 4 do
            result[i + n*(j - 1)] = string.sub(float, j, j)
        end
    end

    return table.concat(result)
end

local function write_Double(double)
    return string.pack(">d", double)
end
local function write_Array_Double(doubles)
    local n = #doubles
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_Double(doubles[i])
    end

    return table.concat(result)
end

local function write_UDim(udim)
    local result = table.create(8)
    local scale = write_Float32(udim.Scale)
    local offset = write_Int32(udim.Offset)
    local flattened = scale .. offset

    for i = 1, 2 do
        for j = 1, 4 do
            local k = i + 2*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_UDim(udims)
    local n = #udims
    local result = table.create(n*8)

    for i = 1, n do
        local udim = write_UDim(udims[i])
        for j = 1, 8 do
            result[i + n*(j - 1)] = string.sub(udim, j, j)
        end
    end

    return table.concat(result)
end

local function write_UDim2(udim2)
    local result = table.create(16)
    local x, y = udim2.X, udim2.Y
    local scaleX = write_Float32(x.Scale)
    local scaleY = write_Float32(y.Scale)
    local offsetX = write_Int32(x.Offset)
    local offsetY = write_Int32(y.Offset)

    local row1 = scaleX .. scaleY
    local row2 = offsetX .. offsetY
    local flattened = row1 .. row2

    for i = 1, 2 do
        for j = 1, 8 do
            local k = i + 2*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_UDim2(udim2s)
    local row = #udim2s
    local result = table.create(row*16)

    for i = 1, row do
        local udim2 = write_UDim2(udim2s[i])
        for j = 1, 16 do
            result[i + row*(j - 1)] = string.sub(udim2, j, j)
        end
    end

    return table.concat(result)
end

local function write_Ray(ray)
    local origin = ray.Origin
    local direction = ray.Direction
    return string.pack("<ffffff", origin.X, origin.Y, origin.Z, direction.X, direction.Y, direction.Z)
end
local function write_Array_Ray(rays)
    local n = #rays
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_Ray(rays[i])
    end

    return table.concat(result)
end

local function write_Faces(faces)
    return string.pack("b",
        (faces.Front and 32 or 0) +
        (faces.Bottom and 16 or 0) +
        (faces.Left and 8 or 0) +
        (faces.Back and 4 or 0) +
        (faces.Top and 2 or 0) +
        (faces.Right and 1 or 0)
    )
end
local function write_Array_Faces(faces)
    local n = #faces
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_Faces(faces[i])
    end

    return table.concat(result)
end

local function write_Axes(axes)
    return string.pack("b",
        (axes.Z and 4 or 0) +
        (axes.Y and 2 or 0) +
        (axes.X and 1 or 0)
    )
end
local function write_Array_Axes(axes)
    local n = #axes
    local result = table.create(n)

    for i = 1, n do
        result[i] = write_Axes(axes[i])
    end

    return table.concat(result)
end

local function write_BrickColor(color)
    return string.pack(">I4", color.Number)
end
local function write_Array_BrickColor(colors)
    local row = #colors
    local result = table.create(row*4)

    for i = 1, row do
        local color = write_BrickColor(colors[i])
        for j = 1, 4 do
            result[i + row*(j - 1)] = string.sub(color, j, j)
        end
    end

    return table.concat(result)
end

local function write_Color3(color)
    local result = table.create(12)
    local r = write_Float32(color.R)
    local g = write_Float32(color.G)
    local b = write_Float32(color.B)
    local flattened = r .. g .. b

    for i = 1, 3 do
        for j = 1, 4 do
            local k = i + 3*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_Color3(colors)
    local row = #colors
    local result = table.create(row*12)

    for i = 1, row do
        local color = write_Color3(colors[i])
        for j = 1, 12 do
            result[i + row*(j - 1)] = string.sub(color, j, j)
        end
    end

    return table.concat(result)
end

local function write_Vector2(vec2)
    local result = table.create(8)
    local x = write_Float32(vec2.X)
    local y = write_Float32(vec2.Y)
    local flattened = x .. y

    for i = 1, 2 do
        for j = 1, 4 do
            local k = i + 2*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_Vector2(vec2s)
    local row = #vec2s
    local result = table.create(row*8)

    for i = 1, row do
        local vec2 = write_Vector2(vec2s[i])
        for j = 1, 8 do
            result[i + row*(j - 1)] = string.sub(vec2, j, j)
        end
    end

    return table.concat(result)
end

local function write_Vector3(vec3)
    local result = table.create(12)
    local x = write_Float32(vec3.X)
    local y = write_Float32(vec3.Y)
    local z = write_Float32(vec3.Z)
    local flattened = x .. y .. z

    for i = 1, 3 do
        for j = 1, 4 do
            local k = i + 3*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_Vector3(vec3s)
    local row = #vec3s
    local result = table.create(row*12)

    for i = 1, row do
        local vec = write_Vector3(vec3s[i])
        for j = 1, 12 do
            result[i + row*(j - 1)] = string.sub(vec, j, j)
        end
    end

    return table.concat(result)
end

local function write_CFrame(cframe: CFrame)
    local position = write_Vector3(cframe.Position)
    local rotationType = string.pack("<fffffffff", select(4, cframe:GetComponents()))

    return (CFRAME_PAIR[rotationType] or ("\0" .. rotationType)) .. position
end
local function write_Array_CFrame(cframes)
    local n = #cframes
    local rotations = table.create(n)
    local positions = table.create(n*12)

    for i = 1, n do
        local cf = cframes[i]
        local position = write_Vector3(cf.Position)
        local rotation = string.pack("<fffffffff", select(4, cf:GetComponents()))
        rotations[i] = CFRAME_PAIR[rotation] or ("\0" .. rotation)

        for j = 1, 12 do
            positions[i + n*(j - 1)] = string.sub(position, j, j)
        end
    end

    return table.concat(rotations) .. table.concat(positions)
end

local function write_Enum(enum: EnumItem)
    return string.pack(">I4", enum.Value)
end
local function write_Array_Enum(enums)
    local row = #enums
    local result = table.create(row*4)

    for i = 1, row do
        local enum = write_Enum(enums[i])
        for j = 1, 4 do
            result[i + row*(j - 1)] = string.sub(enum, j, j)
        end
    end

    return table.concat(result)
end

local function write_Referent(referent)
    return write_Int32(referent < 0 and -2*referent-1 or 2*referent)
end
local function write_Array_Referent(referents)
    local row = #referents
    local result = table.create(row*4)

    local prev
    for i = 1, row do
        local int = referents[i]
        local now = prev and int - prev or int
        prev = int
        now = write_Int32(now)

        for j = 1, 4 do
            result[i + row*(j - 1)] = string.sub(now, j, j)
        end
    end

    return table.concat(result)
end

local function write_Vector3int16(vec3)
    return string.pack("<i2i2i2", vec3.X, vec3.Y, vec3.Z)
end
local function write_Array_Vector3int16(vec3s)
    local row = #vec3s
    local result = table.create(row)

    for i = 1, row do
        result[i] = write_Vector3int16(vec3s[i])
    end

    return table.concat(result)
end

local function write_NumberSequence(numSeq)
    local n = #numSeq.Keypoints
    return string.pack("<I4" .. string.rep("fff", n), n, unpack(string.split(tostring(numSeq), " ")))
end
local function write_Array_NumberSequence(numSeqs)
    local row = #numSeqs
    local result = table.create(row)

    for i = 1, row do
        result[i] = write_NumberSequence(numSeqs[i])
    end

    return table.concat(result)
end

local function write_ColorSequence(colorSeq)
    local n = #colorSeq.Keypoints
    return string.pack("<I4" .. string.rep("fffff", n), n, unpack(string.split(tostring(colorSeq), " ")))
end
local function write_Array_ColorSequence(colorSeqs)
    local row = #colorSeqs
    local result = table.create(row)

    for i = 1, row do
        result[i] = write_ColorSequence(colorSeqs[i])
    end

    return table.concat(result)
end

local function write_NumberRange(numRange)
    return string.pack("<ff", numRange.Min, numRange.Max)
end
local function write_Array_NumberRange(numRanges)
    local row = #numRanges
    local result = table.create(row)

    for i = 1, row do
        result[i] = write_NumberRange(numRanges[i])
    end

    return table.concat(result)
end

local function write_Rect(rect: Rect)
    local result = table.create(16)
    local min, max = rect.Min, rect.Max
    local minX = write_Float32(min.X)
    local minY = write_Float32(min.Y)
    local maxX = write_Float32(max.X)
    local maxY = write_Float32(max.Y)
    local flattened = minX .. minY .. maxX .. maxY

    for i = 1, 4 do
        for j = 1, 4 do
            local k = i + 4*(j - 1)
            result[k] = string.sub(flattened, k, k)
        end
    end

    return table.concat(result)
end
local function write_Array_Rect(rects)
    local row = #rects
    local result = table.create(row*16)

    for i = 1, row do
        local rect = write_Rect(rects[i])
        for j = 1, 16 do
            result[i + row*(j - 1)] = string.sub(rect, j, j)
        end
    end

    return table.concat(result)
end



local str = write_Color3(Color3.fromRGB(255, 180, 20))
local a = ""
for i = 1, #str do
    local byte = str:byte(i, i)
    a = a .. string.format("%x", byte) .. " "
end
print(a)
