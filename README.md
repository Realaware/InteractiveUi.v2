# Interactive Ui Version 2

Interactive Ui is Userinterface for lua u.
Still, this is not stable and we are improving performances.

# Changelogs

## 2021 / 10 / 22
* setTheme added. usage
```lua
  local library = ? -- any loaded your library.
  local page = library:addPage("");

  page:addButton("Target Button", nil, "HI", function() end);

  page:addColorpicker("Recoloring Test", "Yeah", nil, function(v)
    library:setTheme("Target object className (TextLabel, TextButton etc...)", "Property (TextColor3, BackgroundColor3)", value (Color3 only));
  end)
```