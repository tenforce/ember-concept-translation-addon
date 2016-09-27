`import Ember from 'ember'`
`import layout from '../templates/components/translation-source'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`

TranslationSourceComponent = Ember.Component.extend KeyboardShortcuts,
  layout: layout
  classNames: ['input source']
  keyboardShortcuts: Ember.computed 'disableShortcuts', ->
    if @get('disableShortcuts') then return {}
    else
      {
        'ctrl+alt+d':
          action: 'deleteSource'
          scoped: true
        'ctrl+alt+o':
          action: 'closeSource'
          scoped: true
          preventDefault: true
      }

  didRender: ->
    Ember.run.next =>
      @$()?.children()[0]?.focus()
  actions:
    deleteSource: ->
      @set('source', '')
    closeSource: ->
      @sendAction('closeSource')
      false
    sourceContentModified: (source, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @set('source', event.target.value.trim())
        @sendAction('closeSource')
      else
        @set('source', event.target.value)
      false

`export default TranslationSourceComponent`
