`import Ember from 'ember'`
`import layout from '../templates/components/show-suggestions'`

ShowSuggestionsComponent = Ember.Component.extend
  layout: layout
  tagName: ''
  showSuggestions: false
  sButtonId: Ember.computed 'buttonId', ->
    if @get('buttonId') then return "#"+@get('buttonId')
  loaded: Ember.computed 'buttonId', ->
    if @get('buttonId') then return true
    else return false

  emptySources: Ember.computed 'sources', ->
    if @get('sources')?.length is 0 then return true
    else return false

  dataChanged: Ember.observer('term', 'label', 'sourceLanguage', 'targetLanguage', ->
    label = @get 'label'
    source = @get 'sourceLanguage'
    target = @get 'targetLanguage'
    if label and source and target
      @getSources(label, source, target)
  ).on('init')

  loading: true
  isLoading: Ember.computed 'loading', ->
    return @get('loading')
  getSources: (label, source, target) ->
    @set 'loading', true
    promise = Ember.$.ajax "/translate?term=#{label}&source_language=#{source}&target_languages=#{target}",
      headers:
        'Accept': 'application/json'
        'type':'GET'

    promise.then (result) =>
      unless @get('isDestroyed')
        if result?.data
          @set 'sources', result.data
        else @set 'sources', []
        @set 'loading', 'false'
  actions:
    closeSuggestions: ->
      if @get('shouldSendAction')
        @sendAction('closeSuggestions')
      else
        @set('showSuggestions', false)
    toggleSuggestion: ->
      if @get 'disabled'
        return false
      if @get('shouldSendAction')
        @sendAction('toggleSuggestions')
      else
        @toggleProperty('showSuggestions')
    selectSuggestion: (translation) ->
      if @get 'disabled'
        return false
      unless @get('disabled')
        @sendAction('selectSuggestion', @get('term'), translation)

`export default ShowSuggestionsComponent`
