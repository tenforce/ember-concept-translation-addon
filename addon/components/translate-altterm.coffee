`import Ember from 'ember'`
`import layout from '../templates/components/translate-altterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`
`import TermManager from '../mixins/term-manager'`

TranslateAlttermComponent =  Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager, TermManager,
  layout: layout
  keyboardShortcuts:
    'ctrl+alt+d':
      action: 'deleteTerm'
      scoped: true
    'ctrl+alt+o':
      action: 'toggleSource'
      scoped: true
      preventDefault: true

  languageObserver: Ember.observer 'targetLanguage',  (->
    unless @get('term.id')
      event=
        target:
          value: ''
      @changeTermValue(@get('term'), event, false)
    ).on('init')

  actions:
    altTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @changeTermValue(term, event, true)
        @sendAction('saveAltTerm', term)
      else
        @changeTermValue(term, event, false)
    removeAltTerm: (term, index) ->
      @sendAction('removeAltTerm', term, index)
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
        @sendAction('removeAltTerm', term, @get('index'))

`export default TranslateAlttermComponent`
