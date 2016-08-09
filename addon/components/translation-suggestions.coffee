`import Ember from 'ember'`
`import layout from '../templates/components/translation-suggestions'`

TranslationSuggestionsComponent = Ember.Component.extend
  layout: layout
  classNames:['translation-suggestions']
  actions:
    selectSuggestion: (translation) ->
      @sendAction('selectSuggestion', translation)

`export default TranslationSuggestionsComponent`
