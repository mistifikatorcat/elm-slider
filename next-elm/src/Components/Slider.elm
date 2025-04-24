module Components.Slider exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Config.Products exposing (Product, Flags)
import Components.Slide as Slide exposing (SlideMsg)
import List exposing (drop, head, length, take, indexedMap)
import Maybe exposing (withDefault)
import Platform.Cmd as Cmd


-- MODEL

type alias Model =
    { slides       : List Product
    , currentIndex : Int
    , innerStates  : List Bool
    }

init : Flags -> ( Model, Cmd.Cmd Msg )
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
        total = List.length model.slides
        visibleCount = 3
        clampPrev = max 0 (model.currentIndex - 1)
        clampNext = min (total - visibleCount) (model.currentIndex + 1)
        toggleAt idx =
            List.indexedMap
                (\i b -> if i == idx then not b else b)
                model.innerStates
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

                Slide.SelectColor _ ->
                    model


-- VIEW

view : Model -> Html Msg
view model =
    let
        total = List.length model.slides
        visibleCount = 3
        canPrev = model.currentIndex > 0
        canNext = model.currentIndex + visibleCount < total
        visible = List.take visibleCount (List.drop model.currentIndex model.slides)
        slidesWithIdx =
            List.indexedMap
                (\i p -> ( p, i + model.currentIndex ))
                visible
    in
    div [ class "slider-container" ]
        ((if canPrev then
              [ button [ onClick Prev, class "nav-button prev" ] [ text "<" ] ]
          else
              []
         )
         ++ [ div [ class "slides-wrapper" ]
                (List.map
                    (\(product, idx) ->
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
            ]
         ++ (if canNext then
                [ button [ onClick Next, class "nav-button next" ] [ text ">" ] ]
             else
                []
            )
        )
