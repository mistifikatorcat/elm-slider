module Components.Slider exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Config.Products exposing (Product, Flags)
import Components.Slide as Slide exposing (SlideMsg)
import List exposing (drop, head, indexedMap, length, map, maximum, take)
import Maybe exposing (withDefault)
import Platform.Cmd as Cmd


-- MODEL

type alias Model =
    { slides         : List Product
    , currentIndex   : Int
    , innerStates    : List Bool
    , selectedColors : List Int
    }


init : Flags -> ( Model, Cmd.Cmd Msg )
init flags =
    let
        n =
            List.length flags
    in
    ( { slides         = flags
      , currentIndex   = 0
      , innerStates    = List.repeat n False
      , selectedColors = List.repeat n 0
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
        total        = List.length model.slides
        visibleCount = 3

        clampPrev =
            max 0 (model.currentIndex - 1)

        clampNext =
            min (total - visibleCount) (model.currentIndex + 1)

        toggleAt idx =
            List.indexedMap (\i b -> if i == idx then not b else b) model.innerStates

        selectAt idx choice =
            List.indexedMap (\i c -> if i == idx then choice else c) model.selectedColors
    in
    case msg of
        Prev ->
            { model | currentIndex = clampPrev }

        Next ->
            { model | currentIndex = clampNext }

        SlideMsgAt idx slideMsg ->
            case slideMsg of
                Slide.ToggleInner ->
                    { model | innerStates = toggleAt idx }

                Slide.SelectColor choice ->
                    { model | selectedColors = selectAt idx choice }


-- VIEW

view : Model -> Html Msg
view model =
    let
        total        = List.length model.slides
        visibleCount = 3

        maxSwatches : Int
        maxSwatches =
            model.slides
                |> map .colors
                |> map length
                |> maximum
                |> withDefault 0

        canPrev =
            model.currentIndex > 0

        canNext =
            model.currentIndex + visibleCount < total

        visible =
            List.take visibleCount (List.drop model.currentIndex model.slides)

        slidesWithIdx =
            List.indexedMap (\i p -> ( p, i + model.currentIndex )) visible
    in
    div [ class "slider-container" ]
        (  (if canPrev then
                [ button [ onClick Prev, class "nav-button prev" ] [ text "<" ] ]
            else
                []
           )
        ++ [ div [ class "slides-wrapper" ]
                (List.map
                    (\( product, idx ) ->
                        let
                            isInner =
                                head (drop idx model.innerStates)
                                    |> withDefault False

                            selectedIdx =
                                head (drop idx model.selectedColors)
                                    |> withDefault 0
                        in
                        Html.map (SlideMsgAt idx)
                            (Slide.view isInner selectedIdx maxSwatches idx product)
                    )
                    slidesWithIdx
                )
           ]
        ++ (if canNext then
                [ button [ onClick Next, class "nav-button next" ] [ text ">" ] ]
            else
                []
           )
        )
