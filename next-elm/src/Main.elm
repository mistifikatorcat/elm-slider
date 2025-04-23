module Main exposing (main)

import Browser
import Components.Slider exposing (Model, Msg, update, view)
import Config.Products exposing (Flags, flagsDecoder)
import Platform.Cmd as Cmd
import Platform.Sub as Sub


main =
    Browser.element
        { init = \flags ->
            ( { slides = flags, currentIndex = 0 }
            , Cmd.none
            )

        , update = \msg model ->
            ( update msg model, Cmd.none )

        , view = view

        , subscriptions = \_ ->
            Sub.none

        }
