# Shared State Demo, Version II

This app is derived Ohanhi's [Shared State Demo](https://github.com/ohanhi/elm-shared-state).  In this example, when the user signs in sign in, his successful sign-in informatiom, e.g. a sesssion token, is stored the parent, shared state, and so is resistant to tamperign.

The app's functionality is deliberately restricted, so that it can, if desired, sere as a templaste for others.  I do plan to put registration functions in the sign-in page, but that is about it.

## Theory

Please consult Ohahnhi's README to understand the logic behind the shared state architecture.  The main point of Ohanhi's setup is to use an augmented `update` function with the type signature:

```
update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )

```

This function can be used in a child page, and the `SharedStateUpdate` constructor can be used to update the share state, "the parent," from the child.

## The App

There are two pages in the app, **Home** and **Sign in Page**.  In the sign-in page one can either sign in to or register for the site presented by the back  end.  I've left the backend that I've used for testing for the moment: [Booklib.io](https://booklib.io), a site for keeping track of the books you read — taking notes, sharing your reading list with others, etc.

Putting that aside, the main point is that if you sign in or register on the **Sign in Page**, then the user information returned by the server, including a token to authenticate a session, is stored in the `SharedState` and so is available to all child pages.  You will see this if you sign in: your username will also be displayed in the home page.

I've deliberatey keep the app as limited in features as possible so that  it will be useful as a starting point for others.  If you use it,
please point the backend url, which is stored in the module `Configuration`, to another server.  You will likely need to modify the code in the `User.Session` module as well.


I'll polish this demo up a bit but want to keep it simple.  Otherwise it is not a template.

And three cheers to Ohanhi for this great design!


## Installation

For now: `elm make src/Main.elm --output=Main.js`.  Then start `elm reactor` and click on `index.html`
