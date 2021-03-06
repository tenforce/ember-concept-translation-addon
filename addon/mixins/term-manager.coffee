`import Ember from 'ember'`

TermManagerMixin = Ember.Mixin.create

  loadingRoles: true
  checkLoadingRoles: Ember.observer('concept.id', ->
    @set 'loadingRoles', true
    if @get('term')
      @get('term.roles').then =>
        @set 'loadingRoles', false
  ).on('init')

  newLabel: ->
    label = @get('store').createRecord('conceptLabel', literalFormValues: [])
    label.get('literalFormValues').pushObject(Ember.Object.create({content: "", language: @get('language')}))
    label.set('literalForm', "")
    label.set('literalFormValues.firstObject.content', "")
    label
  generateAltTerm: () ->
    term = @newLabel()
    term.set('altLabelOf', [@get('concept')])
    term
  generateHiddenTerm: () ->
    term = @newLabel()
    term.set('hiddenLabelOf', [@get('concept')])
    term
  removeRoleFromTerms: (role) ->
    @get('altTerms').forEach (t) ->
      if t.get('id') and t.hasRole(role.get('preflabel'))
        t.setRole(role, false).then ->
          t.save()
    @get('prefTerms').forEach (t) ->
      if t.get('id') and t.hasRole(role.get('preflabel'))
        t.setRole(role, false).then ->
          t.save()

  setAsPreferred: (term, save, gender, preferred) ->
    return unless term
    promises = []
    unless preferred then g = @get('roles').findBy('preflabel', gender)
    sg = @get('roles').findBy('preflabel', "standard #{gender} term")
    @removeRoleFromTerms(sg)
    unless preferred then promises.push(term.setRole(g, true))
    promises.push(term.setRole(sg, true))
    Ember.RSVP.Promise.all(promises).then ->
      if save then term.save()
  setRole: (term, save, gender) ->
    return unless term
    g = @get('roles').findBy('preflabel', gender)
    term.setRole(g, true).then =>
      if save then term.save()
  toggleRole: (term, label) ->
    role = @get('roles').findBy('preflabel', label)
    term.toggleRole(role)
    term.save() if term.get('id')
  # only one term can be preferred male/female
  # this removes the role from all terms and add's it to the selected one
  togglePreferred: (term, label) ->
    return unless term.get("id")
    role = @get('roles').findBy('preflabel', label)
    if term.hasGender(label)
      term.setRole(role, false).then ->
        term.save()
    else
      @removeRoleFromTerms(role)
      if term.get("id")
        term.setRole(role, true).then ->
          term.save()
  actions:
    toggleFemale: (term) ->
      unless term.hasGender('standard female term')
        @toggleRole(term, 'female')
    toggleMale: (term) ->
      unless term.hasGender('standard male term')
        @toggleRole(term, 'male')
      else
    toggleNeutral: (term) ->
      @toggleRole(term, 'neutral')
    toggleStandardMale: (term) ->
      unless term.hasGender('male')
        @toggleRole(term, 'male')
      @togglePreferred(term, 'standard male term')
    toggleStandardFemale: (term) ->
      unless term.hasGender('female')
        @toggleRole(term, 'female')
      @togglePreferred(term, 'standard female term')
    togglePreferredMale: (term) ->
      @togglePreferred(term, 'standard male term')
    togglePreferredFemale: (term) ->
      @togglePreferred(term, 'standard female term')

`export default TermManagerMixin`
