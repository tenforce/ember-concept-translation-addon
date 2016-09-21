`import Ember from 'ember'`

TermManagerMixin = Ember.Mixin.create
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
        t.setGender(role, false).then ->
          t.save()
    prefTerm = @get('prefTerm')
    if prefTerm.get("id") and prefTerm.hasRole(role.get('preflabel'))
      prefTerm.setGender(role, false).then ->
        prefTerm.save()

  setAsPreferred: (term, save, gender, preferred) ->
    return unless term
    promises = []
    unless preferred then g = @get('roles').findBy('preflabel', gender)
    sg = @get('roles').findBy('preflabel', "standard #{gender} term")
    @removeRoleFromTerms(sg)
    unless preferred then promises.push(term.setGender(g, true))
    promises.push(term.setGender(sg, true))
    Ember.RSVP.Promise.all(promises).then ->
      if save then term.save()
  setGender: (term, save, gender) ->
    return unless term
    g = @get('roles').findBy('preflabel', gender)
    term.setGender(g, true).then =>
      if save then term.save()
  toggleGender: (term, label) ->
    role = @get('roles').findBy('preflabel', label)
    term.toggleGender(role)
    term.save() if term.get('id')
  # only one term can be preferred male/female
  # this removes the role from all terms and add's it to the selected one
  togglePreferred: (term, label) ->
    return unless term.get("id")
    role = @get('roles').findBy('preflabel', label)
    if term.hasRole(label)
      term.setGender(role, false).then ->
        term.save()
    else
      @removeRoleFromTerms(role)
      if term.get("id")
        term.setGender(role, true).then ->
          term.save()
  actions:
    toggleFemale: (term) ->
      unless term.hasRole('standard female term')
        @toggleGender(term, 'female')
    toggleMale: (term) ->
      unless term.hasRole('standard male term')
        @toggleGender(term, 'male')
    toggleNeutral: (term) ->
      @toggleGender(term, 'neutral')
    toggleStandardMale: (term) ->
      unless term.hasRole('male')
        @toggleGender(term, 'male')
      @togglePreferred(term, 'standard male term')
    toggleStandardFemale: (term) ->
      unless term.hasRole('female')
        @toggleGender(term, 'female')
      @togglePreferred(term, 'standard female term')
    togglePreferredMale: (term) ->
      @togglePreferred(term, 'standard male term')
    togglePreferredFemale: (term) ->
      @togglePreferred(term, 'standard female term')

`export default TermManagerMixin`
