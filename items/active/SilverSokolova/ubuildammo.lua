require("/items/active/SilverSokolova/scripts/uassetmissing.lua")
function build(directory, config, parameters)
  parameters.projectileType = parameters.projectileType or randomProjectile(config.projectileTypes)
  config.inventoryIcon = jarray()
  table.insert(config.inventoryIcon, {image = "uammo.png"})
  table.insert(config.inventoryIcon, {image = uassetmissing("/items/active/SilverSokolova/interface/utooltips/"..parameters.projectileType..".png", "/items/active/SilverSokolova/interface/utooltips/uassetmissing.png")})
  config.shortdescription = getName(parameters.projectileType) or config.shortdescription
  local maxStack = root.assetJson("/items/defaultParameters.config:defaultMaxStack")
  if maxStack < 9999 then config.maxStack = 9999 end
  return config, parameters
end

function randomProjectile(a)
  return a[math.random(#a)]
end

function getName(a)
  local names = root.assetJson("/items/active/SilverSokolova/uprojectiles.config")
  return names[a] and names[a] or nil
end