module Components.Slider exposing (Model, Msg(..), init, update, view, subscriptions)

import Browser.Events exposing (onResize)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Config.Products exposing (Flags, Product)
import Components.Slide as Slide exposing (SlideMsg)
import List exposing (drop, head, indexedMap, length, map, maximum, take)
import Maybe exposing (withDefault)
import Platform.Cmd as Cmd
import Platform.Sub as Sub


-- MODEL

type alias Model =
    { slides         : List Product
    , currentIndex   : Int
    , innerStates    : List Bool
    , selectedColors : List Int
    , viewportWidth  : Float
    }


init : Flags -> ( Model, Cmd.Cmd Msg )
init flags =
    let n = List.length flags in
    ( { slides         = flags
      , currentIndex   = 0
      , innerStates    = List.repeat n False
      , selectedColors = List.repeat n 0
      , viewportWidth  = 0
      }
    , Cmd.none
    )


-- MESSAGES

type Msg
    = Prev
    | Next
    | SlideMsgAt Int SlideMsg
    | WindowResized { width : Float, height : Float }


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    onResize (\w h -> WindowResized { width = toFloat w, height = toFloat h })


-- UPDATE

update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case msg of
        WindowResized vp ->
            ( { model | viewportWidth = vp.width }, Cmd.none )

        Prev ->
            let
                vc        = visibleCount model.viewportWidth
                clampPrev = max 0 (model.currentIndex - 1)
            in
            ( { model | currentIndex = clampPrev }, Cmd.none )

        Next ->
            let
                total  = List.length model.slides
                vc     = visibleCount model.viewportWidth
                clampN = min (total - vc) (model.currentIndex + 1)
            in
            ( { model | currentIndex = clampN }, Cmd.none )

        SlideMsgAt idx slideMsg ->
            case slideMsg of
                Slide.ToggleInner ->
                    ( { model
                        | innerStates =
                            List.indexedMap (\i b -> if i == idx then not b else b) model.innerStates
                      }
                    , Cmd.none
                    )

                Slide.SelectColor choice ->
                    ( { model
                        | selectedColors =
                            List.indexedMap (\i c -> if i == idx then choice else c) model.selectedColors
                      }
                    , Cmd.none
                    )


-- VIEW

view : Model -> Html Msg
view model =
    let
        total       = List.length model.slides
        vc          = visibleCount model.viewportWidth

        canPrev     = model.currentIndex > 0
        canNext     = model.currentIndex + vc < total

        maxSwatches =
            model.slides
                |> map .colors
                |> map List.length
                |> maximum
                |> withDefault 0

        visibleSlides =
            take vc (drop model.currentIndex model.slides)

        slidesWithIdx =
            indexedMap (\i p -> ( p, i + model.currentIndex )) visibleSlides
    in
    div [ class "slider-container" ]
        [ -- Left arrow
          button
            [ onClick Prev
            , classList [ ( "nav-button", True ), ( "prev", True ), ( "hidden", not canPrev ) ]
            ]
            [ text "<" ]

          -- The slide track
        , div [ class "slides-wrapper" ]
            (slidesWithIdx
                |> List.map
                    (\( product, idx ) ->
                        let
                            isInner  =
                                head (drop idx model.innerStates) |> withDefault False

                            selIdx   =
                                head (drop idx model.selectedColors) |> withDefault 0
                        in
                        Html.map (SlideMsgAt idx)
                            (Slide.view isInner selIdx maxSwatches idx product)
                    )
            )

          -- Right arrow
        , button
            [ onClick Next
            , classList [ ( "nav-button", True ), ( "next", True ), ( "hidden", not canNext ) ]
            ]
            [ text ">" ]
        ]


-- HELPER

visibleCount : Float -> Int
visibleCount w =
    if w <= 600 then
        1
    else if w <= 900 then
        2
    else
        3
