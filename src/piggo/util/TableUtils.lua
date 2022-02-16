local TableUtils = {}

--check if two tables have equal contents all the way down
--slow, as it needs two potentially recursive loops
function TableUtils.deep_compare(a, b)
	if a == b then return true end
	--not equal on type
	if type(a) ~= type(b) then
		return false
	end
	--bottomed out
	if type(a) ~= "table" then
        if type(a) == "number" and type(b) == "number" then
            return tostring(a) == tostring(b)
        end
		return a == b
	end
	for k, v in pairs(a) do
		if not TableUtils.deep_compare(v, b[k]) then
			return false
		end
	end
	for k, v in pairs(b) do
		if not TableUtils.deep_compare(v, a[k]) then
			return false
		end
	end
	return true
end

function TableUtils.map(tbl, func, ...)
    local newtbl = {}
    for k, v in pairs(tbl) do newtbl[k] = func(v, k, ...) end
    return newtbl
end

return TableUtils
