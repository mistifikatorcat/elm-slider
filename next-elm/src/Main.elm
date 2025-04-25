module Main exposing (main)

import Browser
import Components.Slider exposing (Model, Msg, init, update, view, subscriptions)
import Config.Products exposing (Flags, flagsDecoder)


main : Program Flags Model Msg
main =
    Browser.element
        { init          = init
        , update        = update
        , view          = view
        , subscriptions = subscriptions
        } 
