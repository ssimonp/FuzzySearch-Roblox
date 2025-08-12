--!strict
-- FuzzySearch.lua

local FuzzySearch = {}
FuzzySearch.__index = FuzzySearch

export type Options = {
	threshold: number?, -- 0 = exact match only, 1 = match everything
	keys: {string}?, -- keys to search in objects
	caseSensitive: boolean?
}

type SearchResult = {
	item: any,
	score: number
}

-- Utility: Normalize case
local function normalize(str: string, caseSensitive: boolean?): string
	if not caseSensitive then
		return string.lower(str)
	end
	return str
end

-- Utility: Levenshtein distance
local function levenshtein(a: string, b: string): number
	local lenA, lenB = #a, #b
	local matrix = {}

	for i = 0, lenA do
		matrix[i] = {[0] = i}
	end
	for j = 0, lenB do
		matrix[0][j] = j
	end

	for i = 1, lenA do
		for j = 1, lenB do
			if a:sub(i, i) == b:sub(j, j) then
				matrix[i][j] = matrix[i - 1][j - 1]
			else
				local deletion = matrix[i - 1][j] + 1
				local insertion = matrix[i][j - 1] + 1
				local substitution = matrix[i - 1][j - 1] + 1
				matrix[i][j] = math.min(deletion, insertion, substitution)
			end
		end
	end

	return matrix[lenA][lenB]
end

-- Utility: Similarity score (0 = identical, 1 = completely different)
local function similarity(a: string, b: string): number
	if a == b then
		return 0
	end
	local dist = levenshtein(a, b)
	return dist / math.max(#a, #b)
end

-- Constructor
function FuzzySearch.new(list: {any}, options: Options?)
	local self = setmetatable({}, FuzzySearch)
	self.list = list or {}
	self.options = options or {}
	self.options.threshold = self.options.threshold or 0.4
	self.options.keys = self.options.keys or {}
	self.options.caseSensitive = self.options.caseSensitive or false
	return self
end

-- Utility: Get nested value by path
local function getNestedValue(tbl: any, path: string)
	local current = tbl
	for part in string.gmatch(path, "[^%.]+") do
		if type(current) ~= "table" then
			return nil
		end
		current = current[part]
		if current == nil then
			return nil
		end
	end
	return current
end

-- Utility: Collect all string values in a table (non-recursive or recursive)
local function collectAllStrings(tbl: any, results: {string}, recursive: boolean)
	if type(tbl) ~= "table" then return end
	for _, v in pairs(tbl) do
		if type(v) == "string" then
			table.insert(results, v)
		elseif recursive and type(v) == "table" then
			collectAllStrings(v, results, recursive)
		end
	end
end

-- Internal: Extract searchable text from an item
function FuzzySearch:_extractText(item: any): {string}
	if type(item) == "string" then
		return {item}
	elseif type(item) == "table" and #self.options.keys > 0 then
		local results = {}
		for _, key in ipairs(self.options.keys) do
			if key == ".*" then
				-- All string properties in the item (recursive)
				collectAllStrings(item, results, true)

			elseif string.sub(key, -2) == ".*" then
				-- Wildcard: all children of a nested table
				local basePath = string.sub(key, 1, -3)
				local tbl = basePath ~= "" and getNestedValue(item, basePath) or item
				if type(tbl) == "table" then
					collectAllStrings(tbl, results, true)
				end

			else
				-- Normal key/path
				local value
				if string.find(key, "%.") then
					value = getNestedValue(item, key)
				else
					value = item[key]
				end
				if type(value) == "string" then
					table.insert(results, value)
				end
			end
		end
		return results
	end
	return {}
end




-- Search
function FuzzySearch:search(pattern: string): {SearchResult}
	local results = {}
	local threshold = self.options.threshold or 0.4
	local caseSensitive = self.options.caseSensitive

	local normalizedPattern = normalize(pattern, caseSensitive)

	for _, item in ipairs(self.list) do
		for _, text in ipairs(self:_extractText(item)) do
			local normText = normalize(text, caseSensitive)
			local score = similarity(normalizedPattern, normText)

			if score <= threshold then
				table.insert(results, {item = item, score = score})
				break
			end
		end
	end

	table.sort(results, function(a, b)
		return a.score < b.score
	end)

	return results
end

return FuzzySearch
