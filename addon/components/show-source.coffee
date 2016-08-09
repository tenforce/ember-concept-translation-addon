`import Ember from 'ember'`
`import layout from '../templates/components/show-source'`

ShowSourceComponent = Ember.Component.extend
  layout: layout
  sButtonId: Ember.computed 'buttonId', ->
    if @get('buttonId') then return "#"+@get('buttonId')
  loaded: Ember.computed 'buttonId', ->
    if @get('buttonId') then return true
    else return false

  displaySource: false
  source: Ember.computed.alias 'term.source'

  init: ->
    this._super()
    # if @get('term')
    unless @get('term.source') then @set('term.source', '')
  actions:
    toggleSource: ->
      if @get('displaySource')
        @set('displaySource', false)
        @sendAction('saveSource', @get('term'))
      else @set('displaySource', true)
    closeSource: ->
      @set('displaySource', false)
      @sendAction('saveSource', @get('term'))

`export default ShowSourceComponent`
