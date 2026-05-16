local Runtime = {};

Runtime.scopeStack = {};
Runtime.observerStack = {};

function Runtime.getCurrentObserver()
  return Runtime.observerStack[#Runtime.observerStack];
end

function Runtime.pushObserver(observer)
  table.insert(Runtime.observerStack, observer);
end

function Runtime.popObserver()
  return table.remove(Runtime.observerStack);
end

function Runtime.getCurrentScope()
  return Runtime.scopeStack[#Runtime.scopeStack];
end

function Runtime.pushScope(scope)
  table.insert(Runtime.scopeStack, scope);
end

function Runtime.popScope()
  return table.remove(Runtime.scopeStack);
end

return Runtime;