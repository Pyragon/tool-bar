{CompositeDisposable} = require 'atom'
{View, $$} = require 'space-pen'
_ = require 'underscore-plus'
ToolbarButtonView = require './toolbar-button-view'

module.exports = class ToolbarView extends View
  @content: ->
    @div class: 'tool-bar'

  initialize: (serializeState) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'toolbar:toggle', =>
      @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'toolbar:position:top', =>
      @updatePosition 'Top'
      atom.config.set 'toolbar.position', 'Top'
    @subscriptions.add atom.commands.add 'atom-workspace', 'toolbar:position:right', =>
      @updatePosition 'Right'
      atom.config.set 'toolbar.position', 'Right'
    @subscriptions.add atom.commands.add 'atom-workspace', 'toolbar:position:bottom', =>
      @updatePosition 'Bottom'
      atom.config.set 'toolbar.position', 'Bottom'
    @subscriptions.add atom.commands.add 'atom-workspace', 'toolbar:position:left', =>
      @updatePosition 'Left'
      atom.config.set 'toolbar.position', 'Left'

    atom.config.observe 'toolbar.iconSize', (newValue) =>
      @updateSize newValue

    atom.config.onDidChange 'toolbar.position', ({newValue, oldValue}) =>
      @show() if atom.config.get 'toolbar.visible'

    atom.config.onDidChange 'toolbar.visible', ({newValue, oldValue}) =>
      if newValue then @show() else @hide()

    if atom.config.get 'toolbar.visible'
      @show()

  serialize: ->

  destroy: ->
    @subscriptions.dispose()
    @detach() if @panel?
    @panel.destroy() if @panel?

  updateSize: (size) ->
    @removeClass 'tool-bar-16px tool-bar-24px tool-bar-32px'
    @addClass "tool-bar-#{size}"

  updatePosition: (position) ->
    @removeClass 'tool-bar-top tool-bar-right tool-bar-bottom tool-bar-left tool-bar-horizontal tool-bar-vertical'

    switch position
      when 'Top' then @panel = atom.workspace.addTopPanel { item: @ }
      when 'Right' then @panel = atom.workspace.addRightPanel { item: @ }
      when 'Bottom' then @panel = atom.workspace.addBottomPanel { item: @ }
      when 'Left' then @panel = atom.workspace.addLeftPanel { item: @, priority: 50 }
    @addClass "tool-bar-#{position.toLowerCase()}"

    if position is 'Top' or position is 'Bottom'
      @addClass 'tool-bar-horizontal'
    else
      @addClass 'tool-bar-vertical'

    @updateMenu position

  updateMenu: (position) ->
    packagesMenu = _.find(atom.menu.template, ({label}) -> label is 'Packages' or label is '&Packages')
    toolbarMenu = _.find(packagesMenu.submenu, ({label}) -> label is 'Toolbar' or label is '&Toolbar') if packagesMenu
    positionsMenu = _.find(toolbarMenu.submenu, ({label}) -> label is 'Position' or label is '&Position') if toolbarMenu
    positionMenu = _.find(positionsMenu.submenu, ({label}) -> label is position) if positionsMenu
    positionMenu?.checked = true;

  addButton: (options) ->
    button = new ToolbarButtonView @group, options
    @append button
    button

  addSpacer: ->
    spacer = $$ -> @hr class: 'tool-bar-spacer'
    spacer.attr 'data-group', @group
    @append spacer
    spacer

  removeToolbarItems: ->
    @find("[data-group='#{@group}']").remove();

  hide: ->
    @detach() if @panel?
    @panel.destroy() if @panel?

  show: ->
    @hide()
    @updatePosition atom.config.get 'toolbar.position'
    @updateSize atom.config.get 'toolbar.iconSize'

  toggle: ->
    if @hasParent()
      @hide()
      atom.config.set 'toolbar.visible', false
    else
      @show()
      atom.config.set 'toolbar.visible', true
