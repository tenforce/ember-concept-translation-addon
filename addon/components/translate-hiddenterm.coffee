`import Ember from 'ember'`
`import layout from '../templates/components/translate-hiddenterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`

TranslateHiddentermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager,
  layout: layout
  keyboardShortcuts:
    'ctrl+alt+d':
      action: 'deleteTerm'
      scoped: true
    'ctrl+alt+o':
      action: 'toggleSource'
      scoped: true
      preventDefault: true
  placeholder: 'Enter the hidden term and press ENTER'
  actions:
    hiddenTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @changeTermValue(term, event, true)
        @sendAction('saveHiddenTerm', term)
      else
        @changeTermValue(term, event, false)
    removeHiddenTerm: (term, index) ->
       @sendAction('removeHiddenTerm', term, index)
    deleteTerm: ->
      term = @get('term')
      if term.get('literalForm')
        event=
          target:
            value: ''
        @changeTermValue(term, event, false)
        term.set('source', '')
        term.save()
      else
        @sendAction('removeHiddenTerm', term, @get('index'))


`export default TranslateHiddentermComponent`
