local function cbrt( x )
	return x < 0 and -(-x)^(1/3) or x^(1/3)
end
local function lerp( a, b, t ) --Guarantees monotonicity
	if t < 0.5 then
		return a + (b - a)*t
	end
	return b + (b - a)*(t - 1)
end

local function create_interpolator( c0: Color3, c1: Color3 )
	local c0r, c0g, c0b = c0.R, c0.G, c0.B --[0, 1]
	local c1r, c1g, c1b = c1.R, c1.G, c1.B --[0, 1]

	local lr0, lg0, lb0 = (c0r <= 0.0404482362771082) and (c0r/12.92) or ((c0r + 0.055)/1.055)^2.4,
						(c0g <= 0.0404482362771082) and (c0g/12.92) or ((c0g + 0.055)/1.055)^2.4,
						(c0b <= 0.0404482362771082) and (c0b/12.92) or ((c0b + 0.055)/1.055)^2.4
	local lr1, lg1, lb1 = (c1r <= 0.0404482362771082) and (c1r/12.92) or ((c1r + 0.055)/1.055)^2.4,
						(c1g <= 0.0404482362771082) and (c1g/12.92) or ((c1g + 0.055)/1.055)^2.4,
						(c1b <= 0.0404482362771082) and (c1b/12.92) or ((c1b + 0.055)/1.055)^2.4

	local x0, y0, z0 = lr0*0.4124564 + lg0*0.3575761 + lb0*0.1804375,
						lr0*0.2126729 + lg0*0.7151522 + lb0*0.0721750,
						lr0*0.0193339 + lg0*0.1191920 + lb0*0.9503041
	local x1, y1, z1 = lr1*0.4124564 + lg1*0.3575761 + lb1*0.1804375,
						lr1*0.2126729 + lg1*0.7151522 + lb1*0.0721750,
						lr1*0.0193339 + lg1*0.1191920 + lb1*0.9503041

	local l0, m0, s0 = cbrt(x0*0.8189330101 + y0*0.3618667424 - z0*0.1288597137),
						cbrt(x0*0.0329845436 + y0*0.9293118715 + z0*0.0361456387),
						cbrt(x0*0.0482003018 + y0*0.2643662691 + z0*0.6338517070)
	local l1, m1, s1 = cbrt(x1*0.8189330101 + y1*0.3618667424 - z1*0.1288597137),
						cbrt(x1*0.0329845436 + y1*0.9293118715 + z1*0.0361456387),
						cbrt(x1*0.0482003018 + y1*0.2643662691 + z1*0.6338517070)

	local L0, a0, b0 = l0*0.2104542553 + m0*0.7936177850 - s0*0.0040720468,
						l0*1.9779984951 - m0*2.4285922050 + s0*0.4505937099,
						l0*0.0259040371 + m0*0.7827717662 - s0*0.8086757660
	local L1, a1, b1 = l1*0.2104542553 + m1*0.7936177850 - s1*0.0040720468,
						l1*1.9779984951 - m1*2.4285922050 + s1*0.4505937099,
						l1*0.0259040371 + m1*0.7827717662 - s1*0.8086757660

	return function(t)
		t = math.clamp(t, 0, 1)
		local L, a, b = lerp(L0, L1, t),
						lerp(a0, a1, t),
						lerp(b0, b1, t)

		local l, m, s = L + a*0.3963377921 + b*0.2158037580,
						L - a*0.1055613423 - b*0.0638541747,
						L - a*0.0894841820 - b*1.2914855378
		l, m, s = l*l*l, m*m*m, s*s*s

		local x, y, z = l*1.2270138511 - m*0.5577999806 + s*0.2812561489,
						-l*0.0405801784 + m*1.1122568696 - s*0.0716766786,
						-l*0.0763812845 - m*0.4214819784 + s*1.5861632204

		local lr, lg, lb = x*3.2404542 - y*1.5371385 - z*0.4985314,
							-x*0.9692660 + y*1.8760108 + z*0.0415560,
							x*0.0556434 -y*0.2040259 + z*1.0572252

		if lr < 0 and lr < lg and lr < lb then
			lr, lg, lb = 0, lg - lr, lb - lr
		elseif lg < 0 and lg < lb then
			lr, lg, lb = lr - lg, 0, lb - lg
		elseif lb < 0 then
			lr, lg, lb = lr - lb, lg - lb, 0
		end

		local r, g, b = math.clamp(lr <= 0.00313066844250063 and (lr*12.92) or (1.055*lr^(1/2.4) - 0.055), 0, 1),
						math.clamp(lg <= 0.00313066844250063 and (lg*12.92) or (1.055*lg^(1/2.4) - 0.055), 0, 1),
						math.clamp(lb <= 0.00313066844250063 and (lb*12.92) or (1.055*lb^(1/2.4) - 0.055), 0, 1)

		return Color3.new(r, g, b)
	end
end
