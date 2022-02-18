mice = 0
bunnies = 0
foxes = 0
wait_id = 0

outcast = 2 -- 0,1 - mouse outcast,hated; 2,3 - bunny outcast/hated, 4,5 - fox outcast/hated

function onLoad(script_state)
  local state = JSON.decode(script_state)
  if state.lizWizOutcast then
    outcast = state.lizWizOutcast
  end
  restoreOutcastButtons()
  createButtons()
  wait_id = Wait.time(updateButtons, 1, -1)
end

function onSave()
  local state = {
    lizWizOutcast = outcast
  }
  return JSON.encode(state)
end

function onDestroy()
    Wait.stop(wait_id)
end

function nothing()
end

function addCard(suit)
  suit = suit:lower()
  if suit == "fox" then
      foxes = foxes +1
  elseif suit == "mouse" then
      mice = mice + 1
  elseif suit == "bunny" then
      bunnies= bunnies + 1
  end
end

function createButtons()
  self.createButton({
      click_function = "nothing",
      function_owner = self,
      label = '0',
      position = {0.45, 0.25, 0.03},
      scale = {0.9, 0.5, 0.9},
      width = 0,
      height = 0,
      font_size = 120
  })
  self.createButton({
      click_function = "nothing",
      function_owner = self,
      label = '0',
      position = {0.45, 0.25, 0.4},
      scale = {0.9, 0.5, 0.9},
      width = 0,
      height = 0,
      font_size = 120
  })
  self.createButton({
      click_function = "nothing",
      function_owner = self,
      label = '0',
      position = {0.45, 0.25, 0.73},
      scale = {0.9, 0.5, 0.9},
      width = 0,
      height = 0,
      font_size = 120
  })
end

function updateButtons()
  mice = 0
  foxes = 0
  bunnies = 0
  items = Physics.cast({
      origin       = self.positionToWorld({-0.0, 0.2, 0.45}),
      direction    = self.getTransformUp(),
      type         = 3,
      size         = {3, 0.1, 6},
      max_distance = 2,
  })
  for _, item in ipairs(items) do
      if item.hit_object.tag == "Card" then
          addCard(item.hit_object.getDescription())
      end
      if item.hit_object.tag == "Deck" then
          for _, card in ipairs(item.hit_object.getObjects()) do
              addCard(card.description)
          end
      end
  end

  self.editButton({index=0,label=tostring(mice)})
  self.editButton({index=1,label=tostring(bunnies)})
  self.editButton({index=2,label=tostring(foxes)})
end

function updateOutcast(player, value, id)
  if self.UI.getAttribute(id, "color") ~= "rgba(1, 1, 1, 1)" then
    resetOutcast()
    self.UI.setAttribute(id, "image", "Outcast")
    self.UI.setAttribute(id, "color", "rgba(1, 1, 1, 1)")
  else
    if self.UI.getAttribute(id, "image") ~= "Hated" then
      self.UI.setAttribute(id, "image", "Hated")
    else
      self.UI.setAttribute(id, "image", "Outcast")
    end
    self.UI.setXml(self.UI.getXml())
  end

  --Store the outcast state
  if id == "outcastMouse" then
    outcast = ((self.UI.getAttribute(id, "image") == "Outcast") and 0 or 1)
  elseif id == "outcastRabbit" then
    outcast = ((self.UI.getAttribute(id, "image") == "Outcast") and 2 or 3)
  elseif id  == "outcastFox" then
    outcast = ((self.UI.getAttribute(id, "image") == "Outcast") and 4 or 5)
  end
end

function resetOutcast()
  self.UI.setAttribute("outcastMouse", "color", "rgba(1, 1, 1, 0)")
  self.UI.setAttribute("outcastRabbit", "color", "rgba(1, 1, 1, 0)")
  self.UI.setAttribute("outcastFox", "color", "rgba(1, 1, 1, 0)")
  self.UI.setXml(self.UI.getXml())
end

function restoreOutcastButtons()
  local suit = "outcastRabbit"
  local image = "Outcast"

  resetOutcast()

  -- Set hated/outcast status
  if math.fmod(outcast,2) ~= 0 then
    image = "Hated"
  end

  --set suit, if different from Rabbit default
  if outcast < 2 then
    suit = "outcastMouse"
  elseif outcast > 3 then
    suit = "outcastFox"
  end

  self.UI.setAttribute(suit, "image", image)
  self.UI.setXml(self.UI.getXml())
end