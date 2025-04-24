module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import List exposing (drop, head)
import Maybe exposing (withDefault)
import Config.Products exposing (Product)


-- SLIDE‐SPECIFIC MESSAGES

type SlideMsg
    = SelectColor Int
    | ToggleInner


{-|
    view isInner selectedIdx maxSwatches slideIndex product

    - isInner     : Bool, whether to show innerUrl (True) or outerUrl (False)
    - selectedIdx : Int, which color swatch is currently selected
    - maxSwatches : Int, the maximum number of swatches across all slides
    - slideIndex  : Int, this slide’s index (used for Html.map)
    - product     : Product record
-}
view : Bool -> Int -> Int -> Int -> Product -> Html SlideMsg
view isInner selectedIdx maxSwatches _ product =
    let
        -- unwrap the Maybe String for set‐products
        setUrl : String
        setUrl =
            withDefault "" product.setImageUrl

        -- pick the selected color record
        maybeColor =
            head (drop selectedIdx product.colors)

        -- build the single <img> element
        imageElement : Html SlideMsg
        imageElement =
            if product.isSet then
                if setUrl /= "" then
                    img [ src setUrl, class "slide-image" ] []
                else
                    text "No image!"
            else
                case maybeColor of
                    Just c ->
                        let
                            urlToShow =
                                if isInner then
                                    c.innerUrl
                                else
                                    c.outerUrl
                        in
                        img [ src urlToShow, class "slide-image" ] []

                    Nothing ->
                        text "No image!"

        -- real swatch circles
        swatchElems : List (Html SlideMsg)
        swatchElems =
            List.indexedMap
                (\i c ->
                    span
                        [ class ("swatch" ++ if i == selectedIdx then " selected" else "")
                        , onClick (SelectColor i)
                        , Html.Attributes.title c.name
                        , Html.Attributes.style "background-color" c.name
                        ]
                        []
                )
                product.colors

        -- how many placeholders we need
        placeholderCount : Int
        placeholderCount =
            maxSwatches - List.length product.colors

        placeholderSpans : List (Html SlideMsg)
        placeholderSpans =
            List.repeat placeholderCount
                ( span [ class "swatch placeholder" ] [] )
    in
    div [ class "slide" ]
        [ -- IMAGE + hover‐toggle button
          div [ class "slide-image-wrapper" ]
            [ imageElement
            , button [ onClick ToggleInner, class "slide-toggle" ] [ text "⟳" ]
            ]

          -- CONTENT BELOW THE IMAGE
        , div [ class "slide-content" ]
            (  -- badges row
               (if product.isNew then
                    [ span [ class "badge" ] [ text "New" ] ]
                else
                    [ span [ class "badge placeholder" ] [] ]
               )
             ++ (if product.isSet then
                    [ span [ class "badge" ] [ text "Set" ] ]
                else
                    [ span [ class "badge placeholder" ] [] ]
                )

             -- title & price
             ++ [ div [ class "slide-title" ] [ text product.title ]
                , div [ class "slide-price" ] [ text ("$" ++ String.fromFloat product.price) ]
                ]

             -- swatches row: real + placeholders
             ++ [ div [ class "color-swatches" ]
                    (swatchElems ++ placeholderSpans)
                ]

             -- description (pinned to bottom via CSS)
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
