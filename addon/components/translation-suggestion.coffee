`import Ember from 'ember'`
`import layout from '../templates/components/translation-suggestion'`

TranslationSuggestionComponent = Ember.Component.extend
  layout: layout
  classNames:['translation-suggestion']
  collapsed: true
  actions:
    selectSuggestion: (translation) ->
      @sendAction('selectSuggestion', translation)
    toggleCollapsed:  ->
      @toggleProperty("collapsed")
      if @get 'collapsed' then @set 'collapsedPlaceholder', '[+]'
      else @set 'collapsedPlaceholder', '[-]'


`export default TranslationSuggestionComponent`
