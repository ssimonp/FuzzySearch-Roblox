# FuzzySearch – Fuse.js-Inspired Fuzzy Matching for Roblox

A lightweight fuzzy search module for Roblox, inspired by the popular JavaScript library [Fuse.js](https://fusejs.io/).
Lets you search through arrays of strings or objects even if the search term isn’t exact — great for player search bars, autocomplete, inventory filters, and more.

## ✨ Features

* 🔍 **Fuzzy matching** using Levenshtein distance (typo-tolerant search)
* 📦 Works with **strings** or **objects** (customizable key selection)
* ⚙️ Adjustable **threshold** (how strict/loose matches are)
* 🔠 Optional **case-sensitive** matching
* 📊 Results sorted by relevance
* 🛠 **NEW:**

  * **Nested key paths** (`"job.name"`)
  * **Wide search keys** (`"job.*"`) to match all child properties
  * **Root wide search** (`".*"`) to search everything in an object recursively

## 📥 Installation

1. Download the `FuzzySearch.lua` file.
2. Place it in `ReplicatedStorage` (or anywhere you want).
3. `require` it in your script:

```lua
local FuzzySearch = require(game.ReplicatedStorage.FuzzySearch)
```

## 📌 Example Usage

### Search a list of strings

```lua
local fruits = {"apple", "orange", "banana", "pineapple"}
local searcher = FuzzySearch.new(fruits, {threshold = 0.4})

local results = searcher:search("aple")
for _, result in ipairs(results) do
    print(result.item, result.score)
end
```

Output:

```
apple      0.2
pineapple  0.36
```

### Search in objects

```lua
local people = {
    {name = "John Doe", job = "Developer"},
    {name = "Jane Smith", job = "Designer"},
    {name = "Jake Johnson", job = "Doctor"}
}

local searcher = FuzzySearch.new(people, {
    threshold = 0.3,
    keys = {"name", "job"}
})

local results = searcher:search("Desiner")
for _, result in ipairs(results) do
    print(result.item.name, result.item.job, result.score)
end
```

Output:

```
Jane Smith  Designer  0.18
```

### Search in nested object properties

```lua
local people = {
    {name = "John Doe", job = {name = "Lawyer", Salary = 2000}},
    {name = "Jane Smith", job = {name = "Doctor", Salary = 3000}},
    {name = "Jake Johnson", job = {name = "Designer", Salary = 1500}}
}

-- Search 'name' directly, and 'job.name' via nested key path
local searcher = FuzzySearch.new(people, {
    threshold = 0.3,
    keys = {"name", "job.name"}
})

local results = searcher:search("Desiner")
for _, result in ipairs(results) do
    print(result.item.name, result.item.job.name, result.score)
end
```

### Use wide search to search all child properties

```lua
local searcher = FuzzySearch.new(people, {
    threshold = 0.3,
    keys = {"name", "job.*"} -- all string values inside 'job'
})
```

### Root wide search to search everything

```lua
local searcher = FuzzySearch.new(people, {
    threshold = 0.3,
    keys = {".*"} -- all string values in the object, recursively
})
```

## ⚙️ API

### `FuzzySearch.new(list, options)`

**list** → `{string}` or `{table}`
**options**:

* `threshold` *(number)* → 0 = exact match, 1 = match everything (default: `0.4`)
* `keys` *(array of strings)* → Keys/paths to search in objects
* `caseSensitive` *(boolean)* → Default `false`

### `FuzzySearch:search(query)`

Returns:

```lua
{
    {item = any, score = number},
    ...
}
```

Sorted by best score first.

## 📜 License

MIT License — free to use, modify, and share.

## ☕ Support the Project

If this saved you time or improved your game, consider supporting the project ❤️
Roblox DevForum Thread: [FuzzySearch – Fuse.js-Inspired Fuzzy Matching for Roblox](https://devforum.roblox.com/t/fuzzy-search-%E2%80%93-fusejs-inspired-fuzzy-matching-for-roblox/3875736)
