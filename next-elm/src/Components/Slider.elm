module Components.Slider exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Config.Products exposing (Product)
import Components.Slide as Slide exposing (SlideMsg, view)

import List exposing (drop, filterMap, head, length, map2)


-- MODEL

type alias Model =
    { slides       : List Product
    , currentIndex : Int
    }

init : Model
init =
    { slides       = []
    , currentIndex = 0
    }


-- UPDATE

type Msg
    = Prev
    | Next
    | SlideMsgAt Int SlideMsg


update : Msg -> Model -> Model
update msg model =
    let
        count =
            length model.slides

        wrap idx =
            if idx < 0 then
                count - 1
            else if idx >= count then
                0
            else
                idx
    in
    case msg of
        Prev ->
            { model | currentIndex = wrap (model.currentIndex - 1) }

        Next ->
            { model | currentIndex = wrap (model.currentIndex + 1) }

        SlideMsgAt _ _ ->
            -- TODO: handle per‐slide interaction (e.g. color changes)
            model


-- VIEW

view : Model -> Html Msg
view model =
    let
        count =
            length model.slides

        wrap idx =
            if idx < 0 then
                count - 1
            else if idx >= count then
                0
            else
                idx

        -- pick the three slide indices
        indices =
            [ wrap (model.currentIndex - 1)
            , model.currentIndex
            , wrap (model.currentIndex + 1)
            ]

        -- pull those products out
        visibleSlides =
            filterMap (\i -> head (drop i model.slides)) indices

        -- pair each product with its original index
        slidesWithIdx =
            map2 (\product idx -> ( product, idx )) visibleSlides indices
    in
    div [ class "slider-container" ]
        [ button [ onClick Prev, class "nav-button" ] [ text "<" ]
        , div [ class "slides-wrapper" ]
            (List.map
                (\( product, idx ) ->
                    Html.map (SlideMsgAt idx) (Slide.view idx product)

                )
                slidesWithIdx
            )
        , button [ onClick Next, class "nav-button" ] [ text ">" ]
        ]
