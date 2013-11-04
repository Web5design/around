# The main app view, loaded when the app is started. Not much happens here,
# it just loads up other views after it loads app.html.ejs into the <body>.
define ['zepto', 'underscore', 'backbone', 'brick', 'cs!collections/users', 'tpl!templates/app.html.ejs'], ($, _, Backbone, xtag, Users, AppTemplate) ->
  'use strict'

  AppView = Backbone.View.extend
    currentView: null
    el: 'body'
    $el: $('body')
    template: AppTemplate

    events:
      'click #back': 'goBack'

    # Initialize the app. First thing we do is check to see if there's a "self"
    # user already present (there should only ever be one). If there is, we'll
    # load up the default first-load view; otherwise we'll show a login screen
    # so they can authorize their account and we can get their OAuth access
    # token.
    initialize: ->
      _(this).bindAll '_checkForSelfUser'

      # First thing we do: render the app.
      @render()

    render: ->
      $(@$el).html(@template)

      @_checkForSelfUser()

    # Go back one step in the app. For now, we simply use our router to control
    # all state and thus just go back in history. Cheeky!
    goBack: ->
      $('body').removeClass 'check-in'
      window.history.back()

    # Check to see if there's a User with "self" status. This means we have
    # authorization and are signed in. If not, we'll show an intro/login
    # screen so the user can sign in with Foursquare.
    _checkForSelfUser: ->
      # If we've already checked and @selfUser exists, skip the checks.
      # HACK: Also skip the check if we're in the sign in process. This
      # prevents the "please sign in screen" from appearing during sign-in.
      return if @selfUser or window.location.hash.match 'access_token='

      self = this

      Users.fetch
        success: (users) ->
          self.selfUser = Users.getSelf()

          # If there's no "selfUser", we need to display an intro screen/login
          # prompt and authorize the user's device.
          if not self.selfUser
            console.info "No user with relationship: RELATIONSHIP_SELF found"
            # We manually set the location.hash here because the router hasn't
            # actually finished loading yet (and thus isn't assigned to
            # `window.router`, where we'd usually access its `.navigate`
            # method).
            window.location.hash = "login"
        error: ->
          # TODO: Obviously, make this better.
          window.alert "Error loading data. Contact support: tofumatt@mozilla.com"
