module Main exposing (main)

import Browser
import Components.Slider exposing (Model, Msg, init, update, view)
import Config.Products exposing (Flags, flagsDecoder)
import Platform.Cmd as Cmd
import Platform.Sub as Sub


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = \msg model ->
            ( update msg model, Cmd.none )
        , view = view
        , subscriptions = \_ ->
            Sub.none
        }
