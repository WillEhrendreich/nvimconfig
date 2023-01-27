for key, _ in pairs(package.loaded) do
  if key:find "vimsharp.*" then package.loaded[key] = nil end
end

require "vimsharp_theme"
