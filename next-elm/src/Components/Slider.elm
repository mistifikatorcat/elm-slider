module Components.Slider exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Config.Products exposing (Product, Flags)
import Components.Slide as Slide exposing (SlideMsg)
import List exposing (drop, head, indexedMap, length, map2, range)
import Maybe exposing (withDefault)


-- MODEL

type alias Model =
    { slides       : List Product
    , currentIndex : Int
    , innerStates  : List Bool
    }

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { slides       = flags
      , currentIndex = 0
      , innerStates  = List.repeat (List.length flags) False
      }
    , Cmd.none
    )


-- MESSAGES

type Msg
    = Prev
    | Next
    | SlideMsgAt Int SlideMsg


-- UPDATE

update : Msg -> Model -> Model
update msg model =
    let
        wrap idx =
            if idx < 0 then
                List.length model.slides - 1
            else if idx >= List.length model.slides then
                0
            else
                idx

        toggleAt idx =
            indexedMap (\i b -> if i == idx then not b else b) model.innerStates
    in
    case msg of
        Prev ->
            { model | currentIndex = wrap (model.currentIndex - 1) }

        Next ->
            { model | currentIndex = wrap (model.currentIndex + 1) }

        SlideMsgAt idx slideMsg ->
            case slideMsg of
                Slide.ToggleInner ->
                    { model | innerStates = toggleAt idx }

                Slide.SelectColor _ ->
                    -- you can handle color selection here if desired
                    model


-- VIEW

view : Model -> Html Msg
view model =
    let
        visibleSlides =
            drop model.currentIndex model.slides

        indices =
            range 0 (List.length visibleSlides - 1)

        slidesWithIdx =
            map2 (\product idx -> ( product, idx )) visibleSlides indices
    in
    div [ class "slider-container" ]
        [ button [ onClick Prev, class "nav-button" ] [ text "<" ]
        , div [ class "slides-wrapper" ]
            (List.map
                (\( product, idx ) ->
                    let
                        isInner =
                            head (List.drop idx model.innerStates)
                                |> withDefault False
                    in
                    Html.map (SlideMsgAt idx)
                        (Slide.view isInner idx product)
                )
                slidesWithIdx
            )
        , button [ onClick Next, class "nav-button" ] [ text ">" ]
        ]
