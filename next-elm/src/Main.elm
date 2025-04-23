module Main exposing (main)

import Browser
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL

type alias Slide =
    { title : String
    , imageUrl : String
    }

type alias Model =
    { slides : List Slide
    , currentIndex : Int
    }

init : Model
init =
    { slides =
        [ { title = "Slide 1", imageUrl = "https://i.imgur.com/41zS5qq.jpeg" }
        , { title = "Slide 2", imageUrl = "https://i.imgur.com/5WqZcFu.jpeg" }
        , { title = "Slide 3", imageUrl = "https://i.imgur.com/KOCOkNn.jpeg" }
        , { title = "Slide 4", imageUrl = "https://i.imgur.com/xzh4FCe.jpeg" }
        ]
    , currentIndex = 0
    }


-- UPDATE

type Msg
    = Prev
    | Next

update : Msg -> Model -> Model
update msg model =
    let
        count =
            List.length model.slides

        newIndex =
            case msg of
                Prev ->
                    if model.currentIndex == 0 then
                        count - 1
                    else
                        model.currentIndex - 1

                Next ->
                    if model.currentIndex == count - 1 then
                        0
                    else
                        model.currentIndex + 1
    in
    { model | currentIndex = newIndex }


-- VIEW

view : Model -> Html Msg
view model =
    let
        currentSlide =
            List.drop model.currentIndex model.slides
                |> List.head
    in
    div [ class "slider-container" ]
        [ button [ onClick Prev, class "nav-button" ] [ text "<" ]
        , case currentSlide of
            Just slide ->
                div [ class "slide" ]
                    [ img [ class "slide-image", Html.Attributes.src slide.imageUrl ] []
                    , div [ class "slide-title" ] [ text slide.title ]
                    ]

            Nothing ->
                text "No slides!"
        , button [ onClick Next, class "nav-button" ] [ text ">" ]
        ]


-- MAIN

main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }
