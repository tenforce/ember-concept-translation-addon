`import Ember from 'ember'`
`import TranslationsUtils from '../mixins/translations-utils'`

SuggestionsManagerMixin = Ember.Mixin.create TranslationsUtils,
  showSuggestions: false
  actions:
    toggleSuggestions : ->
      @toggleProperty('showSuggestions')
      unless @get('showSuggestions')
        Ember.run.next =>
          @$('.tabbable')[0]?.focus()
    closeSuggestions: ->
      @set('showSuggestions', false)
      Ember.run.next =>
        @$('.tabbable')[0]?.focus()
    selectSuggestion: (term, translation) ->
      buffer = term.get('literalForm')
      unless buffer is null or buffer is "" then buffer += " "
      buffer += translation
      event =
        target:
          value: buffer
      @changeTermValue(term, event, true)

`export default SuggestionsManagerMixin`
