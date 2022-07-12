P= function(v)
    print(vim.inspect(v))
    return v
end
RELOAD = function(...)
    P ("Reloading Module ".. ...)

    return require("plenary.reload").reload_module(...)
end
R = function(name)
    RELOAD(name)
    return require(name)
end

TRY = function(module, Ok, NotOk)

  local ok, _ = pcall(require,module)
  if ok then
    Ok()
  else  
    NotOk()
  end
end
