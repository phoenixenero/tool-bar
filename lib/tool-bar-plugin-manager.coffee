ToolBarManager = require './tool-bar-manager'
{CompositeDisposable} = require 'atom'

module.exports = class ToolBarPluginManager
  plugins: {}
  subscriptions: {}

  constructor: (@config) ->
    console.log 'ToolBarPluginManager::constructor', @config

  register: (name, toolBar) ->
    console.debug 'ToolBarPluginManager::register', arguments
    settingsKey = "tool-bar.plugins.#{name}"

    @plugins[name] = new ToolBarManager name, toolBar
    @subscriptions[name] = new CompositeDisposable

    @config.plugins.properties[name] =
      type: 'boolean'
      title: name
      description: "Whether the #{name} plugin is activated and displayed on the Tool Bar."
      default: true

    atom.config.set(settingsKey, true) unless atom.config.get(settingsKey)?

    @subscriptions[name].add atom.config.onDidChange settingsKey, ({newValue, oldValue}) =>
      console.debug "ToolBarPluginManager:#{settingsKey}:onDidChange", arguments
      if newValue
        @plugins[name]?.restoreItems()
      else
        @plugins[name]?.hideItems()

    return @plugins[name]

  unregister: (name) ->
    console.debug 'ToolBarPluginManager::unregister', name
    delete @plugins[name]
    @subscriptions[name].destroy()
    delete @subscriptions[name]
    delete @config.plugins.properties[name]

  destroy: ->
    console.debug 'ToolBarPluginManager::destroy'
    @unregister(plugin) for plugin of @plugins
    @plugins = null
    @subscriptions = null